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
    
    func saveProfile(model: SecureDNS, completion: @escaping (Error?) -> Void) {
        guard model.validation().0 else {
            let error = NSError(
                domain: "NEConfigurationErrorDomain",
                code: 8,
                userInfo: [NSLocalizedDescriptionKey: "Invalid configuration operation request"]
            )
            completion(error)
            return
        }
        
        manager.loadFromPreferences { error in
            self.manager.dnsSettings = self.getDnsSettings(model: model)
            self.manager.onDemandRules = self.getOnDemandRules(model: model)
            self.manager.saveToPreferences { error in
                completion(error)
            }
        }
    }
    
    func loadProfile(completion: @escaping (Error?) -> Void) {
        manager.loadFromPreferences { error in
            completion(error)
        }
    }
    
    func removeProfile(completion: @escaping (Error?) -> Void) {
        manager.removeFromPreferences { error in
            completion(error)
        }
    }
    
    func saveResolvedDNS(server: String) {
        DNSResolver.resolve(host: server) { list in
            var addresses: [String]? = nil
            
            for ip in list {
                if let host = ip.host {
                    addresses?.append(host)
                }
            }
            
            UserDefaults.standard.set(addresses, forKey: UserDefaults.Key.resolvedDNSOutsideVPN)
            NotificationCenter.default.post(name: Notification.Name.UpdateResolvedDNS, object: nil)
        }
    }
    
    // MARK: - Private methods -
    
    private func getDnsSettings(model: SecureDNS) -> NEDNSSettings {
        let servers = UserDefaults.standard.value(forKey: UserDefaults.Key.resolvedDNSOutsideVPN) as? [String] ?? []
        let type = SecureDNSType.init(rawValue: model.type)

        if type == .dot {
            let dnsSettings = NEDNSOverTLSSettings(servers: servers)
            dnsSettings.serverName = model.serverName
            return dnsSettings
        } else {
            let dnsSettings = NEDNSOverHTTPSSettings(servers: servers)
            dnsSettings.serverURL = URL.init(string: model.serverURL ?? "")
            return dnsSettings
        }
    }
    
    private func getOnDemandRules(model: SecureDNS) -> [NEOnDemandRule] {
        var onDemandRules: [NEOnDemandRule] = []
        
        let mobileNetworkRule = model.mobileNetwork ? NEOnDemandRuleConnect() : NEOnDemandRuleDisconnect()
        mobileNetworkRule.interfaceTypeMatch = .cellular
        onDemandRules.append(mobileNetworkRule)
        
        let wifiNetworkRule = model.wifiNetwork ? NEOnDemandRuleConnect() : NEOnDemandRuleDisconnect()
        wifiNetworkRule.interfaceTypeMatch = .wiFi
        onDemandRules.append(wifiNetworkRule)
        
        onDemandRules.append(NEOnDemandRuleConnect())
        
        return onDemandRules
    }
    
}
