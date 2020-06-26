//
//  CreateAccountViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import JGProgressHUD

class CreateAccountViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var createAccountView: CreateAccountView!
    
    // MARK: - Properties -
    
    private let hud = JGProgressHUD(style: .dark)
    
    // MARK: - @IBActions -
    
    @IBAction func copyAccountID(_ sender: UIButton) {
        guard let text = createAccountView.accountLabel.text else { return }
        UIPasteboard.general.string = text
        showFlashNotification(message: "Account ID copied to clipboard", presentInView: (navigationController?.view)!)
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
}
