//
//  CircleWaveLayer.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 12/19/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class CircleWaveLayer: CAShapeLayer {
    
    override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
        path = circle.cgPath
        
        frame = CGRect(x: 0,
                       y: 0,
                       width: CircleParameters.circleSize,
                       height: CircleParameters.circleSize
        )
        
        opacity = 0
        
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.init(named: Theme.Key.ivpnBlue)?.withAlphaComponent(0.5).cgColor
        circleLayer.lineWidth = 6
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.path = circle.cgPath
        
        addSublayer(circleLayer)
        
        let outerCircleLayer = CAShapeLayer()
        outerCircleLayer.strokeColor = UIColor.init(named: Theme.Key.ivpnBlue)?.withAlphaComponent(0.9).cgColor
        outerCircleLayer.lineWidth = 3
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.path = circle.cgPath
        
        addSublayer(outerCircleLayer)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var circle: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(
                x: CircleParameters.circleSize / 2,
                y: CircleParameters.circleSize / 2
            ),
            radius: CGFloat(CircleParameters.circleSize / 2) - 10,
            startAngle: 0,
            endAngle: CGFloat(.pi * 2.0),
            clockwise: true)
    }
    
    func startAnimation(delay: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform")
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        animation.fromValue = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        animation.toValue = CATransform3DScale(CATransform3DIdentity, 2.5, 2.5, 1)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 2
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.infinity
        add(animation, forKey: "fadeAnimation")
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        opacity.fromValue = 0.5
        opacity.toValue = 0
        opacity.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        opacity.duration = 2
        opacity.fillMode = CAMediaTimingFillMode.forwards
        opacity.isRemovedOnCompletion = false
        opacity.repeatCount = Float.infinity
        add(opacity, forKey: "opacity")
    }
    
}
