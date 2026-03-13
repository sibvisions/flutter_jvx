import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  static let CHANNEL = "com.sibvisions.flutter_jvx/security"

  static var isAuthenticating = false
  static var secureCount: Int = 0

  static var isSecure: Bool {
   return secureCount > 0
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    setupMethodChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  private func setupMethodChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: AppDelegate.CHANNEL, binaryMessenger: messenger)

    channel.setMethodCallHandler({ (call, result) in
      switch call.method {
        case "setAuthStatus":
          AppDelegate.isAuthenticating = call.arguments as? Bool ?? false
          result(true)
        case "hideBlur":
          NotificationCenter.default.post(name: NSNotification.Name("HidePrivacyBlur"), object: nil)
          result(true)
        case "setSecure":
          let secure = call.arguments as? Bool ?? false
          AppDelegate.secureCount += secure ? 1 : -1
          if AppDelegate.secureCount < 0 { AppDelegate.secureCount = 0 }
          result(true)
        default:
          result(FlutterMethodNotImplemented)
      }
    })
  }

}

