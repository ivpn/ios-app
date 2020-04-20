//
//  SelectPlanViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class SelectPlanViewController: UITableViewController {
    
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
            case .content?:
                spinner.stopAnimating()
            case .error?:
                spinner.stopAnimating()
            case .none:
                break
            }
            
            tableView.reloadData()
        }
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        setupLayout()
        displayMode = .loading
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProducts()
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
    
    private func setupLayout() {
        spinner.bb.center()
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
                self.displayMode = .content
            }
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension SelectPlanViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard displayMode == .content else {
            return 0
        }
        
        return tableView.rowHeight
    }
    
}

extension SelectPlanViewController {
    
    enum DisplayMode {
        case loading
        case content
        case error
    }
    
}
