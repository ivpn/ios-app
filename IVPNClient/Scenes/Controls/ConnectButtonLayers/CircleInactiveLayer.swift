//
//  CicleLayer.swift
//  AnimationTests
//
//  Created by Fedir Nepyyvoda on 12/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class CircleLayer: CAShapeLayer {
    
    // MARK: - Properties -
    
    private var circle: UIBezierPath {
        let centerPoint = CGPoint(
            x: CircleParameters.circleSize / 2,
            y: CircleParameters.circleSize / 2
        )
        
        return UIBezierPath(
            arcCenter: centerPoint,
            radius: CGFloat(CircleParameters.circleSize / 2),
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true)
    }
    
    // MARK: - Initialize -
    
    override init() {
        super.init()
        
        fillColor = UIColor.clear.cgColor
        strokeColor = CircleParameters.inactiveColor.cgColor
        
        lineWidth = CGFloat(CircleParameters.circleStrokeWidth)
        path = circle.cgPath
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
