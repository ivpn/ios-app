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
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties -
    
    private var filteredCollection = [VPNServer]()
    
    private var collection: [VPNServer] {
        if !searchBar.text!.isEmpty {
            return filteredCollection
        }
        
        return Application.shared.serverList.getServers()
    }
    
    // MARK: - IBActions -
    
    @IBAction func sortBy(_ sender: Any) {
        let actions = ServersSort.actions()
        let selected = UserDefaults.shared.serversSort.camelCaseToCapitalized() ?? ""
        
        showActionSheet(image: nil, selected: selected, largeText: true, centered: true, title: "Sort by", actions: actions, sourceView: tableView) { [self] index in
            guard index > -1 else { return }
            
            let sort = ServersSort.allCases[index]
            UserDefaults.shared.set(sort.rawValue, forKey: UserDefaults.Key.serversSort)
            Application.shared.serverList.sortServers()
            filteredCollection = VPNServerList.sort(filteredCollection)
            tableView.reloadData()
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
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
    
    func toggle(isOn: Bool, server: VPNServer) {
        if UserDefaults.standard.bool(forKey: UserDefaults.Key.fastestServerConfigured) {
            StorageManager.save(server: server, isFastestEnabled: isOn)
        } else {
            Application.shared.serverList.saveAllServers(exceptionGateway: server.gateway)
            UserDefaults.standard.set(true, forKey: UserDefaults.Key.fastestServerConfigured)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func showValidation(error: String) {
        showAlert(title: "", message: error)
    }
    
}

// MARK: - UISearchBarDelegate -

extension ServersConfigurationTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let collection = Application.shared.serverList.getServers()
        filteredCollection.removeAll(keepingCapacity: false)
        filteredCollection = collection.filter { (server: VPNServer) -> Bool in
            let location = "\(server.city) \(server.countryCode)".lowercased()
            return location.contains(searchBar.text!.lowercased())
        }
        filteredCollection = VPNServerList.sort(filteredCollection)
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
}
