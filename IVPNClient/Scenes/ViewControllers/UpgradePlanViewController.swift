//
//  UpgradePlanViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-10-15.
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

class UpgradePlanViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var illustrationHeightConstraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        titleLabel.text = "\(UserDefaults.shared.sessionsLimit) devices connected"
        
        if UIDevice.screenHeightSmallerThan(device: .iPhones66s78) {
            illustrationHeightConstraint.constant = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    // MARK: - @IBActions -
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func retry(_ sender: Any) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.NewSession, object: nil)
        }
    }
    
    @IBAction func forceRetry(_ sender: Any) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.ForceNewSession, object: nil)
        }
    }
    
    @IBAction func upgradePlan(_ sender: Any) {
        openWebPage(UserDefaults.shared.upgradeToUrl)
    }

}
