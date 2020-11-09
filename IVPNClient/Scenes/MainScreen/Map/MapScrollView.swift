//
//  MapScrollView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-02-20.
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

class MapScrollView: UIScrollView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    // MARK: - Properties -
    
    var viewModel: ProofsViewModel! {
        didSet {
            if oldValue == nil {
                UIView.animate(withDuration: 0.65) {
                    self.alpha = 1
                }
            }
            
            markerLocalView.viewModel = viewModel
            
            if !viewModel.model.isIvpnServer && Application.shared.connectionManager.status.isDisconnected() {
                updateMapPosition(animated: oldValue != nil)
                markerGatewayView.hide(animated: true)
                markerLocalView.show(animated: oldValue != nil)
            }
        }
    }
    
    let markerLocalView = MapMarkerView(type: .local)
    let markerGatewayView = MapMarkerView(type: .gateway)
    var localCoordinates: (Double, Double)?
    var currentCoordinates: (Double, Double)?
    
    private var markers: [UIButton] = []
    private var connectToServerPopup = ConnectToServerPopupView()
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupConstraints()
        setupView()
        initGestures()
        initServerLocationMarkers()
        initMarkers()
        initConnectToServerPopup()
        addObservers()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            snp.remakeConstraints { make in
                make.top.equalTo(MapConstants.Container.iPadLandscapeTopAnchor)
                make.left.equalTo(MapConstants.Container.iPadLandscapeLeftAnchor)
            }
        } else {
            snp.removeConstraints()
        }
    }
    
    func updateStatus(vpnStatus: NEVPNStatus) {
        var color = UIColor.init(named: Theme.ivpnGray22)
        
        if vpnStatus == .connected {
            color = UIColor.init(named: Theme.ivpnGray24)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = color
            self.mapImageView.backgroundColor = color
        }
        
        if vpnStatus == .disconnected {
            if localCoordinates != nil {
                markerGatewayView.hide(animated: true)
            }
        }
    }
    
    func updateMapPosition(animated: Bool = false) {
        guard let viewModel = viewModel else { return }
        
        updateMapPosition(latitude: viewModel.model.latitude, longitude: viewModel.model.longitude, animated: animated, isLocalPosition: true)
    }
    
    func updateMapPositionToCurrentCoordinates() {
        if let currentCoordinates = currentCoordinates {
            updateMapPosition(latitude: currentCoordinates.0, longitude: currentCoordinates.1, isLocalPosition: false, updateMarkers: false)
        }
    }
    
    func updateMapPosition(latitude: Double, longitude: Double, animated: Bool = false, isLocalPosition: Bool, updateMarkers: Bool = true) {
        let halfWidth = Double(UIScreen.main.bounds.width / 2)
        let halfHeight = Double(UIScreen.main.bounds.height / 2)
        let point = getCoordinatesBy(latitude: latitude, longitude: longitude)
        let bottomOffset = Double((MapConstants.Container.getBottomAnchor() / 2) - MapConstants.Container.getTopAnchor())
        let leftOffset = Double((MapConstants.Container.getLeftAnchor()) / 2)
        
        if animated {
            UIView.animate(withDuration: 0.55, delay: 0, options: .curveEaseInOut, animations: {
                self.setContentOffset(CGPoint(x: point.0 - halfWidth + leftOffset, y: point.1 - halfHeight + bottomOffset), animated: false)
            })
        } else {
            setContentOffset(CGPoint(x: point.0 - halfWidth + leftOffset, y: point.1 - halfHeight + bottomOffset), animated: false)
        }
        
        if updateMarkers {
            updateMarkerPosition(x: point.0 - 49, y: point.1 - 49, isLocalPosition: isLocalPosition)
        }
        
        currentCoordinates = (latitude, longitude)
    }
    
    func updateMapMarkers() {
        markerLocalView.updateView()
        markerGatewayView.updateView()
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        isUserInteractionEnabled = true
        isScrollEnabled = true
        backgroundColor = UIColor.init(named: Theme.ivpnGray22)
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -875, right: 0)
        scrollsToTop = false
        mapImageView.tintColor = UIColor.init(named: Theme.ivpnGray23)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapPositionToSelectedServer), name: Notification.Name.ShowConnectToServerPopup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideConnectToServerPopup), name: Notification.Name.HideConnectToServerPopup, object: nil)
    }
    
    private func initGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        hideConnectToServerPopup()
        NotificationCenter.default.post(name: Notification.Name.HideConnectionInfoPopup, object: nil)
    }
    
    private func initServerLocationMarkers() {
        for server in Application.shared.serverList.servers {
            placeMarker(latitude: server.latitude, longitude: server.longitude, city: server.city)
        }
    }
    
    private func initMarkers() {
        markerLocalView.hide()
        markerGatewayView.hide()
        addSubview(markerLocalView)
        addSubview(markerGatewayView)
    }
    
    private func initConnectToServerPopup() {
        addSubview(connectToServerPopup)
    }
    
    private func updateMarkerPosition(x: Double, y: Double, isLocalPosition: Bool) {
        if isLocalPosition {
            markerLocalView.snp.updateConstraints { make in
                make.left.equalTo(x)
                make.top.equalTo(y)
            }
            
            UIView.animate(withDuration: 0.15) {
                self.layoutIfNeeded()
            }
        } else {
            markerGatewayView.snp.updateConstraints { make in
                make.left.equalTo(x)
                make.top.equalTo(y)
            }
            
            UIView.animate(withDuration: 0.15) {
                self.layoutIfNeeded()
            }
        }
    }
    
    private func placeMarker(latitude: Double, longitude: Double, city: String) {
        let point = getCoordinatesBy(latitude: latitude, longitude: longitude)
        
        let button = UIButton(frame: CGRect(x: point.0 - 50, y: point.1 - 21, width: 100, height: 20))
        button.setTitle(city, for: .normal)
        button.setTitleColor(UIColor.init(named: Theme.ivpnGray21), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .regular)
        button.addTarget(self, action: #selector(selectServer), for: .touchUpInside)
        
        let marker = UIView(frame: CGRect(x: 50 - 3, y: 18, width: 6, height: 6))
        marker.layer.cornerRadius = 3
        marker.backgroundColor = UIColor.init(named: Theme.ivpnGray21)
        marker.tag = 1
        
        if city == "Bratislava" {
            button.titleEdgeInsets = UIEdgeInsets(top: 21, left: 59, bottom: 0, right: 0)
            button.frame = CGRect(x: point.0 - 55, y: point.1 - 21, width: 110, height: 20)
            marker.frame = CGRect(x: 55 - 3, y: 18, width: 6, height: 6)
        }

        if city == "Budapest" {
            button.titleEdgeInsets = UIEdgeInsets(top: 21, left: 58, bottom: 0, right: 0)
            button.frame = CGRect(x: point.0 - 55, y: point.1 - 21, width: 110, height: 20)
            marker.frame = CGRect(x: 55 - 3, y: 18, width: 6, height: 6)
        }
        
        if city == "New Jersey, NJ" {
            button.titleEdgeInsets = UIEdgeInsets(top: 22, left: 93, bottom: 0, right: 0)
            button.frame = CGRect(x: point.0 - 85, y: point.1 - 21, width: 170, height: 20)
            marker.frame = CGRect(x: 85 - 3, y: 18, width: 6, height: 6)
        }
        
        button.addSubview(marker)
        addSubview(button)
        
        markers.append(button)
    }
    
    @objc private func selectServer(_ sender: UIButton) {
        let city = sender.titleLabel?.text ?? ""
        
        if let server = Application.shared.serverList.getServer(byCity: city) {
            showConnectToServerPopup(server: server)
            updateMapPosition(latitude: server.latitude, longitude: server.longitude, animated: true, isLocalPosition: false, updateMarkers: false)
            
            if Application.shared.connectionManager.status.isDisconnected() && Application.shared.serverList.validateServer(firstServer: Application.shared.settings.selectedServer, secondServer: server) {
                
                if UserDefaults.shared.isMultiHop {
                    Application.shared.settings.selectedExitServer = server
                    Application.shared.settings.selectedExitServer.fastest = false
                } else {
                    Application.shared.settings.selectedServer = server
                    Application.shared.settings.selectedServer.fastest = false
                }
                
                Application.shared.connectionManager.needsUpdateSelectedServer()
                NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
            }
        }
    }
    
    @objc private func updateMapPositionToSelectedServer() {
        guard Application.shared.connectionManager.status.isDisconnected() else {
            return
        }
        
        let server = UserDefaults.shared.isMultiHop ? Application.shared.settings.selectedExitServer : Application.shared.settings.selectedServer
        
        guard !server.random else {
            NotificationCenter.default.post(name: Notification.Name.CenterMap, object: nil)
            return
        }
        
        showConnectToServerPopup(server: server)
        updateMapPosition(latitude: server.latitude, longitude: server.longitude, animated: true, isLocalPosition: false, updateMarkers: false)
    }
    
    private func showConnectToServerPopup(server: VPNServer) {
        let point = getCoordinatesBy(latitude: server.latitude, longitude: server.longitude)
        connectToServerPopup.snp.updateConstraints { make in
            make.left.equalTo(point.0 - 135)
            make.top.equalTo(point.1 + 17)
        }
        
        let nearByServers = getNearByServers(server: server)
        connectToServerPopup.servers = nearByServers
        connectToServerPopup.vpnServer = nearByServers.first ?? server
        connectToServerPopup.show()
        NotificationCenter.default.post(name: Notification.Name.HideConnectionInfoPopup, object: nil)
    }
    
    private func getNearByServers(server selectedServer: VPNServer) -> [VPNServer] {
        var servers = Application.shared.serverList.validateServer(firstServer: Application.shared.settings.selectedServer, secondServer: selectedServer) ? [selectedServer] : []
        
        for server in Application.shared.serverList.servers {
            guard server !== selectedServer else { continue }
            guard Application.shared.serverList.validateServer(firstServer: Application.shared.settings.selectedServer, secondServer: server) else { continue }
            
            if isNearByServer(selectedServer, server) {
                servers.append(server)
            }
        }
        
        return servers
    }
    
    private func isNearByServer(_ server1: VPNServer, _ server2: VPNServer) -> Bool {
        let point1 = getCoordinatesBy(latitude: server1.latitude, longitude: server1.longitude)
        let point2 = getCoordinatesBy(latitude: server2.latitude, longitude: server2.longitude)
        
        let diffX = abs(point1.0 - point2.0)
        let diffY = abs(point1.1 - point2.1)
        
        if diffX < 60 && diffY < 18 {
            return true
        }
        
        return false
    }
    
    @objc private func hideConnectToServerPopup() {
        connectToServerPopup.hide()
    }
    
    private func getCoordinatesBy(latitude: Double, longitude: Double) -> (Double, Double) {
        let bitmapWidth: Double = 5400
        let bitmapHeight: Double = 3942
        
        var x: Double = longitude.toRadian() - 0.18
        var y: Double = latitude.toRadian()
        
        let yStrech = 0.542
        let yOffset = 0.053
        
        y = yStrech * log(tan(0.25 * Double.pi + 0.4 * y)) + yOffset
        
        x = ((bitmapWidth) / 2) + (bitmapWidth / (2 * Double.pi)) * x
        y = (bitmapHeight / 2) - (bitmapHeight / 2) * y
        
        return (x, y)
    }
    
}
