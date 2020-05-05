//
//  PaymentViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Bamboo

class PaymentViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var payButton: UIButton?
    
    // MARK: - Properties -
    
    var service = Service(type: .standard, duration: .year) {
        didSet {
            if extendingService {
                payButton?.set(title: "Pay", subtitle: "(Will be active until \(service.willBeActiveUntil))")
            }
        }
    }
    
    var extendingService = false
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }()
    
    lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(fetchProducts), for: .touchUpInside)
        button.setTitle("Retry", for: .normal)
        button.sizeToFit()
        button.isHidden = true
        return button
    }()
    
    var displayMode: DisplayMode = .content {
        didSet {
            switch displayMode {
            case .loading:
                spinner.startAnimating()
                tableView.separatorStyle = .none
                retryButton.isHidden = true
                payButton?.isHidden = true
            case .content:
                spinner.stopAnimating()
                tableView.separatorStyle = .singleLine
                tableView.reloadData()
                retryButton.isHidden = true
                payButton?.isHidden = false
            case .error:
                spinner.stopAnimating()
                tableView.separatorStyle = .none
                retryButton.isHidden = false
                payButton?.isHidden = true
            }
            
            tableView.reloadData()
        }
    }
    
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
        purchaseProduct(identifier: service.productId)
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if extendingService {
            fetchProducts()
        }
    }
    
    // MARK: - Private methods -
    
    private func initNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if extendingService {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissViewController))
            navigationItem.rightBarButtonItem = nil
        } else {
            let button = UIButton(type: .system)
            button.setImage(UIImage(named: "icon-arrow-left"), for: .normal)
            button.sizeToFit()
            button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        
        if extendingService {
            displayMode = .loading
            tableView.separatorStyle = .none
            view.addSubview(spinner)
            view.addSubview(retryButton)
            spinner.bb.centerX().centerY(-80)
            retryButton.bb.centerX().centerY(-80)
            payButton?.set(title: "Pay", subtitle: "(Will be active until \(service.willBeActiveUntil))")
        }
    }
    
    @objc private func fetchProducts() {
        displayMode = .loading
        
        IAPManager.shared.fetchProducts { [weak self] products, error in
            guard let self = self else { return }
            
            if error != nil {
                self.showAlert(title: "iTunes Store error", message: "Cannot connect to iTunes Store")
                self.displayMode = .error
                return
            }
            
            if products != nil {
                self.displayMode = .content
            }
        }
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

// MARK: - UITableViewDataSource -

extension PaymentViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.collection.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTitleTableViewCell", for: indexPath) as! ServiceTitleTableViewCell
            cell.service = service.collection[0]
            cell.changeButton.isHidden = extendingService
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableViewCell", for: indexPath) as! ServiceTableViewCell
        cell.service = service.collection[indexPath.row - 1]
        cell.checked = service.collection[indexPath.row - 1] == service
        cell.selectionStyle = .default
        return cell
    }
    
}

// MARK: - UITableViewDelegate -

extension PaymentViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard displayMode == .content else {
            return 0
        }
        
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        service = service.collection[indexPath.row - 1]
        tableView.reloadData()
    }
    
}

extension PaymentViewController {
    
    enum DisplayMode {
        case loading
        case content
        case error
    }
    
}
