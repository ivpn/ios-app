//
//  SelectPlanView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 16/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class SelectPlanView: UITableView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        messageLabel.sizeToFit()
    }
    
}
