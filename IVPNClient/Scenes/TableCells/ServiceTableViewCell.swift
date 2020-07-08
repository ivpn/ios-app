//
//  ServiceTableViewCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-27.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
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
