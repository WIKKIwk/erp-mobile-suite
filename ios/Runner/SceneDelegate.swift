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
      !(window.rootViewController is NativeTabBarController)
    else {
      return
    }

    let navigationController = NativeBackNavigationController(
      flutterViewController: flutterViewController
    )
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
  }
}

final class NativeBackNavigationController: UINavigationController {
  private let rootFlutterViewController: FlutterViewController
  private lazy var dockController = NativeTabBarController(
    messenger: flutterBinaryMessenger
  )
  private lazy var backBridge = NativeBackButtonChannelBridge(
    messenger: flutterBinaryMessenger,
    onVisibilityChanged: { [weak self] visible in
      self?.setBackButtonVisible(visible)
    }
  )

  private var flutterBinaryMessenger: FlutterBinaryMessenger {
    rootFlutterViewController.binaryMessenger
  }

  init(flutterViewController: FlutterViewController) {
    self.rootFlutterViewController = flutterViewController
    super.init(rootViewController: flutterViewController)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    _ = backBridge
    navigationBar.prefersLargeTitles = false
    navigationBar.tintColor = .label
    topViewController?.navigationItem.leftBarButtonItem = makeBackBarButtonItem()
    setNavigationBarHidden(true, animated: false)
    configureDockController()
  }

  private func setBackButtonVisible(_ visible: Bool) {
    UIView.performWithoutAnimation {
      topViewController?.navigationItem.leftBarButtonItem = visible
        ? makeBackBarButtonItem()
        : nil
      setNavigationBarHidden(!visible, animated: false)
      navigationBar.layoutIfNeeded()
    }
  }

  private func makeBackBarButtonItem() -> UIBarButtonItem {
    let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    let image = UIImage(systemName: "chevron.backward", withConfiguration: configuration)
    return UIBarButtonItem(
      image: image,
      style: .plain,
      target: self,
      action: #selector(handleBackButtonTap)
    )
  }

  @objc
  private func handleBackButtonTap() {
    backBridge.sendBackPressed()
  }

  private func configureDockController() {
    addChild(dockController)
    dockController.view.translatesAutoresizingMaskIntoConstraints = false
    dockController.view.backgroundColor = .clear
    view.addSubview(dockController.view)
    NSLayoutConstraint.activate([
      dockController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      dockController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      dockController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      dockController.view.heightAnchor.constraint(equalToConstant: 126),
    ])
    dockController.didMove(toParent: self)
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
    channel.invokeMethod("nativeBackButtonReady", arguments: nil)
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

final class NativeTabBarController: UITabBarController, UITabBarControllerDelegate {
  private lazy var dockBridge = NativeDockChannelBridge(
    messenger: messenger,
    onStateChanged: { [weak self] state in
      self?.applyDockState(state)
    }
  )
  private let messenger: FlutterBinaryMessenger
  private var currentState = NativeDockState(arguments: [:])
  private var placeholderControllers: [NativeTabPlaceholderViewController] = []
  private var isApplyingState = false
  private var accessoryButton: UIButton?

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    view.backgroundColor = .clear
    _ = dockBridge
    if #available(iOS 18.0, *) {
      mode = .tabBar
    }
    if #available(iOS 26.0, *) {
      tabBarMinimizeBehavior = .onScrollDown
    }
  }

  private func applyDockState(_ state: NativeDockState) {
    currentState = state
    let tabItems = state.items.filter { !$0.primary }
    let accessoryItem = state.items.first(where: \.primary)

    isApplyingState = true
    defer { isApplyingState = false }

    guard state.visible, !tabItems.isEmpty else {
      view.isHidden = true
      setSystemTabBarHidden(true)
      if #available(iOS 26.0, *) {
        setBottomAccessory(nil, animated: false)
      }
      return
    }

    syncPlaceholders(with: tabItems)
    view.isHidden = false

    if let selectedIndex = tabItems.firstIndex(where: \.active) {
      self.selectedIndex = selectedIndex
    } else if selectedIndex >= tabItems.count {
      self.selectedIndex = 0
    }

    configureBottomAccessory(with: accessoryItem)
    setSystemTabBarHidden(false)
  }

  private func syncPlaceholders(with items: [NativeDockItem]) {
    let existingIds = placeholderControllers.map(\.itemId)
    let newIds = items.map(\.id)
    if existingIds != newIds {
      placeholderControllers = items.map(NativeTabPlaceholderViewController.init)
      viewControllers = placeholderControllers
    }

    for (index, item) in items.enumerated() {
      let controller = placeholderControllers[index]
      controller.update(with: item)
    }
  }

  private func configureBottomAccessory(with item: NativeDockItem?) {
    guard #available(iOS 26.0, *) else {
      return
    }
    guard let item else {
      setBottomAccessory(nil, animated: false)
      accessoryButton = nil
      return
    }

    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
    var configuration = UIButton.Configuration.prominentGlass()
    configuration.cornerStyle = .capsule
    configuration.image = UIImage(
      systemName: item.active ? (item.selectedSymbol ?? item.symbol) : item.symbol,
      withConfiguration: symbolConfig
    )
    configuration.preferredSymbolConfigurationForImage = symbolConfig
    configuration.baseForegroundColor = .white
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 12,
      leading: 18,
      bottom: 12,
      trailing: 18
    )

    let button: UIButton
    if let existing = accessoryButton {
      button = existing
    } else {
      button = UIButton(type: .system)
      button.addTarget(self, action: #selector(handleAccessoryTap), for: .primaryActionTriggered)
      accessoryButton = button
    }
    button.accessibilityIdentifier = item.id
    button.configuration = configuration
    setBottomAccessory(UITabAccessory(contentView: button), animated: false)
  }

  @objc
  private func handleAccessoryTap() {
    guard let id = accessoryButton?.accessibilityIdentifier else {
      return
    }
    dockBridge.sendTap(id: id)
  }

  private func setSystemTabBarHidden(_ hidden: Bool) {
    if #available(iOS 18.0, *) {
      setTabBarHidden(hidden, animated: false)
    } else {
      tabBar.isHidden = hidden
    }
  }

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
    guard let placeholder = viewController as? NativeTabPlaceholderViewController else {
      return
    }
    guard !isApplyingState else {
      return
    }
    dockBridge.sendTap(id: placeholder.itemId)
  }
}

