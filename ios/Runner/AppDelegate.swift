import UIKit
import Flutter
import CoreMotion
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let calibratedMagnetometerHandler = CalibratedMagnetometerStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle 下，plugin 註冊必須放在這裡，不能放在 didFinishLaunchingWithOptions
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TownPassCalibratedMagnetometer") {
      FlutterEventChannel(name: "town_pass/calibrated_magnetometer", binaryMessenger: registrar.messenger())
        .setStreamHandler(calibratedMagnetometerHandler)
    }
  }
}

/// 室內定位用的 iOS 磁力計：CMDeviceMotion 校正後的磁場（已扣除手機本身的磁偏差）。
/// sensors_plus 在 iOS 用的是 CMMagnetometer 的未校正原始值，會混入數十 µT 以上的裝置偏差，無法做地磁比對。
/// 每筆事件為 `[epoch 毫秒, x, y, z, 校正精度]`，x/y/z 為裝置座標系的 µT（與 Android 校正後磁力計一致）。
final class CalibratedMagnetometerStreamHandler: NSObject, FlutterStreamHandler {
  private let motionManager = CMMotionManager()
  // CMDeviceMotion.timestamp 是開機後的秒數，換算成 epoch
  private let bootTime = Date().timeIntervalSince1970 - ProcessInfo.processInfo.systemUptime

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard motionManager.isDeviceMotionAvailable,
          CMMotionManager.availableAttitudeReferenceFrames().contains(.xArbitraryCorrectedZVertical) else {
      return FlutterError(code: "UNAVAILABLE", message: "Calibrated magnetometer is not available", details: nil)
    }

    let intervalUs = (arguments as? [String: Any])?["interval_us"] as? Int ?? 20000
    motionManager.deviceMotionUpdateInterval = max(Double(intervalUs) / 1_000_000, 0.01)
    // 只有使用磁力計的參考座標系才會提供校正後的 magneticField
    motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main) { [weak self] motion, _ in
      guard let self, let motion else { return }
      let field = motion.magneticField
      // 未校正或低精度時仍混有裝置偏差（實測 |B| 可達 100–180 µT），先不送；手機畫 8 字可加速校正
      if field.accuracy == .uncalibrated || field.accuracy == .low { return }
      events([
        (self.bootTime + motion.timestamp) * 1000,
        field.field.x, field.field.y, field.field.z,
        Int(field.accuracy.rawValue),
      ])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopDeviceMotionUpdates()
    return nil
  }
}
