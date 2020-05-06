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
    @IBOutlet weak var standardPriceLabel: UILabel!
    @IBOutlet weak var proPriceLabel: UILabel!
    @IBOutlet weak var standardButton: UIButton!
    @IBOutlet weak var proButton: UIButton!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupLayout()
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
