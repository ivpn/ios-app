//
//  NavigationManager.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/10/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class NavigationManager {
    
    static func getMainViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "mainView")
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
    static func getLoginViewController(modalPresentationStyle: UIModalPresentationStyle = .formSheet) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "loginView")
        return viewController
    }
    
    static func getSubscriptionViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        
        let navController = storyBoard.instantiateViewController(withIdentifier: "subscriptionView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        if let viewController = navController?.topViewController as? SelectPlanViewController {
            viewController.extendingService = true
        }
        
        return navController!
    }
    
    static func getStaticWebViewController(resourceName: String, screenTitle: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "staticWebView") as! StaticWebViewController
        viewController.resourceName = resourceName
        viewController.screenTitle = screenTitle
        return viewController
    }
    
    static func getTermsOfServiceViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Initial", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: "termsOfServiceView")
    }
    
    static func getUpgradePlanViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: "upgradePlanView")
    }
    
    static func getScannerViewController(delegate: ScannerViewControllerDelegate? = nil) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        
        let navController = storyBoard.instantiateViewController(withIdentifier: "scannerView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        if let viewController = navController?.topViewController as? ScannerViewController {
            viewController.delegate = delegate
        }
        
        return navController!
    }
    
    static func getCreateAccountViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: "createAccountView")
    }
    
}
