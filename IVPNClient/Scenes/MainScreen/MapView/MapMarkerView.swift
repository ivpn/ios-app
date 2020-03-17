//
//  MapMarkerView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class MapMarkerView: UIView {
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.center().width(187).height(187)
    }
    
}
