//
//  MainView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-01.
//  Copyright (c) 2023 IVPN Limited.
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
import NetworkExtension
import SnapKit

class MainView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var infoAlertView: InfoAlertView!
    @IBOutlet weak var mapScrollView: MapScrollView!
    @IBOutlet weak var ipProtocolView: IpProtocolView!
    
    // MARK: - Properties -
    
    var ipv4ViewModel: ProofsViewModel! {
        didSet {
            mapScrollView.viewModel = ipv4ViewModel
            
            guard let model = ipv4ViewModel.model else {
                return
            }
            
            if Application.shared.connectionManager.status.isDisconnected() {
                localCoordinates = (model.latitude, model.longitude)
                mapScrollView.localCoordinates = (model.latitude, model.longitude)
            }
        }
    }
    
    var ipv6ViewModel: ProofsViewModel! {
        didSet {
            ipProtocolView.update(ipv4ViewModel: ipv4ViewModel, ipv6ViewModel: ipv6ViewModel)
        }
    }
    
    var infoAlertViewModel = InfoAlertViewModel()
    private var localCoordinates: (Double, Double)?
    private var accountButton = UIButton()
    private var settingsButton = UIButton()
    private var centerMapButton = UIButton()
    
    // MARK: - @IBActions -
    
    @IBAction func selectIpProtocol(_ sender: UISegmentedControl) {
        guard let model = sender.selectedSegmentIndex == 1 ? ipv6ViewModel.model : ipv4ViewModel.model else {
            return
        }
        
        let isDisconnected = Application.shared.connectionManager.status.isDisconnected()
        mapScrollView.updateMapPosition(latitude: model.latitude, longitude: model.longitude, animated: true, isLocalPosition: isDisconnected, updateMarkers: true)
        
        if isDisconnected {
            mapScrollView.localCoordinates = (model.latitude, model.longitude)
            mapScrollView.markerLocalView.locationButton.setTitle(model.city, for: .normal)
        } else {
            mapScrollView.gatewayCoordinates = (model.latitude, model.longitude)
        }
    }
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        backgroundColor = UIColor.init(named: Theme.ivpnGray22)
        initSettingsAction()
        initInfoAlert()
        updateInfoAlert()
        addObservers()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            centerMap()
        }
    }
    
    // MARK: - Methods -
    
    func setupView(animated: Bool = true) {
        setupConstraints()
        updateInfoAlert()
        updateActionButtons()
        updateMapPosition(animated: animated)
        mapScrollView.updateMapMarkers()
    }
    
    func updateLayout() {
        setupConstraints()
        updateInfoAlert()
        updateActionButtons()
        mapScrollView.updateMapPositionToCurrentCoordinates()
        mapScrollView.updateMapMarkers()
        ipProtocolView.updateLayout()
    }
    
    func updateStatus(vpnStatus: NEVPNStatus) {
        mapScrollView.updateStatus(vpnStatus: vpnStatus)
    }
    
    func updateInfoAlert() {
        if infoAlertViewModel.shouldDisplay {
            infoAlertView.show(viewModel: infoAlertViewModel)
        } else {
            infoAlertView.hide()
        }
        
        updateActionButtons()
    }
    
    // MARK: - Private methods -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(centerMap), name: Notification.Name.CenterMap, object: nil)
    }
    
    private func initSettingsAction() {
        addSubview(settingsButton)
        
        settingsButton.snp.makeConstraints { make in
            make.width.equalTo(42)
            make.height.equalTo(42)
            make.top.equalTo(55)
            make.right.equalTo(-30)
        }
        
        settingsButton.setupIcon(imageName: "icon-settings")
        settingsButton.accessibilityLabel = "Settings"
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        addSubview(accountButton)
        accountButton.setupIcon(imageName: "icon-user")
        accountButton.accessibilityLabel = "Account"
        accountButton.addTarget(self, action: #selector(openAccountInfo), for: .touchUpInside)
        
        addSubview(centerMapButton)
        centerMapButton.setupIcon(imageName: "icon-crosshair")
        centerMapButton.accessibilityLabel = "Center map"
        centerMapButton.addTarget(self, action: #selector(centerMap), for: .touchUpInside)
    }
    
    private func initInfoAlert() {
        infoAlertView.delegate = infoAlertViewModel
        bringSubviewToFront(infoAlertView)
    }
    
    private func setupConstraints() {
        mapScrollView.setupConstraints()
    }
    
    private func updateMapPosition(animated: Bool = true) {
        let vpnStatus = Application.shared.connectionManager.status
        
        guard vpnStatus != .invalid else {
            return
        }
        
        mapScrollView.updateStatus(vpnStatus: vpnStatus)
    }
    
    private func updateActionButtons() {
        if UIDevice.current.userInterfaceIdiom == .pad && !UIApplication.shared.isSplitOrSlideOver {
            accountButton.snp.remakeConstraints { make in
                make.width.equalTo(42)
                make.height.equalTo(42)
                make.top.equalTo(55)
                make.right.equalTo(-100)
            }
        } else {
            accountButton.snp.remakeConstraints { make in
                make.width.equalTo(42)
                make.height.equalTo(42)
                make.top.equalTo(55)
                make.left.equalTo(30)
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad && !UIApplication.shared.isSplitOrSlideOver {
            centerMapButton.snp.remakeConstraints { make in
                make.size.equalTo(42)
                make.right.equalTo(-170)
                make.top.equalTo(55)
            }
            return
        }
        
        var bottomOffset = 22
        
        if infoAlertViewModel.shouldDisplay {
            bottomOffset = 74
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() != .ipsec && UserDefaults.shared.isMultiHop {
            centerMapButton.snp.remakeConstraints { make in
                make.size.equalTo(42)
                make.right.equalTo(-30)
                make.bottom.equalTo(-MapConstants.Container.bottomAnchorC - bottomOffset)
            }
            return
        }

        if Application.shared.settings.connectionProtocol.tunnelType() != .ipsec {
            centerMapButton.snp.remakeConstraints { make in
                make.size.equalTo(42)
                make.right.equalTo(-30)
                make.bottom.equalTo(-MapConstants.Container.bottomAnchorB - bottomOffset)
            }
            return
        }
        
        centerMapButton.snp.remakeConstraints { make in
            make.size.equalTo(42)
            make.right.equalTo(-30)
            make.bottom.equalTo(-MapConstants.Container.bottomAnchorA - bottomOffset)
        }
    }
    
    @objc private func openSettings(_ sender: UIButton) {
        if let topViewController = UIApplication.topViewController() as? MainViewController {
            topViewController.openSettings(sender)
        }
    }
    
    @objc private func openAccountInfo(_ sender: UIButton) {
        if let topViewController = UIApplication.topViewController() as? MainViewController {
            topViewController.openAccountInfo(sender)
        }
    }
    
    @objc private func centerMap() {
        mapScrollView.centerMap()
    }
    
}
