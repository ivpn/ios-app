//
//  WaveView.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 12/19/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class WaveView: UIView {
    
    var waveLayer = WaveLayer()
    var isConnected = false
    var userInterfaceStyle: Int = 1 // UIUserInterfaceStyle.light
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.insertSublayer(waveLayer, at: 0)
        
        if #available(iOS 13.0, *) {
            userInterfaceStyle = UIView().traitCollection.userInterfaceStyle.rawValue
        }
    }
    
    override func layoutSubviews() {
        waveLayer.frame = self.bounds
        
        if #available(iOS 13.0, *) {
            guard userInterfaceStyle != UIView().traitCollection.userInterfaceStyle.rawValue else {
                return
            }

            userInterfaceStyle = UIView().traitCollection.userInterfaceStyle.rawValue
            waveLayer.removeFromSuperlayer()
            waveLayer = WaveLayer()
            let backgroundColor = isConnected ? UIColor.init(named: Theme.Key.ivpnBackgroundConnected)!.cgColor : UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)!.cgColor
            waveLayer.updateLayer(backgroundColor: backgroundColor)
            layer.insertSublayer(waveLayer, at: 0)
            waveLayer.frame = self.bounds
        }
    }
    
    func setConnected(isConnected: Bool, isAnimated: Bool) {
        self.isConnected = isConnected
        waveLayer.animateConnection(isConnected: isConnected, isAnimated: isAnimated)
    }
    
}
