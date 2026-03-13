import UIKit
import Flutter

class SceneDelegate: FlutterSceneDelegate {
  var privacyBlurView: UIVisualEffectView?

  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    NotificationCenter.default.addObserver(forName: NSNotification.Name("HidePrivacyBlur"), object: nil, queue: .main) { _ in
      self.hideBlurScreen()
    }
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)

    guard let windowScene = scene as? UIWindowScene else { return }

    if AppDelegate.isSecure && !AppDelegate.isAuthenticating {
      showBlurScreen(in: windowScene)
    }
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.hideBlurScreen()
    }
  }

  private func showBlurScreen(in windowScene: UIWindowScene) {
    guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? self.window,
      privacyBlurView == nil else { return }

    let blurEffect = UIBlurEffect(style: .systemMaterial)
    let blurView = UIVisualEffectView(effect: blurEffect)

    blurView.frame = window.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurView.isUserInteractionEnabled = false
    blurView.alpha = 1

    window.addSubview(blurView)
    self.privacyBlurView = blurView
  }

  private func hideBlurScreen() {
    guard let blurView = privacyBlurView else { return }

    UIView.animate(withDuration: 0.2, animations: {
      blurView.alpha = 0
    }) { _ in
      blurView.removeFromSuperview()
      if self.privacyBlurView === blurView {
          self.privacyBlurView = nil
      }
    }
  }
}
