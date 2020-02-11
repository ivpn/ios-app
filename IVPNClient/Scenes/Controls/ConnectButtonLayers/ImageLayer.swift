//
//  ImageLayer.swift
//  AnimationTests
//
//  Created by Fedir Nepyyvoda on 12/18/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class ImageLayer: CALayer, CAAnimationDelegate {

    convenience init(imageName: String, isMinimized: Bool = false) {
        self.init()
        
        let image = UIImage(named: imageName)?.cgImage
        contents = image
        
        frame = normalFrame
        contents = UIImage(named: imageName)?.cgImage
        
        if isMinimized {
            transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1)
        }
        
    }
    
    var normalFrame: CGRect {
        return CGRect(x: CircleParameters.circleSize / 2 - 32,
               y: CircleParameters.circleSize / 2 - 20,
               width: 64,
               height: 41
        )
    }
    
    func displayNormal() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        CATransaction.commit()
    }
    
    func displayMinimized() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1)
        CATransaction.commit()
    }
    
    private var wasFadingIn: Bool = false
    
    func fadeOut(delay: CFTimeInterval = 0.2) {
        wasFadingIn = false
        
        let animation = CABasicAnimation(keyPath: "transform")
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, 0, 0, 1)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.toValue = transform
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = 0.5
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        add(animation, forKey: "fadeAnimation")
    }
    
    func fadeIn(delay: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform")
        wasFadingIn = true
        
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fromValue = CATransform3DScale(CATransform3DIdentity, 0, 0, 1)
        animation.toValue = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = 0.5
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        add(animation, forKey: "fadeAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if wasFadingIn {
                displayNormal()
            } else {
                displayMinimized()
            }
        }
    }
    
}
