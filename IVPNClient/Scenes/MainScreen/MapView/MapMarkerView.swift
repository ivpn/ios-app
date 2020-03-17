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
        
        addSubview(circle1)
        circle1.bb.center().size(width: 187, height: 187)
        circle1.layer.cornerRadius = 187 / 2
        circle1.clipsToBounds = true
        circle1.backgroundColor = blueColor.withAlphaComponent(0.1)
        
        addSubview(circle2)
        circle2.bb.center().size(width: 97, height: 97)
        circle2.layer.cornerRadius = 97 / 2
        circle2.clipsToBounds = true
        circle2.backgroundColor = blueColor.withAlphaComponent(0.3)
        
        addSubview(circle3)
        circle3.bb.center().size(width: 41, height: 41)
        circle3.layer.cornerRadius = 41 / 2
        circle3.clipsToBounds = true
        circle3.backgroundColor = blueColor.withAlphaComponent(0.5)
        
        addSubview(circle4)
        circle4.bb.center().size(width: 9, height: 9)
        circle4.layer.cornerRadius = 9 / 2
        circle4.clipsToBounds = true
        circle4.backgroundColor = blueColor
        
        super.updateConstraints()
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.center().size(width: 187, height: 187)
    }
    
}
