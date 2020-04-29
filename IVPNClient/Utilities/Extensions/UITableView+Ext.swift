//
//  UITableView+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 03/01/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

extension UITableView {
    
    open override func awakeFromNib() {
        backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        separatorColor = UIColor.init(named: Theme.ivpnGray5)
    }
    
}
