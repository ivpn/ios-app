//
//  MapMarkerView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

class MapMarkerView: UIView {
    
    // MARK: - Properties -
    
    private var circle1 = UIView()
    private var circle2 = UIView()
    private var circle3 = UIView()
    private var circle4 = UIView()
    private var blueColor = UIColor.init(red: 68, green: 156, blue: 248)
    
    // MARK: - View lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        setupConstraints()
        initCircles()
        updateCircles(color: blueColor)
        
        super.updateConstraints()
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.center().size(width: 187, height: 187)
    }
    
    private func initCircle(_ circle: UIView, radius: CGFloat) {
        addSubview(circle)
        circle.bb.center().size(width: radius, height: radius)
        circle.layer.cornerRadius = radius / 2
        circle.clipsToBounds = true
    }
    
    private func updateCircle(_ circle: UIView, color: UIColor) {
        circle.backgroundColor = color
    }
    
    private func initCircles() {
        initCircle(circle1, radius: 187)
        initCircle(circle2, radius: 97)
        initCircle(circle3, radius: 41)
        initCircle(circle4, radius: 9)
    }
    
    private func updateCircles(color: UIColor) {
        updateCircle(circle1, color: color.withAlphaComponent(0.1))
        updateCircle(circle2, color: color.withAlphaComponent(0.3))
        updateCircle(circle3, color: color.withAlphaComponent(0.5))
        updateCircle(circle4, color: color)
    }
    
}
