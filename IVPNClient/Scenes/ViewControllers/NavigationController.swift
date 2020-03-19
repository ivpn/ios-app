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
    }
    
}
