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
            serverURL = getServerURL(address: address ?? "")
            serverName = getServerName(address: address ?? "")
            save()
        }
    }
    
    var ipAddress: String? {
        didSet {
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
    
    private static let secureDNSKey = "SecureDNS"
    
    // MARK: - Initialize -
    
    init() {
        let model = SecureDNS.load()
        address = model?.address
        ipAddress = model?.ipAddress
        serverURL = model?.serverURL
        serverName = model?.serverName
        type = model?.type ?? "doh"
        mobileNetwork = model?.mobileNetwork ?? true
        wifiNetwork = model?.wifiNetwork ?? true
    }
    
    // MARK: - Methods -
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: SecureDNS.secureDNSKey)
        }
    }
    
    static func load() -> SecureDNS? {
        if let savedObj = UserDefaults.standard.object(forKey: SecureDNS.secureDNSKey) as? Data {
            if let loadedObj = try? JSONDecoder().decode(SecureDNS.self, from: savedObj) {
                return loadedObj
            }
        }
        
        return nil
    }
    
    func validation() -> (Bool, String?) {
        let configType = SecureDNSType.init(rawValue: type)
        
        guard let ipAddress = ipAddress, !ipAddress.isEmpty else {
            return (false, "Please enter DNS server ip address")
        }
        
        switch configType {
        case .doh:
            guard let serverURL = serverURL, !serverURL.isEmpty else {
                return (false, "Please enter DNS server URL")
            }
        case .dot:
            guard let serverName = serverName, !serverName.isEmpty else {
                return (false, "Please enter DNS server name")
            }
        case .none:
            return (false, "Invalid DNS configuration")
        }
        
        return (true, nil)
    }
    
    // MARK: - Private methods -
    
    private func getServerURL(address: String) -> String {
        var serverURL = address
        
        if !address.hasPrefix("https://") {
            serverURL = "https://\(serverURL)"
        }
        
        if !address.hasSuffix("/dns-query") {
            serverURL = "\(serverURL)/dns-query"
        }
        
        return serverURL
    }
    
    private func getServerName(address: String) -> String {
        var serverName = address
        
        if !address.hasPrefix("https://") {
            serverName = "https://\(serverName)"
        }
        
        if let serverURL = URL.init(string: serverName) {
            if let host = serverURL.host {
                do {
                    let ipAddress = try CIDRAddress(stringRepresentation: host)
                    return ipAddress?.ipAddress ?? address
                } catch {}
            }
            
            return serverURL.getTopLevelDomain()
        }
        
        return address
    }
    
}

enum SecureDNSType: String {
    case doh
    case dot
}
