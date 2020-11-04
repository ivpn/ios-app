//
//  MapMarkerView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-17.
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
import NetworkExtension

class MapMarkerView: UIView {
    
    // MARK: - Properties -
    
    var status: NEVPNStatus = .invalid {
        didSet {
            switch status {
            case .reasserting, .connecting, .disconnecting:
                displayMode = .changing
            case .connected:
                displayMode = .protected
            default:
                displayMode = .unprotected
            }
            
            connectionInfoPopup.vpnStatusViewModel = VPNStatusViewModel(status: status)
        }
    }
    
    var viewModel: ProofsViewModel? {
        didSet {
            if markerType == .local && !(viewModel?.model.isIvpnServer ?? false) {
                locationButton.setTitle(viewModel?.city, for: .normal)
                connectionInfoPopup.viewModel = viewModel
            }
            
            if markerType == .gateway {
                locationButton.setTitle("", for: .normal)
                connectionInfoPopup.viewModel = viewModel
            }
        }
    }
    
    var displayMode: DisplayMode = .unprotected {
        didSet {
            switch displayMode {
            case .unprotected:
                updateCircles(color: redColor)
                animatedCircleLayer.stopAnimations()
            case .changing:
                updateCircles(color: grayColor)
                animatedCircleLayer.stopAnimations()
            case .protected:
                updateCircles(color: blueColor)
                animatedCircleLayer.startAnimation()
            }
        }
    }
    
    var markerType: MarkerType = .local
    
    var connectionInfoPopup = ConnectionInfoPopupView()
    private var circle1 = UIView()
    private var circle2 = UIView()
    private var locationButton = UIButton()
    private var animatedCircle = UIView()
    private var animatedCircleLayer = AnimatedCircleLayer()
    private var radius1: CGFloat = 98
    private var radius2: CGFloat = 8
    private var blueColor = UIColor.init(red: 68, green: 156, blue: 248)
    private var redColor = UIColor.init(named: Theme.ivpnRedOff)!
    private var grayColor = UIColor.init(named: Theme.ivpnGray18)!
    
    // MARK: - View lifecycle -
    
    convenience init(type: MarkerType) {
        self.init(frame: CGRect.zero)
        self.markerType = type
    }

    override func updateConstraints() {
        setupConstraints()
        initCircles()
        updateCircles(color: redColor)
        initLocationButton()
        initConnectionInfoPopup()
        addObservers()
        
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func updateCircles(color: UIColor) {
        updateCircle(circle1, color: color.withAlphaComponent(0.5))
        updateCircle(circle2, color: color)
    }
    
    func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard animated else {
            alpha = 1
            transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            return
        }
        
        UIView.animate(withDuration: 0.7, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: { _ in
            if let completion = completion {
                completion()
            }
        })
    }
    
    func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard animated else {
            alpha = 0
            transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
            connectionInfoPopup.hide()
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }, completion: { _ in
            self.connectionInfoPopup.hide()
            
            if let completion = completion {
                completion()
            }
        })
    }
    
    func updateView() {
        connectionInfoPopup.updateView()
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopup), name: Notification.Name.HideConnectionInfoPopup, object: nil)
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIScene.didActivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.size.equalTo(radius1)
        }
    }
    
    private func initCircle(_ circle: UIView, radius: CGFloat) {
        addSubview(circle)
        
        circle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(radius)
            make.height.equalTo(radius)
        }
        
        circle.layer.cornerRadius = radius / 2
        circle.clipsToBounds = true
    }
    
    private func updateCircle(_ circle: UIView, color: UIColor) {
        UIView.animate(withDuration: 0.25, animations: {
            circle.backgroundColor = color
        })
    }
    
    private func initCircles() {
        initCircle(circle1, radius: radius1)
        initCircle(circle2, radius: radius2)
        
        circle1.addSubview(animatedCircle)
        circle1.isUserInteractionEnabled = false
        animatedCircle.isUserInteractionEnabled = false
        
        animatedCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(radius1)
            make.height.equalTo(radius1)
        }
        
        animatedCircle.layer.addSublayer(animatedCircleLayer)
    }
    
    private func initLocationButton() {
        locationButton.setTitleColor(redColor, for: .normal)
        locationButton.titleLabel?.font = .systemFont(ofSize: 10)
        locationButton.addTarget(self, action: #selector(markerAction), for: .touchUpInside)
        addSubview(locationButton)
        
        locationButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-11)
        }
    }
    
    private func initConnectionInfoPopup() {
        addSubview(connectionInfoPopup)
    }
    
    @objc private func markerAction() {
        if connectionInfoPopup.displayMode == .hidden {
            connectionInfoPopup.show()
            NotificationCenter.default.post(name: Notification.Name.CenterMap, object: nil)
            NotificationCenter.default.post(name: Notification.Name.HideConnectToServerPopup, object: nil)
        } else {
            connectionInfoPopup.hide()
        }
    }
    
    @objc func hidePopup() {
        connectionInfoPopup.hide()
    }
    
    @objc private func appDidBecomeActive() {
        if displayMode == .protected {
            animatedCircleLayer.startAnimation()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else {
            return nil
        }
        
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else {
                continue
            }
            
            return result
        }
        
        return nil
    }
    
}

extension MapMarkerView {
    
    enum DisplayMode {
        case unprotected
        case changing
        case protected
    }
    
    enum MarkerType {
        case local
        case gateway
    }
    
}
