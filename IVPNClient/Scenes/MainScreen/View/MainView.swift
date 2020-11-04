//
//  MainView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-01.
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
import NetworkExtension
import SnapKit

class MainView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var infoAlertView: InfoAlertView!
    @IBOutlet weak var mapScrollView: MapScrollView!
    
    // MARK: - Properties -
    
    var connectionViewModel: ProofsViewModel! {
        didSet {
            mapScrollView.viewModel = connectionViewModel
            
            if !connectionViewModel.model.isIvpnServer {
                localCoordinates = (connectionViewModel.model.latitude, connectionViewModel.model.longitude)
                mapScrollView.localCoordinates = (connectionViewModel.model.latitude, connectionViewModel.model.longitude)
            }
        }
    }
    
    var infoAlertViewModel = InfoAlertViewModel()
    private var localCoordinates: (Double, Double)?
    private var centerMapButton = UIButton()
    
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
    }
    
    func updateStatus(vpnStatus: NEVPNStatus) {
        updateMapPosition(vpnStatus: vpnStatus)
        mapScrollView.updateStatus(vpnStatus: vpnStatus)
    }
    
    func updateInfoAlert() {
        if infoAlertViewModel.shouldDisplay {
            infoAlertView.show(type: infoAlertViewModel.type, text: infoAlertViewModel.text, actionText: infoAlertViewModel.actionText)
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
        let settingsButton = UIButton()
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
        
        let accountButton = UIButton()
        addSubview(accountButton)
        if UIDevice.current.userInterfaceIdiom == .pad {
            accountButton.snp.makeConstraints { make in
                make.width.equalTo(42)
                make.height.equalTo(42)
                make.top.equalTo(55)
                make.right.equalTo(-100)
            }
        } else {
            accountButton.snp.makeConstraints { make in
                make.width.equalTo(42)
                make.height.equalTo(42)
                make.top.equalTo(55)
                make.left.equalTo(30)
            }
        }
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
        
        if vpnStatus.isDisconnected() && !Application.shared.connectionManager.reconnectAutomatically {
            updateMapPositionToLocalCoordinates(animated: animated)
        } else {
            updateMapPositionToGateway(animated: animated)
        }
    }
    
    private func updateMapPosition(vpnStatus: NEVPNStatus) {
        mapScrollView.markerGatewayView.status = vpnStatus
        
        if vpnStatus == .connecting || vpnStatus == .connected {
            updateMapPositionToGateway()
        }
        
        if vpnStatus == .disconnecting && !Application.shared.connectionManager.reconnectAutomatically {
            updateMapPositionToLocalCoordinates()
        }
        
        if vpnStatus == .disconnecting && Application.shared.connectionManager.reconnectAutomatically {
            mapScrollView.markerGatewayView.hide(animated: true)
        }
    }
    
    private func updateMapPositionToGateway(animated: Bool = true) {
        var server = Application.shared.settings.selectedServer
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            server = Application.shared.settings.selectedExitServer
        }
        
        mapScrollView.updateMapPosition(latitude: server.latitude, longitude: server.longitude, animated: true, isLocalPosition: false)
        mapScrollView.markerLocalView.hide(animated: true)
        DispatchQueue.delay(0.25) {
            let model = GeoLookup(ipAddress: server.ipAddresses.first ?? "", countryCode: server.countryCode, country: server.country, city: server.city, isIvpnServer: true, isp: "", latitude: server.latitude, longitude: server.longitude)
            self.mapScrollView.markerGatewayView.viewModel = ProofsViewModel(model: model)
            self.mapScrollView.markerGatewayView.show(animated: true)
        }
    }
    
    private func updateMapPositionToLocalCoordinates(animated: Bool = true) {
        if let localCoordinates = localCoordinates {
            mapScrollView.updateMapPosition(latitude: localCoordinates.0, longitude: localCoordinates.1, animated: animated, isLocalPosition: true)
            mapScrollView.markerGatewayView.hide(animated: true)
            DispatchQueue.delay(0.25) {
                self.mapScrollView.markerLocalView.show(animated: true)
            }
        }
    }
    
    private func updateActionButtons() {
        if UIDevice.current.userInterfaceIdiom == .pad {
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
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            centerMapButton.snp.remakeConstraints { make in
                make.size.equalTo(42)
                make.right.equalTo(-30)
                make.bottom.equalTo(-MapConstants.Container.bottomAnchorC - bottomOffset)
            }
            return
        }

        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
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
        let vpnStatus = Application.shared.connectionManager.status
        
        if vpnStatus.isDisconnected() {
            updateMapPositionToLocalCoordinates()
        } else {
            updateMapPositionToGateway()
        }
    }
    
}
