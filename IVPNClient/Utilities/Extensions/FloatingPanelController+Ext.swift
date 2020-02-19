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
    
    func setupFloatingPanel() {
        surfaceView.shadowHidden = true
        surfaceView.contentInsets = .init(top: 20, left: 0, bottom: 0, right: 0)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            surfaceView.grabberHandle.isHidden = true
        }
    }
    
}
