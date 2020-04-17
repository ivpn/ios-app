//
//  PaymentComponentView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class PaymentComponentView: UIView {
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bb.left(4)
        }
    }
    
}
