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
    
}
