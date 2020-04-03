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
                updateCircles(color: grayColor)
            case .connected:
                updateCircles(color: blueColor)
            default:
                updateCircles(color: redColor)
            }
            
            connectionInfoPopup.vpnStatusViewModel = VPNStatusViewModel(status: status)
        }
    }
    
    var connectionInfoPopup = ConnectionInfoPopupView()
    private var circle1 = UIView()
    private var circle2 = UIView()
    private var circle3 = UIView()
    private var circle4 = UIView()
    private var blueColor = UIColor.init(red: 68, green: 156, blue: 248)
    private var redColor = UIColor.init(red: 255, green: 98, blue: 88)
    private var grayColor = UIColor.init(red: 211, green: 211, blue: 211)
    private var radius1: CGFloat = 187
    private var radius2: CGFloat = 97
    private var radius3: CGFloat = 41
    private var radius4: CGFloat = 9
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        updateSize()
        setupConstraints()
        initCircles()
        updateCircles(color: grayColor)
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
        updateCircle(circle1, color: color.withAlphaComponent(0.1))
        updateCircle(circle2, color: color.withAlphaComponent(0.3))
        updateCircle(circle3, color: color.withAlphaComponent(0.5))
        updateCircle(circle4, color: color)
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopup), name: Notification.Name.HideConnectionInfoPopup, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.HideConnectionInfoPopup, object: nil)
    }
    
    // MARK: - Private methods -
    
    private func updateSize() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            radius1 = 340
            radius2 = 176
            radius3 = 75
            radius4 = 16
        }
    }
    
    private func setupConstraints() {
        bb.center().size(width: 340, height: radius1)
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
        initCircle(circle4, radius: radius4)
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
    
}
