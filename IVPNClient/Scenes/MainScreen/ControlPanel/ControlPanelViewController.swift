//
//  ControlPanelViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-02-20.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import NetworkExtension
import JGProgressHUD
import WidgetKit

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
        
        let isEnabled = sender == controlPanelView.enableMultiHopButton
        
        Application.shared.settings.updateSelectedServerForMultiHop(isEnabled: isEnabled)
        
        isMultiHop = isEnabled
        reloadView()
        evaluateReconnect(sender: sender as UIView)
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
    }
    
    @IBAction func toggleAntiTracker(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "AntiTracker is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isAntiTracker)
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        evaluateReconnect(sender: sender as UIView)
        controlPanelView.updateAntiTracker(viewModel: vpnStatusViewModel)
        
        if sender.isOn {
            registerUserActivity(type: UserActivityType.AntiTrackerEnable, title: UserActivityTitle.AntiTrackerEnable)
        } else {
            registerUserActivity(type: UserActivityType.AntiTrackerDisable, title: UserActivityTitle.AntiTrackerDisable)
        }
    }
    
    @IBAction func selectIpProtocol(_ sender: UISegmentedControl) {
        controlPanelView.addressType = sender.selectedSegmentIndex == 1 ? .IPv6 : .IPv4
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        addObservers()
        setupGestureRecognizers()
        startAPIUpdate()
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
    
    // MARK: - Gestures -
    
    private func setupGestureRecognizers() {
        let entryServerGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectServerlongPress(_:)))
        entryServerGesture.numberOfTouchesRequired = 3
        entryServerGesture.minimumPressDuration = 3
        
        let exitServerGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectExitServerlongPress(_:)))
        exitServerGesture.numberOfTouchesRequired = 3
        exitServerGesture.minimumPressDuration = 3
        
        controlPanelView.entryServerTableCell.addGestureRecognizer(entryServerGesture)
        controlPanelView.exitServerTableCell.addGestureRecognizer(exitServerGesture)
    }
    
    @objc func selectServerlongPress(_ guesture: UILongPressGestureRecognizer) {
        guard guesture.state == .recognized else { return }
        askForCustomServer(isExitServer: false)
    }
    
    @objc func selectExitServerlongPress(_ guesture: UILongPressGestureRecognizer) {
        guard guesture.state == .recognized else { return }
        askForCustomServer(isExitServer: true)
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
        log(.info, message: "Connect VPN")
        
        guard evaluateIsNetworkReachable() else {
            controlPanelView.connectSwitch.setOn(vpnStatusViewModel.connectToggleIsOn, animated: true)
            return
        }
        
        guard evaluateIsLoggedIn() else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(connectionExecute), name: Notification.Name.ServiceAuthorized, object: nil)
            return
        }
        
        guard evaluateHasUserConsent() else {
            controlPanelView.connectSwitch.setOn(vpnStatusViewModel.connectToggleIsOn, animated: true)
            NotificationCenter.default.addObserver(self, selector: #selector(agreedToTermsOfService), name: Notification.Name.TermsOfServiceAgreed, object: nil)
            return
        }
        
        guard evaluateIsServiceActive() else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
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
                    self.updateStatus(vpnStatus: Application.shared.connectionManager.status)
                }
            }
        } else {
            manager.resetRulesAndConnect()
        }
        
        registerUserActivity(type: UserActivityType.Connect, title: UserActivityTitle.Connect)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    @objc func disconnect() {
        log(.info, message: "Disconnect VPN")
        
        let manager = Application.shared.connectionManager
        
        if UserDefaults.shared.networkProtectionEnabled {
            manager.resetRulesAndDisconnectShortcut()
        } else {
            manager.resetRulesAndDisconnect()
        }
        
        registerUserActivity(type: UserActivityType.Disconnect, title: UserActivityTitle.Disconnect)
        
        DispatchQueue.delay(0.5) {
            if Application.shared.connectionManager.status.isDisconnected() {
                Pinger.shared.ping()
                Application.shared.settings.updateRandomServer()
            }
            
        }
    }
    
    @objc func newSession() {
        sessionManager.createSession()
    }
    
    @objc func forceNewSession() {
        sessionManager.createSession(force: true)
    }
    
    func updateStatus(vpnStatus: NEVPNStatus, animated: Bool = true) {
        vpnStatusViewModel.status = vpnStatus
        controlPanelView.updateVPNStatus(viewModel: vpnStatusViewModel, animated: animated)
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
        controlPanelView.updateAntiTracker(viewModel: vpnStatusViewModel)
        
        if vpnStatus == .disconnected {
            hud.dismiss()
        }
        
        if !needsToReconnect && !Application.shared.connectionManager.reconnectAutomatically && vpnStatus != lastVPNStatus && (vpnStatus == .invalid || vpnStatus == .disconnected) {
            if Application.shared.connectionManager.isStatusStable && NetworkManager.shared.isNetworkReachable {
                refreshServiceStatus()
                NotificationCenter.default.post(name: Notification.Name.HideConnectToServerPopup, object: nil)
            }
        }
        
        if vpnStatus != lastVPNStatus && (vpnStatus == .connected || vpnStatus == .disconnected) {
            NotificationCenter.default.post(name: Notification.Name.HideConnectToServerPopup, object: nil)
            DispatchQueue.delay(0.75) {
                if Application.shared.connectionManager.isStatusStable && NetworkManager.shared.isNetworkReachable && !self.needsToReconnect && !Application.shared.connectionManager.reconnectAutomatically {
                    self.reloadGeoLocation()
                }
            }
        }
        
        lastVPNStatus = vpnStatus
    }
    
    @objc func refreshServiceStatus() {
        if let lastUpdateDate = lastStatusUpdateDate {
            let now = Date()
            if now.timeIntervalSince(lastUpdateDate) < Config.serviceStatusRefreshMaxIntervalSeconds { return }
        }
        
        if Application.shared.connectionManager.status != .connecting {
            lastStatusUpdateDate = Date()
            sessionManager.getSessionStatus()
        }
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
                
                self.controlPanelView.updateServerNames()
                
                Application.shared.connectionManager.getStatus { _, status in
                    self.updateStatus(vpnStatus: status)
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
    
    func presentSelectProtocol() {
        if let topViewController = UIApplication.topViewController() as? MainViewController {
            topViewController.performSegue(withIdentifier: "MainScreenSelectProtocol", sender: nil)
        }
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateControlPanel), name: Notification.Name.UpdateControlPanel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serverSelected), name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionExecute), name: Notification.Name.Connect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnect), name: Notification.Name.Disconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationDismissed), name: Notification.Name.AuthenticationDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(protocolSelected), name: Notification.Name.ProtocolSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: Notification.Name.AntiTrackerUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(evaluateReconnectHandler), name: Notification.Name.EvaluateReconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(evaluatePlanUpdate), name: Notification.Name.EvaluatePlanUpdate, object: nil)
    }
    
    // MARK: - Private methods -
    
    private func initView() {
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        isMultiHop = UserDefaults.shared.isMultiHop
        controlPanelView.updateServerNames()
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
        controlPanelView.updateAntiTracker(viewModel: vpnStatusViewModel)
        controlPanelView.updateProtocol()
    }
    
    @objc private func reloadView() {
        tableView.reloadData()
        isMultiHop = UserDefaults.shared.isMultiHop
        Application.shared.connectionManager.needsToUpdateSelectedServer()
        controlPanelView.updateServerNames()
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
        controlPanelView.updateAntiTracker(viewModel: vpnStatusViewModel)
        controlPanelView.updateProtocol()
    }
    
    private func reloadGeoLocation() {
        NotificationCenter.default.post(name: Notification.Name.UpdateGeoLocation, object: nil)
    }
    
    @objc private func updateControlPanel() {
        reloadView()
        controlPanelView.updateVPNStatus(viewModel: vpnStatusViewModel)
    }
    
    @objc private func serverSelected() {
        Application.shared.connectionManager.needsToUpdateSelectedServer()
        Application.shared.connectionManager.installOnDemandRules()
        controlPanelView.updateServerNames()
        controlPanelView.updateServerLabels(viewModel: vpnStatusViewModel)
    }
    
    @objc private func protocolSelected() {
        Application.shared.connectionManager.needsToUpdateSelectedServer()
        Application.shared.connectionManager.installOnDemandRules()
        controlPanelView.updateProtocol()
        tableView.reloadData()
        isMultiHop = UserDefaults.shared.isMultiHop
    }
    
    @objc private func pingDidComplete() {
        serverSelected()
        
        if needsToReconnect {
            needsToReconnect = false
            Application.shared.connectionManager.reconnectAutomatically = true
            Application.shared.connectionManager.connect()
            
            DispatchQueue.delay(1) {
                Application.shared.connectionManager.reconnectAutomatically = false
            }
        }
    }
    
    @objc private func authenticationDismissed() {
        updateStatus(vpnStatus: Application.shared.connectionManager.status)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
    }
    
    @objc private func subscriptionDismissed() {
        updateStatus(vpnStatus: Application.shared.connectionManager.status)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    @objc private func agreedToTermsOfService() {
        connectionExecute()
    }
    
    @objc private func evaluateReconnectHandler() {
        evaluateReconnect(sender: controlPanelView)
    }
    
    @objc private func evaluatePlanUpdate() {
        let isMultiHopAvailable = Application.shared.serviceStatus.isEnabled(capability: .multihop)
        let isMultiHopEnabled = UserDefaults.shared.isMultiHop
        let status = Application.shared.connectionManager.status
        
        if !isMultiHopAvailable && isMultiHopEnabled {
            if status == .connected {
                let plan = Application.shared.serviceStatus.currentPlan
                showActionAlert(title: "Subscription is changed to \(plan)", message: "Active VPN connection is using Pro plan features (MultiHop) and will be disconnected.", action: "Reconnect with SingleHop VPN", cancel: "OK", cancelHandler: { [self] _ in
                    disableMultiHop()
                    if Application.shared.connectionManager.canDisconnect(status: status) {
                        Application.shared.connectionManager.disconnect()
                    } else {
                        Application.shared.connectionManager.reconnect()
                    }
                }, actionHandler: { [self] _ in
                    disableMultiHop()
                    Application.shared.connectionManager.reconnect()
                })
            } else {
                disableMultiHop()
            }
        }
    }
    
    private func disableMultiHop() {
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
        Application.shared.settings.updateSelectedServerForMultiHop(isEnabled: false)
        updateControlPanel()
    }
    
    private func startAPIUpdate() {
        Timer.scheduledTimer(timeInterval: 60 * 60, target: self, selector: #selector(refreshServiceStatus), userInfo: nil, repeats: true)
    }
    
}
