//
//  ViewController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 9/29/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit
import NetworkExtension
import JGProgressHUD
import SDCAlertView

enum ConnectionState {
    case determiningFastestServer
    case vpnObjectState
}

class MainViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectButton: ConnectButton!
    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var connectedToServerName: UILabel!
    @IBOutlet weak var statusBarConnectionLabel: UILabel!
    @IBOutlet weak var connectedToExitServerName: UILabel!
    @IBOutlet weak var statusBarExitConnectionLabel: UILabel!
    @IBOutlet weak var tapToDisconnectLabel: UILabel!
    @IBOutlet weak var entryServerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitServerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitServerView: UIView!
    @IBOutlet weak var entryServerButton: UIButton!
    @IBOutlet weak var exitServerButton: UIButton!
    @IBOutlet weak var entryServerFlagImage: UIImageView!
    @IBOutlet weak var exitServerFlagImage: UIImageView!
    @IBOutlet weak var entryServerFastestLabel: UILabel!
    @IBOutlet weak var networkView: NetworkView!
    
    // MARK: - Properties -
    
    let hud = JGProgressHUD(style: .dark)
    private let keyManager = AppKeyManager()
    private let sessionManager = SessionManager()
    private var lastStatusUpdateDate: Date?
    private var lastAccountStatus: NEVPNStatus = .invalid
    private var oldStatus: NEVPNStatus?
    private var wireguardErrorObserver: NSKeyValueObservation?
    private let defaults = UserDefaults.shared
    private var updateServerListDidComplete = false
    private var needsToReconnect = false
    private var isSessionDeleted = false
    
    // MARK: - @IBActions -
    
    @IBAction func showConnectionInfo(_ sender: Any) {
        let content = ConnectionInfoView(frame: ConnectionInfoView.calculatedFrame)
        let alert = AlertController(title: "Location", message: "")
        alert.addAction(AlertAction(title: "Close", style: .normal))
        alert.contentView.addSubview(content)
        
        content.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: alert.contentView.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: alert.contentView.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: alert.contentView.rightAnchor).isActive = true
        
        alert.present()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "mainScreen"
        
        updateServerList()
        Timer.scheduledTimer(timeInterval: 60 * 15, target: self, selector: #selector(updateServerList), userInfo: nil, repeats: true)
        
        connectButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        connectButton.addTarget(self, action: #selector(buttonCancelled(_:)), for: .touchUpOutside)
        connectButton.addTarget(self, action: #selector(buttonCancelled(_:)), for: .touchCancel)
        connectButton.addTarget(self, action: #selector(buttonExecute(_:)), for: .touchUpInside)
        
        refreshServiceStatus()
        addErrorObservers()
        addObservers()
        setupGestureRecognizers()
        
        keyManager.delegate = self
        sessionManager.delegate = self
        networkView.delegate = self
        
        // UITests setup
        if UserDefaults.standard.bool(forKey: "-UITests") {
            connectButton.addTarget(self, action: #selector(UITestsConnect), for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateConstraints()
        
        Application.shared.connectionManager.getStatus { _, status in
            log(info: "Updating button status to (without animation): \(status.rawValue)")
            self.updateStatus(vpnStatus: status, animated: false)
            
            Application.shared.connectionManager.onStatusChanged { status in
                log(info: "Updating button status to (with animation): \(status.rawValue)")
                self.updateStatus(vpnStatus: status, animated: true)
            }
        }
        
        updateServerNames()
        refreshServiceStatus()
        updateExitServer()
        
        if UserDefaults.shared.networkProtectionEnabled {
            NetworkManager.shared.evaluateReachability()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(pingDidComplete), name: Notification.Name.PingDidComplete, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if updateServerListDidComplete {
            DispatchQueue.delay(0.5) {
                Pinger.shared.ping()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        Application.shared.connectionManager.removeStatusChangeUpdates()
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.TermsOfServiceAgreed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ForceNewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PingDidComplete, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        removeObservers()
        wireguardErrorObserver?.invalidate()
        wireguardErrorObserver = nil
    }
    
    // MARK: - Gestures -
    
    private func setupGestureRecognizers() {
        let entryServerGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectServerlongPress(_:)))
        entryServerGesture.numberOfTouchesRequired = 3
        entryServerGesture.minimumPressDuration = 3
        
        let exitServerGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectExitServerlongPress(_:)))
        exitServerGesture.numberOfTouchesRequired = 3
        exitServerGesture.minimumPressDuration = 3
        
        entryServerButton.addGestureRecognizer(entryServerGesture)
        exitServerButton.addGestureRecognizer(exitServerGesture)
    }
    
    @objc func selectServerlongPress(_ guesture: UILongPressGestureRecognizer) {
        guard guesture.state == .recognized else { return }
        askForCustomServer(isExitServer: false)
    }
    
    @objc func selectExitServerlongPress(_ guesture: UILongPressGestureRecognizer) {
        guard guesture.state == .recognized else { return }
        askForCustomServer(isExitServer: true)
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectServer" {
            let viewController = segue.destination as! ServerViewController
            viewController.serverDelegate = self
        }
        
        if segue.identifier == "SelectExitServer" {
            let viewController = segue.destination as! ServerViewController
            viewController.isExitServer = true
        }
        
        if segue.identifier == "MainScreenNetworkProtectionRules" {
            let viewController = segue.destination as! NetworkTrustViewController
            viewController.network = Application.shared.network
            viewController.delegate = networkView
        }
    }
    
    // MARK: - UserDefaults observer methods
    
    private func addErrorObservers() {
        let defaults = UserDefaults(suiteName: Config.appGroup)
        
        wireguardErrorObserver = defaults?.observe(\.wireguardTunnelProviderError, options: [.initial, .new]) { _, _ in
            guard defaults?.wireguardTunnelProviderError != "" else { return }
            
            defaults?.set("", forKey: UserDefaults.Key.wireguardTunnelProviderError)
            
            self.showErrorAlert(title: "Error", message: "WireGuard tunnel failed to start. Check WireGuard public key and IP address in your settings.")
        }
    }
    
    private func showExpiredSubscriptionError() {
        showActionAlert(
            title: "No active subscription",
            message: "To continue using IVPN, you must activate your subscription.",
            action: "Activate",
            cancel: "Cancel",
            actionHandler: { _ in
                self.present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
            }
        )
    }
    
    // MARK: - Interface Orientations -
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateExitServer()
        updateConstraints()
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(serverSelected), name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnect), name: Notification.Name.Disconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationDismissed), name: Notification.Name.AuthenticationDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectErrorObserver), name: Notification.Name.ConnectError, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Disconnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AuthenticationDismissed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ForceNewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ConnectError, object: nil)
    }
    
    @objc func updateServerList() {
        ApiService.shared.getServersList(storeInCache: true) { result in
            self.updateServerListDidComplete = true
            switch result {
            case .success(let serverList):
                Application.shared.serverList = serverList
                Pinger.shared.serverList = Application.shared.serverList
                Pinger.shared.ping()
            default:
                break
            }
        }
    }
    
    @objc func serverSelected() {
        Application.shared.connectionManager.getStatus { _, status in
            if status == .disconnected || status == .disconnecting || status == .invalid {
                self.updateServerNames()
            }
        }
    }
    
    @objc func agreedToTermsOfService() {
        if UserDefaults.standard.bool(forKey: "-UITests") {
            UITestsConnect()
            return
        }
        
        connectionExecute()
    }
    
    @objc func authenticationDismissed() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
    }
    
    @objc func subscriptionDismissed() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    @objc func newSession() {
        sessionManager.createSession()
    }
    
    @objc func forceNewSession() {
        sessionManager.createSession(force: true)
    }
    
    @objc func connectErrorObserver() {
        switch Application.shared.settings.connectionProtocol.tunnelType() {
        case .ipsec:
            handleIKEv2Error()
        case .openvpn:
            handleOpenVPNError()
        case .wireguard:
            break
        }
    }
    
    @objc func pingDidComplete() {
        updateServerNames()
        
        if needsToReconnect {
            needsToReconnect = false
            Application.shared.connectionManager.connect()
        }
    }
    
    // MARK: - Methods -
    
    private func buttonPressAnimation() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = CATransform3DScale(CATransform3DIdentity, 0.95, 0.95, 1)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 0.1
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.autoreverses = false
        
        connectButton.layer.add(animation, forKey: nil)
    }
    
    private func buttonReleaseAnimation() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 0.1
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        connectButton.layer.add(animation, forKey: nil)
    }
    
    @objc func buttonPressed(_ sender: Any) {
        buttonPressAnimation()
    }
    
    @objc func buttonCancelled(_ sender: Any) {
        buttonReleaseAnimation()
    }
    
    @objc func buttonExecute(_ sender: Any) {
        connectionExecute()
        
        // Disable multiple tap gestures on VPN connect button
        connectButton.isUserInteractionEnabled = false
        DispatchQueue.delay(1, closure: {
            self.connectButton.isUserInteractionEnabled = true
        })
    }
    
    @objc func UITestsConnect() {
        connect(status: .disconnected)
    }
    
    @objc func connectionExecute() {
        buttonReleaseAnimation()
        
        Application.shared.connectionManager.getStatus { _, status in
            if status == .disconnected || status == .invalid {
                self.connect(status: status)
            } else {
                self.disconnect()
            }
            self.updateServerNames()
        }
    }
    
    private func connect(status: NEVPNStatus) {
        guard NetworkManager.shared.isNetworkReachable else {
            showAlert(title: "Connection error", message: "Please check your Internet connection and try again.")
            return
        }
        
        guard Application.shared.authentication.isLoggedIn else {
            if #available(iOS 13.0, *) {
                let viewController = NavigationManager.getLoginViewController()
                viewController.presentationController?.delegate = self
                present(viewController, animated: true, completion: nil)
            } else {
                let viewController = NavigationManager.getLoginViewController()
                viewController.presentationController?.delegate = self
                present(viewController, animated: true, completion: nil)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(connectionExecute), name: Notification.Name.ServiceAuthorized, object: nil)
            return
        }
        
        guard UserDefaults.shared.hasUserConsent else {
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(agreedToTermsOfService), name: Notification.Name.TermsOfServiceAgreed, object: nil)
            return
        }
        
        guard Application.shared.serviceStatus.isActive else {
            let viewController = NavigationManager.getSubscriptionViewController()
            viewController.presentationController?.delegate = self
            present(viewController, animated: true, completion: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(connectionExecute), name: Notification.Name.SubscriptionActivated, object: nil)
            return
        }
        
        if AppKeyManager.isKeyPairRequired && ExtensionKeyManager.needToRegenerate() {
            keyManager.setNewKey()
            return
        }
        
        let manager = Application.shared.connectionManager
        
        if defaults.networkProtectionEnabled && !manager.canConnect(status: status) {
            showActionSheet(title: "IVPN cannot connect to trusted network. Do you want to change Network Protection settings for the current network and connect?", actions: ["Connect"], sourceView: self.connectButton) { index in
                switch index {
                case 0:
                    self.networkView.resetTrustToDefault()
                    manager.resetRulesAndConnect()
                default:
                    break
                }
            }
        } else {
            manager.resetRulesAndConnect()
        }
        
        registerUserActivity(type: UserActivityType.Connect, title: UserActivityTitle.Connect)
    }
    
    @objc func disconnect() {
        let manager = Application.shared.connectionManager
        
        if defaults.networkProtectionEnabled {
            manager.resetRulesAndDisconnectShortcut()
        } else {
            manager.resetRulesAndDisconnect()
        }
        
        registerUserActivity(type: UserActivityType.Disconnect, title: UserActivityTitle.Disconnect)
        
        if updateServerListDidComplete {
            DispatchQueue.delay(0.5) {
                Pinger.shared.ping()
            }
        }
    }
    
    private func updateExitServer() {
        if UserDefaults.shared.isMultiHop {
            exitServerView.isHidden = false
            if UIDevice.screenHeightLargerThan(device: .iPhones55s5cSE) {
                entryServerViewHeightConstraint.constant = 102
                exitServerViewHeightConstraint.constant = 102
            } else {
                entryServerViewHeightConstraint.constant = 70
                exitServerViewHeightConstraint.constant = 70
            }
        } else {
            exitServerViewHeightConstraint.constant = 0
            exitServerView.isHidden = true
        }
    }
    
    private func updateConnectionLabel(value: String) {
        if UserDefaults.shared.isMultiHop {
            statusBarConnectionLabel.text = "Entry Server"
            statusBarExitConnectionLabel.text = "Exit Server"
            entryServerButton.accessibilityLabel = "Select Entry Server"
        } else {
            statusBarConnectionLabel.text = value
            entryServerButton.accessibilityLabel = "Select Server"
        }
    }
    
    private func updateConstraints() {
        if defaults.networkProtectionEnabled {
            networkViewHeightConstraint.constant = 60
            networkView.isHidden = false
        } else {
            networkViewHeightConstraint.constant = 0
            networkView.isHidden = true
        }
    }
    
    private func getServerConnectedTo(completion: @escaping (VPNServer) -> Void) {
        Application.shared.connectionManager.getConnectionServerAddress { serverAddress in
            if let serverAddress = serverAddress {
                if let connectedToVPNServer = Application.shared.serverList.getServer(byGateway: serverAddress) {
                    completion(connectedToVPNServer)
                    return
                }
            }
            
            completion(Application.shared.settings.selectedServer)
        }
    }
    
    private func updateServerName(server: VPNServer, label: UILabel, flag: UIImageView) {
        let serverViewModel = VPNServerViewModel(server: server)
        label.iconMirror(text: serverViewModel.formattedServerNameForMainScreen, image: serverViewModel.imageForPingTimeForMainScreen)
        flag.image = serverViewModel.imageForCountryCodeForMainScreen
    }
    
    private func updateServerNames() {
        Application.shared.connectionManager.getStatus { _, status in
            if status != .connected && status != .connecting {
                Application.shared.connectionManager.updateSelectedServer()
            }
            
            self.updateServerName(server: Application.shared.settings.selectedServer, label: self.connectedToServerName, flag: self.entryServerFlagImage)
            self.updateServerName(server: Application.shared.settings.selectedExitServer, label: self.connectedToExitServerName, flag: self.exitServerFlagImage)
            self.entryServerFastestLabel.isHidden = !Application.shared.settings.selectedServer.fastest || Application.shared.settings.selectedServer.fastestServerLabelShouldBePresented
        }
    }
    
    private func updateServerInfo(status: NEVPNStatus) {
        switch status {
        case .connected:
            updateConnectionLabel(value: "Connected to")
        case .reasserting, .connecting:
            updateConnectionLabel(value: "Connecting to")
        case .disconnected, .disconnecting, .invalid:
            updateConnectionLabel(value: "Connect to")
        @unknown default:
            log(info: "Unknown default value")
        }
        
        Application.shared.settings.selectedServer.status = status
        updateServerNames()
        updateExitServer()
    }
    
    @objc func updateStatusWithoutAnimation(status: NEVPNStatus) {
        switch status {
        case .connected:
            connectButton.setImmediateState(newState: .connected)
        case .disconnected:
            connectButton.setImmediateState(newState: .disconnected)
        default:
            break
        }
    }
    
    private func updateStatus(vpnStatus: NEVPNStatus, animated: Bool) {
        updateServerInfo(status: vpnStatus)
        
        if oldStatus == vpnStatus { return }
        
        oldStatus = vpnStatus
        
        tapToDisconnectLabel.isHidden = true
        
        // To avoid unnecessary status request on start to api server
        // we do update status only when the client disconnects
        
        if vpnStatus != lastAccountStatus && (vpnStatus == .invalid || vpnStatus == .disconnected) {
            refreshServiceStatus()
        }
        
        lastAccountStatus = vpnStatus
        
        switch vpnStatus {

        case .connected:
            tapToDisconnectLabel.isHidden = false
            
            waveView.setConnected(isConnected: true, isAnimated: animated)
            
            if !animated {
                connectButton.setImmediateState(newState: .connected)
            } else {
                if connectButton.buttonState == .connecting {
                    connectButton.connectedAnimation()
                    Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateStatusWithoutAnimation), userInfo: nil, repeats: false)
                } else {
                    connectButton.setImmediateState(newState: .connected)
                }
            }
            
            statusLabel.text = "Secure connection"
            if #available(iOS 13.0, *) {
                statusLabel.textColor = UIColor.label
            } else {
                statusLabel.textColor = UIColor.black
            }
            connectButton.isEnabled = true
            
        case .connecting, .reasserting:
            statusLabel.text = "Connecting..."
            statusLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
            connectButton.isEnabled = true
            connectButton.setImmediateState(newState: .connecting)
            
        case .disconnected, .invalid:
            statusLabel.text = "Tap to connect"
            statusLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)

            waveView.setConnected(isConnected: false, isAnimated: animated)

            connectButton.isEnabled = true
            if !animated {
                connectButton.setImmediateState(newState: .disconnected)
            } else {
                if connectButton.buttonState != .connected {
                    connectButton.setImmediateState(newState: .disconnected)
                } else {
                    connectButton.startDisconnectAnimation()
                    Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateStatusWithoutAnimation), userInfo: nil, repeats: false)
                }
            }
            
        case .disconnecting:
            statusLabel.text = "Disconnecting"
            statusLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
            
            connectButton.isEnabled = false
            if !animated {
                connectButton.setImmediateState(newState: .disconnected)
            }
        
        @unknown default:
            log(info: "Unknown default value")
            
        }
    }
    
    func refreshServiceStatus() {
        if let lastUpdateDate = lastStatusUpdateDate {
            let now = Date()
            if now.timeIntervalSince(lastUpdateDate) < Config.serviceStatusRefreshMaxIntervalSeconds { return }
        }
        
        let status = Application.shared.connectionManager.status
        if status != .connected && status != .connecting {
            self.lastStatusUpdateDate = Date()
            self.sessionManager.getSessionStatus()
        }
    }
    
    private func handleIKEv2Error() {
        guard Application.shared.connectionManager.status != .connected else { return }
        
        disconnect()
        
        showErrorAlert(title: "Error", message: "IKEv2 tunnel failed with error: Authentication")
    }
    
    private func handleOpenVPNError() {
        let error = UserDefaults.shared.openvpnTunnelProviderError
        guard !error.isEmpty else { return }
        
        showErrorAlert(title: "Error", message: "OpenVPN tunnel failed with error: \(error.camelCaseToCapitalized() ?? "")")
        
        UserDefaults.shared.set("", forKey: UserDefaults.Key.openvpnTunnelProviderError)
    }
    
    func askForCustomServer(isExitServer: Bool) {
        let alert = UIAlertController(title: "Add Custom Server", message: "Enter Server Hostname", preferredStyle: .alert)
        
        alert.addTextField { _ in }
        
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: { [weak alert] _ in
                if let textField = alert?.textFields![0] {
                    let host = textField.text ?? ""
                    if isExitServer {
                        Application.shared.settings.selectedExitServer = VPNServer(gateway: host, countryCode: "UNK", country: "Custom", city: host)
                    } else {
                        Application.shared.settings.selectedServer = VPNServer(gateway: host, countryCode: "UNK", country: "Custom", city: host)
                    }
                }
                
                Application.shared.connectionManager.getStatus { _, status in
                    self.updateServerInfo(status: status)
                }
            })
        )
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        present(alert, animated: true, completion: {
            let textField = alert.textFields![0]
            let beginning = textField.beginningOfDocument
            textField.text = ".gw.ivpn.net"
            textField.selectedTextRange = textField.textRange(from: beginning, to: beginning)
        })
    }
    
}

