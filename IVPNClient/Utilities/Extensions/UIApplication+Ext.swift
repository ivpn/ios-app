//
//  UIApplication+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-28.
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

extension UIApplication {
    
    public var isSplitOrSlideOver: Bool {
        guard let window = self.windows.filter({ $0.isKeyWindow }).first else {
            return false
        }

        return !(window.frame.width == window.screen.bounds.width) && !(window.frame.width == window.screen.bounds.height)
    }
    
    class func topViewController() -> UIViewController? {
        let vc = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap( { $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .topMostViewController()
        
        return vc
    }
    
    class func isValidURL(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        
        return false
    }
    
    class func openNetworkSettings() {
        if let url = URL(string: "App-prefs:root=General") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                if let topViewController = topViewController() {
                    topViewController.showAlert(title: "Cannot open Network/VPN settings", message: "Please go to iOS Settings - General - VPN & Network.")
                }
            }
        }
    }
    
}
