//
//  ConnectToServerPopupView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 24/06/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import SnapKit

class ConnectToServerPopupView: UIView {
    
    // MARK: - View components -
    
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        container.layer.cornerRadius = 8
        container.clipsToBounds = false
        return container
    }()
    
    lazy var arrow: UIView = {
        let arrow = UIView(frame: .zero)
        arrow.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        arrow.rotate(angle: 45)
        return arrow
    }()
    
    lazy var descriptionLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = UIColor.init(named: Theme.ivpnLabel5)
        return statusLabel
    }()
    
    lazy var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        return locationLabel
    }()
    
    var actionButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setTitle("CONNECT TO SERVER", for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        actionButton.backgroundColor = UIColor.init(named: Theme.ivpnBlue)
        actionButton.layer.cornerRadius = 8
        actionButton.addTarget(self, action: #selector(connectAction), for: .touchUpInside)
        return actionButton
    }()
    
    // MARK: - Properties -
    
    var vpnServer: VPNServer! {
        didSet {
            let geoLookupModel = GeoLookup(ipAddress: "", countryCode: vpnServer.countryCode, country: vpnServer.country, city: vpnServer.city, isIvpnServer: true, isp: "", latitude: 0, longitude: 0)
            let viewModel = ProofsViewModel(model: geoLookupModel)
            locationLabel.iconMirror(text: "\(viewModel.city), \(viewModel.countryCode)", image: UIImage(named: viewModel.imageNameForCountryCode), alignment: .left)
            
            if Application.shared.connectionManager.status.isDisconnected() && Application.shared.settings.selectedServer == vpnServer {
                descriptionLabel.text = "Connected to"
                actionButton.setTitle("DISCONNECT", for: .normal)
            } else {
                descriptionLabel.text = "Protect yourself by connecting to"
                actionButton.setTitle("CONNECT TO SERVER", for: .normal)
            }
        }
    }
    
    var displayMode: DisplayMode = .hidden {
        didSet {
            switch displayMode {
            case .hidden:
                UIView.animate(withDuration: 0.15, animations: { self.alpha = 0 }) { _ in
                    self.isHidden = true
                }
            case .content:
                container.isHidden = false
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
        displayMode = .content
    }
    
    func hide() {
        displayMode = .hidden
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        setupLayout()
    }
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        layer.cornerRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
        isHidden = true
        alpha = 0
        
        container.addSubview(descriptionLabel)
        container.addSubview(locationLabel)
        container.addSubview(actionButton)
        addSubview(arrow)
        addSubview(container)
        
        displayMode = .hidden
    }
    
    private func setupLayout() {
        snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(270)
            make.height.equalTo(130)
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        arrow.snp.makeConstraints { make in
            make.size.equalTo(14)
            make.centerX.equalToSuperview()
            make.top.equalTo(-7)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.top.equalTo(15)
            make.right.equalTo(-18)
            make.height.equalTo(14)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.top.equalTo(35)
            make.right.equalTo(-18)
            make.height.equalTo(19)
        }
        
        actionButton.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.height.equalTo(44)
            make.bottom.equalTo(-20)
        }
    }
    
    @objc private func connectAction() {
        Application.shared.settings.selectedServer = vpnServer
        Application.shared.connectionManager.needsUpdateSelectedServer()
        
        if Application.shared.connectionManager.status.isDisconnected() {
            NotificationCenter.default.post(name: Notification.Name.Connect, object: nil)
        } else {
            Application.shared.connectionManager.reconnect()
            NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
        }
        
        hide()
    }
    
}

// MARK: - ConnectToServerPopupView extension -

extension ConnectToServerPopupView {
    
    enum DisplayMode {
        case hidden
        case content
    }
    
}
