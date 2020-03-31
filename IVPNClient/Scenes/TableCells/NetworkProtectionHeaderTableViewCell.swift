//
//  NetworkProtectionHeaderTableViewCell.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 21/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

protocol NetworkProtectionHeaderTableViewCellDelegate: class {
    func toggle(isOn: Bool)
}

class NetworkProtectionHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    weak var delegate: NetworkProtectionHeaderTableViewCellDelegate?
    
    @IBAction func toggle(_ sender: UISwitch) {
        delegate?.toggle(isOn: sender.isOn)
    }
    
    override func awakeFromNib() {
        if UserDefaults.shared.networkProtectionEnabled {
            toggleSwitch.setOn(true, animated: false)
        }
    }
    
}
