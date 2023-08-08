//
//  AntiTrackerListViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-07-06.
//  Copyright (c) 2023 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

class AntiTrackerListViewController: UITableViewController {
    
    private var collection = [
        Application.shared.serverList.antiTrackerBasicList,
        Application.shared.serverList.antiTrackerIndividualList
    ]
    
    private var selectedDns = AntiTrackerDns.load()
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }

}

// MARK: - UITableViewDatasource -

extension AntiTrackerListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return collection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AntiTrackerListCell", for: indexPath)
        let dns = collection[indexPath.section][indexPath.row]
        cell.textLabel?.text = dns.description
        cell.accessoryType = .none
        
        if let selectedDns = selectedDns, dns == selectedDns {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Individual lists"
        default:
            return "Pre-defined lists"
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension AntiTrackerListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dns = collection[indexPath.section][indexPath.row]
        selectedDns = dns
        selectedDns?.save()
        tableView.reloadData()
        navigationController?.popViewController(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.AntiTrackerListUpdated, object: nil)
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
