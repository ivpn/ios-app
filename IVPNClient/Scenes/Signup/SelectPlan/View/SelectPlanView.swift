//
//  SelectPlanView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-16.
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
import SnapKit

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
            messageLabel.snp.makeConstraints { make in
                make.left.equalTo(21)
                make.right.equalTo(-21)
            }
            
            standardView.snp.makeConstraints { make in
                make.left.equalTo(21)
                make.right.equalTo(-21)
            }
            
            proView.snp.makeConstraints { make in
                make.left.equalTo(21)
                make.right.equalTo(-21)
            }
        }
        
    }
    
}
