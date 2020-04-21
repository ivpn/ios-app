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
    @IBOutlet weak var monthPriceLabel: UILabel!
    @IBOutlet weak var yearPriceLabel: UILabel!
    
    // MARK: - Properties -
    
    var period: PaymentPeriod = .year {
        didSet {
            switch period {
            case .week:
                weekCellImage.image = UIImage.init(named: "icon-check")
                monthCellImage.image = nil
                yearCellImage.image = nil
            case .month:
                weekCellImage.image = nil
                monthCellImage.image = UIImage.init(named: "icon-check")
                yearCellImage.image = nil
            case .year:
                weekCellImage.image = nil
                monthCellImage.image = nil
                yearCellImage.image = UIImage.init(named: "icon-check")
            }
        }
    }
    
    // MARK: - Methods -
    
    func updatePrices(collection: [SubscriptionType]) {
        for subscriptionType in collection {
            switch subscriptionType.getDurationLabel() {
            case "month":
                monthPriceLabel.text = IAPManager.shared.productPrice(subscriptionType: subscriptionType)
            case "year":
                yearPriceLabel.text = IAPManager.shared.productPrice(subscriptionType: subscriptionType)
            default:
                break
            }
        }
    }
    
}
