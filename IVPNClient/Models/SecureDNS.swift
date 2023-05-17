//
//  SecureDNS.swift
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

struct SecureDNS: Codable {
    
    var address: String? {
        didSet {
            if let address = address {
                serverURL = DNSProtocolType.getServerURL(address: address)
                serverName = DNSProtocolType.getServerName(address: address)
                DNSManager.saveResolvedDNS(server: DNSProtocolType.getServerToResolve(address: address), key: UserDefaults.Key.resolvedDNSOutsideVPN)
            } else {
                serverURL = nil
                serverName = nil
            }
            save()
        }
    }
    
    var serverURL: String? {
        didSet {
            save()
        }
    }
    
    var serverName: String? {
        didSet {
            save()
        }
    }
    
    var type: String {
        didSet {
            save()
        }
    }
    
    var mobileNetwork: Bool {
        didSet {
            save()
        }
    }
    
    var wifiNetwork: Bool {
        didSet {
            save()
        }
    }
    
    // MARK: - Initialize -
    
    init() {
        let model = SecureDNS.load()
        address = model?.address
        serverURL = model?.serverURL
        serverName = model?.serverName
        type = model?.type ?? "doh"
        mobileNetwork = model?.mobileNetwork ?? true
        wifiNetwork = model?.wifiNetwork ?? true
    }
    
    // MARK: - Methods -
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Key.secureDNS)
        }
    }
    
    static func load() -> SecureDNS? {
        if let savedObj = UserDefaults.standard.object(forKey: UserDefaults.Key.secureDNS) as? Data {
            if let loadedObj = try? JSONDecoder().decode(SecureDNS.self, from: savedObj) {
                return loadedObj
            }
        }
        
        return nil
    }
    
    func validation() -> (Bool, String?) {
        guard let address = address, !address.isEmpty else {
            return (false, "Please enter DNS server info")
        }
        
        return (true, nil)
    }
    
}
