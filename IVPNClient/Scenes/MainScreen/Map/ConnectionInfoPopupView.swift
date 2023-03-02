//
//  ConnectionInfoPopupView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-18.
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
import SnapKit

class ConnectionInfoPopupView: UIView {
    
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
    
    lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.text = "Please check your internet connection and try again."
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.init(named: Theme.ivpnLabel5)
        errorLabel.numberOfLines = 0
        errorLabel.isAccessibilityElement = true
        return errorLabel
    }()
    
    lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = UIColor.init(named: Theme.ivpnLabel5)
        statusLabel.isAccessibilityElement = true
        return statusLabel
    }()
    
    lazy var flagImage = FlagImageView()
    
    lazy var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
        locationLabel.isAccessibilityElement = true
        return locationLabel
    }()
    
    lazy var actionButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setImage(UIImage.init(named: "icon-info-2"), for: .normal)
        actionButton.accessibilityLabel = "Connection info details"
        actionButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        actionButton.isAccessibilityElement = true
        return actionButton
    }()
    
    lazy var resumeButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setTitle("RESUME", for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        actionButton.backgroundColor = UIColor.init(named: Theme.ivpnBlue)
        actionButton.layer.cornerRadius = 8
        actionButton.addTarget(self, action: #selector(resumeAction), for: .touchUpInside)
        actionButton.isAccessibilityElement = true
        return actionButton
    }()
    
    // MARK: - Properties -
    
    var viewModel: ProofsViewModel! {
        didSet {
            guard !PauseManager.shared.isPaused else {
                setupPauseView()
                return
            }
            
            statusLabel.text = vpnStatusViewModel.popupStatusText
            flagImage.image = UIImage.init(named: viewModel.imageNameForCountryCode)
            locationLabel.text = viewModel.location
            locationLabel.accessibilityLabel = viewModel.city
        }
    }
    
    var vpnStatusViewModel = VPNStatusViewModel(status: .invalid)
    
    var displayMode: DisplayMode = .hidden {
        didSet {
            switch displayMode {
            case .hidden:
                UIView.animate(withDuration: 0.20, animations: {
                    self.alpha = 0
                }, completion: { _ in
                    self.isHidden = true
                })
            case .content:
                container.isHidden = false
                errorLabel.isHidden = true
                setupPauseView()
                isHidden = false
                UIView.animate(withDuration: 0.20, animations: { self.alpha = 1 })
            case .error:
                container.isHidden = true
                errorLabel.isHidden = false
                isHidden = false
                UIView.animate(withDuration: 0.20, animations: { self.alpha = 1 })
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
    
    func updateView() {
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape && !UIApplication.shared.isSplitOrSlideOver {
            actionButton.isHidden = true
        } else {
            actionButton.isHidden = false
        }
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        snp.updateConstraints { make in
            make.width.equalTo(270)
            make.height.equalTo(PauseManager.shared.isPaused ? 130 : 69)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(52)
        }
    }
    
    private func setupView() {
        backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        layer.cornerRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
        isHidden = true
        alpha = 0
        
        container.addSubview(statusLabel)
        container.addSubview(flagImage)
        container.addSubview(locationLabel)
        container.addSubview(actionButton)
        container.addSubview(resumeButton)
        addSubview(arrow)
        addSubview(container)
        addSubview(errorLabel)
        
        displayMode = .hidden
        setupLayout()
        initGestures()
    }
    
    private func setupLayout() {
        container.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        arrow.snp.updateConstraints { make in
            make.width.equalTo(14)
            make.height.equalTo(14)
            make.centerX.equalToSuperview()
            make.top.equalTo(-7)
        }
        
        statusLabel.snp.updateConstraints { make in
            make.left.equalTo(18)
            make.top.equalTo(15)
            make.right.equalTo(-18)
            make.height.equalTo(14)
        }
        
        flagImage.snp.updateConstraints { make in
            make.left.equalTo(18)
            make.bottom.equalTo(-17)
            make.width.equalTo(20)
            make.height.equalTo(15)
        }
        
        locationLabel.snp.updateConstraints { make in
            make.left.equalTo(PauseManager.shared.isPaused ? 18 : 45)
            make.top.equalTo(34)
            make.right.equalTo(-48)
            make.height.equalTo(19)
        }
        
        actionButton.snp.updateConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
            make.right.equalTo(-18)
        }
        
        resumeButton.snp.updateConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.height.equalTo(44)
            make.bottom.equalTo(-18)
        }
        
        errorLabel.snp.updateConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(-20)
            make.bottom.equalTo(-10)
            make.left.equalTo(20)
        }
    }
    
    private func setupPauseView() {
        if PauseManager.shared.isPaused {
            PauseManager.shared.delegate = self
            locationLabel.text = PauseManager.shared.countdown
            flagImage.isHidden = true
            actionButton.isHidden = true
            resumeButton.isHidden = false
        } else {
            PauseManager.shared.delegate = nil
            flagImage.isHidden = false
            actionButton.isHidden = false
            resumeButton.isHidden = true
        }
        
        setupConstraints()
        setupLayout()
    }
    
    @objc private func infoAction() {
        if let topViewController = UIApplication.topViewController() as? MainViewController {
            topViewController.expandFloatingPanel()
        }
    }
    
    @objc private func resumeAction() {
        NotificationCenter.default.post(name: Notification.Name.Connect, object: nil)
        PauseManager.shared.suspend()
    }
    
    private func initGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        
    }
    
}

// MARK: - ConnectionInfoPopupView extension -

extension ConnectionInfoPopupView {
    
    enum DisplayMode {
        case hidden
        case content
        case error
    }
    
}

// MARK: - PauseManagerDelegate -

extension ConnectionInfoPopupView: PauseManagerDelegate {
    
    func updateCountdown(text: String) {
        locationLabel.text = text
    }
    
}
