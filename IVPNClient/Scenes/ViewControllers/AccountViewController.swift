//
//  AccountViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 23/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
    }
    
    // MARK: - Methods -
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissViewController(_:)))
        }
    }
    
}
