//
//  CircleConnected.swift
//  AnimationTests
//
//  Created by Fedir Nepyyvoda on 12/18/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class CircleConnected: CAShapeLayer {
    
    // MARK: - Properties -
    
    var activeImageLayer = ImageLayer(imageName: "icon-active-shield", isMinimized: true)
    
    // MARK: - Initialize -
    
    override init() {
        super.init()
        
        fillColor = CircleParameters.activeColor.cgColor
        path = circleConnecting.cgPath
        
        addSublayer(activeImageLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CALayer -
    
    override func removeAllAnimations() {
        super.removeAllAnimations()
        activeImageLayer.removeAllAnimations()
    }
    
    // MARK: - Methods -
    
    func setConnected(_ isConnected: Bool) {
        fillColor = CircleParameters.activeColor.cgColor
        
        if isConnected {
            activeImageLayer.displayNormal()
            path = circleConnected.cgPath
        } else {
            activeImageLayer.displayMinimized()
            path = circleConnecting.cgPath
        }
    }
    
    private var circleConnecting: UIBezierPath {
        let centerPoint = CGPoint(
            x: CircleParameters.circleSize / 2,
            y: CircleParameters.circleSize / 2
        )
        
        let section = UIBezierPath(
            arcCenter: centerPoint,
            radius: CGFloat((CircleParameters.circleSize + CircleParameters.circleStrokeWidth) / 2),
            startAngle: -.pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: true
        )
        
        section.addArc(
            withCenter: centerPoint,
            radius: CGFloat((CircleParameters.circleSize - CircleParameters.circleStrokeWidth) / 2),
            startAngle: .pi * 2 - .pi / 2,
            endAngle: -.pi / 2,
            clockwise: false
        )
        
        section.close()
        
        return section
    }
    
    private var circleStage1: UIBezierPath {
        let centerPoint = CGPoint(
            x: CircleParameters.circleSize / 2,
            y: CircleParameters.circleSize / 2
        )
        
        let section = UIBezierPath(
            arcCenter: centerPoint,
            radius: CGFloat((CircleParameters.circleSize + CircleParameters.circleStrokeWidth) / 2),
            startAngle: -.pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: true
        )
        
        section.addArc(
            withCenter: centerPoint,
            radius: CGFloat((CircleParameters.circleSize) / 2),
            startAngle: .pi * 2 - .pi / 2,
            endAngle: -.pi / 2,
            clockwise: false
        )
        
        section.close()
        
        return section
    }
    
    private var circleConnected: UIBezierPath {
        let centerPoint = CGPoint(
            x: CircleParameters.circleSize / 2,
            y: CircleParameters.circleSize / 2
        )
        
        let section = UIBezierPath(
            arcCenter: centerPoint,
            radius: CGFloat((CircleParameters.circleSize + CircleParameters.circleStrokeWidth) / 2),
            startAngle: -.pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: true
        )
        
        section.addArc(
            withCenter: centerPoint,
            radius: CGFloat(0),
            startAngle: .pi * 2 - .pi / 2,
            endAngle: -.pi / 2,
            clockwise: false
        )
        
        section.close()
        
        return section
    }
    
    func startConnectedAnimation() {
        let animation1: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animation1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation1.fromValue = circleConnecting.cgPath
        animation1.toValue = circleStage1.cgPath
        animation1.beginTime = 0
        animation1.duration = 0.2
        
        let animation2: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animation2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation2.fromValue = circleStage1.cgPath
        animation2.toValue = circleConnected.cgPath
        animation2.beginTime = animation1.beginTime + animation1.duration
        animation2.duration = 0.5
        
        let group = CAAnimationGroup()
        group.animations = [
            animation1,
            animation2
        ]
        
        group.duration = animation1.duration + animation2.duration
        group.fillMode = CAMediaTimingFillMode.forwards
        group.isRemovedOnCompletion = false
        
        activeImageLayer.fadeIn()
        add(group, forKey: nil)
    }
    
    func startDisconnectedAnimation() {
        activeImageLayer.fadeOut(delay: 0)
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fromValue = circleConnected.cgPath
        animation.toValue = circleConnecting.cgPath
        animation.beginTime = CACurrentMediaTime() + 0.5
        animation.duration = 0.5
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        add(animation, forKey: nil)
        
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.toValue = CircleParameters.inactiveColor.cgColor
        colorAnimation.beginTime = CACurrentMediaTime() + 0.5
        colorAnimation.duration = 0.5
        colorAnimation.fillMode = CAMediaTimingFillMode.forwards
        colorAnimation.isRemovedOnCompletion = false
        add(colorAnimation, forKey: nil)
    }
    
}
