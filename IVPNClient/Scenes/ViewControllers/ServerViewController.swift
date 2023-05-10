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
    
    private var collection = [VPNServer]()
    private var expandedGateways = [String]()
    
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
        searchTextDidChange(searchText: searchBar.text!)
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
        collection = getCollection()
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
        filteredCollection = VPNServerList.sort(filteredCollection)
        filteredCollection = Application.shared.serverList.getAllHosts(filteredCollection, isFavorite: isFavorite)
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
    
    private func getCollection() -> [VPNServer] {
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
    
    private func searchTextDidChange(searchText: String) {
        guard !searchText.isEmpty else {
            tableView.reloadData()
            return
        }
        
        let collection = Application.shared.serverList.getServers()
        filteredCollection.removeAll(keepingCapacity: false)
        filteredCollection = collection.filter { (server: VPNServer) -> Bool in
            let location = "\(server.city) \(server.countryCode)".lowercased()
            return location.contains(searchText.lowercased())
        }
        filteredCollection = VPNServerList.sort(filteredCollection)
        filteredCollection = Application.shared.serverList.getAllHosts(filteredCollection, isFavorite: isFavorite)
        tableView.reloadData()
    }
    
    private func isFastestServer(indexPath: IndexPath) -> Bool {
        return !UserDefaults.shared.isMultiHop && !isFavorite && indexPath.row == 0
    }
    
    private func isRandomServer(indexPath: IndexPath) -> Bool {
        return ((!UserDefaults.shared.isMultiHop && indexPath.row == 1) || (UserDefaults.shared.isMultiHop && indexPath.row == 0)) && !isFavorite
    }
    
    private func differentServer(server: VPNServer) -> Bool {
        if isExitServer {
            return server !== Application.shared.settings.selectedExitServer
        }
        
        return server !== Application.shared.settings.selectedServer
    }
    
    private func differentHost(host: Host?) -> Bool {
        guard let host = host else {
            return false
        }
        
        if isExitServer {
            if let selectedExitHost = Application.shared.settings.selectedExitHost {
                return host.hostName != selectedExitHost.hostName
            }
        }
        
        if let selectedHost = Application.shared.settings.selectedHost {
            return host.hostName != selectedHost.hostName
        }
        
        return false
    }
    
    private func validMultiHop(server: VPNServer, indexPath: IndexPath, force: Bool) -> Bool {
        guard !force else {
            return true
        }
        
        let secondServer = isExitServer ? Application.shared.settings.selectedServer : Application.shared.settings.selectedExitServer
        
        guard VPNServer.validMultiHop(server, secondServer) else {
            showAlert(title: "Entry and exit servers are the same", message: "Please select a different entry or exit server.")
            tableView.deselectRow(at: indexPath, animated: true)
            return false
        }
        
        guard VPNServer.validMultiHopCountry(server, secondServer) else {
            showActionAlert(title: VPNServer.validMultiHopCountryTitle, message: VPNServer.validMultiHopCountryMessage, action: "Continue", cancel: "Cancel", actionHandler: { [self] _ in
                selected(indexPath: indexPath, force: true)
            })
            tableView.deselectRow(at: indexPath, animated: true)
            return false
        }
        
        guard VPNServer.validMultiHopISP(server, secondServer) else {
            showActionAlert(title: VPNServer.validMultiHopISPTitle, message: VPNServer.validMultiHopISPMessage, action: "Continue", cancel: "Cancel", actionHandler: { [self] _ in
                selected(indexPath: indexPath, force: true)
            })
            tableView.deselectRow(at: indexPath, animated: true)
            return false
        }
        
        return true
    }
    
    private func select(server: VPNServer, host: Host?) {
        if isExitServer {
            Application.shared.settings.selectedExitServer = server
            Application.shared.settings.selectedExitHost = host
        } else {
            Application.shared.settings.selectedServer = server
            Application.shared.settings.selectedHost = host
            UserDefaults.standard.set(Application.shared.settings.selectedServer.fastest, forKey: UserDefaults.Key.fastestServerPreferred)
            if !UserDefaults.shared.isMultiHop, server == Application.shared.settings.selectedExitServer {
                Application.shared.settings.selectedExitServer = Application.shared.serverList.getExitServer(entryServer: server)
                Application.shared.settings.selectedExitHost = nil
            }
        }
    }
    
    private func postNotification() {
        log(.info, message: "Update selected server = \(Application.shared.settings.selectedServer.city)")
        NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.post(name: Notification.Name.ShowConnectToServerPopup, object: nil)
    }
    
    private func reconnect(_ differentServer: Bool, _ differentHost: Bool) {
        if differentServer || differentHost || Application.shared.serverList.noPing {
            if Application.shared.settings.selectedServer.fastest && Application.shared.serverList.noPing {
                serverDelegate?.reconnectToFastestServer()
            } else {
                Application.shared.connectionManager.reconnect()
            }
        }
    }
    
    private func popViewController() {
        if isPresentedModally {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func selected(indexPath: IndexPath, force: Bool = false) {
        var selectedServer = collection[indexPath.row]
        selectedServer.fastest = false
        var selectedHost: Host?
        let isFastestServer = isFastestServer(indexPath: indexPath)
        let isRandomServer = isRandomServer(indexPath: indexPath)
        let isHost = selectedServer.isHost
        let gateway = selectedServer.gateway
        
        if isFastestServer {
            if let fastestServer = Application.shared.serverList.getFastestServer() {
                selectedServer = fastestServer
            }
        }
        
        if isRandomServer {
            selectedServer = Application.shared.serverList.getRandomServer(isExitServer: isExitServer)
        }
        
        if isHost {
            if let serverByCity = Application.shared.serverList.getServer(byCity: selectedServer.city) {
                selectedServer = serverByCity
                selectedHost = serverByCity.getHost(hostName: gateway)
            }
        }
        
        guard validMultiHop(server: selectedServer, indexPath: indexPath, force: force) else {
            return
        }
        
        let differentServer = differentServer(server: selectedServer)
        let differentHost = differentHost(host: selectedHost)
        select(server: selectedServer, host: selectedHost)
        postNotification()
        reconnect(differentServer, differentHost)
        popViewController()
    }
    
}

// MARK: - UITableViewDataSource -

extension ServerViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collection = getCollection()
        
        if isFavorite && collection.isEmpty && searchBar.text!.isEmpty {
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
        
        selected(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let server = collection[indexPath.row]
        let serverToValidate = isExitServer ? Application.shared.settings.selectedServer : Application.shared.settings.selectedExitServer
        if !VPNServer.validMultiHop(server, serverToValidate) && (!isFavorite || !server.isHost) {
            return 0
        }
        if server.isHost && !expandHost(server) && !isFavorite {
            return 0
        }
        
        return 64
    }
    
}

// MARK: - UISearchBarDelegate -

extension ServerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextDidChange(searchText: searchBar.text!)
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
