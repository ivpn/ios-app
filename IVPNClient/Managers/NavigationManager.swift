//
//  NavigationManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-10.
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
import WebKit
import SnapKit

class NavigationManager {
    
    static func getMainViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "mainView")
        viewController.modalPresentationStyle = .fullScreen
        
        return viewController
    }
    
    static func getLoginViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "loginView")
        
        return viewController
    }
    
    static func getChangePlanViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "selectPlanView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? SelectPlanViewController {
            let serviceType = ServiceType.getType(currentPlan: Application.shared.serviceStatus.currentPlan)
            viewController.changingPlan = true
            viewController.service = Service(type: serviceType, duration: .month)
        }
        
        return navController!
    }
    
    static func getSelectPlanViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "selectPlanView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? SelectPlanViewController {
            viewController.selectingPlan = true
        }
        
        return navController!
    }
    
    static func getSubscriptionViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "subscriptionView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? PaymentViewController {
            let serviceType = ServiceType.getType(currentPlan: Application.shared.serviceStatus.currentPlan)
            viewController.extendingService = true
            viewController.service = Service(type: serviceType, duration: .year)
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
    
    static func getSettingsViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyBoard.instantiateViewController(withIdentifier: "settingsView")
    }
    
    static func getAccountViewController() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyBoard.instantiateViewController(withIdentifier: "accountView")
    }
    
    static func getControlPanelViewController() -> UITableViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyBoard.instantiateViewController(withIdentifier: "controlPanelView") as! ControlPanelViewController
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
    
    static func getTwoFactorViewController(delegate: TwoFactorViewControllerDelegate? = nil) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "twoFactorView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? TwoFactorViewController {
            viewController.delegate = delegate
        }
        
        return navController!
    }
    
    static func getCaptchaViewController(delegate: CaptchaViewControllerDelegate? = nil, imageData: String, captchaId: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "captchaView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? CaptchaViewController {
            viewController.delegate = delegate
            viewController.imageData = imageData
            viewController.captchaId = captchaId
        }
        
        return navController!
    }
    
    static func getWebkitViewController(webView: WKWebView) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Signup", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "webkitView") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController {
            viewController.view.addSubview(webView)
            viewController.navigationController?.navigationBar.prefersLargeTitles = false
            webView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.top.equalToSuperview()
            }
        }
        
        return navController!
    }
    
    static func getAddCustomPortViewController(delegate: AddCustomPortViewControllerDelegate? = nil) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "addCustomPort") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? AddCustomPortViewController {
            viewController.delegate = delegate
        }
        
        return navController!
    }
    
    static func getMTUViewController(delegate: MTUViewControllerDelegate? = nil) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "configureMtu") as? UINavigationController
        navController?.modalPresentationStyle = .formSheet
        
        if let viewController = navController?.topViewController as? MTUViewController {
            viewController.delegate = delegate
        }
        
        return navController!
    }
    
}
