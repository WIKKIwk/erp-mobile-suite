import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard
      let window,
      let flutterViewController = window.rootViewController as? FlutterViewController,
      !(window.rootViewController is NativeBackButtonContainerViewController)
    else {
      return
    }

    let container = NativeBackButtonContainerViewController(
      flutterViewController: flutterViewController
    )
    window.rootViewController = container
    window.makeKeyAndVisible()
  }
}

final class NativeBackButtonContainerViewController: UIViewController {
  private let flutterViewController: FlutterViewController
  private lazy var bridge = NativeBackButtonChannelBridge(
    messenger: flutterViewController.binaryMessenger,
    onVisibilityChanged: { [weak self] visible in
      self?.setBackButtonVisible(visible, animated: true)
    }
  )

  private lazy var backButtonEffectView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: Self.makeBackButtonEffect())
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
    view.layer.cornerRadius = 26
    view.layer.cornerCurve = .continuous
    view.isHidden = true
    view.alpha = 0
    if #available(iOS 26.0, *) {
      view.effect = Self.makeBackButtonEffect()
    } else {
      view.layer.borderWidth = 0.5
      view.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
    }
    return view
  }()

  private lazy var backButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.tintColor = .label
    button.addTarget(self, action: #selector(handleBackButtonTap), for: .touchUpInside)
    let configuration = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
    button.setImage(UIImage(systemName: "chevron.backward", withConfiguration: configuration), for: .normal)
    button.accessibilityLabel = "Back"
    return button
  }()

  init(flutterViewController: FlutterViewController) {
    self.flutterViewController = flutterViewController
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    embedFlutterViewController()
    configureBackButton()
  }

  override var childForStatusBarStyle: UIViewController? {
    flutterViewController
  }

  override var childForStatusBarHidden: UIViewController? {
    flutterViewController
  }

  override var childForHomeIndicatorAutoHidden: UIViewController? {
    flutterViewController
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    flutterViewController.supportedInterfaceOrientations
  }

  private func embedFlutterViewController() {
    addChild(flutterViewController)
    flutterViewController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(flutterViewController.view)
    NSLayoutConstraint.activate([
      flutterViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      flutterViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      flutterViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      flutterViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    flutterViewController.didMove(toParent: self)
  }

  private func configureBackButton() {
    view.addSubview(backButtonEffectView)
    backButtonEffectView.contentView.addSubview(backButton)

    NSLayoutConstraint.activate([
      backButtonEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      backButtonEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      backButtonEffectView.widthAnchor.constraint(equalToConstant: 52),
      backButtonEffectView.heightAnchor.constraint(equalToConstant: 52),

      backButton.centerXAnchor.constraint(equalTo: backButtonEffectView.contentView.centerXAnchor),
      backButton.centerYAnchor.constraint(equalTo: backButtonEffectView.contentView.centerYAnchor),
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalToConstant: 44),
    ])
  }

  @objc
  private func handleBackButtonTap() {
    bridge.sendBackPressed()
  }

  private func setBackButtonVisible(_ visible: Bool, animated: Bool) {
    let changes = {
      self.backButtonEffectView.isHidden = false
      self.backButtonEffectView.alpha = visible ? 1 : 0
      self.backButtonEffectView.transform = visible
        ? .identity
        : CGAffineTransform(scaleX: 0.92, y: 0.92)
    }

    let completion: (Bool) -> Void = { _ in
      self.backButtonEffectView.isHidden = !visible
    }

    if animated {
      UIView.animate(
        withDuration: 0.22,
        delay: 0,
        options: [.curveEaseInOut, .beginFromCurrentState],
        animations: changes,
        completion: completion
      )
    } else {
      changes()
      completion(true)
    }
  }

  private static func makeBackButtonEffect() -> UIVisualEffect {
    if #available(iOS 26.0, *) {
      let effect = UIGlassEffect(style: .regular)
      effect.isInteractive = true
      effect.tintColor = UIColor.white.withAlphaComponent(0.08)
      return effect
    }
    return UIBlurEffect(style: .systemUltraThinMaterial)
  }
}

private final class NativeBackButtonChannelBridge: NSObject {
  private let channel: FlutterMethodChannel
  private let onVisibilityChanged: (Bool) -> Void

  init(
    messenger: FlutterBinaryMessenger,
    onVisibilityChanged: @escaping (Bool) -> Void
  ) {
    self.channel = FlutterMethodChannel(
      name: "accord/native_back_button",
      binaryMessenger: messenger
    )
    self.onVisibilityChanged = onVisibilityChanged
    super.init()
    channel.setMethodCallHandler(handleMethodCall)
  }

  func sendBackPressed() {
    channel.invokeMethod("nativeBackPressed", arguments: nil)
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setBackButtonVisible":
      let visible = (call.arguments as? Bool) ?? false
      DispatchQueue.main.async {
        self.onVisibilityChanged(visible)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
