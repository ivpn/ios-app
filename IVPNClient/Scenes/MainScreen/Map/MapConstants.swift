//
//  MapConstants.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 24/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
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
            if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
                return iPadLandscapeTopAnchor
            }
            
            return topAnchor + 10
        }
        
        static func getLeftAnchor() -> Int {
            if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
                return iPadLandscapeLeftAnchor
            }
            
            return leftAnchor
        }
        
        static func getBottomAnchor() -> Int {
            if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
                return iPadLandscapeBottomAnchor
            }
            
            if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
                return bottomAnchorC
            }
            
            if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
                return bottomAnchorB
            }
            
            return bottomAnchorA
        }
    }
    
}
