//
//  PortViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-07-11.
//  Copyright (c) 2022 IVPN Limited.
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

class PortViewController: UITableViewController {
    
    // MARK: - Properties -
    
    var portRanges = Application.shared.serverList.getPortRanges(tunnelType: Application.shared.settings.connectionProtocol.formatTitle())
    var selectedPort = Application.shared.settings.connectionProtocol
    var selectedPortIndex = 0
    var updatedPortRange: PortRange?
    var updatedTextField: UITextField?
    
    var ports: [ConnectionSettings] {
        return Application.shared.settings.connectionProtocol.supportedProtocols(protocols: Application.shared.serverList.ports)
    }
    
    var customPorts: [ConnectionSettings] {
        var ports = [ConnectionSettings]()
        if let storedCustomPorts = StorageManager.fetchCustomPorts(vpnProtocol: selectedPort.formatTitle().lowercased()) {
            for customPort in storedCustomPorts {
                if UserDefaults.shared.isV2ray && Application.shared.settings.connectionProtocol.tunnelType() == .wireguard && UserDefaults.shared.v2rayProtocol != customPort.type {
                    continue
                }
                
                let string = "\(customPort.vpnProtocol ?? "")-\(customPort.type ?? "")-\(customPort.port)"
                ports.append(ConnectionSettings.getFrom(portString: string))
            }
        }
        
        return ports
    }
    
    var collection: [ConnectionSettings] {
        return ports + customPorts
    }
    
    // MARK: - @IBActions -
    
    @IBAction func addCustomPort(_ sender: Any) {
        let viewController = NavigationManager.getAddCustomPortViewController(delegate: self)
        present(viewController, animated: true)
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        title = "Select Port"
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
    }
    
    private func setPort(_ port: ConnectionSettings) {
        selectedPort = port
        Application.shared.settings.connectionProtocol = port
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource -

extension PortViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPortTableViewCell", for: indexPath)
            return cell
        }
        
        let port = collection[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortTableViewCell", for: indexPath) as! PortTableViewCell
        cell.setup(port: port, selectedPort: selectedPort, ports: ports)
        
        if port == selectedPort {
            selectedPortIndex = indexPath.row
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Select port"
        default:
            return ""
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension PortViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setPort(collection[indexPath.row])
        
        navigationController?.popViewController(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
        }
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
    
}

// MARK: - AddCustomPortViewControllerDelegate -

extension PortViewController: AddCustomPortViewControllerDelegate {
    
    func customPortAdded(port: ConnectionSettings) -> Bool {
        if collection.contains(where: { $0 == port }) {
            return false
        }
        
        StorageManager.saveCustomPort(vpnProtocol: port.formatTitle().lowercased(), type: port.protocolType().lowercased(), port: port.port())
        
        // Add the same UDP port to other VPN protocol
        if port.protocolType() == "UDP" {
            let vpnProtocol = port.tunnelType() == .wireguard ? "openvpn" : "wireguard"
            StorageManager.saveCustomPort(vpnProtocol: vpnProtocol, type: port.protocolType().lowercased(), port: port.port())
        }
        
        setPort(port)
        
        return true
    }
    
    func portSelected() {
        navigationController?.popViewController(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
        }
    }
    
}
