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
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bb.left(375).top().right().bottom()
        } else {
            bb.left().top().right().bottom(-230)
        }
    }
    
}
