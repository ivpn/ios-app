//
//  ServerViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-01-18.
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

protocol ServerViewControllerDelegate: AnyObject {
    func reconnectToFastestServer()
}

class ServerViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favoriteControl: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    // MARK: - Properties -
    
    var isExitServer = false
    var isFavorite: Bool {
        return Application.shared.settings.serverListIsFavorite
    }
    var filteredCollection = [VPNServer]()
    weak var serverDelegate: ServerViewControllerDelegate?
    
    private var collection: [VPNServer] {
        var list = [VPNServer]()
        
        if !searchBar.text!.isEmpty {
            list = filteredCollection
        } else {
            list = Application.shared.serverList.getAllHosts(isFavorite: isFavorite)
        }
        
        if isFavorite {
            return list
        }
        
        list.insert(VPNServer(gateway: "", countryCode: "", country: "", city: "", fastest: false), at: 0)
        
        if !UserDefaults.shared.isMultiHop {
            list.insert(VPNServer(gateway: "", countryCode: "", country: "", city: "", fastest: true), at: 0)
        }
        
        return list
    }
    
    private var expandedGateways: [String] = []
    
    // MARK: - IBActions -
    
    @IBAction func refresh(_ sender: Any) {
        refreshControl?.endRefreshing()
        DispatchQueue.delay(1) {
            Pinger.shared.ping()
        }
    }
    
    @IBAction func sortBy(_ sender: Any) {
        let actions = ServersSort.actions()
        let selected = UserDefaults.shared.serversSort.camelCaseToCapitalized() ?? ""
        
        showActionSheet(image: nil, selected: selected, largeText: true, centered: true, title: "Sort by", actions: actions, sourceView: tableView) { [self] index in
            guard index > -1 else { return }
            
            let sort = ServersSort.allCases[index]
            UserDefaults.shared.set(sort.rawValue, forKey: UserDefaults.Key.serversSort)
            Application.shared.serverList.sortServers()
            filteredCollection = VPNServerList.sort(filteredCollection)
            filteredCollection = Application.shared.serverList.getAllHosts(filteredCollection, isFavorite: isFavorite)
            tableView.reloadData()
        }
    }
    
    @IBAction func expandGateway(_ sender: Any) {
        var superview = (sender as AnyObject).superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view?.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        toggleExpandedGateways(collection[indexPath.row])
        tableView.reloadData()
    }
    
    @IBAction func toggleFavorite(_ sender: UISegmentedControl) {
        Application.shared.settings.serverListIsFavorite = sender.selectedSegmentIndex == 1
        tableView.reloadData()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        Application.shared.serverList.sortServers()
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        favoriteControl.selectedSegmentIndex = Application.shared.settings.serverListIsFavorite ? 1 : 0
        restore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        
        if Application.shared.settings.selectedServer.status == .connected {
            disableRefreshControl()
        } else {
            enableRefreshControl()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Pinger.shared.ping()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(pingDidComplete), name: Notification.Name.PingDidComplete, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PingDidComplete, object: nil)
    }
    
    @objc func pingDidComplete() {
        Application.shared.serverList.sortServers()
        filteredCollection = VPNServerList.sort(self.filteredCollection)
        tableView.reloadData()
    }
    
    func showEmptyView() {
        tableView.backgroundView = emptyView
        headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 41)
        emptyView.frame = CGRect(x: 0, y: 0, width: emptyView.frame.size.width, height: 320)
        emptyView.isHidden = false
        searchBar.isHidden = true
    }
    
    func restore() {
        tableView.backgroundView = nil
        headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 115)
        emptyView.frame = CGRect(x: 0, y: 0, width: emptyView.frame.size.width, height: 0)
        emptyView.isHidden = true
        searchBar.isHidden = false
    }
    
    // MARK: - Methods -
    
    private func initNavigationBar() {
        title = "Select Server"
        
        if isExitServer {
            title = "Select Exit Server"
        } else if UserDefaults.shared.isMultiHop {
            title = "Select Entry Server"
        }
        
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
        
        searchBar.backgroundImage = UIImage()
    }
    
    private func enableRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        refreshControl?.endRefreshing()
    }
    
    private func disableRefreshControl() {
        refreshControl?.removeTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        refreshControl = nil
    }
    
    private func expandHost(_ server: VPNServer) -> Bool {
        return expandedGateways.contains(server.city)
    }
    
    private func toggleExpandedGateways(_ server: VPNServer) {
        if expandedGateways.contains(server.city) {
            expandedGateways = expandedGateways.filter { $0 != server.city }
        } else {
            expandedGateways.append(server.city)
        }
    }
    
}

// MARK: - UITableViewDataSource -

