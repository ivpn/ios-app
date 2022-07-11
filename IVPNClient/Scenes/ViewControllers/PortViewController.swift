//
//  PortViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-07-11.
//  Copyright (c) 2022 Privatus Limited.
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
    
    var viewModel = PortViewModel()
    var collection = [ConnectionSettings]()
    var selectedPort = Application.shared.settings.connectionProtocol
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollection()
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        title = "Select Port"
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
    }
    
    private func initCollection() {
        collection = selectedPort.supportedProtocols(protocols: Application.shared.serverList.ports)
    }

}

// MARK: - UITableViewDataSource -

extension PortViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let port = collection[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortTableViewCell", for: indexPath)
        cell.textLabel?.text = "\(port.formatProtocol())"
        
        if port == selectedPort {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
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
        selectedPort = collection[indexPath.row]
        tableView.reloadData()
        Application.shared.settings.connectionProtocol = selectedPort
        NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
        navigationController?.popViewController(animated: true)
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
