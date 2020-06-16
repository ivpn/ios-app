//
//  AccountView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 30/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class AccountView: UITableView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var accountIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var activeUntilLabel: UILabel!
    @IBOutlet weak var logOutActionButton: UIButton!
    
    // MARK: - Methods -
    
    func setupView(viewModel: AccountViewModel) {
        accountIdLabel.text = viewModel.accountId
        statusLabel.text = viewModel.statusText
        statusLabel.backgroundColor = viewModel.statusColor
        subscriptionLabel.text = viewModel.subscriptionText
        activeUntilLabel.text = viewModel.activeUntilText
        logOutActionButton.setTitle(viewModel.logOutActionText, for: .normal)
    }
    
    func initQRCode(viewModel: AccountViewModel) {
        qrCodeImage.image = UIImage.generateQRCode(from: viewModel.accountId)
    }
    
}
