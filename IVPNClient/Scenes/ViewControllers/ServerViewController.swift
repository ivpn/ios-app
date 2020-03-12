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
    
    // MARK: - Properties -
    
    var isExitServer = false
    var collection = [VPNServer]()
    weak var serverDelegate: ServerViewControllerDelegate?
    
    // MARK: - IBActions -
    
    @IBAction func refresh(_ sender: Any) {
        refreshControl?.endRefreshing()
        DispatchQueue.delay(1, closure: {
            Pinger.shared.ping()
        })
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
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissViewController(_:)))
        }
    }
    
    private func initCollection() {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerTableViewCell", for: indexPath) as! ServerTableViewCell
        let server = collection[indexPath.row]
        
        cell.isMultiHop = UserDefaults.shared.isMultiHop
        cell.indexPath = indexPath
        cell.viewModel = VPNServerViewModel(server: server)
        cell.serverToValidate = isExitServer ? Application.shared.settings.selectedServer : Application.shared.settings.selectedExitServer
        cell.selectedServer = isExitServer ? Application.shared.settings.selectedExitServer : Application.shared.settings.selectedServer
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select Server"
    }
    
}

// MARK: - UITableViewDelegate -

extension ServerViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < collection.count else { return }
        
        let server = collection[indexPath.row]
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
            header.textLabel?.textColor = UIColor.init(named: Theme.Key.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}
