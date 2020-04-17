//
//  PaymentView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class PaymentView: UITableView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var weekCellImage: UIImageView!
    @IBOutlet weak var monthCellImage: UIImageView!
    @IBOutlet weak var yearCellImage: UIImageView!
    
    // MARK: - Properties -
    
    var period: PaymentPeriod = .month {
        didSet {
            switch period {
            case .week:
                break
            case .month:
                break
            case .year:
                break
            }
        }
    }
    
}
