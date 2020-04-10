//
//  ControlPanelViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 20/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import NetworkExtension
import JGProgressHUD

class ControlPanelViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var controlPanelView: ControlPanelView!
    
    // MARK: - Properties -
    
    let hud = JGProgressHUD(style: .dark)
    var needsToReconnect = false
    
    var sessionManager: SessionManager {
        let sessionManager = SessionManager()
        sessionManager.delegate = self
        return sessionManager
    }
    
    var connectionInfoViewModel: ProofsViewModel! {
        didSet {
            controlPanelView.updateConnectionInfo(viewModel: connectionInfoViewModel)
        }
    }
    
    private var vpnStatusViewModel = VPNStatusViewModel(status: .invalid)
    private var lastStatusUpdateDate: Date?
    private var lastVPNStatus: NEVPNStatus = .invalid
    
    private var keyManager: AppKeyManager {
        let keyManager = AppKeyManager()
        keyManager.delegate = self
        return keyManager
    }
    
    private var isMultiHop: Bool = UserDefaults.shared.isMultiHop {
        didSet {
            UserDefaults.shared.set(isMultiHop, forKey: UserDefaults.Key.isMultiHop)
            controlPanelView.updateMultiHopButtons(isMultiHop: isMultiHop)
            NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        }
    }
    
    // MARK: - @IBActions -
    
    @IBAction func toggleConnect(_ sender: UISwitch) {
        connectionExecute()
        
        // Disable multiple tap gestures on VPN connect button
        sender.isUserInteractionEnabled = false
        DispatchQueue.delay(1) {
            sender.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func toggleMultiHop(_ sender: UIButton) {
        guard evaluateIsLoggedIn() else {
            return
        }
        
        guard evaluateIsServiceActive() else {
            return
        }
        
        guard evaluateMultiHopCapability(sender) else {
            return
        }
        
        guard Application.shared.connectionManager.status.isDisconnected() else {
            showConnectedAlert(message: "To change Multi-Hop settings, please first disconnect", sender: sender)
            return
        }
        
        let isEnabled = sender == controlPanelView.enableMultiHopButton
        
        Application.shared.settings.updateSelectedServerForMultiHop(isEnabled: isEnabled)
        
        isMultiHop = isEnabled
        reloadView()
    }
    
    @IBAction func toggleAntiTracker(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "AntiTracker is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard Application.shared.connectionManager.status.isDisconnected() else {
            showConnectedAlert(message: "To change AntiTracker settings, please first disconnect", sender: sender)
            sender.setOn(sender.isOn, animated: true)
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isAntiTracker)
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshServiceStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(pingDidComplete), name: Notification.Name.PingDidComplete, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PingDidComplete, object: nil)
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Methods -
    
    @objc func connectionExecute() {
        if vpnStatusViewModel.connectToggleIsOn {
            disconnect()
        } else {
            connect()
        }
    }
    
    func connect() {
        guard evaluateIsNetworkReachable() else {
            controlPanelView.connectSwitch.setOn(vpnStatusViewModel.connectToggleIsOn, animated: true)
            return
        }
        
        guard evaluateIsLoggedIn() else {
            NotificationCenter.default.addObserver(self, selector: #selector(connectionExecute), name: Notification.Name.ServiceAuthorized, object: nil)
            return
        }
        
        guard evaluateIsServiceActive() else {
            NotificationCenter.default.addObserver(self, selector: #selector(connectionExecute), name: Notification.Name.SubscriptionActivated, object: nil)
            return
        }
        
        if AppKeyManager.isKeyPairRequired && ExtensionKeyManager.needToRegenerate() {
            keyManager.setNewKey()
            return
        }
        
        let manager = Application.shared.connectionManager
        
        if UserDefaults.shared.networkProtectionEnabled && !manager.canConnect {
            showActionSheet(title: "IVPN cannot connect to trusted network. Do you want to change Network Protection settings for the current network and connect?", actions: ["Connect"], sourceView: self.controlPanelView.connectSwitch) { index in
                switch index {
                case 0:
                    self.controlPanelView.networkView.resetTrustToDefault()
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
        
        if UserDefaults.shared.networkProtectionEnabled {
            manager.resetRulesAndDisconnectShortcut()
        } else {
            manager.resetRulesAndDisconnect()
        }
        
        registerUserActivity(type: UserActivityType.Disconnect, title: UserActivityTitle.Disconnect)
        
        DispatchQueue.delay(0.5) {
            Pinger.shared.ping()
        }
    }
    
    @objc func newSession() {
        sessionManager.createSession()
    }
    
    @objc func forceNewSession() {
        sessionManager.createSession(force: true)
    }
    
    func showExpiredSubscriptionError() {
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
    
    func showConnectedAlert(message: String, sender: Any?, completion: (() -> Void)? = nil) {
        if let sourceView = sender as? UIView {
            showActionSheet(title: message, actions: ["Disconnect"], sourceView: sourceView) { index in
                if let completion = completion {
                    completion()
                }
                
                switch index {
                case 0:
                    let status = Application.shared.connectionManager.status
                    guard Application.shared.connectionManager.canDisconnect(status: status) else {
                        self.showAlert(title: "Cannot disconnect", message: "IVPN cannot disconnect from the current network while it is marked \"Untrusted\"")
                        return
                    }
                    self.disconnect()
                default:
                    break
                }
            }
        }
    }
    
    func updateStatus(vpnStatus: NEVPNStatus, animated: Bool = true) {
        vpnStatusViewModel.status = vpnStatus
        controlPanelView.updateVPNStatus(viewModel: vpnStatusViewModel, animated: animated)
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
        
        if vpnStatus == .disconnected {
            hud.dismiss()
        }
        
        if vpnStatus != lastVPNStatus && (vpnStatus == .invalid || vpnStatus == .disconnected) {
            refreshServiceStatus()
        }
        
        if vpnStatus != lastVPNStatus && (vpnStatus == .connected || vpnStatus == .disconnected) {
            if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
                topViewController.updateGeoLocation()
            }
        }
        
        lastVPNStatus = vpnStatus
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateControlPanel), name: Notification.Name.UpdateControlPanel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serverSelected), name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnect), name: Notification.Name.Disconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationDismissed), name: Notification.Name.AuthenticationDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(protocolSelected), name: Notification.Name.ProtocolSelected, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UpdateControlPanel, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Disconnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AuthenticationDismissed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ForceNewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ProtocolSelected, object: nil)
    }
    
    // MARK: - Private methods -
    
    private func initView() {
        tableView.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        isMultiHop = UserDefaults.shared.isMultiHop
        Application.shared.connectionManager.needsUpdateSelectedServer()
        controlPanelView.updateServerNames()
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
        controlPanelView.updateAntiTracker()
        controlPanelView.updateProtocol()
    }
    
    private func reloadView() {
        tableView.reloadData()
        isMultiHop = UserDefaults.shared.isMultiHop
        Application.shared.connectionManager.needsUpdateSelectedServer()
        controlPanelView.updateServerNames()
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
        controlPanelView.updateAntiTracker()
        controlPanelView.updateProtocol()
    }
    
    private func refreshServiceStatus() {
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
    
    @objc private func updateControlPanel() {
        reloadView()
    }
    
    @objc private func serverSelected() {
        Application.shared.connectionManager.needsUpdateSelectedServer()
        controlPanelView.updateServerNames()
    }
    
    @objc private func protocolSelected() {
        controlPanelView.updateProtocol()
        tableView.reloadData()
        isMultiHop = UserDefaults.shared.isMultiHop
    }
    
    @objc private func pingDidComplete() {
        Application.shared.connectionManager.needsUpdateSelectedServer()
        controlPanelView.updateServerNames()
        
        if needsToReconnect {
            needsToReconnect = false
            Application.shared.connectionManager.connect()
        }
    }
    
    @objc private func authenticationDismissed() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
    }
    
    @objc private func subscriptionDismissed() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    @objc private func agreedToTermsOfService() {
        connectionExecute()
    }
    
}
