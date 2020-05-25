//
//  ScannerView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 08/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class ScannerView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var qrView: UIView!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabel()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
    }
    
    private func setupLabel() {
        // textLabel.textWithIcon(prefix: "Find your QR code under the User Profile menu", image: UIImage.init(named: "icon-user"), sufix: "on any other device with IVPN installed and scan it")
    }
    
}
