//
//  ViewModel.swift
//  today-extension
//
//  Created by Juraj Hilje on 17/09/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation
import NetworkExtension

struct ViewModel {
    
    static var status: NEVPNStatus {
        let rawValue = UserDefaults.shared.connectionStatus
        return NEVPNStatus.init(rawValue: rawValue) ?? .invalid
    }
    
    var model: GeoLookup
    
    var connectionLocation: String {
        return "\(model.city), \(model.countryCode)"
    }
    
    var connectionIpAddress: String {
        return "IP: \(model.ipAddress)"
    }
    
    // MARK: - Initialize -
    
    init(model: GeoLookup) {
        self.model = model
    }
    
}
