//
//  ServerViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/01/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

protocol ServerViewControllerDelegate: class {
    func reconnectToFastestServer()
}

class ServerViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties -
    
    var isExitServer = false
    var collection = [VPNServer]()
    var filteredCollection = [VPNServer]()
    weak var serverDelegate: ServerViewControllerDelegate?
    
    var isSearchActive: Bool {
        return !searchBar.text!.isEmpty
    }
    
    // MARK: - IBActions -
    
    @IBAction func refresh(_ sender: Any) {
        refreshControl?.endRefreshing()
        DispatchQueue.delay(1) {
            Pinger.shared.ping()
        }
    }
    
    @IBAction func sortBy(_ sender: Any) {
        let actionsRawValue = ServersSort.allCases.map { $0.rawValue }
        let actions = actionsRawValue.map { $0.camelCaseToCapitalized() ?? "" }
        let selected = UserDefaults.shared.serversSort.camelCaseToCapitalized() ?? ""
        
        showActionSheet(image: nil, selected: selected, largeText: true, centered: true, title: "Sort by", actions: actions, sourceView: tableView) { index in
            guard index > -1 else { return }
            
            let sort = ServersSort.allCases[index]
            
            UserDefaults.shared.set(sort.rawValue, forKey: UserDefaults.Key.serversSort)
            self.initCollection()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initCollection()
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
        initCollection()
        tableView.reloadData()
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
    
    private func initCollection() {
        Application.shared.serverList.sortServers()
        
        collection = [VPNServer(gateway: "", countryCode: "", country: "", city: "", fastest: true)] + Application.shared.serverList.servers
        
        if UserDefaults.shared.isMultiHop {
            collection = Application.shared.serverList.servers
        }
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
    
}

// MARK: - UITableViewDataSource -

extension ServerViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredCollection.count
        } else {
            return collection.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerTableViewCell", for: indexPath) as! ServerTableViewCell
        let server = isSearchActive ? filteredCollection[indexPath.row] : collection[indexPath.row]
        
        cell.isMultiHop = UserDefaults.shared.isMultiHop
        cell.indexPath = indexPath
        cell.viewModel = VPNServerViewModel(server: server)
        cell.serverToValidate = isExitServer ? Application.shared.settings.selectedServer : Application.shared.settings.selectedExitServer
        cell.selectedServer = isExitServer ? Application.shared.settings.selectedExitServer : Application.shared.settings.selectedServer
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate -

extension ServerViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < collection.count, isSearchActive && indexPath.row < filteredCollection.count else { return }
        
        let server = isSearchActive ? filteredCollection[indexPath.row] : collection[indexPath.row]
        var secondServer = Application.shared.settings.selectedExitServer
        var serverDifferentToSelectedServer = server !== Application.shared.settings.selectedServer
        
        if isExitServer {
            secondServer = Application.shared.settings.selectedServer
            serverDifferentToSelectedServer = server !== Application.shared.settings.selectedExitServer
        }
        
        guard Application.shared.serverList.validateServer(firstServer: server, secondServer: secondServer) == true else {
            showAlert(title: "Unable to set Exit Server", message: "When using Multi-Hop you must select entry and exit servers in different countries.")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if isExitServer {
            Application.shared.settings.selectedExitServer = server
        } else {
            if UserDefaults.shared.isMultiHop || indexPath.row > 0 {
                Application.shared.settings.selectedServer = server
                Application.shared.settings.selectedServer.fastest = false
            } else {
                if let fastestServer = Application.shared.serverList.getFastestServer() {
                    if fastestServer == Application.shared.settings.selectedServer {
                        serverDifferentToSelectedServer = false
                    } else {
                        serverDifferentToSelectedServer = true
                        Application.shared.settings.selectedServer = fastestServer
                    }
                }
                Application.shared.settings.selectedServer.fastest = true
            }
            
            if !UserDefaults.shared.isMultiHop {
                Application.shared.settings.selectedExitServer = Application.shared.serverList.getExitServer(entryServer: server)
            }
            UserDefaults.standard.set(Application.shared.settings.selectedServer.fastest, forKey: "FastestServerPreferred")
        }
        
        NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        
        if serverDifferentToSelectedServer {
            if Application.shared.settings.selectedServer.fastest {
                serverDelegate?.reconnectToFastestServer()
            } else {
                Application.shared.connectionManager.reconnect()
            }
        }
        
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
        return 64
    }
    
}

// MARK: - UISearchBarDelegate -

extension ServerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCollection.removeAll(keepingCapacity: false)
        
        filteredCollection = [VPNServer(gateway: "", countryCode: "", country: "", city: "", fastest: true)] + collection.filter { (server: VPNServer) -> Bool in
            return server.city.lowercased().contains(searchBar.text!.lowercased())
        }
        
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
