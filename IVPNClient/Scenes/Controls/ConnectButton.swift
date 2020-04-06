//
//  ConnectButton.swift
//  AnimationTests
//
//  Created by Fedir Nepyyvoda on 12/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class ConnectButton: UIControl {
    
    // MARK: - Properties -
    
    var inactiveCircle = CircleLayer()
    var progressCircle = CircleProgressLayer()
    var connectedCircle = CircleConnected()
    var inactiveImageLayer = ImageLayer(imageName: "icon-inactive-shield")
    var waveLayer = CircleWaveLayer()
    var userInterfaceStyle: Int = 1 // UIUserInterfaceStyle.light
    
    private (set) var buttonState: ConnectButtonState = .disconnected {
        didSet {
            switch buttonState {
            case .connected:
                self.accessibilityLabel = "Tap to disconnect"
                return
            case .disconnected:
                self.accessibilityLabel = "Tap to connect"
                return
            default:
                break
            }
        }
    }
    
    // MARK: - Initialize -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            userInterfaceStyle = UIView().traitCollection.userInterfaceStyle.rawValue
        }
                
        setImmediateState(newState: .disconnected)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods -
    
    func setImmediateState(newState: ConnectButtonState) {
        removeSublayers()
        
        switch newState {
            
        case .connected:
            
            inactiveImageLayer.displayMinimized()
            
            connectedCircle.setConnected(true)
            layer.addSublayer(connectedCircle)
            
            inactiveImageLayer.displayMinimized()
            layer.addSublayer(inactiveImageLayer)
            
            layer.addSublayer(waveLayer)
            waveLayer.startAnimation()
            
        case .connecting:
            
            connectedCircle.setConnected(false)
            layer.addSublayer(inactiveCircle)
            layer.addSublayer(progressCircle)
            
            inactiveImageLayer.displayNormal()
            layer.addSublayer(inactiveImageLayer)
            
            progressCircle.animateProgress()
            
        case .disconnected:
            
            connectedCircle.setConnected(false)
            
            inactiveImageLayer.displayNormal()
            layer.addSublayer(inactiveImageLayer)
            
            layer.addSublayer(inactiveCircle)
            layer.addSublayer(progressCircle)
            
        }
        
        buttonState = newState
    }
    
    func startConnectAnimation() {
        progressCircle.animateProgress()
    }
    
    func startDisconnectAnimation() {
        waveLayer.removeAllAnimations()
        
        connectedCircle.startDisconnectedAnimation()
        
        inactiveImageLayer.displayMinimized()
        layer.addSublayer(inactiveImageLayer)
        inactiveImageLayer.fadeIn(delay: 0.5)   
        buttonState = .disconnected
    }
    
    @objc func startAnimatingWaves() {
        if buttonState == .connected {
            waveLayer.startAnimation()
        }
    }
    
    @objc func startConnectedAnimation() {
        self.layer.addSublayer(self.connectedCircle)
        self.progressCircle.removeFromSuperlayer()
        
        if !(layer.sublayers?.contains(waveLayer) ?? false) {
            layer.addSublayer(waveLayer)
        }
        
        self.inactiveCircle.removeFromSuperlayer()
        self.inactiveImageLayer.fadeOut()
        self.connectedCircle.startConnectedAnimation()
        buttonState = .connected
        
        Timer.scheduledTimer(
            timeInterval: 0.6,
            target: self,
            selector: #selector(startAnimatingWaves),
            userInfo: nil,
            repeats: false
        )
    }
    
    func connectedAnimation() {
        DispatchQueue.delay(0.1) {
            Application.shared.connectionManager.getStatus { _, status in
                guard status == .connected else { return }
                
                self.progressCircle.finishAnimationQuickly()
                
                Timer.scheduledTimer(
                    timeInterval: 0.2,
                    target: self,
                    selector: #selector(self.startConnectedAnimation),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }
    
    override func layoutSubviews() {
        if #available(iOS 13.0, *) {
            guard userInterfaceStyle != UIView().traitCollection.userInterfaceStyle.rawValue else {
                return
            }
            
            userInterfaceStyle = UIView().traitCollection.userInterfaceStyle.rawValue
            removeSublayers()
            initSublayers()
            setImmediateState(newState: buttonState)
        }
    }
    
    private func removeSublayers() {
        inactiveCircle.removeFromSuperlayer()
        progressCircle.removeFromSuperlayer()
        connectedCircle.removeFromSuperlayer()
        inactiveImageLayer.removeFromSuperlayer()
        waveLayer.removeFromSuperlayer()
        
        inactiveCircle.removeAllAnimations()
        progressCircle.removeAllAnimations()
        connectedCircle.removeAllAnimations()
        inactiveImageLayer.removeAllAnimations()
        waveLayer.removeAllAnimations()
    }
    
    private func initSublayers() {
        inactiveCircle = CircleLayer()
        progressCircle = CircleProgressLayer()
        connectedCircle = CircleConnected()
        inactiveImageLayer = ImageLayer(imageName: "icon-inactive-shield")
        waveLayer = CircleWaveLayer()
    }
    
}

// MARK: - ConnectButtonState enum -

extension ConnectButton {
    
    enum ConnectButtonState {
        case disconnected
        case connecting
        case connected
    }
    
}
