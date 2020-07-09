//
//  ProgressIndicator.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-09-26.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
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
