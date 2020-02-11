//
//  ProgressIndicator.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 9/26/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit
import JGProgressHUD

public class ProgressIndicator {
    
    static let shared = ProgressIndicator()
    
    var containerView = UIView()
    let hud = JGProgressHUD(style: .dark)
    
    public func showIn(view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor.init(red: 44/255, green: 44/255, blue: 46/255, alpha: 0.5)
        view.addSubview(containerView)
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.parallaxMode = .alwaysOff
        hud.show(in: view)
    }
    
    public func hide() {
        hud.dismiss()
        containerView.removeFromSuperview()
    }
    
}
