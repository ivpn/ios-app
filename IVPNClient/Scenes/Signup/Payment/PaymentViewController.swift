//
//  PaymentViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-15.
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
import SwiftyStoreKit
import SnapKit
import JGProgressHUD

class PaymentViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var descriptionLabel: UILabel?
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
    
    private let hud = JGProgressHUD(style: .dark)
    
    private lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.delegate = self
        return sessionManager
    }()
    
    // MARK: - @IBActions -
    
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        purchaseProduct(identifier: service.productId)
    }
    
    @IBAction func close() {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.SubscriptionDismissed, object: nil)
        }
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "subscriptionScreen"
        initNavigation()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if extendingService {
            if Application.shared.authentication.isLoggedIn && !Application.shared.serviceStatus.isNewStyleAccount() {
                let serviceType: ServiceType = Application.shared.serviceStatus.currentPlan == "IVPN Pro" ? .pro : .standard
                service = Service(type: serviceType, duration: .year)
            }
            
            fetchProducts()
        }
    }
    
    // MARK: - Private methods -
    
    private func initNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if extendingService {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
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
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        view.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        payButton?.set(title: "Pay", subtitle: "")
        
        if extendingService {
            displayMode = .loading
            tableView.separatorStyle = .none
            view.addSubview(spinner)
            view.addSubview(retryButton)
            
            spinner.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-80)
            }
            
            retryButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-80)
            }
            
            descriptionLabel?.text = "Add more time to your IVPN account"
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
        guard deviceCanMakePurchases() else { return }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Processing payment..."
        hud.show(in: (navigationController?.view)!)
        
        IAPManager.shared.purchaseProduct(identifier: identifier) { [weak self] purchase, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showErrorAlert(title: "Error", message: error)
                self.hud.dismiss()
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
            
            self.hud.dismiss()
            
            if let error = error {
                self.showErrorAlert(title: "Error", message: error.message) { _ in
                    if error.status == 400 {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            if let serviceStatus = serviceStatus {
                self.showSubscriptionActivatedAlert(serviceStatus: serviceStatus) {
                    if KeyChain.sessionToken == nil {
                        KeyChain.username = KeyChain.tempUsername
                        KeyChain.tempUsername = nil
                        self.sessionManager.createSession()
                        return
                    }
                    
                    self.navigationController?.dismiss(animated: true) {
                        NotificationCenter.default.post(name: Notification.Name.SubscriptionActivated, object: nil)
                    }
                }
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

// MARK: - SessionManagerDelegate -

extension PaymentViewController {
    
    override func createSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func createSessionSuccess() {
        hud.dismiss()
        
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.SubscriptionActivated, object: nil)
        }
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        showErrorAlert(title: "Error", message: message)
    }
    
}

extension PaymentViewController {
    
    enum DisplayMode {
        case loading
        case content
        case error
    }
    
}
