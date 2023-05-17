//
//  UIWindow+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-25.
//  Copyright (c) 2023 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

extension UIWindow {
    
    static var interfaceOrientation: UIInterfaceOrientation {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation ?? .portrait
    }
    
    static var isLandscape: Bool {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation
            .isLandscape ?? false
    }
    
    static var isPortrait: Bool {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation
            .isPortrait ?? false
    }
    
    static var keyWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }
    }
    
}
