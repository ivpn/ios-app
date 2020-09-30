//
//  SettingsViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-17.
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
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var multiHopSwitch: UISwitch!
    @IBOutlet weak var entryServerCell: UITableViewCell!
    @IBOutlet weak var keepAliveSwitch: UISwitch!
    @IBOutlet weak var loggingSwitch: UISwitch!
    @IBOutlet weak var loggingCrashesSwitch: UISwitch!
    @IBOutlet weak var loggingCell: UITableViewCell!
    
    // MARK: - Properties -
    
    let hud = JGProgressHUD(style: .dark)
    private let defaults = UserDefaults(suiteName: Config.appGroup)
    private var needsToReconnect = false
    
    // MARK: - @IBActions -
    
    @IBAction func close(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func toggleMultiHop(_ sender: UISwitch) {
        guard evaluateIsLoggedIn() else {
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard evaluateIsServiceActive() else {
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard evaluateMultiHopCapability(sender) else {
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            
            showActionSheet(title: "MultiHop is supported only on IVPN Pro plan", actions: ["Switch plan"], sourceView: sender) { index in
                switch index {
                case 0:
                    sender.setOn(false, animated: true)
                    let upgradeToUrl = Application.shared.serviceStatus.upgradeToUrl ?? ""
                    self.openWebPage(upgradeToUrl)
                default:
                    sender.setOn(false, animated: true)
                }
            }
            
            return
        }
        
        guard evaluateIsOpenVPN() else {
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard Application.shared.connectionManager.status.isDisconnected() else {
            showConnectedAlert(message: "To change Multi-Hop settings, please first disconnect", sender: sender, completion: {
                sender.setOn(UserDefaults.shared.isMultiHop, animated: true)
                self.tableView.reloadData()
            })
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isMultiHop)
        Application.shared.settings.updateSelectedServerForMultiHop(isEnabled: sender.isOn)
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
    
    @IBAction func changePlan(_ sender: Any) {
        present(NavigationManager.getChangePlanViewController(), animated: true, completion: nil)
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
            present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
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
        addObservers()
        
        versionLabel.layer.cornerRadius = 4
        versionLabel.clipsToBounds = true
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                versionLabel.text = "VERSION \(version) (\(buildNumber))"
            }
        } else {
            versionLabel.isHidden = true
        }
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PingDidComplete, object: nil)
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
            NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
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
        selectedExitServerName.text = exitServerViewModel.formattedServerNameForSettings
        selectedExitServerFlag.image = exitServerViewModel.imageForCountryCodeForSettings
    }
    
    private func updateSelectedProtocol() {
        selectedProtocol.text = Application.shared.settings.connectionProtocol.format()
        
        if Application.shared.settings.connectionProtocol == .ipsec {
            multiHopSwitch.setOn(false, animated: true)
            tableView.reloadData()
        }
    }
    
    private func sendLogs() {
        guard evaluateIsLoggedIn() else {
            return
        }
        
        guard evaluateMailCompose() else {
            return
        }
        
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
    }
    
    private func contactSupport() {
        guard evaluateMailCompose() else {
            return
        }
        
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
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate -

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

// MARK: - ServerViewControllerDelegate -

extension SettingsViewController: ServerViewControllerDelegate {
    
    func reconnectToFastestServer() {
        Application.shared.connectionManager.getStatus { _, status in
            if status == .connected {
                self.needsToReconnect = true
                Application.shared.connectionManager.resetRulesAndDisconnect(reconnectAutomatically: true)
                DispatchQueue.delay(0.5) {
                    Pinger.shared.ping()
                }
            }
        }
    }
    
}