extension ServerViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFavorite && collection.isEmpty {
            showEmptyView()
        } else {
            restore()
        }
        
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let server = collection[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerTableViewCell", for: indexPath) as! ServerTableViewCell
        cell.isMultiHop = UserDefaults.shared.isMultiHop
        cell.isFavorite = isFavorite
        cell.indexPath = indexPath
        cell.viewModel = VPNServerViewModel(server: server)
        cell.serverToValidate = isExitServer ? Application.shared.settings.selectedServer : Application.shared.settings.selectedExitServer
        cell.expandedGateways = expandedGateways
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate -

extension ServerViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < collection.count else {
            return
        }
        
        var selectedHost: Host?
        var server = collection[indexPath.row]
        var differentSelectedServer = false
        var differentSelectedHost = false
        server.random = false
        
        if server.isHost {
            let hostName = server.gateway
            if let serverByCity = Application.shared.serverList.getServer(byCity: server.city) {
                server = serverByCity
                selectedHost = server.getHost(hostName: hostName)
            }
            
            if let selectedHost = Application.shared.settings.selectedHost {
                differentSelectedHost = hostName != selectedHost.hostName
            }
            
            if isExitServer {
                if let selectedExitHost = Application.shared.settings.selectedExitHost {
                    differentSelectedHost = hostName != selectedExitHost.hostName
                }
            }
        }
        
        if ((!UserDefaults.shared.isMultiHop && indexPath.row == 1) || (UserDefaults.shared.isMultiHop && indexPath.row == 0)) && !isFavorite {
            server = Application.shared.serverList.getRandomServer(isExitServer: isExitServer)
            server.random = true
            server.fastest = false
        }
        
        var secondServer = Application.shared.settings.selectedExitServer
        differentSelectedServer = server !== Application.shared.settings.selectedServer
        
        if isExitServer {
            secondServer = Application.shared.settings.selectedServer
            differentSelectedServer = server !== Application.shared.settings.selectedExitServer
        }
        
        guard Application.shared.serverList.validateServer(firstServer: server, secondServer: secondServer) == true else {
            showAlert(title: isExitServer ? "Unable to set Exit Server" : "Unable to set Entry Server", message: "When using Multi-Hop you must select entry and exit servers in different countries.")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if isExitServer {
            Application.shared.settings.selectedExitServer = server
            Application.shared.settings.selectedExitHost = selectedHost
        } else {
            if UserDefaults.shared.isMultiHop || indexPath.row > 0 || server.random || isFavorite {
                Application.shared.settings.selectedServer = server
                Application.shared.settings.selectedHost = selectedHost
                Application.shared.settings.selectedServer.fastest = false
            } else {
                if let fastestServer = Application.shared.serverList.getFastestServer() {
                    if fastestServer == Application.shared.settings.selectedServer {
                        differentSelectedServer = false
                    } else {
                        differentSelectedServer = true
                        Application.shared.settings.selectedServer = fastestServer
                        Application.shared.settings.selectedHost = selectedHost
                    }
                }
                Application.shared.settings.selectedServer.fastest = true
                Application.shared.settings.selectedServer.random = false
            }
            
            if !UserDefaults.shared.isMultiHop {
                Application.shared.settings.selectedExitServer = Application.shared.serverList.getExitServer(entryServer: server)
            }
            UserDefaults.standard.set(Application.shared.settings.selectedServer.fastest, forKey: UserDefaults.Key.fastestServerPreferred)
        }
        
        NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.post(name: Notification.Name.ShowConnectToServerPopup, object: nil)
        
        if differentSelectedServer || differentSelectedHost || Application.shared.serverList.noPing {
            if Application.shared.settings.selectedServer.fastest && Application.shared.serverList.noPing {
                serverDelegate?.reconnectToFastestServer()
            } else {
                Application.shared.connectionManager.reconnect()
            }
        }
        
        log(.info, message: "Update selected server = \(Application.shared.settings.selectedServer.city)")
        
        if isPresentedModally {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let server = collection[indexPath.row]
        if server.isHost && !expandHost(server) && !isFavorite {
            return 0
        }
        
        return 64
    }
    
}

// MARK: - UISearchBarDelegate -

extension ServerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let collection = Application.shared.serverList.getServers()
        filteredCollection.removeAll(keepingCapacity: false)
        filteredCollection = collection.filter { (server: VPNServer) -> Bool in
            let location = "\(server.city) \(server.countryCode)".lowercased()
            return location.contains(searchBar.text!.lowercased())
        }
        filteredCollection = VPNServerList.sort(filteredCollection)
        filteredCollection = Application.shared.serverList.getAllHosts(filteredCollection, isFavorite: isFavorite)
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
