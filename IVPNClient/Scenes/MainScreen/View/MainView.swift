//
//  MainView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 01/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
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
            }
        }
    }
    
    let markerView = MapMarkerView()
    var infoAlertViewModel = InfoAlertViewModel()
    private var localCoordinates: (Double, Double)?
    private var centerMapButton = UIButton()
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        backgroundColor = UIColor.init(named: Theme.ivpnGray19)
        initSettingsAction()
        initInfoAlert()
        updateInfoAlert()
    }
    
    // MARK: - Methods -
    
    func setupView(animated: Bool = true) {
        setupConstraints()
        updateInfoAlert()
        updateActionButtons()
        updateMapPosition(animated: animated)
    }
    
    func updateStatus(vpnStatus: NEVPNStatus) {
        updateMapPosition(vpnStatus: vpnStatus)
    }
    
    func updateInfoAlert() {
        if infoAlertViewModel.shouldDisplay {
            infoAlertViewModel.update()
            infoAlertView.show(type: infoAlertViewModel.type, text: infoAlertViewModel.text, actionText: infoAlertViewModel.actionText)
        } else {
            infoAlertView.hide()
        }
    }
    
    // MARK: - Private methods -
    
    private func initSettingsAction() {
        let settingsButton = UIButton()
        addSubview(settingsButton)
        settingsButton.bb.size(width: 42, height: 42).top(55).right(-30)
        settingsButton.setupIcon(imageName: "icon-settings")
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        let accountButton = UIButton()
        addSubview(accountButton)
        if UIDevice.current.userInterfaceIdiom == .pad {
            accountButton.bb.size(width: 42, height: 42).top(55).right(-100)
        } else {
            accountButton.bb.size(width: 42, height: 42).top(55).left(30)
        }
        accountButton.setupIcon(imageName: "icon-user")
        accountButton.addTarget(self, action: #selector(openAccountInfo), for: .touchUpInside)
        
        addSubview(centerMapButton)
        centerMapButton.setupIcon(imageName: "icon-crosshair")
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
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            centerMapButton.snp.remakeConstraints { make in
                make.size.equalTo(42)
                make.right.equalTo(-30)
                make.bottom.equalTo(-MapConstants.Container.bottomAnchorC - 22)
            }
            return
        }

        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
            centerMapButton.snp.remakeConstraints { make in
                make.size.equalTo(42)
                make.right.equalTo(-30)
                make.bottom.equalTo(-MapConstants.Container.bottomAnchorB - 22)
            }
            return
        }
        
        centerMapButton.snp.remakeConstraints { make in
            make.size.equalTo(42)
            make.right.equalTo(-30)
            make.bottom.equalTo(-MapConstants.Container.bottomAnchorA - 22)
        }
    }
    
    @objc private func openSettings(_ sender: UIButton) {
        if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
            topViewController.openSettings(sender)
        }
    }
    
    @objc private func openAccountInfo(_ sender: UIButton) {
        if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
            topViewController.openAccountInfo(sender)
        }
    }
    
    @objc private func centerMap(_ sender: UIButton) {
        let vpnStatus = Application.shared.connectionManager.status
        
        if vpnStatus.isDisconnected() {
            updateMapPositionToLocalCoordinates()
        } else {
            updateMapPositionToGateway()
        }
    }
    
}
