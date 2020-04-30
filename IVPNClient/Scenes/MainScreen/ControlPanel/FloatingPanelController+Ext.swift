//
//  FloatingPanelController+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import FloatingPanel

extension FloatingPanelController {
    
    func setup() {
        surfaceView.shadowHidden = true
        surfaceView.contentInsets = .init(top: 20, left: 0, bottom: 0, right: 0)
        surfaceView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        
        let contentViewController = NavigationManager.getControlPanelViewController()
        set(contentViewController: contentViewController)
        track(scrollView: contentViewController.tableView)
    }
    
}
