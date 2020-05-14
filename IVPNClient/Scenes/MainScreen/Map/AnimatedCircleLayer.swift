//
//  AnimatedCircleLayer.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 14/05/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class AnimatedCircleLayer: CAShapeLayer {
    
    // MARK: - Properties -
    
    private let radius = 160
    
    private var circle: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(x: radius / 2, y: radius / 2),
            radius: CGFloat(radius / 2),
            startAngle: 0,
            endAngle: CGFloat(.pi * 2.0),
            clockwise: true)
    }
    
    private var circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.init(red: 68, green: 156, blue: 248).cgColor
        return circleLayer
    }()
    
    // MARK: - Initialize -
    
    override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
        path = circle.cgPath
        opacity = 0
        frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        
        circleLayer.path = circle.cgPath
        addSublayer(circleLayer)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods -
    
    func startAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        scaleAnimation.duration = 2
        scaleAnimation.fillMode = CAMediaTimingFillMode.forwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.fromValue = 0.4
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 2
        opacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, opacityAnimation]
        groupAnimation.duration = 4
        groupAnimation.repeatCount = .greatestFiniteMagnitude
    
        add(groupAnimation, forKey: "groupanimation")
    }
    
    func stopAnimations() {
        removeAllAnimations()
    }
    
}
