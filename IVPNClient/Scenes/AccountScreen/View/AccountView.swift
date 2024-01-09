//
//  AccountView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-30.
//  Copyright (c) 2023 IVPN Limited.
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

class AccountView: UITableView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var accountIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var activeUntilLabel: UILabel!
    @IBOutlet weak var logOutActionButton: UIButton!
    @IBOutlet weak var activeUntilCell: UITableViewCell!
    @IBOutlet weak var deviceNameTitle: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var header: UIView!
    
    // MARK: - Properties -
    
    private var serviceType = ServiceType.getType(currentPlan: Application.shared.serviceStatus.currentPlan)
    
    // MARK: - Methods -
    
    func setupView(viewModel: AccountViewModel) {
        accountIdLabel.text = viewModel.accountId
        statusLabel.text = viewModel.statusText
        statusLabel.backgroundColor = viewModel.statusColor
        subscriptionLabel.text = viewModel.subscriptionText
        activeUntilLabel.text = viewModel.activeUntilText
        activeUntilCell.isHidden = Application.shared.serviceStatus.isLegacyAccount()
        deviceName.text = viewModel.deviceName
        deviceNameTitle.isHidden = !viewModel.showDeviceName
        deviceName.isHidden = !viewModel.showDeviceName
        let headerHeight = viewModel.showDeviceName ? 270 : 210
        header.frame = CGRect(x: 0, y: 0, width: Int(header.frame.width), height: headerHeight)
    }
    
    func initQRCode(viewModel: AccountViewModel) {
        qrCodeImage.image = UIImage.generateQRCode(from: viewModel.accountId)
    }
    
}
