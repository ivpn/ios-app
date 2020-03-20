//
//  NavigationController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 21/12/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        UINavigationBar.appearance().tintColor = UIColor.init(named: Theme.Key.ivpnBlue)
        navigationBar.barTintColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.init(named: Theme.Key.ivpnLabelPrimary)!]
        
        // Hide navigation bar 1px bottom line
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            navigationBar.standardAppearance = appearance
        } else {
            navigationBar.setBackgroundImage(#imageLiteral(resourceName: "BarBackground"), for: .default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
}
