//
//  SettingsViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-17.
//  Copyright (c) 2023 IVPN Limited.
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
import NetworkExtension
import WidgetKit

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
    @IBOutlet weak var ipv6Switch: UISwitch!
    @IBOutlet weak var showIPv4ServersSwitch: UISwitch!
    @IBOutlet weak var killSwitchSwitch: UISwitch!
    @IBOutlet weak var selectHostSwitch: UISwitch!
    
    // MARK: - Properties -
    
    let hud = JGProgressHUD(style: .dark)
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
        
        guard evaluateProtocolForMultiHop() else {
            DispatchQueue.delay(0.5) {
                sender.setOn(false, animated: true)
            }
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isMultiHop)
        Application.shared.settings.updateSelectedServerForMultiHop(isEnabled: sender.isOn)
        updateCellInset(cell: entryServerCell, inset: sender.isOn)
        tableView.reloadData()
        evaluateReconnect(sender: sender as UIView)
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
    }
    
    @IBAction func toggleIpv6(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isIPv6)
        showIPv4ServersSwitch.isEnabled = sender.isOn
        evaluateReconnect(sender: sender as UIView)
    }
    
    @IBAction func toggleShowIPv4Servers(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.Key.showIPv4Servers)
        NotificationCenter.default.post(name: Notification.Name.ServersListUpdated, object: nil)
        Application.shared.connectionManager.needsToUpdateSelectedServer()
    }
    
    @IBAction func toggleKillSwitch(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "Kill Switch is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.killSwitch)
        evaluateReconnect(sender: sender as UIView)
    }
    
    @IBAction func toggleKeepAlive(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.keepAlive)
        evaluateReconnect(sender: sender as UIView)
    }
    
    @IBAction func toggleSelectHost(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.selectHost)
        
        if !sender.isOn {
            Application.shared.settings.selectedHost = nil
            Application.shared.settings.selectedExitHost = nil
            updateSelectedServer()
        }
    }
    
    @IBAction func extendSubscription(_ sender: Any) {
        guard !Application.shared.serviceStatus.isLegacyAccount() else {
            return
        }
        
        present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @IBAction func changePlan(_ sender: Any) {
        present(NavigationManager.getChangePlanViewController(), animated: true, completion: nil)
    }
    
    @IBAction func authenticate(_ sender: Any) {
        present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
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
        
        multiHopSwitch.setOn(UserDefaults.shared.isMultiHop, animated: false)
        ipv6Switch.setOn(UserDefaults.shared.isIPv6, animated: false)
        showIPv4ServersSwitch.setOn(UserDefaults.standard.showIPv4Servers, animated: false)
        showIPv4ServersSwitch.isEnabled = UserDefaults.shared.isIPv6
        killSwitchSwitch.setOn(UserDefaults.shared.killSwitch, animated: false)
        keepAliveSwitch.setOn(UserDefaults.shared.keepAlive, animated: false)
        selectHostSwitch.setOn(UserDefaults.shared.selectHost, animated: false)
        
        updateCellInset(cell: entryServerCell, inset: UserDefaults.shared.isMultiHop)
        updateSelectedServer()
        
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
        if identifier == "NetworkProtection" {
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
            
            if !Application.shared.serviceStatus.isActive && !Application.shared.serviceStatus.isLegacyAccount() {
                present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
                deselectRow(sender: sender)
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(turnOffMultiHop), name: Notification.Name.TurnOffMultiHop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(agreedToTermsOfService), name: Notification.Name.TermsOfServiceAgreed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serviceAuthorized), name: Notification.Name.ServiceAuthorized, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationDismissed), name: Notification.Name.AuthenticationDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateVpnStatus(_:)), name: Notification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    @objc func turnOffMultiHop() {
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
        multiHopSwitch.setOn(false, animated: false)
        tableView.reloadData()
    }
    
    @objc fileprivate func agreedToTermsOfService() {
        guard !Application.shared.serviceStatus.isLegacyAccount() else {
            return
        }
        
        present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @objc fileprivate func serviceAuthorized() {
        tableView.reloadData()
    }
    
    @objc fileprivate func authenticationDismissed() {
        tableView.reloadData()
    }
    
    @objc func pingDidComplete() {
        if needsToReconnect {
            needsToReconnect = false
            Application.shared.connectionManager.connect()
            NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        }
    }
    
    // MARK: - Private methods -
    
    private func updateSelectedServer() {
        let serverViewModel = VPNServerViewModel(server: Application.shared.settings.selectedServer, selectedHost: Application.shared.settings.selectedHost)
        let exitServerViewModel = VPNServerViewModel(server: Application.shared.settings.selectedExitServer, selectedHost: Application.shared.settings.selectedExitHost)
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
    
    @objc private func onUpdateVpnStatus(_ notification: NSNotification) {
        guard let vpnConnection = notification.object as? NEVPNConnection else {
            return
        }
        
        if vpnConnection.status == .disconnected {
            hud.dismiss()
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 { return 60 }
        if indexPath.section == 0 && indexPath.row == 3 && !multiHopSwitch.isOn { return 0 }
        if indexPath.section == 3 && indexPath.row == 1 { return 60 }
        
        // Disconnected custom DNS
        if indexPath.section == 3 && indexPath.row == 3 {
            return UITableView.automaticDimension
        }
        
        // Kill Switch
        if indexPath.section == 3 && indexPath.row == 4 {
            if #available(iOS 15.1, *) {
                if #available(iOS 16, *) { } else {
                    return UITableView.automaticDimension
                }
            }
            return 0
        }
        
        // Experimental
        if indexPath.section == 3 && indexPath.row == 11 {
            if #available(iOS 15.1, *) {
                return UITableView.automaticDimension
            }
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 5 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            openTermsOfService()
        }
        
        if indexPath.section == 5 && indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            openPrivacyPolicy()
        }
        
        if indexPath.section == 5 && indexPath.row == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            contactSupport()
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            guard evaluateIsLoggedIn() else {
                return
            }
            
            guard evaluateIsServiceActive() else {
                return
            }
            
            Application.shared.connectionManager.isOnDemandEnabled { [self] enabled in
                if enabled, Application.shared.connectionManager.status.isDisconnected() {
                    showDisableVPNPrompt(sourceView: tableView.cellForRow(at: indexPath)!) {
                        Application.shared.connectionManager.removeOnDemandRules {}
                        self.performSegue(withIdentifier: "SelectProtocol", sender: nil)
                    }
                    return
                }
                
                performSegue(withIdentifier: "SelectProtocol", sender: nil)
            }
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
        if Application.shared.connectionManager.status == .connected {
            needsToReconnect = true
            Application.shared.connectionManager.resetRulesAndDisconnect(reconnectAutomatically: true)
            DispatchQueue.delay(UserDefaults.shared.killSwitch ? 2 : 0.5) {
                Pinger.shared.ping()
            }
        }
    }
    
}
