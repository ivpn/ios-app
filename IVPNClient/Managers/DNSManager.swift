//
//  DNSManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-02-16.
//  Copyright (c) 2021 IVPN Limited.
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
        return NEDNSSettingsManager.shared().isEnabled
    }
    
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
        
        NEDNSSettingsManager.shared().loadFromPreferences { _ in
            NEDNSSettingsManager.shared().removeFromPreferences { _ in
                NEDNSSettingsManager.shared().dnsSettings = self.getDnsSettings(model: model)
                NEDNSSettingsManager.shared().onDemandRules = self.getOnDemandRules(model: model)
                NEDNSSettingsManager.shared().saveToPreferences { error in
                    completion(error)
                }
            }
        }
    }
    
    func loadProfile(completion: @escaping (Error?) -> Void) {
        NEDNSSettingsManager.shared().loadFromPreferences { error in
            completion(error)
        }
    }
    
    func removeProfile(completion: @escaping (Error?) -> Void) {
        NEDNSSettingsManager.shared().removeFromPreferences { error in
            completion(error)
        }
    }
    
    static func saveResolvedDNS(server: String, key: String) {
        guard !server.trim().isEmpty else {
            return
        }
        
        DNSResolver.resolve(host: server) { list in
            var addresses: [String] = []
            
            for ip in list {
                if let host = ip.host {
                    addresses.append(host)
                }
            }
            
            switch key {
            case UserDefaults.Key.resolvedDNSOutsideVPN:
                UserDefaults.standard.set(addresses, forKey: UserDefaults.Key.resolvedDNSOutsideVPN)
                NotificationCenter.default.post(name: Notification.Name.UpdateResolvedDNS, object: nil)
            case UserDefaults.Key.resolvedDNSInsideVPN:
                UserDefaults.shared.set(addresses, forKey: UserDefaults.Key.resolvedDNSInsideVPN)
                NotificationCenter.default.post(name: Notification.Name.UpdateResolvedDNSInsideVPN, object: nil)
            default:
                break
            }
            
            if addresses.isEmpty {
                NotificationCenter.default.post(name: Notification.Name.ResolvedDNSError, object: nil)
            }
        }
    }
    
    // MARK: - Private methods -
    
    private func getDnsSettings(model: SecureDNS) -> NEDNSSettings {
        let servers = UserDefaults.standard.value(forKey: UserDefaults.Key.resolvedDNSOutsideVPN) as? [String] ?? []
        let type = DNSProtocolType.init(rawValue: model.type)

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
