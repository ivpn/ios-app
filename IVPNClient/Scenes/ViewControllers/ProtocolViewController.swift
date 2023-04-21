//
//  ProtocolViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2018-07-16.
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
import JGProgressHUD
import ActiveLabel

class ProtocolViewController: UITableViewController {
    
    // MARK: - Properties -
    
    var collection = [[ConnectionSettings]]()
    let keyManager = AppKeyManager()
    let hud = JGProgressHUD(style: .dark)
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        keyManager.delegate = self
        updateCollection(connectionProtocol: Application.shared.settings.connectionProtocol)
        initNavigationBar()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(protocolSelected), name: Notification.Name.ProtocolSelected, object: nil)
    }
    
    // MARK: - Methods -
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
    }
    
    func updateCollection(connectionProtocol: ConnectionSettings) {
        collection.removeAll()
        collection.append(ConnectionSettings.tunnelTypes(protocols: Config.supportedProtocolTypes))
        
        if connectionProtocol.tunnelType() == .wireguard {
            if UserDefaults.shared.isMultiHop {
                collection.append([.wireguard(.udp, 1), .wireguard(.udp, 2)])
            } else {
                collection.append([.wireguard(.udp, 0), .wireguard(.udp, 1), .wireguard(.udp, 2)])
            }
        }
        
        if connectionProtocol.tunnelType() == .openvpn {
            collection.append([.openvpn(.udp, 0)])
        }
    }
    
    func validateMultiHop(connectionProtocol: ConnectionSettings) -> Bool {
        if UserDefaults.shared.isMultiHop && connectionProtocol.tunnelType() == .ipsec {
            return false
        }
        
        return true
    }
    
    func validateCustomDNSAndAntiTracker(connectionProtocol: ConnectionSettings) -> Bool {
        if UserDefaults.shared.isCustomDNS && UserDefaults.shared.isAntiTracker && connectionProtocol == .ipsec {
            return false
        }
        
        return true
    }
    
    func validateCustomDNS(connectionProtocol: ConnectionSettings) -> Bool {
        if UserDefaults.shared.isCustomDNS && connectionProtocol == .ipsec {
            return false
        }
        
        return true
    }
    
    func validateAntiTracker(connectionProtocol: ConnectionSettings) -> Bool {
        if UserDefaults.shared.isAntiTracker && connectionProtocol == .ipsec {
            return false
        }
        
        return true
    }
    
    func validateKillSwitch(connectionProtocol: ConnectionSettings) -> Bool {
        if UserDefaults.shared.killSwitch && connectionProtocol == .ipsec {
            return false
        }
        
        return true
    }
    
    func validateSecureDNS(connectionProtocol: ConnectionSettings) -> Bool {
        if DNSManager.shared.isEnabled && connectionProtocol == .ipsec {
            return false
        }
        
        return true
    }
    
    func reloadTable(connectionProtocol: ConnectionSettings, indexPath: IndexPath) {
        Application.shared.settings.connectionProtocol = connectionProtocol
        Application.shared.serverList = VPNServerList()
        Application.shared.settings.selectedHost = Application.shared.serverList.getHost(Application.shared.settings.selectedHost)
        Application.shared.settings.selectedExitHost = Application.shared.serverList.getHost(Application.shared.settings.selectedExitHost)
        updateCollection(connectionProtocol: connectionProtocol)
        tableView.reloadData()
        UserDefaults.shared.set(0, forKey: "LastPingTimestamp")
        Pinger.shared.serverList = Application.shared.serverList
        Pinger.shared.ping()
        
        if let cell = tableView.cellForRow(at: indexPath) {
            evaluateReconnect(sender: cell as UIView)
        }
    }
    
    func selectPreferredProtocol(connectionProtocol: ConnectionSettings) {
        let selected = Application.shared.settings.connectionProtocol.protocolType()
        let protocols: [ConnectionSettings] = [.openvpn(.udp, 2049), .openvpn(.tcp, 443)]
        let actions = connectionProtocol.supportedProtocolsFormatMultiHop()
        
        showActionSheet(image: nil, selected: selected, largeText: true, centered: true, title: "Preferred protocol", actions: actions, sourceView: view) { [self] index in
            guard index > -1 else {
                return
            }
            
            Application.shared.settings.connectionProtocol = protocols[index]
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
        }
    }
    
    @objc private func protocolSelected() {
        if let navigationController = navigationController {
            evaluateReconnect(sender: navigationController.navigationBar)
        } else {
            evaluateReconnect(sender: tableView.headerView(forSection: 0) ?? tableView)
        }
    }
    
}

