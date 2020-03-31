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
    
    // MARK: - Properties -
    
    private lazy var constraintsA = bb.left().top(25).right().bottom(-359).constraints.deactivate()
    private lazy var constraintsB = bb.left().top(25).right().bottom(-274).constraints.deactivate()
    private lazy var constraintsC = bb.left().top(25).right().bottom(-230).constraints.deactivate()
    private lazy var iPadConstraints = bb.left(375).top().right().bottom().constraints.deactivate()
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        initGestures()
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        constraintsA.deactivate()
        constraintsB.deactivate()
        constraintsC.deactivate()
        iPadConstraints.deactivate()
        
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            iPadConstraints.activate()
            return
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            constraintsA.activate()
            return
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
            constraintsB.activate()
            return
        }
        
        constraintsC.activate()
    }
    
    // MARK: - Private methods -
    
    private func initGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        NotificationCenter.default.post(name: Notification.Name.HideConnectionInfoPopup, object: nil)
    }
    
}
