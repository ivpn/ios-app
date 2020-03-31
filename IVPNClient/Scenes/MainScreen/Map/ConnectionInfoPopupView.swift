//
//  ConnectionInfoPopupView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class ConnectionInfoPopupView: UIView {
    
    // MARK: - View components -
    
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        container.layer.cornerRadius = 8
        container.clipsToBounds = false
        return container
    }()
    
    lazy var arrow: UIView = {
        let arrow = UIView(frame: .zero)
        arrow.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        arrow.rotate(angle: 45)
        return arrow
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            spinner.style = .medium
        } else {
            spinner.style = .gray
        }
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }()
    
    lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.text = "Please check your internet connection and try again."
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
        errorLabel.numberOfLines = 0
        return errorLabel
    }()
    
    lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
        return statusLabel
    }()
    
    lazy var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabelPrimary)
        return locationLabel
    }()
    
    var actionButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setImage(UIImage.init(named: "icon-info-2"), for: .normal)
        actionButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        return actionButton
    }()
    
    // MARK: - Properties -
    
    var viewModel: ProofsViewModel! {
        didSet {
            statusLabel.text = vpnStatusViewModel.popupStatusText
            locationLabel.iconMirror(text: "\(viewModel.city), \(viewModel.countryCode)", image: UIImage(named: viewModel.imageNameForCountryCode), alignment: .left)
            
            if displayMode == .loading {
                displayMode = .content
            }
        }
    }
    
    var vpnStatusViewModel = VPNStatusViewModel(status: .invalid)
    
    var displayMode: DisplayMode = .hidden {
        didSet {
            switch displayMode {
            case .hidden:
                UIView.animate(withDuration: 0.15, animations: { self.alpha = 0 }) { _ in
                    self.isHidden = true
                }
            case .loading:
                spinner.startAnimating()
                container.isHidden = true
                errorLabel.isHidden = true
                isHidden = false
                UIView.animate(withDuration: 0.15, animations: { self.alpha = 1 })
            case .content:
                spinner.stopAnimating()
                container.isHidden = false
                errorLabel.isHidden = true
                isHidden = false
                UIView.animate(withDuration: 0.15, animations: { self.alpha = 1 })
            case .error:
                spinner.stopAnimating()
                container.isHidden = true
                errorLabel.isHidden = false
                isHidden = false
                UIView.animate(withDuration: 0.15, animations: { self.alpha = 1 })
            }
        }
    }
    
    // MARK: - View lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func updateConstraints() {
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func show() {
        displayMode = .loading
        fetchData()
    }
    
    func hide() {
        displayMode = .hidden
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.size(width: 270, height: 69).centerX().bottom(-5)
    }
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        layer.cornerRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
        isHidden = true
        alpha = 0
        
        container.addSubview(statusLabel)
        container.addSubview(locationLabel)
        container.addSubview(actionButton)
        addSubview(arrow)
        addSubview(container)
        addSubview(errorLabel)
        addSubview(spinner)
        
        displayMode = .hidden
        setupLayout()
    }
    
    private func setupLayout() {
        container.bb.fill()
        arrow.bb.size(width: 14, height: 14).centerX().top(-7)
        statusLabel.bb.left(18).top(15).right(-18).height(14)
        locationLabel.bb.left(18).bottom(-15).right(-48).height(19)
        actionButton.bb.size(width: 20, height: 20).bottom(-15).right(-18)
        errorLabel.bb.top(10).right(-20).bottom(-10).left(20)
        spinner.bb.center()
    }
    
    private func fetchData() {
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        
        ApiService.shared.request(request) { [weak self] (result: Result<GeoLookup>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                self.viewModel = ProofsViewModel(model: model)
            case .failure:
                if self.displayMode == .loading {
                    self.displayMode = .error
                }
            }
        }
    }
    
    @objc private func infoAction() {
        if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
            topViewController.expandFloatingPanel()
        }
    }
    
}

// MARK: - ConnectionInfoPopupView extension -

extension ConnectionInfoPopupView {
    
    enum DisplayMode {
        case hidden
        case loading
        case content
        case error
    }
    
}