// MARK: - WGKeyManagerDelegate -

extension MainViewController {
    
    override func setKeyStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Generating new keys..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func setKeySuccess() {
        hud.dismiss()
        connect(status: .disconnected)
    }
    
    override func setKeyFail() {
        hud.dismiss()
        
        if AppKeyManager.isKeyExpired {
            showAlert(title: "Failed to automatically regenerate WireGuard keys", message: "Cannot connect using WireGuard protocol: regenerating WireGuard keys failed. This is likely because of no access to an IVPN API server. You can retry connection, regenerate keys manually from preferences, or select another protocol. Please contact support if this error persists.")
        } else {
            showAlert(title: "Failed to regenerate WireGuard keys", message: "There was a problem generating and uploading WireGuard keys to IVPN server.")
        }
    }
    
}

// MARK: - SessionManagerDelegate -

extension MainViewController {
    
    override func createSessionSuccess() {
        connect(status: .disconnected)
    }
    
    override func createSessionServiceNotActive() {
        connect(status: .disconnected)
    }
    
    override func createSessionTooManySessions(error: Any?) {
        if let error = error as? ErrorResultSessionNew {
            if let data = error.data {
                if data.upgradable {
                    NotificationCenter.default.addObserver(self, selector: #selector(newSession), name: Notification.Name.NewSession, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(forceNewSession), name: Notification.Name.ForceNewSession, object: nil)
                    UserDefaults.shared.set(data.limit, forKey: UserDefaults.Key.sessionsLimit)
                    UserDefaults.shared.set(data.upgradeToUrl, forKey: UserDefaults.Key.upgradeToUrl)
                    UserDefaults.shared.set(data.isAppStoreSubscription(), forKey: UserDefaults.Key.subscriptionPurchasedOnDevice)
                    present(NavigationManager.getUpgradePlanViewController(), animated: true, completion: nil)
                    return
                }
            }
        }
        
        showCreateSessionAlert(message: "You've reached the maximum number of connected devices")
    }
    
    override func createSessionAuthenticationError() {
        logOut(deleteSession: false)
        present(NavigationManager.getLoginViewController(), animated: true)
    }
    
    override func createSessionFailure(error: Any?) {
        if let error = error as? ErrorResultSessionNew {
            showErrorAlert(title: "Error", message: error.message)
        }
    }
    
    override func sessionStatusNotFound() {
        guard !UserDefaults.standard.bool(forKey: "-UITests") else { return }
        logOut(deleteSession: false)
        present(NavigationManager.getLoginViewController(), animated: true)
    }
    
    override func sessionStatusExpired() {
        showExpiredSubscriptionError()
    }
    
    override func deleteSessionStart() {
        isSessionDeleted = true
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Deleting active session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func deleteSessionSuccess() {
        hud.delegate = self
        hud.dismiss()
    }
    
    override func deleteSessionFailure() {
        hud.delegate = self
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.detailTextLabel.text = "There was an error deleting session"
        hud.show(in: (navigationController?.view)!)
        hud.dismiss(afterDelay: 2)
    }
    
    override func deleteSessionSkip() {
        present(NavigationManager.getLoginViewController(), animated: true)
    }
    
    func showCreateSessionAlert(message: String) {
        showActionSheet(title: message, actions: ["Log out from all other devices", "Try again"], sourceView: self.connectButton) { index in
            switch index {
            case 0:
                self.sessionManager.createSession(force: true)
            case 1:
                self.sessionManager.createSession()
            default:
                break
            }
        }
    }
    
}

// MARK: - JGProgressHUDDelegate -

extension MainViewController: JGProgressHUDDelegate {
    
    func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        if isSessionDeleted {
            present(NavigationManager.getLoginViewController(), animated: true)
            isSessionDeleted = false
        }
    }
    
}

// MARK: - ServerViewControllerDelegate -

extension MainViewController: ServerViewControllerDelegate {
    
    func reconnectToFastestServer() {
        Application.shared.connectionManager.getStatus { _, status in
            if status == .connected {
                self.needsToReconnect = true
                Application.shared.connectionManager.resetRulesAndDisconnect(reconnectAutomatically: true)
            }
        }
    }
    
}

// MARK: - NetworkViewDelegate -

extension MainViewController: NetworkViewDelegate {

    func setNetworkTrust() {
        performSegue(withIdentifier: "MainScreenNetworkProtectionRules", sender: nil)
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension MainViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
}
