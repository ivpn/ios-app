//
//  UpgradePlanViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

class UpgradePlanViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        titleLabel.text = "\(UserDefaults.shared.sessionsLimit) devices connected"
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
        if UserDefaults.shared.subscriptionPurchasedOnDevice {
            UIApplication.manageSubscription()
        } else {
            openWebPage(UserDefaults.shared.upgradeToUrl)
        }
    }

}
