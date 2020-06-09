//
//  MapMarkerView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo
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
    
    var connectionInfoPopup = ConnectionInfoPopupView()
    private var circle1 = UIView()
    private var circle2 = UIView()
    private var circle3 = UIView()
    private var animatedCircle = UIView()
    private var animatedCircleLayer = AnimatedCircleLayer()
    private var radius1: CGFloat = 160
    private var radius2: CGFloat = 26
    private var radius3: CGFloat = 20
    private var blueColor = UIColor.init(red: 68, green: 156, blue: 248)
    private var redColor = UIColor.init(named: Theme.ivpnRedOff)!
    private var grayColor = UIColor.init(named: Theme.ivpnGray18)!
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        setupConstraints()
        initCircles()
        updateCircles(color: redColor)
        initActionButton()
        initConnectionInfoPopup()
        addObservers()
        
        super.updateConstraints()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Methods -
    
    func updateCircles(color: UIColor) {
        updateCircle(circle1, color: color.withAlphaComponent(0.5))
        updateCircle(circle2, color: UIColor.white)
        updateCircle(circle3, color: color)
    }
    
    func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard animated else {
            alpha = 1
            transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }) { _ in
            if let completion = completion {
                completion()
            }
        }
    }
    
    func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard animated else {
            alpha = 0
            transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }) { _ in
            if let completion = completion {
                completion()
            }
        }
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
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.HideConnectionInfoPopup, object: nil)
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.size(width: radius1, height: radius1)
    }
    
    private func initCircle(_ circle: UIView, radius: CGFloat) {
        addSubview(circle)
        circle.bb.center().size(width: radius, height: radius)
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
        initCircle(circle3, radius: radius3)
        
        circle1.addSubview(animatedCircle)
        animatedCircle.bb.center().size(width: radius1, height: radius1)
        animatedCircle.layer.addSublayer(animatedCircleLayer)
    }
    
    private func initActionButton() {
        let actionButton = UIButton()
        addSubview(actionButton)
        actionButton.bb.center().size(width: radius1, height: radius1)
        actionButton.addTarget(self, action: #selector(markerAction), for: .touchUpInside)
    }
    
    private func initConnectionInfoPopup() {
        addSubview(connectionInfoPopup)
    }
    
    @objc private func markerAction() {
        if connectionInfoPopup.displayMode == .hidden {
            connectionInfoPopup.show()
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
    
}

extension MapMarkerView {
    
    enum DisplayMode {
        case unprotected
        case changing
        case protected
    }
    
}
