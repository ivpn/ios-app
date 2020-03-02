//
//  ControlPanelViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 20/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import NetworkExtension

class ControlPanelViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var protectionStatusLabel: UILabel!
    @IBOutlet weak var connectToServerLabel: UILabel!
    @IBOutlet weak var connectSwitch: UISwitch!
    
    // MARK: - Properties -
    
    var vpnStatusViewModel: VPNStatusViewModel!
    
    // MARK: - @IBActions -
    
    @IBAction func toggleConnect(_ sender: UISwitch) {
        connectionExecute()
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Application.shared.connectionManager.getStatus { _, status in
            self.updateStatus(vpnStatus: status)
            
            Application.shared.connectionManager.onStatusChanged { status in
                self.updateStatus(vpnStatus: status)
            }
        }
    }
    
    // MARK: - Methods -
    
    @objc func connectionExecute() {
        Application.shared.connectionManager.getStatus { _, status in
            if status == .disconnected || status == .invalid {
                self.connect(status: status)
            } else {
                self.disconnect()
            }
        }
    }
    
    // MARK: - Private methods -
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    private func updateStatus(vpnStatus: NEVPNStatus) {
        vpnStatusViewModel.status = vpnStatus
        protectionStatusLabel.text = vpnStatusViewModel.protectionStatusText
        connectToServerLabel.text = vpnStatusViewModel.connectToServerText
        connectSwitch.setOn(vpnStatusViewModel.connectToggleIsOn, animated: true)
    }
    
    private func connect(status: NEVPNStatus) {
        guard NetworkManager.shared.isNetworkReachable else {
            showAlert(title: "Connection error", message: "Please check your Internet connection and try again.")
            return
        }
        
        let manager = Application.shared.connectionManager
        
        if UserDefaults.shared.networkProtectionEnabled && !manager.canConnect(status: status) {
            showActionSheet(title: "IVPN cannot connect to trusted network. Do you want to change Network Protection settings for the current network and connect?", actions: ["Connect"], sourceView: self.connectSwitch) { index in
                switch index {
                case 0:
                    // self.networkView.resetTrustToDefault()
                    manager.resetRulesAndConnect()
                default:
                    break
                }
            }
        } else {
            manager.resetRulesAndConnect()
        }
        registerUserActivity(type: UserActivityType.Connect, title: UserActivityTitle.Connect)
    }
    
    private func disconnect() {
        let manager = Application.shared.connectionManager
        
        if UserDefaults.shared.networkProtectionEnabled {
            manager.resetRulesAndDisconnectShortcut()
        } else {
            manager.resetRulesAndDisconnect()
        }
        
        registerUserActivity(type: UserActivityType.Disconnect, title: UserActivityTitle.Disconnect)
    }
    
}
