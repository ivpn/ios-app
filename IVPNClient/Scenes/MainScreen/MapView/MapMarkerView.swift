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
    
    private var circle1 = UIView()
    private var circle2 = UIView()
    private var circle3 = UIView()
    private var circle4 = UIView()
    private var connectionInfoPopup = ConnectionInfoPopupView()
    private var blueColor = UIColor.init(red: 68, green: 156, blue: 248)
    private var redColor = UIColor.init(red: 255, green: 98, blue: 88)
    private var grayColor = UIColor.init(red: 211, green: 211, blue: 211)
    
    // MARK: - View lifecycle -
    
    override func updateConstraints() {
        setupConstraints()
        initCircles()
        updateCircles(color: blueColor)
        initActionButton()
        initConnectionInfoPopup()
        
        super.updateConstraints()
    }
    
    // MARK: - Methods -
    
    func updateCircles(color: UIColor) {
        updateCircle(circle1, color: color.withAlphaComponent(0.1))
        updateCircle(circle2, color: color.withAlphaComponent(0.3))
        updateCircle(circle3, color: color.withAlphaComponent(0.5))
        updateCircle(circle4, color: color)
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.center().size(width: 270, height: 187)
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
        initCircle(circle1, radius: 187)
        initCircle(circle2, radius: 97)
        initCircle(circle3, radius: 41)
        initCircle(circle4, radius: 9)
    }
    
    private func initActionButton() {
        let actionButton = UIButton()
        addSubview(actionButton)
        actionButton.bb.center().size(width: 187, height: 187)
        actionButton.addTarget(self, action: #selector(markerAction), for: .touchUpInside)
    }
    
    private func initConnectionInfoPopup() {
        addSubview(connectionInfoPopup)
    }
    
    @objc private func markerAction() {
        // TODO: Present connection info popup
    }
    
}