private final class NativeTabPlaceholderViewController: UIViewController {
  private(set) var itemId: String

  init(item: NativeDockItem) {
    itemId = item.id
    super.init(nibName: nil, bundle: nil)
    update(with: item)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  func update(with item: NativeDockItem) {
    itemId = item.id
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    tabBarItem = UITabBarItem(
      title: nil,
      image: UIImage(systemName: item.symbol, withConfiguration: imageConfig),
      selectedImage: UIImage(
        systemName: item.selectedSymbol ?? item.symbol,
        withConfiguration: imageConfig
      )
    )
    tabBarItem.badgeValue = item.showBadge ? " " : nil
  }
}

private final class NativeDockChannelBridge: NSObject {
  private let channel: FlutterMethodChannel
  private let onStateChanged: (NativeDockState) -> Void

  init(
    messenger: FlutterBinaryMessenger,
    onStateChanged: @escaping (NativeDockState) -> Void
  ) {
    self.channel = FlutterMethodChannel(
      name: "accord/native_dock",
      binaryMessenger: messenger
    )
    self.onStateChanged = onStateChanged
    super.init()
    channel.setMethodCallHandler(handleMethodCall)
    channel.invokeMethod("nativeDockReady", arguments: nil)
  }

  func sendTap(id: String) {
    channel.invokeMethod("nativeDockTap", arguments: id)
  }

  func sendLongPress(id: String) {
    channel.invokeMethod("nativeDockLongPress", arguments: id)
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setDockState":
      let state = NativeDockState(arguments: call.arguments as? [String: Any] ?? [:])
      DispatchQueue.main.async {
        self.onStateChanged(state)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

private struct NativeDockState {
  let visible: Bool
  let compact: Bool
  let tightToEdges: Bool
  let items: [NativeDockItem]

  init(arguments: [String: Any]) {
    visible = arguments["visible"] as? Bool ?? false
    compact = arguments["compact"] as? Bool ?? true
    tightToEdges = arguments["tightToEdges"] as? Bool ?? true
    let rawItems = arguments["items"] as? [[String: Any]] ?? []
    items = rawItems.map(NativeDockItem.init)
  }
}

private struct NativeDockItem {
  let id: String
  let symbol: String
  let selectedSymbol: String?
  let active: Bool
  let primary: Bool
  let showBadge: Bool
  let supportsLongPress: Bool

  init(arguments: [String: Any]) {
    id = arguments["id"] as? String ?? UUID().uuidString
    symbol = arguments["symbol"] as? String ?? "circle"
    selectedSymbol = arguments["selectedSymbol"] as? String
    active = arguments["active"] as? Bool ?? false
    primary = arguments["primary"] as? Bool ?? false
    showBadge = arguments["showBadge"] as? Bool ?? false
    supportsLongPress = arguments["supportsLongPress"] as? Bool ?? false
  }
}
