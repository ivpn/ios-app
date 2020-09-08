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
        formattedString.bold("What information do we collect and store when you sign up for our service?\n\n", fontSize: 14)
        formattedString.regular("To ensure your privacy we collect only your email address to facilitate password resets and send important security updates relating to our service. You are free to use any email address. We do not request or store your name, physical addresses, phone number or any other personal information.\n\n", fontSize: 14)
        formattedString.bold("What information is logged when customers connect to our network?\n\n", fontSize: 14)
        formattedString.regular("We do not store any connection logs whatsoever. In addition we do not log bandwidth usage, session data or requests to our DNS servers.\n\n", fontSize: 14)
        formattedString.bold("Do you collect or store any usage/stats information relating to an account?\n\n", fontSize: 14)
        formattedString.regular("IVPN purposefully does not log any usage data associated with an account as we provide an unlimited and unrestricted quota free service.", fontSize: 14)
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
