//
//  WaveLayer.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 12/19/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class WaveLayer: CALayer {
    
    let connectedColor = UIColor.init(named: Theme.Key.ivpnBackgroundConnected)!
    let disconnectedColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)!
    
    override init() {
        super.init()
        backgroundColor = disconnectedColor.cgColor
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateConnection(isConnected: Bool, isAnimated: Bool) {
        let fromValue = isConnected ? disconnectedColor.cgColor : connectedColor.cgColor
        let toValue = isConnected ? connectedColor.cgColor : disconnectedColor.cgColor
        
        if isAnimated {
            let animation = CABasicAnimation(keyPath: "backgroundColor")
            animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.beginTime = CACurrentMediaTime()
            animation.duration = 0.2
            
            add(animation, forKey: nil)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundColor = toValue
        CATransaction.commit()
    }
    
    func updateLayer(backgroundColor layerBackgroundColor: CGColor) {
        backgroundColor = layerBackgroundColor
    }
    
}
