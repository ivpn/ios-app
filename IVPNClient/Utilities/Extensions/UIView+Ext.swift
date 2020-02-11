//
//  UIView+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 09/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

extension UIView {
    
    func bindFrameToSuperviewBounds(top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        guard let superview = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing).isActive = true
    }
    
}
