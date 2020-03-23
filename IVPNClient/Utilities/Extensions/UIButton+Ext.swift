//
//  UIButton+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 23/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setupIcon(imageName: String) {
        setImage(UIImage.init(named: imageName), for: .normal)
        backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        layer.cornerRadius = 21
        clipsToBounds = true
    }
    
}
