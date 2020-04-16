//
//  PaymentViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
    }
    
    // MARK: - Private methods -
    
    private func initNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon-arrow-left"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func backButtonPressed(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}
