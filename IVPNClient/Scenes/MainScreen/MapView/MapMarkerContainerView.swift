//
//  MapMarkerContainerView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class MapMarkerContainerView: UIView {
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bb.left(375).top().right().bottom()
            return
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            bb.left().top(25).right().bottom(-359)
            return
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && !UserDefaults.shared.isMultiHop {
            bb.left().top(25).right().bottom(-274)
            return
        }
        
        bb.left().top(25).right().bottom(-230)
    }
    
}
