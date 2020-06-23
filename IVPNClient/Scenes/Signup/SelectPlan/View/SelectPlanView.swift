//
//  SelectPlanView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 16/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class SelectPlanView: UITableView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var standardView: UIStackView!
    @IBOutlet weak var proView: UIStackView!
    @IBOutlet weak var standardWeekPriceLabel: UILabel!
    @IBOutlet weak var standardMonthPriceLabel: UILabel!
    @IBOutlet weak var standardYearPriceLabel: UILabel!
    @IBOutlet weak var proWeekPriceLabel: UILabel!
    @IBOutlet weak var proMonthPriceLabel: UILabel!
    @IBOutlet weak var proYearPriceLabel: UILabel!
    @IBOutlet weak var standardButton: UIButton!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var standardCurrentLabel: UILabel!
    @IBOutlet weak var proCurrentLabel: UILabel!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    // MARK: - Methods -
    
    func setupView(service: Service) {
        switch service.type {
        case .standard:
            standardButton.backgroundColor = UIColor.init(named: Theme.ivpnBlue)
            standardButton.set(title: "Select", subtitle: "(Will be active until \(service.willBeActiveUntil))")
            proButton.backgroundColor = UIColor.init(named: Theme.ivpnGray5)
            proButton.set(title: "Select", subtitle: "")
            standardCurrentLabel.isHidden = false
            proCurrentLabel.isHidden = true
        case .pro:
            standardButton.backgroundColor = UIColor.init(named: Theme.ivpnGray5)
            standardButton.set(title: "Select", subtitle: "")
            proButton.backgroundColor = UIColor.init(named: Theme.ivpnBlue)
            proButton.set(title: "Select", subtitle: "(Will be active until \(service.willBeActiveUntil))")
            standardCurrentLabel.isHidden = true
            proCurrentLabel.isHidden = false
        }
    }
    
    // MARK: - Private methods -
    
    private func setupLayout() {
        messageLabel.sizeToFit()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            messageLabel.bb.left(21).right(-21)
            standardView.bb.left(21).right(-21)
            proView.bb.left(21).right(-21)
        }
        
    }
    
}
