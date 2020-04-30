//
//  ConnectionInfoView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 12/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class ConnectionInfoView: UIView {
    
    // MARK: - View components -
    
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        return container
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
        errorLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        errorLabel.text = "Please check your internet connection and try again."
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        errorLabel.numberOfLines = 0
        return errorLabel
    }()
    
    lazy var countryLabel: UILabel = {
        let countryLabel = UILabel()
        countryLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .regular)
        countryLabel.iconMirror(text: "Australia", image: UIImage(named: "au"), alignment: .left)
        countryLabel.textAlignment = .center
        countryLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return countryLabel
    }()
    
    lazy var cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .regular)
        cityLabel.text = "Salt Lake City, UT"
        cityLabel.textAlignment = .center
        cityLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return cityLabel
    }()
    
    lazy var ipAddressTitleLabel: UILabel = {
        let ipAddressTitleLabel = UILabel()
        ipAddressTitleLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        ipAddressTitleLabel.text = "Public IP Address"
        ipAddressTitleLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return ipAddressTitleLabel
    }()
    
    lazy var ipAddressLabel: UILabel = {
        let ipAddressLabel = UILabel()
        ipAddressLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        ipAddressLabel.text = "111.111.111.111"
        ipAddressLabel.textAlignment = .right
        ipAddressLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return ipAddressLabel
    }()
    
    lazy var protocolTitleLabel: UILabel = {
        let protocolTitleLabel = UILabel()
        protocolTitleLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        protocolTitleLabel.text = "Protocol"
        protocolTitleLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return protocolTitleLabel
    }()
    
    lazy var protocolLabel: UILabel = {
        let protocolLabel = UILabel()
        protocolLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        protocolLabel.text = "WireGuard"
        protocolLabel.textAlignment = .right
        protocolLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return protocolLabel
    }()
    
    lazy var localIpAddressTitleLabel: UILabel = {
        let localIpAddressTitleLabel = UILabel()
        localIpAddressTitleLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        localIpAddressTitleLabel.text = "Local IP Address"
        localIpAddressTitleLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return localIpAddressTitleLabel
    }()
    
    lazy var localIpAddressLabel: UILabel = {
        let localIpAddressLabel = UILabel()
        localIpAddressLabel.font = UIFont.systemFont(ofSize: labelFontSize, weight: .regular)
        localIpAddressLabel.text = ""
        localIpAddressLabel.textAlignment = .right
        localIpAddressLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return localIpAddressLabel
    }()
    
    lazy var delimiter1: UIView = {
        let delimiter1 = UIView(frame: .zero)
        delimiter1.backgroundColor = UIColor.init(named: Theme.ivpnGray9)
        return delimiter1
    }()
    
    lazy var delimiter2: UIView = {
        let delimiter2 = UIView(frame: .zero)
        delimiter2.backgroundColor = UIColor.init(named: Theme.ivpnGray9)
        return delimiter2
    }()
    
    // MARK: - Properties -
    
    let titleHeight = 30.0
    let titleFontSize: CGFloat = 17
    let labelHeight = 46.0
    let labelFontSize: CGFloat = 14
    
    static var showProtocol: Bool {
        return Application.shared.connectionManager.status == .connected
    }
    
    static var showLocalIpAddress: Bool {
        return (Application.shared.settings.connectionProtocol.tunnelType() == .wireguard || Application.shared.settings.connectionProtocol.tunnelType() == .openvpn) && Application.shared.connectionManager.status == .connected
    }
    
    static var calculatedFrame: CGRect {
        if showLocalIpAddress {
            return CGRect(x: 0, y: -20, width: 238, height: 210)
        }
        if showProtocol {
            return CGRect(x: 0, y: -20, width: 238, height: 164)
        }
        
        return CGRect(x: 0, y: -20, width: 238, height: 118)
    }
    
    var displayMode: DisplayMode! {
        didSet {
            switch displayMode {
            case .loading?:
                spinner.startAnimating()
                container.isHidden = true
                errorLabel.isHidden = true
            case .content?:
                spinner.stopAnimating()
                container.isHidden = false
                errorLabel.isHidden = true
            case .error?:
                spinner.stopAnimating()
                container.isHidden = true
                errorLabel.isHidden = false
            case .none:
                break
            }
        }
    }
    
    var viewModel: ProofsViewModel! {
        didSet {
            countryLabel.iconMirror(text: viewModel.country, image: UIImage(named: viewModel.imageNameForCountryCode), alignment: .left)
            cityLabel.text = viewModel.city
            ipAddressLabel.text = viewModel.ipAddress
            protocolLabel.text = viewModel.protocolTitle
            localIpAddressLabel.text = viewModel.localIpAddress
            displayMode = .content
        }
    }
    
    // MARK: - Initialize -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(container)
        addSubview(spinner)
        addSubview(errorLabel)
        container.addSubview(countryLabel)
        container.addSubview(cityLabel)
        container.addSubview(ipAddressTitleLabel)
        container.addSubview(ipAddressLabel)
        
        if ConnectionInfoView.showProtocol {
            container.addSubview(delimiter1)
            container.addSubview(protocolTitleLabel)
            container.addSubview(protocolLabel)
        }
        
        if ConnectionInfoView.showLocalIpAddress {
            container.addSubview(delimiter2)
            container.addSubview(localIpAddressTitleLabel)
            container.addSubview(localIpAddressLabel)
        }
        
        displayMode = .loading
        setupLayout()
        load()
    }
    
    private func load() {
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        
        ApiService.shared.request(request) { [weak self] (result: Result<GeoLookup>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                self.viewModel = ProofsViewModel(model: model)
            case .failure:
                self.displayMode = .error
            }
        }
    }
    
    // MARK: - Auto Layout -
    
    private func setupLayout() {
        spinner.bb.center()
        container.bb.fill()
        errorLabel.bb.centerY().left(10).right(-10)
        countryLabel.bb.left().top().right().height(titleHeight)
        cityLabel.bb.left().below(countryLabel).right().height(titleHeight)
        ipAddressTitleLabel.bb.below(cityLabel, spacing: 10).left().right().height(labelHeight)
        ipAddressLabel.bb.below(cityLabel, spacing: 10).left().right().height(labelHeight)
        
        if ConnectionInfoView.showProtocol {
            delimiter1.bb.below(ipAddressTitleLabel).left().right().height(0.5)
            protocolTitleLabel.bb.below(delimiter1).left().right().height(labelHeight)
            protocolLabel.bb.below(delimiter1).left().right().height(labelHeight)
        }
        
        if ConnectionInfoView.showLocalIpAddress {
            delimiter2.bb.below(protocolTitleLabel).left().right().height(0.5)
            localIpAddressTitleLabel.bb.below(delimiter2).left().right().height(labelHeight)
            localIpAddressLabel.bb.below(delimiter2).left().right().height(labelHeight)
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
}

extension ConnectionInfoView {
    
    enum DisplayMode {
        case loading
        case content
        case error
    }
    
}
