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
import Bamboo
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
    
    private lazy var iPadConstraints = bb.left(MapConstants.Container.iPadLandscapeLeftAnchor).top(MapConstants.Container.iPadLandscapeTopAnchor).constraints.deactivate()
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
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Methods -
    
    func setupConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            iPadConstraints.activate()
        } else {
            iPadConstraints.deactivate()
        }
    }
    
    func updateStatus(vpnStatus: NEVPNStatus) {
        var color = UIColor.init(named: Theme.ivpnGray22)
        
        if vpnStatus == .connected {
            color = UIColor.init(named: Theme.ivpnGray24)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.mapImageView.backgroundColor = color
        }
    }
    
    func updateMapPosition(animated: Bool = false) {
        guard let viewModel = viewModel else { return }
        
        updateMapPosition(latitude: viewModel.model.latitude, longitude: viewModel.model.longitude, animated: animated, isLocalPosition: true)
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
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        isUserInteractionEnabled = true
        isScrollEnabled = true
        backgroundColor = UIColor.init(named: Theme.ivpnGray19)
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -600, right: 0)
        mapImageView.tintColor = UIColor.init(named: Theme.ivpnGray23)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideConnectToServerPopup), name: Notification.Name.HideConnectToServerPopup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectToServerPopup), name: Notification.Name.UpdateConnectToServerPopup, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ServerSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PingDidComplete, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.HideConnectToServerPopup, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UpdateConnectToServerPopup, object: nil)
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
            updateSelectedServer(server)
            connectToServerPopup.show()
            
            if Application.shared.connectionManager.status.isDisconnected() && Application.shared.serverList.validateServer(firstServer: Application.shared.settings.selectedServer, secondServer: server) {
                NotificationCenter.default.post(name: Notification.Name.ServerSelected, object: nil)
            }
        }
    }
    
    private func updateSelectedServer(_ server: VPNServer) {
        let point = getCoordinatesBy(latitude: server.latitude, longitude: server.longitude)
        connectToServerPopup.snp.updateConstraints { make in
            make.left.equalTo(point.0 - 135)
            make.top.equalTo(point.1 + 17)
        }
        
        let nearByServers = getNearByServers(server: server)
        connectToServerPopup.servers = nearByServers
        connectToServerPopup.vpnServer = nearByServers.first ?? server
        
        if Application.shared.connectionManager.status.isDisconnected() && Application.shared.serverList.validateServer(firstServer: Application.shared.settings.selectedServer, secondServer: server) {
            
            if UserDefaults.shared.isMultiHop {
                Application.shared.settings.selectedExitServer = server
                Application.shared.settings.selectedExitServer.fastest = false
            } else {
                Application.shared.settings.selectedServer = server
                Application.shared.settings.selectedServer.fastest = false
            }
            
            Application.shared.connectionManager.needsUpdateSelectedServer()
        }
        
        updateMapPosition(latitude: server.latitude, longitude: server.longitude, animated: true, isLocalPosition: false, updateMarkers: false)
        
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
    
    @objc private func updateConnectToServerPopup() {
        let server = Application.shared.settings.selectedServer
        updateSelectedServer(server)
    }
    
    private func getCoordinatesBy(latitude: Double, longitude: Double) -> (Double, Double) {
        let bitmapWidth: Double = 4206
        let bitmapHeight: Double = 3070
        
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
