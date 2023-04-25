//
//  NetworkProtectionViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-21.
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

class NetworkProtectionViewController: UITableViewController {
    
    // MARK: - Properties -
    
    var collection = [[Network]]()
    let defaults = UserDefaults.shared
    
    var defaultNetwork: Network? {
        if let defaultNetworks = StorageManager.fetchNetworks(isDefault: true) {
            if let first = defaultNetworks.first {
                return first
            }
        }
        return nil
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        StorageManager.saveDefaultNetwork()
        StorageManager.saveCellularNetwork()
        load(isOn: defaults.networkProtectionEnabled)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadHandler), name: Notification.Name.NetworkSaved, object: nil)
    }
    
    // MARK: - Interface Orientations -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.setEditing(false, animated: true)
    }
    
    // MARK: - Methods -
    
    @objc func loadHandler() {
        load(isOn: defaults.networkProtectionEnabled)
        tableView.reloadData()
    }
    
    func load(isOn: Bool = false) {
        collection.removeAll()
        
        guard isOn else {
            collection.append([Network(context: StorageManager.context)])
            return
        }
        
        collection.append([
            Network(context: StorageManager.context),
            Network(context: StorageManager.context)]
        )
        
        if let defaultNetworks = StorageManager.fetchDefaultNeworks() {
            collection.append(defaultNetworks)
        }
        
        if let wifiNetworks = StorageManager.fetchNetworks(type: NetworkType.wifi.rawValue) {
            collection.append(wifiNetworks)
        }
    }
    
    private func removeNetwork(indexPath: IndexPath) {
        let network = collection[indexPath.section][indexPath.row]
        if let name = network.name {
            if Application.shared.network.name == name {
                Application.shared.network.trust = NetworkTrust.Default.rawValue
                NotificationCenter.default.post(name: Notification.Name.UpdateNetwork, object: nil)
            }
            
            StorageManager.removeNetwork(name: name)
            collection[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func trustSelected(trust: String, indexPath: IndexPath) {
        collection[indexPath.section][indexPath.row].trust = trust
        StorageManager.saveContext()
        Application.shared.network.trust = StorageManager.getTrust(network: Application.shared.network)
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name.UpdateNetwork, object: nil)
    }
    
}

// MARK: - UITableViewDataSource -

extension NetworkProtectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkProtectionHeaderTableViewCell", for: indexPath) as! NetworkProtectionHeaderTableViewCell
            cell.delegate = self
            
            return cell
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "NetworkProtectionRulesCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkProtectionTableViewCell", for: indexPath) as! NetworkProtectionTableViewCell
        
        let network = collection[indexPath.section][indexPath.row]
        cell.render(network: network, defaultNetwork: defaultNetwork)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Default & Mobile data"
        case 2:
            return "Wi-Fi networks"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "On iOS 13 and above, current Wi-Fi name is available only when IVPN profile is saved in iOS VPN Configurations."
        default:
            return nil
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension NetworkProtectionViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            performSegue(withIdentifier: "NetworkProtectionRules", sender: nil)
            return
        }
        
        guard indexPath.section > 0 else { return }
        
        selectNetworkTrust(network: collection[indexPath.section][indexPath.row], sourceView: view) { [self] trust in
            let network = collection[indexPath.section][indexPath.row]
            trustSelected(trust: trust, indexPath: indexPath)
            
            if Application.shared.connectionManager.needToReconnect(network: network, newTrust: trust) {
                if let cell = tableView.cellForRow(at: indexPath) {
                    showReconnectPrompt(sourceView: cell as UIView) {
                        Application.shared.connectionManager.reconnect()
                    }
                }
            } else {
                Application.shared.connectionManager.evaluateConnection(network: network, newTrust: trust) { error in
                    if error != nil {
                        self.showWireGuardKeysMissingError()
                    }
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Remove") { (contextualAction, view, boolValue) in
            self.removeNetwork(indexPath: indexPath)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
}

// MARK: - NetworkProtectionTableCellDelegate -

extension NetworkProtectionViewController: NetworkProtectionTableCellDelegate {
    
    func toggle(isOn: Bool) {
        defaults.set(isOn, forKey: UserDefaults.Key.networkProtectionEnabled)
        load(isOn: isOn)
        tableView.reloadData()
        
        if isOn {
            NetworkManager.shared.startMonitoring()
            Application.shared.connectionManager.evaluateConnection { [self] error in
                if error != nil {
                    showWireGuardKeysMissingError()
                }
            }
        } else {
            Application.shared.connectionManager.resetOnDemandRules()
            NetworkManager.shared.stopMonitoring()
        }
    }
    
}
