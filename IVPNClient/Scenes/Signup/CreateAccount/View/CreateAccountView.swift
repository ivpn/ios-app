//
//  CreateAccountView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 16/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class CreateAccountView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountView: UIView!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupView()
        setupLayout()
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        accountLabel.text = KeyChain.tempUsername ?? ""
    }
    
    private func setupLayout() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            accountView.bb.left(21).right(-21)
        }
        
    }
    
}
