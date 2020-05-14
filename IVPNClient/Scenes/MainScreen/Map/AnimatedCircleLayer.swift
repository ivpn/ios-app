//
//  AnimatedCircleLayer.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 14/05/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class AnimatedCircleLayer: CAShapeLayer {
    
    private var circle: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(x: CircleParameters.circleSize / 2, y: CircleParameters.circleSize / 2),
            radius: CGFloat(CircleParameters.circleSize / 2) - 10,
            startAngle: 0,
            endAngle: CGFloat(.pi * 2.0),
            clockwise: true)
    }
    
    override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
        path = circle.cgPath
        opacity = 0
        frame = CGRect(x: 0, y: 0, width: CircleParameters.circleSize, height: CircleParameters.circleSize)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circle.cgPath
        circleLayer.fillColor = UIColor.init(red: 68, green: 156, blue: 248).cgColor
        addSublayer(circleLayer)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        scaleAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, opacityAnimation]
        groupAnimation.duration = 2.5
        groupAnimation.repeatCount = .greatestFiniteMagnitude
        groupAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        add(groupAnimation, forKey: "groupanimation")
    }
    
}
