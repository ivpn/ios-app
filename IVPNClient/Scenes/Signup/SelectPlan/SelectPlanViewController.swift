//
//  SelectPlanViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 15/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo
import JGProgressHUD

class SelectPlanViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var selectPlanView: SelectPlanView?
    
    // MARK: - Properties -
    
    var changingPlan = false
    var selectingPlan = false
    var standardWeekService = Service(type: .standard, duration: .week)
    var standardMonthService = Service(type: .standard, duration: .month)
    var standardYearService = Service(type: .standard, duration: .year)
    var proWeekService = Service(type: .pro, duration: .week)
    var proMonthService = Service(type: .pro, duration: .month)
    var proYearService = Service(type: .pro, duration: .year)
    
    var service = Service(type: .standard, duration: .month) {
        didSet {
            if changingPlan {
                selectPlanView?.setupView(service: service)
            }
        }
    }
    
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
    
    var displayMode: DisplayMode = .loading {
        didSet {
            switch displayMode {
            case .loading:
                spinner.startAnimating()
                tableView.separatorStyle = .none
                retryButton.isHidden = true
            case .content:
                spinner.stopAnimating()
                tableView.separatorStyle = .singleLine
                retryButton.isHidden = true
            case .error:
                spinner.stopAnimating()
                tableView.separatorStyle = .none
                retryButton.isHidden = false
            }
            
            tableView.reloadData()
        }
    }
    
    private let hud = JGProgressHUD(style: .dark)
    private var segueStarted = false
    
    // MARK: - @IBActions -
    
    @IBAction func selectStandard(_ sender: UIButton) {
        if changingPlan {
            changePlan(type: .standard)
            return
        }
        
        guard !segueStarted else { return }
        segueStarted = true
        performSegue(withIdentifier: "selectStandardPlan", sender: nil)
    }
    
    @IBAction func selectPro(_ sender: UIButton) {
        if changingPlan {
            changePlan(type: .pro)
            return
        }
        
        guard !segueStarted else { return }
        segueStarted = true
        performSegue(withIdentifier: "selectProPlan", sender: nil)
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if displayMode == .loading {
            fetchProducts()
        }
        
        segueStarted = false
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectStandardPlan" {
            let viewController = segue.destination as! PaymentViewController
            viewController.service = Service(type: .standard, duration: .year)
        }
        
        if segue.identifier == "selectProPlan" {
            let viewController = segue.destination as! PaymentViewController
            viewController.service = Service(type: .pro, duration: .year)
        }
    }
    
    // MARK: - Private methods -
    
    private func initNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if changingPlan {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController))
            navigationItem.rightBarButtonItem = nil
        } else if selectingPlan {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissViewController))
        } else {
            let button = UIButton(type: .system)
            button.setImage(UIImage(named: "icon-arrow-left"), for: .normal)
            button.sizeToFit()
            button.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    @objc private func backButtonPressed(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupView() {
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        tableView.separatorStyle = .none
        view.addSubview(spinner)
        view.addSubview(retryButton)
        spinner.bb.centerX().centerY(-80)
        retryButton.bb.centerX().centerY(-80)
        
        if changingPlan {
            selectPlanView?.setupView(service: service)
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
                self.updateSubscriptions()
                self.displayMode = .content
            }
        }
    }
    
    private func changePlan(type: ServiceType) {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Changing plan..."
        hud.show(in: (navigationController?.view)!)
        
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        ApiService.shared.request(request) { [weak self] (result: Result<GeoLookup>) in
            guard let self = self else { return }
            
            self.hud.dismiss()
            
            switch result {
            case .success:
                self.service = Service(type: type, duration: .month)
            case .failure:
                break
            }
        }
    }
    
    private func updateSubscriptions() {
        selectPlanView?.standardWeekPriceLabel.text = "\(standardWeekService.priceText) / \(standardWeekService.durationText)"
        selectPlanView?.standardMonthPriceLabel.text = "\(standardMonthService.priceText) / \(standardMonthService.durationText)"
        selectPlanView?.standardYearPriceLabel.text = "\(standardYearService.priceText) / \(standardYearService.durationText)"
        selectPlanView?.proWeekPriceLabel.text = "\(proWeekService.priceText) / \(proWeekService.durationText)"
        selectPlanView?.proMonthPriceLabel.text = "\(proMonthService.priceText) / \(proMonthService.durationText)"
        selectPlanView?.proYearPriceLabel.text = "\(proYearService.priceText) / \(proYearService.durationText)"
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
