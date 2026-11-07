import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:town_pass/util/web_message_handler/tp_web_message_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// 室內定位用：單次 WiFi 掃描。
///
/// 回傳 `{supported, status, scan_started, collected_at, results: [{bssid, ssid, level, frequency, timestamp}]}`。
/// iOS 沒有公開的 WiFi 掃描 API，固定回傳 `supported: false`；
/// Android 9 以上前景掃描限制約每 2 分鐘 4 次，被限制時 `scan_started` 為 false 並回傳系統快取結果。
class WifiScanMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'wifi_scan';

  @override
  Future<void> handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    final CanGetScannedResults canGetResults = await _canGetWifiResults();
    if (canGetResults != CanGetScannedResults.yes) {
      onReply?.call(replyWebMessage(data: _wifiData(status: canGetResults.name, scanStarted: false)));
      return;
    }

    List<WiFiAccessPoint>? results;
    bool scanStarted = false;
    if (await WiFiScan.instance.canStartScan(askPermissions: false) == CanStartScan.yes) {
      // 訂閱時 plugin 會先送出目前的快取結果，需等到比快取更新的結果才算本次掃描完成
      final int cachedNewest = _newestTimestamp(await WiFiScan.instance.getScannedResults());
      // 先訂閱再開始掃描，避免錯過掃描完成事件
      final Future<List<WiFiAccessPoint>> freshResults = WiFiScan.instance.onScannedResultsAvailable
          .firstWhere((results) => _newestTimestamp(results) > cachedNewest)
          .timeout(const Duration(seconds: 10));
      scanStarted = await WiFiScan.instance.startScan();
      if (scanStarted) {
        try {
          results = await freshResults;
        } on TimeoutException {
          // 掃描逾時，改用系統快取結果
        }
      } else {
        freshResults.ignore();
      }
    }
    results ??= await WiFiScan.instance.getScannedResults();

    onReply?.call(replyWebMessage(
      data: _wifiData(status: canGetResults.name, scanStarted: scanStarted, results: results),
    ));
  }
}

/// 室內定位用：持續推送 WiFi 掃描結果。
///
/// 網頁傳入 `{action: 'start', interval_ms: 30000}`，每次有掃描結果（包含系統或其他 App 觸發的掃描）
/// 都會推送與 `wifi_scan` 相同格式的資料（不含 `scan_started`，重複的結果不重送）；並每 `interval_ms` 嘗試主動掃描一次。
class WifiScanStreamMessageHandler extends TPWebMessageStreamHandler {
  @override
  String get name => 'wifi_scan_stream';

  @override
  Future<Future<void> Function()> start({
    required Map config,
    required void Function(Object? data) onData,
  }) async {
    final CanGetScannedResults canGetResults = await _canGetWifiResults();
    if (canGetResults != CanGetScannedResults.yes) {
      onData(_wifiData(status: canGetResults.name));
      return () async {};
    }

    // 訂閱時 plugin 會重送快取結果，只推送比上次更新的結果
    int? lastNewest;
    void onResults(List<WiFiAccessPoint> results) {
      final int newest = _newestTimestamp(results);
      if (newest == lastNewest) {
        return;
      }
      lastNewest = newest;
      onData(_wifiData(status: canGetResults.name, results: results));
    }

    final StreamSubscription<List<WiFiAccessPoint>> subscription = WiFiScan.instance.onScannedResultsAvailable.listen(
      onResults,
      onError: (_) {},
    );
    onResults(await WiFiScan.instance.getScannedResults());

    Future<void> startScan() async {
      if (await WiFiScan.instance.canStartScan(askPermissions: false) == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
      }
    }

    final int intervalMs = _intConfig(config['interval_ms'], fallback: 30000, min: 1000);
    final Timer timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) => startScan());
    await startScan();

    return () async {
      timer.cancel();
      await subscription.cancel();
    };
  }
}

/// 室內定位用：持續推送動作感測器資料（PDR、地磁定位、氣壓判斷樓層）。
///
/// 網頁傳入 `{action: 'start', sensors: ['accelerometer', 'gyroscope', 'magnetometer', 'barometer'], interval_ms: 20, batch_ms: 200}`，
/// 每 `batch_ms` 推送一次 `{accelerometer: [[t, x, y, z], ...], barometer: [[t, hPa], ...], unavailable: [...]}`，
/// `t` 為感測器事件時間（epoch 毫秒，含小數），只包含該批有資料的感測器。
class SensorStreamMessageHandler extends TPWebMessageStreamHandler {
  /// iOS 校正後磁力計（見 ios/Runner/AppDelegate.swift），事件為 `[epoch 毫秒, x, y, z, 校正精度]`。
  static const EventChannel _calibratedMagnetometerChannel = EventChannel('town_pass/calibrated_magnetometer');

