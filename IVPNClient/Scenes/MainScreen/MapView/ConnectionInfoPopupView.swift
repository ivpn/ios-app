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
        return container
    }()
    
    lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.text = "Everyone knows about your location"
        statusLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
        return statusLabel
    }()
    
    lazy var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.iconMirror(text: "Australia", image: UIImage(named: "au"), alignment: .left)
        locationLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabelPrimary)
        return locationLabel
    }()
    
    lazy var actionButton: UIButton = {
        let actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        actionButton.backgroundColor = UIColor.init(named: Theme.Key.ivpnBlue)
        return actionButton
    }()
    
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
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.size(width: 270, height: 69).centerX().bottom(15)
    }
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubsviews()
    }
    
    private func addSubsviews() {
        container.addSubview(statusLabel)
        container.addSubview(locationLabel)
        container.addSubview(actionButton)
        addSubview(container)
        
        setupSubsviewsConstraints()
    }
    
    private func setupSubsviewsConstraints() {
        container.bb.fill()
        statusLabel.bb.left(18).top(15).right(-18).height(14)
        locationLabel.bb.left(18).bottom(-15).right(-48).height(19)
        actionButton.bb.size(width: 20, height: 20).bottom(-15).right(-18)
    }
    
}
