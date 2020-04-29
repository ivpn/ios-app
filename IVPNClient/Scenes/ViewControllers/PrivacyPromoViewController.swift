//
//  PrivacyPromoViewController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 12/20/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class PrivacyPromoViewController: UIViewController {

    @IBOutlet weak var privacyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formattedString = NSMutableAttributedString()
        formattedString.normal("Get ")
        formattedString.bold("serious")
        formattedString.normal(" privacy\nprotection and peace\nof mind")
        
        privacyLabel.attributedText = formattedString
        privacyLabel.textColor = UIColor.init(named: Theme.ivpnLabelSecondary)
    }

}
