//
//  PaymentViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class PaymentViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var paymentView: PaymentView!
    
    // MARK: - Properties -
    
    var collection: [SubscriptionType] = []
    var selectedSubscription: SubscriptionType = .standard(.yearly)
    
    var deviceCanMakePurchases: Bool {
        guard IAPManager.shared.canMakePurchases else {
            showAlert(title: "Error", message: "In-App Purchases are not available on your device.")
            return false
        }
        
        return true
    }
    
    // MARK: - @IBActions -
    
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        purchaseProduct(identifier: selectedSubscription.getProductId())
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        selectedSubscription = collection.last ?? .standard(.yearly)
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
    
    private func purchaseProduct(identifier: String) {
        guard deviceCanMakePurchases else { return }
        
        ProgressIndicator.shared.showIn(view: view)
        
        IAPManager.shared.purchaseProduct(identifier: identifier) { [weak self] purchase, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showErrorAlert(title: "Error", message: error)
                ProgressIndicator.shared.hide()
                return
            }
            
            if let purchase = purchase {
                self.completePurchase(purchase: purchase)
            }
        }
    }
    
    private func completePurchase(purchase: PurchaseDetails) {
        IAPManager.shared.completePurchase(purchase: purchase) { [weak self] serviceStatus, error in
            guard let self = self else { return }
            
            ProgressIndicator.shared.hide()
            
            if let error = error {
                self.showErrorAlert(title: "Error", message: error.message) { _ in
                    if error.status == 400 {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            if let serviceStatus = serviceStatus {
                self.showSubscriptionActivatedAlert(serviceStatus: serviceStatus)
            }
        }
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
            selectedSubscription = collection[0]
        case 3:
            paymentView.period = .year
            selectedSubscription = collection[1]
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
