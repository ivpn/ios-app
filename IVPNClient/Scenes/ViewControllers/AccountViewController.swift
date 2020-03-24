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
    @IBOutlet weak var accountIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var billingCycleLabel: UILabel!
    @IBOutlet weak var nextBillingLabel: UILabel!
    @IBOutlet weak var recurringAmountLabel: UILabel!
    @IBOutlet weak var logOutActionButton: UIButton!
    @IBOutlet weak var subscriptionActionButton: UIButton!
    
    // MARK: - Properties -
    
    private var viewModel = AccountViewModel(serviceStatus: Application.shared.serviceStatus, authentication: Application.shared.authentication)
    
    // MARK: - @IBActions -
    
    @IBAction func logOut(_ sender: Any) {
        showActionAlert(title: "Logout", message: "Are you sure you want to log out?", action: "Log out") { _ in
            self.logOut()
        }
    }
    
    @IBAction func manageSubscription(_ sender: Any) {
        manageSubscription()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initQRCode()
    }
    
    // MARK: - Methods -
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissViewController(_:)))
        }
    }
    
    private func setupView() {
        accountIdLabel.text = viewModel.accountId
        statusLabel.text = viewModel.statusText
        statusLabel.backgroundColor = viewModel.statusColor
        subscriptionLabel.text = viewModel.subscriptionText
        billingCycleLabel.text = viewModel.billingCycleText
        nextBillingLabel.text = viewModel.nextBillingText
        recurringAmountLabel.text = viewModel.recurringAmountText
        logOutActionButton.setTitle(viewModel.logOutActionText, for: .normal)
        subscriptionActionButton.setTitle(viewModel.subscriptionActionText, for: .normal)
        subscriptionActionButton.isHidden = !viewModel.showSubscriptionAction
    }
    
    private func initQRCode() {
        qrCodeImage.image = UIImage.generateQRCode(from: viewModel.accountId)
    }
    
}

// MARK: - UITableViewDelegate -

extension AccountViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}
