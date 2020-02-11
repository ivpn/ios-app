//
//  CircleProgressLayer.swift
//  AnimationTests
//
//  Created by Fedir Nepyyvoda on 12/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class CircleProgressLayer: CAShapeLayer {

    override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
        path = circle.cgPath
        
        lineWidth = CGFloat(CircleParameters.circleStrokeWidth)
        strokeColor = CircleParameters.activeColor.cgColor
        strokeEnd = 0
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var circle: UIBezierPath {
        let section = UIBezierPath(
            arcCenter: CGPoint(
                x: CircleParameters.circleSize / 2,
                y: CircleParameters.circleSize / 2
            ),
            radius: CGFloat((CircleParameters.circleSize) / 2),
            startAngle: -.pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: true
        )
        
        return section
    }
    
    func animateProgress() {
        
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.01, 0.8, 0.25, 0.8)
        
        let strokeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.0
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = 60
        strokeAnimation.timingFunction = timingFunction
        add(strokeAnimation, forKey: "progressAnimation")
    }
    
    func finishAnimationQuickly() {
        
        let currentValue = self.presentation()?.value(forKey: "strokeEnd")
        let strokeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = currentValue
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = 0.2
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        add(strokeAnimation, forKey: "progressAnimation")
    }
    
}
