//
//  PaymentViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class PaymentViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var paymentView: PaymentView!
    
    // MARK: - Properties -
    
    var collection: [SubscriptionType] = []
    
    // MARK: - @IBActions -
    
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        paymentView.updatePrices(collection: collection)
    }
    
    // MARK: - Private methods -
    
    private func initNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon-arrow-left"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
}

// MARK: - UITableViewDelegate -

extension PaymentViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            paymentView.period = .week
        case 2:
            paymentView.period = .month
        case 3:
            paymentView.period = .year
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
