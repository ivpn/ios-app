//
//  APIAccessManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-08-06.
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

import Foundation

class APIAccessManager {
    
    // MARK: - Properties -
    
    static let shared = APIAccessManager()
    
    var ipv4HostName: String {
        if let host = UserDefaults.shared.hostNames.first {
            return host
        }
        
        return UserDefaults.shared.apiHostName
    }
    
    var ipv6HostName: String {
        if let host = UserDefaults.shared.ipv6HostNames.first {
            return host
        }
        
        return UserDefaults.shared.apiHostName
    }
    
    private var hostNames: [String] {
        var hosts = hostNamesCollection
        hosts.move(UserDefaults.shared.apiHostName, to: 0)
        return hosts
    }
    
    private var hostNamesCollection: [String] {
        return [Config.ApiHostName] + UserDefaults.shared.hostNames + UserDefaults.shared.ipv6HostNames
    }
    
    // MARK: - Methods -
    
    func nextHostName(failedHostName: String, addressType: AddressType? = nil) -> String? {
        if let addressType = addressType {
            switch addressType {
            case .IPv4:
                return UserDefaults.shared.hostNames.next(item: failedHostName)
            case .IPv6:
                return UserDefaults.shared.ipv6HostNames.next(item: failedHostName)
            default:
                break
            }
        }
        
        return hostNames.next(item: failedHostName)
    }
    
}
