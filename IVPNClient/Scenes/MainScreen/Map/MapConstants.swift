//
//  MapConstants.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-24.
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

class MapConstants {
    
    class Container {
        static let leftAnchor = 0
        static let topAnchor = 25
        static let bottomAnchorA = 230
        static let bottomAnchorB = 274
        static let bottomAnchorC = 359
        static let iPadLandscapeLeftAnchor = 375
        static let iPadLandscapeTopAnchor = 0
        static let iPadLandscapeBottomAnchor = 0
        
        static func getTopAnchor() -> Int {
            if UIDevice.current.userInterfaceIdiom == .pad && UIWindow.isLandscape && !UIApplication.shared.isSplitOrSlideOver {
                return iPadLandscapeTopAnchor
            }
            
            if UIDevice.current.hasNotch {
                return topAnchor / 2
            }
            
            return topAnchor + 10
        }
        
        static func getLeftAnchor() -> Int {
            if UIDevice.current.userInterfaceIdiom == .pad && UIWindow.isLandscape && !UIApplication.shared.isSplitOrSlideOver {
                return iPadLandscapeLeftAnchor
            }
            
            return leftAnchor
        }
        
        static func getBottomAnchor() -> Int {
            if UIDevice.current.userInterfaceIdiom == .pad && UIWindow.isLandscape && !UIApplication.shared.isSplitOrSlideOver {
                return iPadLandscapeBottomAnchor
            }
            
            if Application.shared.settings.connectionProtocol.tunnelType() != .ipsec && UserDefaults.shared.isMultiHop {
                return bottomAnchorC
            }
            
            if Application.shared.settings.connectionProtocol.tunnelType() != .ipsec {
                return bottomAnchorB
            }
            
            return bottomAnchorA
        }
    }
    
}
