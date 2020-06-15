//
//  ServiceTableViewCell.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 27/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var service: Service! {
        didSet {
            durationLabel.text = service.durationText
            priceLabel.text = service.priceText
            
            if let discountText = service.discountText {
                discountLabel.text = discountText
                discountLabel.isHidden = false
            } else {
                discountLabel.isHidden = true
            }
        }
    }
    
    var checked: Bool = false {
        didSet {
            checkImage.image = checked ? UIImage.init(named: "icon-check") : nil
        }
    }
    
}
