//
//  UIApplication.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 28/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    class func manageSubscription() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                if let topViewController = topViewController() {
                    topViewController.showAlert(title: "Cannot open subscription settings", message: "Please go to App Store app to manage your auto-renewable subscriptions.")
                }
            }
        }
    }
    
    class func isValidURL(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        
        return false
    }
    
}
