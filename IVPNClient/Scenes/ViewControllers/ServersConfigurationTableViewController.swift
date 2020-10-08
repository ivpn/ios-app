//
//  ServersConfigurationTableViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-02-19.
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

class ServersConfigurationTableViewController: UITableViewController {
    
    // MARK: - Properties -
    
    var collection = Application.shared.serverList.servers
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - UITableViewDataSource -

extension ServersConfigurationTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerConfigurationCell", for: indexPath) as! ServerConfigurationCell
        let server = collection[indexPath.row]
        cell.viewModel = VPNServerViewModel(server: server)
        cell.delegate = self
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate -

extension ServersConfigurationTableViewController {
    
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

// MARK: - ServerConfigurationCellDelegate -

extension ServersConfigurationTableViewController: ServerConfigurationCellDelegate {
    
    func toggle(isOn: Bool, gateway: String) {
        let fastestServerConfiguredKey = Application.shared.settings.fastestServerConfiguredKey
        
        if UserDefaults.standard.bool(forKey: fastestServerConfiguredKey) {
            StorageManager.saveServer(gateway: gateway, isFastestEnabled: isOn)
        } else {
            Application.shared.serverList.saveAllServers(exceptionGateway: gateway)
            UserDefaults.standard.set(true, forKey: fastestServerConfiguredKey)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func showValidation(error: String) {
        showAlert(title: "", message: error)
    }
    
}
