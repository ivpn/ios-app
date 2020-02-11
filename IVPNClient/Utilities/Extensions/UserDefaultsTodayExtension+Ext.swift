//
//  UserDefaultsTodayExtension+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 17/09/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    @objc dynamic var isLoggedIn: Bool {
        let username = KeyChain.username ?? ""
        let sessionToken = KeyChain.sessionToken ?? ""
        return !username.isEmpty || !sessionToken.isEmpty
    }
    
    @objc dynamic var connectionStatus: Int {
        return integer(forKey: Key.connectionStatus)
    }
    
    @objc dynamic var connectionLocation: String {
        return string(forKey: Key.connectionLocation) ?? ""
    }
    
    @objc dynamic var connectionIpAddress: String {
        return string(forKey: Key.connectionIpAddress) ?? ""
    }
    
}
