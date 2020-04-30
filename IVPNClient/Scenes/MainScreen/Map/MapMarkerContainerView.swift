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
    
    let top = MapConstants.Container.topAnchor
    
    private lazy var constraintsA = bb.left().top(MapConstants.Container.topAnchor).right().bottom(-MapConstants.Container.bottomAnchorC).constraints.deactivate()
    private lazy var constraintsB = bb.left().top(MapConstants.Container.topAnchor).right().bottom(-MapConstants.Container.bottomAnchorB).constraints.deactivate()
    private lazy var constraintsC = bb.left().top(MapConstants.Container.topAnchor).right().bottom(-MapConstants.Container.bottomAnchorA).constraints.deactivate()
    private lazy var iPadConstraints = bb.left(MapConstants.Container.iPadLandscapeLeftAnchor).top().right().bottom().constraints.deactivate()
    
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