  static final Map<String, Stream<List<num>> Function(Duration samplingPeriod)> _sensorStreams = {
    'accelerometer': (samplingPeriod) => accelerometerEventStream(samplingPeriod: samplingPeriod)
        .map((event) => [_epochMs(event.timestamp), event.x, event.y, event.z]),
    'user_accelerometer': (samplingPeriod) => userAccelerometerEventStream(samplingPeriod: samplingPeriod)
        .map((event) => [_epochMs(event.timestamp), event.x, event.y, event.z]),
    'gyroscope': (samplingPeriod) => gyroscopeEventStream(samplingPeriod: samplingPeriod)
        .map((event) => [_epochMs(event.timestamp), event.x, event.y, event.z]),
    // sensors_plus 在 iOS 給的是未校正的原始磁力計值，地磁定位需要扣除裝置偏差後的數值
    'magnetometer': (samplingPeriod) => Platform.isIOS
        ? _calibratedMagnetometerChannel
            .receiveBroadcastStream({'interval_us': samplingPeriod.inMicroseconds})
            .map((event) => (event as List).cast<num>().sublist(0, 4))
        : magnetometerEventStream(samplingPeriod: samplingPeriod)
            .map((event) => [_epochMs(event.timestamp), event.x, event.y, event.z]),
    'barometer': (samplingPeriod) => barometerEventStream(samplingPeriod: samplingPeriod)
        .map((event) => [_epochMs(event.timestamp), event.pressure]),
  };

  @override
  String get name => 'sensor_stream';

  @override
  Future<Future<void> Function()> start({
    required Map config,
    required void Function(Object? data) onData,
  }) async {
    final Duration samplingPeriod = Duration(milliseconds: _intConfig(config['interval_ms'], fallback: 20, min: 0));
    final int batchMs = _intConfig(config['batch_ms'], fallback: 200, min: 50);
    final Iterable<String> sensors = switch (config['sensors']) {
      List sensors => sensors.whereType<String>().where(_sensorStreams.containsKey).toSet(),
      _ => _sensorStreams.keys,
    };

    final Map<String, List<List<num>>> buffer = {};
    final Set<String> unavailable = {};
    final List<StreamSubscription<List<num>>> subscriptions = [
      for (final String sensor in sensors)
        _sensorStreams[sensor]!(samplingPeriod).listen(
          (sample) => (buffer[sensor] ??= []).add(sample),
          // 裝置沒有此感測器
          onError: (_) => unavailable.add(sensor),
          cancelOnError: true,
        ),
    ];

    final Timer timer = Timer.periodic(Duration(milliseconds: batchMs), (_) {
      if (buffer.isEmpty && unavailable.isEmpty) {
        return;
      }
      onData({
        ...buffer,
        if (unavailable.isNotEmpty) 'unavailable': unavailable.toList(),
      });
      buffer.clear();
      unavailable.clear();
    });

    return () async {
      timer.cancel();
      for (final StreamSubscription<List<num>> subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  }
}

Future<CanGetScannedResults> _canGetWifiResults() async {
  if (!Platform.isAndroid) {
    return CanGetScannedResults.notSupported;
  }
  return await WiFiScan.instance.canGetScannedResults();
}

/// 同批結果中最新的 `timestamp`，用來判斷是否為新的掃描結果。
int _newestTimestamp(List<WiFiAccessPoint> results) {
  return results.fold(0, (newest, accessPoint) => (accessPoint.timestamp ?? 0) > newest ? accessPoint.timestamp! : newest);
}

/// `scanStarted` 只有單次掃描（`wifi_scan`）有意義，串流不帶此欄位。
Map<String, Object?> _wifiData({
  required String status,
  bool? scanStarted,
  List<WiFiAccessPoint> results = const [],
}) {
  return {
    'supported': Platform.isAndroid,
    'status': status,
    'scan_started': ?scanStarted,
    'collected_at': DateTime.now().millisecondsSinceEpoch,
    'results': [
      for (final WiFiAccessPoint accessPoint in results)
        {
          'bssid': accessPoint.bssid,
          'ssid': accessPoint.ssid,
          'level': accessPoint.level,
          'frequency': accessPoint.frequency,
          // 開機後的微秒數（Android ScanResult.timestamp），與 collected_at 不同時鐘，僅適合比較同批結果的新舊
          'timestamp': accessPoint.timestamp,
        },
    ],
  };
}

double _epochMs(DateTime timestamp) => timestamp.microsecondsSinceEpoch / 1000;

int _intConfig(Object? value, {required int fallback, required int min}) {
  return switch (value) {
    num value => value.toInt() < min ? min : value.toInt(),
    _ => fallback,
  };
}
