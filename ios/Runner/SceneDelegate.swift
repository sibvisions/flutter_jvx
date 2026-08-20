import UIKit
import Flutter

class SceneDelegate: FlutterSceneDelegate {
  private var privacyBlurView: UIView?

  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    NotificationCenter.default.addObserver(forName: NSNotification.Name("HidePrivacyBlur"), object: nil, queue: .main) { _ in
      //(UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("HIDE blur screen - command")
      self.hideBlurScreen()
    }
/*
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWillLoseFocus),
      name: UIScene.willDeactivateNotification, // Oder: UIApplication.willResignActiveNotification
      object: nil
    )

    NotificationCenter.default.addObserver(
      forName: UIApplication.willResignActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
            guard let windowScene = (notification.object as? UIWindowScene) ?? self?.window?.windowScene else { return }

            if AppDelegate.isSecure && !AppDelegate.isAuthenticating {
                (UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("Show blur screen")
                self?.showBlurScreen(in: windowScene)
            } else {
                (UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("No blur screen: \(AppDelegate.isSecure), isAuthenticating: \(AppDelegate.isAuthenticating)")
            }
    }
*/
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)

    guard let windowScene = scene as? UIWindowScene else { return }

    if AppDelegate.isSecure && !AppDelegate.isAuthenticating {
      //(UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("Show blur via ResignActive")
      showBlurScreen(in: windowScene)
    }
  }

  override func sceneDidEnterBackground(_ scene: UIScene) {
    super.sceneDidEnterBackground(scene)

    guard let windowScene = scene as? UIWindowScene else { return }

    if AppDelegate.isSecure {
      //(UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("Show blur via Background (Snapshot Safety)")
      showBlurScreen(in: windowScene)
    }
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      //(UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("HIDE blur screen")
      self.hideBlurScreen()
    }
  }

  private func showBlurScreen(in windowScene: UIWindowScene) {
    guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else { return }

    // avoid adding multiple times
    if privacyBlurView != nil { return }

    // create container view
    let containerView = UIView(frame: window.bounds)
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    // blur effect
    let blurEffect = UIBlurEffect(style: .systemMaterial)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = containerView.bounds
    blurEffectView.isUserInteractionEnabled = false
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.addSubview(blurEffectView)

    // app icon
    if let logoImage = UIImage(named: "LaunchImage") {
      let imageView = UIImageView(image: logoImage)
      imageView.contentMode = .scaleAspectFit
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.isUserInteractionEnabled = false
      containerView.addSubview(imageView)

      NSLayoutConstraint.activate([
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        imageView.widthAnchor.constraint(equalToConstant: 120),
        imageView.heightAnchor.constraint(equalToConstant: 120)
      ])
    }

    window.addSubview(containerView)
    self.privacyBlurView = containerView

    //(UIApplication.shared.delegate as? AppDelegate)?.sendLogToUI("Show blur screen (method)")
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
