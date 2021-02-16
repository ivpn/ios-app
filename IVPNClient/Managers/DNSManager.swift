//
//  DNSManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-02-16.
//  Copyright (c) 2021 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import NetworkExtension

@available(iOS 14.0, *)
class DNSManager {
    
    // MARK: - Properties -
    
    static let shared = DNSManager()
    
    var isEnabled: Bool {
        return manager.isEnabled
    }
    
    private let manager = NEDNSSettingsManager.shared()
    
    // MARK: - Initialize -
    
    private init() {}
    
    // MARK: - Methods -
    
    func saveProfile(model: SecureDNS, completion: @escaping (Error?) -> ()) {
        manager.loadFromPreferences { error in
            let dnsSettings = NEDNSSettings(servers: [model.ipAddress ?? ""])
            self.manager.dnsSettings = dnsSettings
            self.manager.onDemandRules = [NEOnDemandRuleConnect()]
            self.manager.saveToPreferences { error in
                completion(error)
            }
        }
    }
    
    func removeProfile(completion: @escaping (Error?) -> ()) {
        manager.removeFromPreferences { error in
            completion(error)
        }
    }
    
}
