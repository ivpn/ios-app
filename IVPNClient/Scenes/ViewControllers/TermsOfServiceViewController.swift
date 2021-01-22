//
//  TermsOfServiceViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-10-02.
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
import ActiveLabel

class TermsOfServiceViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var noteLabel: ActiveLabel!
    
    // MARK: - @IBActions -
    
    @IBAction func agree(_ sender: Any) {
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.hasUserConsent)
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.TermsOfServiceAgreed, object: nil)
        }
    }
    
    @IBAction func decline(_ sender: Any) {
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.hasUserConsent)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "termsOfServiceScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        let formattedString = NSMutableAttributedString()
        formattedString.bold("What data we don’t log?\n\n", fontSize: 14)
        formattedString.regular("We do not log any data relating to a user’s VPN activity (while connected or connecting to the VPN).\n\n", fontSize: 14)
        formattedString.regular("- No traffic logging\n", fontSize: 14)
        formattedString.regular("- No connection timestamp or connection duration\n", fontSize: 14)
        formattedString.regular("- No DNS request logging\n", fontSize: 14)
        formattedString.regular("- No logging of user bandwidth\n", fontSize: 14)
        formattedString.regular("- No logging of customer IP addresses\n", fontSize: 14)
        formattedString.regular("- No logging of any account activity except active total simultaneous connections\n\n", fontSize: 14)
        formattedString.bold("What data do we log on sign-up?\n\n", fontSize: 14)
        formattedString.regular("When a new account is created, we store the following data: (please note that we are using simplified field names and formatting below to highlight the relevant information)\n\n", fontSize: 14)
        formattedString.bold("ID: ", fontSize: 14)
        formattedString.regular("i-XXXX-XXXX-XXXX\n", fontSize: 14)
        formattedString.bold("Created at: ", fontSize: 14)
        formattedString.regular("2020-09-21 05:03:13\n", fontSize: 14)
        formattedString.bold("Product: ", fontSize: 14)
        formattedString.regular("IVPN Pro\n", fontSize: 14)
        formattedString.bold("Max devices: ", fontSize: 14)
        formattedString.regular("7", fontSize: 14)
        textView.attributedText = formattedString
        textView.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        
        let customType = ActiveType.custom(pattern: "Privacy Policy")
        noteLabel.enabledTypes = [customType]
        noteLabel.text = noteLabel.text
        noteLabel.customColor[customType] = UIColor.init(named: Theme.ivpnBlue)
        noteLabel.handleCustomTap(for: customType) { _ in
            self.openPrivacyPolicy()
        }
    }

}
