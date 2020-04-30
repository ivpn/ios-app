//
//  ConnectionInfoBoxView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 27/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class ConnectionInfoBoxView: UIView {
    
    override func layoutSubviews() {
        layer.shadowColor = UIColor.init(named: Theme.ivpnGray15)!.cgColor
    }
    
}
