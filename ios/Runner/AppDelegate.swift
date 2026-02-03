import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  var privacyBlurView: UIVisualEffectView?
  let CHANNEL = "com.sibvisions.flutter_jvx/security"
  var isAuthenticating = false
  var isSecure = false;

  var secureCount: Int = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let privacyChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

    // Listener for flutter commands
    privacyChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "setAuthStatus" {
        // Don't show blur if auth is active
        self.isAuthenticating = call.arguments as? Bool ?? false
        result(true)
      } else if call.method == "hideBlur" {
        self.hideBlurScreen()
        result(true)
      }
      else if call.method == "setSecure" {
        var secure  = call.arguments as? Bool ?? false

        if secure {
          self.secureCount += 1
        }
        else {
          self.secureCount -= 1
          if (self.secureCount < 0) {
            self.secureCount = 0
          }
        }

        if self.secureCount == 0 {
          self.isSecure = false
        }
        else if self.secureCount == 1 {
          self.isSecure = true
        }

        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    if isSecure && !isAuthenticating {
      showBlurScreen()
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    hideBlurScreen()
  }

  private func showBlurScreen() {
    if privacyBlurView == nil {
      // Defines blur style (light, dark or extraLight)
      let blurEffect = UIBlurEffect(style: .systemMaterial)
      privacyBlurView = UIVisualEffectView(effect: blurEffect)
      privacyBlurView?.frame = self.window?.bounds ?? UIScreen.main.bounds

      //fixes problem with rotation
      privacyBlurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      privacyBlurView?.isUserInteractionEnabled = false

      self.window?.addSubview(privacyBlurView!)
    }
  }

  private func hideBlurScreen() {
    UIView.animate(withDuration: 0.2, animations: {
      self.privacyBlurView?.alpha = 0
    }) { _ in
      self.privacyBlurView?.removeFromSuperview()
      self.privacyBlurView = nil
    }
  }

}
