//
//  ViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-09-17.
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
import NetworkExtension

struct ViewModel {
    
    static var currentStatus: NEVPNStatus {
        let rawValue = UserDefaults.shared.connectionStatus
        return NEVPNStatus.init(rawValue: rawValue) ?? .invalid
    }
    
    var model: GeoLookup
    
    var connectionLocation: String {
        return "\(model.city), \(model.countryCode)"
    }
    
    var connectionIpAddress: String {
        guard !model.ipAddress.isEmpty else {
            return ""
        }
        
        if addressType == .IPv6 {
            return "IPv6: \(model.ipAddress)"
        }
        
        return "IPv4: \(model.ipAddress)"
    }
    
    var addressType: AddressType
    
    // MARK: - Initialize -
    
    init(model: GeoLookup, addressType: AddressType = .IPv4) {
        self.model = model
        self.addressType = addressType
    }
    
}
