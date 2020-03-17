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
    
    override func awakeFromNib() {
        setupConstraints()
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bb.left(375).top(0).right(0).bottom(0)
        } else {
            bb.left(0).top(0).right(0).bottom(196)
        }
    }
    
}
