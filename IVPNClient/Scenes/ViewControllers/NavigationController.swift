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
        navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.init(named: Theme.Key.ivpnLabelPrimary)!]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.init(named: Theme.Key.ivpnLabelPrimary)!]
            appearance.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)!
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.init(named: Theme.Key.ivpnLabelPrimary)!]
            navigationBar.setBackgroundImage(#imageLiteral(resourceName: "BarBackground"), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { [weak self] in
            self?.navigationBar.sizeToFit()
        }
    }
    
}
