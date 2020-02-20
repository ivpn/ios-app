//
//  MainViewControllerV2.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import FloatingPanel

class MainViewControllerV2: UIViewController {
    
    // MARK: - Properties -
    
    var floatingPanel: FloatingPanelController!
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFloatingPanel()
    }
    
    deinit {
        destoryFloatingPanel()
    }
    
    // MARK: - Private methods -
    
    private func initFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.setup()
        floatingPanel.delegate = self
        floatingPanel.addPanel(toParent: self)
        floatingPanel.show(animated: true)
    }
    
    private func destoryFloatingPanel() {
        floatingPanel.removePanelFromParent(animated: false)
    }
    
}
