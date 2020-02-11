//
//  TermsOfServiceViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 02/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
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
        textView.textColor = UIColor.init(named: Theme.Key.ivpnLabelPrimary)
        
        let customType = ActiveType.custom(pattern: "Privacy Policy")
        noteLabel.enabledTypes = [customType]
        noteLabel.text = noteLabel.text
        noteLabel.customColor[customType] = UIColor.init(named: Theme.Key.ivpnBlue)
        noteLabel.handleCustomTap(for: customType) { _ in
            self.openPrivacyPolicy()
        }
    }

}
