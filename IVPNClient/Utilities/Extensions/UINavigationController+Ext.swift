//
//  UINavigationController+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 05/12/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
}
