//
//  DisclosureIndicator.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

class DisclosureIndicator: UIButton {
    
    override func awakeFromNib() {
        let disclosure = UITableViewCell()
        disclosure.frame = bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        addSubview(disclosure)
    }

}
