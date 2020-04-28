//
//  SettingsViewController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import JGProgressHUD
import Sentry

class SettingsViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var selectedServerFlag: UIImageView!
    @IBOutlet weak var selectedServerName: UILabel!
    @IBOutlet weak var selectedExitServerFlag: UIImageView!
    @IBOutlet weak var selectedExitServerName: UILabel!
    @IBOutlet weak var selectedProtocol: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var accountUsername: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var multiHopSwitch: UISwitch!
    @IBOutlet weak var entryServerCell: UITableViewCell!
    @IBOutlet weak var keepAliveSwitch: UISwitch!
    @IBOutlet weak var loggingSwitch: UISwitch!
    @IBOutlet weak var loggingCrashesSwitch: UISwitch!
    @IBOutlet weak var loggingCell: UITableViewCell!
    @IBOutlet weak var manageSubscriptionButton: UIButton!
    
    // MARK: - Properties -
    
    let hud = JGProgressHUD(style: .dark)
    private let defaults = UserDefaults(suiteName: Config.appGroup)
    private var needsToReconnect = false
    
    // MARK: - @IBActions -
    
    @IBAction func toggleMultiHop(_ sender: UISwitch) {
        guard Application.shared.authentication.isLoggedIn else {
            authenticate(self)
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard Application.shared.serviceStatus.isActive else {
            guard UserDefaults.shared.hasUserConsent else {
                present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
                DispatchQueue.delay(0.5) {
                    sender.setOn(false, animated: true)
                }
                return
            }
            
            present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard Application.shared.serviceStatus.isEnabled(capability: .multihop) else {
            if Application.shared.serviceStatus.isOnFreeTrial {
                showAlert(title: "", message: "MultiHop is supported only on IVPN Pro plan") { _ in
                    sender.setOn(false, animated: true)
                }
                return
            }
            
            showActionSheet(title: "MultiHop is supported only on IVPN Pro plan", actions: ["Switch plan"], sourceView: sender) { index in
                switch index {
                case 0:
                    sender.setOn(false, animated: true)
                    self.extendSubscription(self)
                default:
                    sender.setOn(false, animated: true)
                }
            }
            
            return
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() != .openvpn {
            showAlert(title: "Change protocol to OpenVPN", message: "For Multi-Hop connection you must select OpenVPN protocol.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        if !Application.shared.connectionManager.status.isDisconnected() {
            showConnectedAlert(message: "To change Multi-Hop settings, please first disconnect", sender: sender, completion: {
                sender.setOn(UserDefaults.shared.isMultiHop, animated: true)
                self.tableView.reloadData()
            })
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isMultiHop)
        
        if sender.isOn && Application.shared.settings.selectedServer.fastest {
            let server = Application.shared.serverList.servers.first!
            server.fastest = false
            Application.shared.settings.selectedServer = server
            Application.shared.settings.selectedExitServer = Application.shared.serverList.getExitServer(entryServer: server)
        }
        
        if !sender.isOn {
            Application.shared.settings.selectedServer.fastest = UserDefaults.standard.bool(forKey: "FastestServerPreferred")
        }
        
        updateCellInset(cell: entryServerCell, inset: sender.isOn)
        
        tableView.reloadData()
    }
    
    @IBAction func toggleKeepAlive(_ sender: UISwitch) {
        if !Application.shared.connectionManager.status.isDisconnected() {
            showConnectedAlert(message: "To change Keep alive on sleep settings, please first disconnect", sender: sender, completion: {
                sender.setOn(UserDefaults.shared.keepAlive, animated: true)
            })
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.keepAlive)
    }
    
    @IBAction func toggleLogging(_ sender: UISwitch) {
        FileSystemManager.resetLogFile(name: Config.openVPNLogFile)
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isLogging)
        updateCellInset(cell: loggingCell, inset: sender.isOn)
        tableView.reloadData()
    }
    
    @IBAction func toggleLoggingCrashes(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isLoggingCrashes)
        Client.shared?.enabled = sender.isOn as NSNumber
        
        if sender.isOn {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setupCrashReports()
        }
    }
    
    @IBAction func extendSubscription(_ sender: Any) {
        present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        guard Application.shared.authentication.isLoggedIn else {
            authenticate(self)
            return
        }
        
        showActionAlert(title: "Logout", message: "Are you sure you want to log out?", action: "Log out") { _ in
            self.logOut()
        }
    }
    
    @IBAction func authenticate(_ sender: Any) {
        if #available(iOS 13.0, *) {
            present(NavigationManager.getLoginViewController(modalPresentationStyle: .automatic), animated: true, completion: nil)
        } else {
            present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "settingsScreen"
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { _ in
                self.updateSelectedServer()
                self.updateSelectedProtocol()
        }
        
        updateSelectedProtocol()
        setupLabels()
        addObservers()
        
        versionLabel.layer.cornerRadius = 4
        versionLabel.clipsToBounds = true
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                versionLabel.text = "Version \(version) (\(buildNumber))"
            }
        } else {
            versionLabel.isHidden = true
        }
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.shared.isMultiHop {
            multiHopSwitch.setOn(true, animated: false)
        }
        
        if !UserDefaults.shared.keepAlive {
            keepAliveSwitch.setOn(false, animated: false)
        }
        
        if !UserDefaults.shared.isLoggingCrashes {
            loggingCrashesSwitch.setOn(false, animated: false)
        }
        
        if UserDefaults.shared.isLogging {
            loggingSwitch.setOn(true, animated: false)
        }
        
        updateCellInset(cell: entryServerCell, inset: UserDefaults.shared.isMultiHop)
        updateCellInset(cell: loggingCell, inset: UserDefaults.shared.isLogging)
        
        updateSelectedServer()
        
        Application.shared.connectionManager.onStatusChanged { status in
            if status == .disconnected {
                self.hud.dismiss()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(pingDidComplete), name: Notification.Name.PingDidComplete, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Application.shared.connectionManager.removeStatusChangeUpdates()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PingDidComplete, object: nil)
    }
    
    deinit {
        removeObservers()
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
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let status = Application.shared.connectionManager.status
        
        if identifier == "SelectProtocol" || identifier == "NetworkProtection" {
            if !Application.shared.authentication.isLoggedIn {
                authenticate(self)
                deselectRow(sender: sender)
                return false
            }
            
            if !UserDefaults.shared.hasUserConsent && !Application.shared.serviceStatus.isActive {
                present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
                deselectRow(sender: sender)
                return false
            }
            
            if !Application.shared.serviceStatus.isActive {
                present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
                deselectRow(sender: sender)
                return false
            }
        }
        
        if identifier == "SelectProtocol" && !status.isDisconnected() {
            showConnectedAlert(message: "To change protocol, please first disconnect", sender: sender)
            return false
        }
        
        if identifier == "CustomDNS" && !status.isDisconnected() {
            showConnectedAlert(message: "To specify custom DNS, please first disconnect", sender: sender)
            return false
        }
        
        if identifier == "AntiTracker" && !status.isDisconnected() {
            showConnectedAlert(message: "To change AntiTracker settings, please first disconnect", sender: sender)
            return false
        }
        
        return true
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(turnOffMultiHop), name: Notification.Name.TurnOffMultiHop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(agreedToTermsOfService), name: Notification.Name.TermsOfServiceAgreed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serviceAuthorized), name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationDismissed), name: Notification.Name.AuthenticationDismissed, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.TurnOffMultiHop, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.TermsOfServiceAgreed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AuthenticationDismissed, object: nil)
    }
    
    @objc func turnOffMultiHop() {
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
        multiHopSwitch.setOn(false, animated: false)
        tableView.reloadData()
    }
    
    @objc fileprivate func agreedToTermsOfService() {
        present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @objc fileprivate func serviceAuthorized() {
        tableView.reloadData()
    }
    
    @objc fileprivate func authenticationDismissed() {
        tableView.reloadData()
    }
    
    @objc func disconnect() {
        Application.shared.connectionManager.resetRulesAndDisconnect(reconnectAutomatically: true)
        Pinger.shared.ping()
    }
    
    @objc func pingDidComplete() {
        if needsToReconnect {
            needsToReconnect = false
            Application.shared.connectionManager.connect()
        }
    }
    
    // MARK: - Methods -
    
    private func showConnectedAlert(message: String, sender: Any?, completion: (() -> Void)? = nil) {
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
                    NotificationCenter.default.post(name: Notification.Name.Disconnect, object: nil)
                    self.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                    self.hud.detailTextLabel.text = "Disconnecting"
                    self.hud.show(in: (self.navigationController?.view)!)
                    self.hud.dismiss(afterDelay: 5)
                default:
                    break
                }
            }
        }
        
        deselectRow(sender: sender)
    }
    
    private func updateSelectedServer() {
        let serverViewModel = VPNServerViewModel(server: Application.shared.settings.selectedServer)
        let exitServerViewModel = VPNServerViewModel(server: Application.shared.settings.selectedExitServer)
        selectedServerName.text = serverViewModel.formattedServerNameForSettings
        selectedServerFlag.image = serverViewModel.imageForCountryCodeForSettings
        selectedExitServerName.text = exitServerViewModel.formattedServerName
        selectedExitServerFlag.image = exitServerViewModel.imageForCountryCode
    }
    
    private func updateSelectedProtocol() {
        selectedProtocol.text = Application.shared.settings.connectionProtocol.format()
        
        if Application.shared.settings.connectionProtocol == .ipsec {
            multiHopSwitch.setOn(false, animated: true)
            tableView.reloadData()
        }
    }
    
    private func sendLogs() {
        guard Application.shared.authentication.isLoggedIn, Application.shared.serviceStatus.isActive else {
            showAlert(title: "Error", message: "You need to authenticate and have an active subscription to use this feature.")
            return
        }
        
        if MFMailComposeViewController.canSendMail() {
            Application.shared.connectionManager.getOpenVPNLog { log in
                FileSystemManager.updateLogFile(newestLog: log, name: Config.openVPNLogFile, isLoggedIn: Application.shared.authentication.isLoggedIn)
                
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setToRecipients([Config.contactSupportMail])
                
                let file = FileSystemManager.sharedFilePath(name: Config.openVPNLogFile).path
                if let fileData = NSData(contentsOfFile: file) {
                    composer.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: "\(Date.logFileName()).txt")
                }
                
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            showAlert(title: "Cannot send e-mail", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.")
        }
    }
    
    private func contactSupport() {
        if let url = URL(string: Config.contactSupportPage) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func deselectRow(sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let indexPath = self.tableView?.indexPath(for: cell) {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    private func setupLabels() {
        accountUsername.text = Application.shared.authentication.getStoredUsername()
        subscriptionLabel.text = Application.shared.serviceStatus.getSubscriptionText()
        logOutButton.setTitle(Application.shared.authentication.isLoggedIn ? "Log Out" : "Log In or Sign Up", for: .normal)
        manageSubscriptionButton.setTitle(Application.shared.serviceStatus.getSubscriptionActionText(), for: .normal)
    }
    
}

// MARK: - UITableViewDelegate -

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 { return 60 }
        if indexPath.section == 0 && indexPath.row == 2 && !multiHopSwitch.isOn { return 0 }
        if indexPath.section == 2 && indexPath.row == 1 { return 60 }
        if indexPath.section == 2 && indexPath.row == 2 { return 60 }
        if indexPath.section == 2 && indexPath.row == 5 { return 60 }
        if indexPath.section == 2 && indexPath.row == 6 && !loggingSwitch.isOn { return 0 }
        if indexPath.section == 4 && indexPath.row == 0 && Application.shared.authentication.getStoredUsername().isEmpty { return 0 }
        if indexPath.section == 4 && indexPath.row == 0 { return 60 }
        if indexPath.section == 4 && indexPath.row == 1 && !Application.shared.authentication.isLoggedIn { return 0 }
        if indexPath.section == 4 && indexPath.row == 1 { return 60 }
        if indexPath.section == 4 && indexPath.row == 2 && !Application.shared.showSubscriptionAction { return 0 }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 6 {
            tableView.deselectRow(at: indexPath, animated: true)
            sendLogs()
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            openTermsOfService()
        }
        
        if indexPath.section == 3 && indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            openPrivacyPolicy()
        }
        
        if indexPath.section == 3 && indexPath.row == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            contactSupport()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.Key.ivpnLabel6)
        }
        
        setupLabels()
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate -

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

// MARK: - SessionManagerDelegate -

extension SettingsViewController {
    
    override func deleteSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Removing session from IVPN server..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func deleteSessionSuccess() {
        hud.delegate = self
        hud.dismiss()
    }
    
    override func deleteSessionFailure() {
        hud.delegate = self
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.detailTextLabel.text = "There was an error with removing session"
        hud.show(in: (navigationController?.view)!)
        hud.dismiss(afterDelay: 2)
    }
    
    override func deleteSessionSkip() {
        tableView.reloadData()
        showAlert(title: "Session removed from IVPN server", message: "You are successfully logged out")
    }
    
}

// MARK: - JGProgressHUDDelegate -

extension SettingsViewController: JGProgressHUDDelegate {
    
    func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        tableView.reloadData()
        showAlert(title: "Session removed from IVPN server", message: "You are successfully logged out")
    }
    
}

// MARK: - ServerViewControllerDelegate -

extension SettingsViewController: ServerViewControllerDelegate {
    
    func reconnectToFastestServer() {
        Application.shared.connectionManager.getStatus { _, status in
            if status == .connected {
                self.needsToReconnect = true
                self.disconnect()
            }
        }
    }
    
}
