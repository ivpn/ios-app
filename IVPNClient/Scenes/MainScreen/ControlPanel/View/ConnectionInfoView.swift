//
//  ConnectionInfoView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-04-14.
//  Copyright (c) 2021 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

class ConnectionInfoView: UIStackView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var ipAddressLoader: UIActivityIndicatorView!
    @IBOutlet weak var ipAddressErrorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLoader: UIActivityIndicatorView!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var providerPlaceholderLabel: UILabel!
    @IBOutlet weak var providerLoader: UIActivityIndicatorView!
    @IBOutlet weak var providerErrorLabel: UILabel!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setup()
    }
    
    // MARK: - Methods -
    
    func setup() {
        ipAddressErrorLabel.icon(text: "Not available", imageName: "icon-wifi-off", alignment: .left)
        locationErrorLabel.icon(text: "Not available", imageName: "icon-wifi-off", alignment: .left)
        providerErrorLabel.icon(text: "Not available", imageName: "icon-wifi-off", alignment: .left)
        
        if UIDevice.screenHeightSmallerThan(device: .iPhones66s78) {
            providerPlaceholderLabel.text = "ISP"
        }
    }
    
    func update(ipv4ViewModel: ProofsViewModel, ipv6ViewModel: ProofsViewModel, addressType: AddressType) {
        let viewModel = addressType == .IPv6 ? ipv6ViewModel : ipv4ViewModel
        ipAddressLabel.text = viewModel.ipAddress
        locationLabel.text = viewModel.location
        providerLabel.text = viewModel.provider
        
        switch viewModel.displayMode {
        case .loading:
            ipAddressLabel.isHidden = true
            ipAddressLoader.startAnimating()
            ipAddressErrorLabel.isHidden = true
            locationLabel.isHidden = true
            locationLoader.startAnimating()
            locationErrorLabel.isHidden = true
            providerLabel.isHidden = true
            providerLoader.startAnimating()
            providerErrorLabel.isHidden = true
        case .content:
            ipAddressLabel.isHidden = false
            ipAddressLoader.stopAnimating()
            ipAddressErrorLabel.isHidden = true
            locationLabel.isHidden = false
            locationLoader.stopAnimating()
            locationErrorLabel.isHidden = true
            providerLabel.isHidden = false
            providerLoader.stopAnimating()
            providerErrorLabel.isHidden = true
        case .error:
            ipAddressLabel.isHidden = true
            ipAddressLoader.stopAnimating()
            ipAddressErrorLabel.isHidden = false
            locationLabel.isHidden = true
            locationLoader.stopAnimating()
            locationErrorLabel.isHidden = false
            providerLabel.isHidden = true
            providerLoader.stopAnimating()
            providerErrorLabel.isHidden = false
        case .none:
            break
        }
    }
    
}
