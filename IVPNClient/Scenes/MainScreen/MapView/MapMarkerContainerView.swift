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
    
    var constraintsA: [NSLayoutConstraint] = []
    var constraintsB: [NSLayoutConstraint] = []
    var constraintsC: [NSLayoutConstraint] = []
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        initConstraints()
        initGestures()
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return
        }
        
        constraintsA.deactivate()
        constraintsB.deactivate()
        constraintsC.deactivate()
        
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
    
    private func initConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bb.left(375).top().right().bottom()
            return
        }
        
        constraintsA = bb.left().top(25).right().bottom(-359).constraints.deactivate()
        constraintsB = bb.left().top(25).right().bottom(-274).constraints.deactivate()
        constraintsC = bb.left().top(25).right().bottom(-230).constraints.deactivate()
    }
    
    @objc private func handleTap() {
        NotificationCenter.default.post(name: Notification.Name.HideConnectionInfoPopup, object: nil)
    }
    
}
