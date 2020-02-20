//
//  MapScrollView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 20/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class MapScrollView: UIScrollView {
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupConstraints()
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bb.left(375).top(0)
        }
    }
    
}
