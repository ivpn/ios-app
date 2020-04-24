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
    
    // MARK: - Properties -
    
    var viewModel: ProofsViewModel! {
        didSet {
            
        }
    }
    
    private lazy var iPadConstraints = bb.left(375).top(0).constraints.deactivate()
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupConstraints()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape {
            iPadConstraints.activate()
        } else {
            iPadConstraints.deactivate()
        }
    }
    
}
