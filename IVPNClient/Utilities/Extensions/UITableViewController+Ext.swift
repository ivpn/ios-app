//
//  UITableViewController+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 22/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    func updateCellInset(cell: UITableViewCell, inset: Bool) {
        if inset {
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
}
