//
//  SubscriptionViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 11/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit
import Bamboo
import JGProgressHUD
import ActiveLabel
import SwiftyStoreKit

class SubscriptionViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var standardProtocolsLabel: UILabel!
    @IBOutlet weak var standardDevicesLabel: UILabel!
    @IBOutlet weak var proProtocolsLabel: UILabel!
    @IBOutlet weak var proDevicesLabel: UILabel!
    @IBOutlet weak var proMultihopLabel: UILabel!
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var yearlyButton: UIButton!
    @IBOutlet weak var monthlyButtonBackground: UIView!
    @IBOutlet weak var yearlyButtonBackground: UIView!
    @IBOutlet weak var standardSubscriptionView: UIView!
    @IBOutlet weak var proSubscriptionView: UIView!
    @IBOutlet weak var noteLabel: ActiveLabel!
    @IBOutlet weak var standardPriceLabel: UILabel!
    @IBOutlet weak var proPriceLabel: UILabel!
    
    // MARK: - Properties -
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }()
    
    var displayMode: DisplayMode! {
        didSet {
            switch displayMode {
            case .loading?:
                spinner.startAnimating()
                standardSubscriptionView.isHidden = true
                proSubscriptionView.isHidden = true
                noteLabel.isHidden = true
            case .content?:
                spinner.stopAnimating()
                standardSubscriptionView.isHidden = false
                proSubscriptionView.isHidden = false
                noteLabel.isHidden = false
            case .error?:
                spinner.stopAnimating()
                standardSubscriptionView.isHidden = true
                proSubscriptionView.isHidden = true
                noteLabel.isHidden = true
            case .none:
                break
            }
        }
    }
    
    var standardSubscription: SubscriptionType = .standard(.yearly) {
        didSet {
            self.updateSubscriptions()
        }
    }
    
    var proSubscription: SubscriptionType = .pro(.yearly) {
        didSet {
            self.updateSubscriptions()
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
    
    @IBAction func close(_ sender: Any) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name.SubscriptionDismissed, object: nil)
        }
    }
    
    @IBAction func toggleMonthly(_ sender: UIButton) {
        guard self.displayMode == .content else { return }
        
        monthlyButton.setTitleColor(.white, for: .normal)
        monthlyButtonBackground.backgroundColor = UIColor.init(named: Theme.Key.ivpnBlue)
        yearlyButton.setTitleColor(UIColor.init(named: Theme.Key.ivpnLabelTertiary), for: .normal)
        yearlyButtonBackground.backgroundColor = .clear
        
        standardSubscription = .standard(.monthly)
        proSubscription = .pro(.monthly)
    }
    
    @IBAction func toggleYearly(_ sender: UIButton) {
        guard self.displayMode == .content else { return }
        
        yearlyButton.setTitleColor(.white, for: .normal)
        yearlyButtonBackground.backgroundColor = UIColor.init(named: Theme.Key.ivpnBlue)
        monthlyButton.setTitleColor(UIColor.init(named: Theme.Key.ivpnLabelTertiary), for: .normal)
        monthlyButtonBackground.backgroundColor = .clear
        
        standardSubscription = .standard(.yearly)
        proSubscription = .pro(.yearly)
    }
    
    @IBAction func purchaseStandard(_ sender: UIButton) {
        purchaseProduct(identifier: standardSubscription.getProductId())
    }
    
    @IBAction func purchasePro(_ sender: UIButton) {
        purchaseProduct(identifier: proSubscription.getProductId())
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "subscriptionScreen"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProducts()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        view.addSubview(spinner)
        
        standardProtocolsLabel.icon(text: standardProtocolsLabel.text!, imageName: "icon-check-grey-small", alignment: .left)
        standardDevicesLabel.icon(text: standardDevicesLabel.text!, imageName: "icon-check-grey-small", alignment: .left)
        proProtocolsLabel.icon(text: proProtocolsLabel.text!, imageName: "icon-check-grey-small", alignment: .left)
        proDevicesLabel.icon(text: proDevicesLabel.text!, imageName: "icon-check-grey-small", alignment: .left)
        proMultihopLabel.icon(text: proMultihopLabel.text!, imageName: "icon-check-grey-small", alignment: .left)
        
        displayMode = .loading
        setupFooter()
        setupLayout()
    }
    
    private func setupLayout() {
        spinner.bb.center()
    }
    
    private func setupFooter() {
        let customType = ActiveType.custom(pattern: "Terms Of Service|Privacy Policy")
        noteLabel.enabledTypes = [customType]
        noteLabel.text = noteLabel.text
        noteLabel.lineSpacing = 3
        noteLabel.customColor[customType] = UIColor.init(named: Theme.Key.ivpnBlue)
        noteLabel.handleCustomTap(for: customType) { element in
            if element == "Terms Of Service" {
                self.openTermsOfService()
            }
            if element == "Privacy Policy" {
                self.openPrivacyPolicy()
            }
        }
    }
    
    private func updateSubscriptions() {
        updateSubscription(type: standardSubscription, label: standardPriceLabel)
        updateSubscription(type: proSubscription, label: proPriceLabel)
    }
    
    private func updateSubscription(type: SubscriptionType, label: UILabel) {
        guard !IAPManager.shared.products.isEmpty else { return }
        let identifier = type.getProductId()
        guard let product = IAPManager.shared.getProduct(identifier: identifier) else { return }
        let price = IAPManager.shared.productPrice(product: product)
        let duration = type.getDurationLabel()
        label.text = "\(price)/\(duration)"
    }
    
    private func fetchProducts() {
        IAPManager.shared.fetchProducts { [weak self] products, error in
            guard let self = self else { return }
            
            if error != nil {
                self.showAlert(title: "iTunes Store error", message: "Cannot connect to iTunes Store")
                self.displayMode = .error
                return
            }
            
            if products != nil {
                self.updateSubscriptions()
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

extension SubscriptionViewController {
    
    enum DisplayMode {
        case loading
        case content
        case error
    }
    
}