// MARK: - UITableViewDataSource -

extension ProtocolViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let connectionProtocol = collection[indexPath.section][indexPath.row]
        
        if connectionProtocol == .wireguard(.udp, 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WireGuardRegenerationRateCell", for: indexPath) as! WireGuardRegenerationRateCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProtocolTableViewCell", for: indexPath) as! ProtocolTableViewCell
        
        cell.setup(connectionProtocol: connectionProtocol, isSettings: indexPath.section > 0)
        
        if !validateMultiHop(connectionProtocol: connectionProtocol) || !validateCustomDNS(connectionProtocol: connectionProtocol) || !validateAntiTracker(connectionProtocol: connectionProtocol) || !validateSecureDNS(connectionProtocol: connectionProtocol) || !validateKillSwitch(connectionProtocol: connectionProtocol) {
            cell.protocolLabel.textColor = UIColor.init(named: Theme.ivpnLabel6)
        } else {
            cell.protocolLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Protocols"
        case 1:
            return "Protocol settings"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "We recommend the WireGuard protocol for its speed, security and connection reliability. For more information visit our protocol comparison web page."
        case 1:
            if Application.shared.settings.connectionProtocol.tunnelType() == .wireguard {
                return "Keys rotation will start automatically in the defined interval. It will also change the internal IP address."
            }
            return nil
        default:
            return nil
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension ProtocolViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let connectionProtocol = collection[indexPath.section][indexPath.row]
        
        if connectionProtocol == .wireguard(.udp, 1) {
            return
        }
        
        if connectionProtocol == .openvpn(.udp, 0) && UserDefaults.shared.isMultiHop {
            selectPreferredProtocol(connectionProtocol: connectionProtocol)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if connectionProtocol == .openvpn(.udp, 0) || connectionProtocol == .wireguard(.udp, 0) {
            performSegue(withIdentifier: "PortSettings", sender: self)
            return
        }
        
        if connectionProtocol == .wireguard(.udp, 2) {
            performSegue(withIdentifier: "WireGuardSettings", sender: self)
            return
        }
        
        guard validateMultiHop(connectionProtocol: connectionProtocol) else {
            if let cell = tableView.cellForRow(at: indexPath) {
                showActionSheet(title: "To use this protocol you must turn Multi-Hop off", actions: ["Turn off"], sourceView: cell as UIView) { index in
                    switch index {
                    case 0:
                        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
                        NotificationCenter.default.post(name: Notification.Name.TurnOffMultiHop, object: nil)
                        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
                        tableView.reloadData()
                    default:
                        break
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            return
        }
        
        guard validateCustomDNSAndAntiTracker(connectionProtocol: connectionProtocol) else {
            if let cell = tableView.cellForRow(at: indexPath) {
                showActionSheet(title: "To use IKEv2 protocol you must turn AntiTracker and Custom DNS off", actions: ["Turn off"], sourceView: cell as UIView) { index in
                    switch index {
                    case 0:
                        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
                        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
                        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
                        tableView.reloadData()
                    default:
                        break
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            return
        }
        
        guard validateAntiTracker(connectionProtocol: connectionProtocol) else {
            if let cell = tableView.cellForRow(at: indexPath) {
                showActionSheet(title: "To use IKEv2 protocol you must turn AntiTracker off", actions: ["Turn off"], sourceView: cell as UIView) { index in
                    switch index {
                    case 0:
                        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
                        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
                        tableView.reloadData()
                    default:
                        break
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            return
        }
        
        guard validateCustomDNS(connectionProtocol: connectionProtocol) else {
            if let cell = tableView.cellForRow(at: indexPath) {
                showActionSheet(title: "To use IKEv2 protocol you must turn Custom DNS off", actions: ["Turn off"], sourceView: cell as UIView) { index in
                    switch index {
                    case 0:
                        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
                        tableView.reloadData()
                    default:
                        break
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            return
        }
        
        guard validateKillSwitch(connectionProtocol: connectionProtocol) else {
            if let cell = tableView.cellForRow(at: indexPath) {
                showActionSheet(title: "To use IKEv2 protocol you must turn Kill Switch off", actions: ["Turn off"], sourceView: cell as UIView) { index in
                    switch index {
                    case 0:
                        UserDefaults.shared.set(false, forKey: UserDefaults.Key.killSwitch)
                        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
                        tableView.reloadData()
                    default:
                        break
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            return
        }
        
        guard validateSecureDNS(connectionProtocol: connectionProtocol) else {
            if let cell = tableView.cellForRow(at: indexPath) {
                showActionSheet(title: "To use IKEv2 protocol you must disable DNS over HTTTPS/TLS", actions: ["Disable"], sourceView: cell as UIView) { index in
                    switch index {
                    case 0:
                        DNSManager.shared.removeProfile { _ in
                            DNSManager.shared.loadProfile { _ in
                                self.tableView.reloadData()
                            }
                        }
                    default:
                        break
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            return
        }
        
        if connectionProtocol.tunnelType() != Application.shared.settings.connectionProtocol.tunnelType() && connectionProtocol.tunnelType() == .wireguard {
            if  KeyChain.wgPublicKey == nil || ExtensionKeyManager.needToRegenerate() {
                keyManager.setNewKey()
                return
            }
        }
        
        if connectionProtocol.tunnelType() == .ipsec {
            DNSManager.shared.removeProfile { _ in
                DNSManager.shared.loadProfile { _ in
                    
                }
            }
        }
        
        reloadTable(connectionProtocol: connectionProtocol, indexPath: indexPath)
        
        NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let connectionProtocol = collection[indexPath.section][indexPath.row]
        if connectionProtocol == .wireguard(.udp, 1) { return 60 }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        
        let label = ActiveLabel(frame: .zero)
        let customType = ActiveType.custom(pattern: "protocol comparison web page")
        label.tag = 10
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.enabledTypes = [customType]
        label.text = footer.textLabel?.text
        label.textColor = UIColor.init(named: Theme.ivpnLabel6)
        label.customColor[customType] = UIColor.init(named: Theme.ivpnBlue)
        label.handleCustomTap(for: customType) { _ in
            self.openWebPage("https://www.ivpn.net/pptp-vs-ipsec-ikev2-vs-openvpn-vs-wireguard/")
        }
        footer.viewWithTag(10)?.removeFromSuperview()
        footer.addSubview(label)
        footer.textLabel?.text = ""
        label.bindFrameToSuperviewBounds(leading: 16, trailing: -16)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}

// MARK: - WGKeyManagerDelegate -

extension ProtocolViewController {
    
    override func setKeyStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Generating new keys..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func setKeySuccess() {
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.detailTextLabel.text = "WireGuard keys successfully generated and uploaded to IVPN server."
        hud.dismiss(afterDelay: 2)
        reloadTable(connectionProtocol: ConnectionSettings.wireguard(.udp, 2049), indexPath: IndexPath(row: 0, section: 0))
        NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
    }
    
    override func setKeyFail() {
        hud.dismiss()
        
        if AppKeyManager.isKeyExpired {
            showAlert(title: "Failed to automatically rotate WireGuard keys", message: "Cannot connect using WireGuard protocol: rotating WireGuard keys failed. This is likely because of no access to an IVPN API server. You can retry connection, rotate keys manually from preferences, or select another protocol. Please contact support if this error persists.")
        } else {
            showAlert(title: "Failed to regenerate WireGuard keys", message: "There was a problem generating and uploading WireGuard keys to IVPN server.")
        }
    }
    
}
