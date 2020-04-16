//
//  PlanLabel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 16/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class PlanLabel: UILabel {
    
    override func awakeFromNib() {
        icon(text: text!, imageName: "icon-check-grey-small", alignment: .left)
    }
    
}
