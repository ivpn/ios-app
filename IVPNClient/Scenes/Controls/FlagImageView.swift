//
//  FlagImageView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

class FlagImageView: UIImageView {
    
    override func awakeFromNib() {
        if let accessibilityIdentifier = image?.accessibilityIdentifier {
            if accessibilityIdentifier == "icon-fastest-server" { return }
        }
        
        layer.cornerRadius = 2.0
        layer.shadowRadius = 0.5
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.label.cgColor
        } else {
            layer.shadowColor = UIColor.black.cgColor
        }
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.3
        backgroundColor = UIColor.clear
    }
    
}
