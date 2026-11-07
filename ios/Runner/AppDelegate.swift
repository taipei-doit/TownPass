import UIKit
import Flutter
import CoreMotion
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let deviceMotionHandler = DeviceMotionStreamHandler()

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

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TownPassDeviceMotion") {
      FlutterEventChannel(name: "town_pass/device_motion", binaryMessenger: registrar.messenger())
        .setStreamHandler(deviceMotionHandler)
    }
  }
}

/// 室內定位用的 iOS 動作感測：全部取自 CMDeviceMotion（系統融合、已校正），取代 sensors_plus 的原始值：
/// - 陀螺儀用 rotationRate（已扣除零點偏差；原始 gyroData 實測直線行走會漂移約 0.65°/s）
/// - 磁力計用 magneticField（已扣除手機本身的磁偏差，附校正精度）
/// - 加速度 = gravity + userAcceleration，轉成 m/s² 並取反號，與 Android 一致（平放朝上 z ≈ +9.8）
/// 每筆事件為 `[epoch 毫秒, ax, ay, az, gx, gy, gz, mx, my, mz, 磁力計校正精度]`，皆為裝置座標系（與 Android 相同軸向）。
final class DeviceMotionStreamHandler: NSObject, FlutterStreamHandler {
  private let motionManager = CMMotionManager()
  private static let gravity = 9.80665

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard motionManager.isDeviceMotionAvailable,
          CMMotionManager.availableAttitudeReferenceFrames().contains(.xArbitraryCorrectedZVertical) else {
      return FlutterError(code: "UNAVAILABLE", message: "Device motion is not available", details: nil)
    }

    let intervalUs = (arguments as? [String: Any])?["interval_us"] as? Int ?? 20000
    motionManager.deviceMotionUpdateInterval = max(Double(intervalUs) / 1_000_000, 0.01)
    // 只有使用磁力計的參考座標系才會提供校正後的 magneticField
    motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main) { motion, _ in
      guard let motion else { return }
      // motion.timestamp 是不含休眠的開機秒數；每筆重新換算 epoch，裝置休眠過也不會偏移
      let epochMs = (Date().timeIntervalSince1970 - ProcessInfo.processInfo.systemUptime + motion.timestamp) * 1000
      let g = DeviceMotionStreamHandler.gravity
      let a = motion.gravity, u = motion.userAcceleration, r = motion.rotationRate, m = motion.magneticField
      events([
        epochMs,
        -(a.x + u.x) * g, -(a.y + u.y) * g, -(a.z + u.z) * g,
        r.x, r.y, r.z,
        m.field.x, m.field.y, m.field.z,
        Double(m.accuracy.rawValue),
      ])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopDeviceMotionUpdates()
    return nil
  }
}
