//
//  NavigationController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-12-21.
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

class NavigationController: UINavigationController {
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        UINavigationBar.appearance().tintColor = UIColor.init(named: Theme.ivpnBlue)
        navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.init(named: Theme.ivpnLabelPrimary)!]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.init(named: Theme.ivpnLabelPrimary)!]
            appearance.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)!
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.init(named: Theme.ivpnLabelPrimary)!]
            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { [weak self] in
            self?.navigationBar.sizeToFit()
        }
    }
    
}
