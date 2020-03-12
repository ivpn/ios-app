//
//  ProofsViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 11/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit
import NetworkExtension

struct ProofsViewModel {
    
    // MARK: - Properties -
    
    var model: GeoLookup
    
    var imageNameForCountryCode: String {
        return model.countryCode.lowercased()
    }
    
    var protocolTitle: String {
        return Application.shared.settings.connectionProtocol.formatTitle()
    }
    
    var ipAddress: String {
        return model.ipAddress
    }
    
    var localIpAddress: String {
        return UserDefaults.shared.localIpAddress
    }
    
    var country: String {
        return model.country
    }
    
    var city: String {
        return model.city
    }
    
    var countryCode: String {
        return model.countryCode
    }
    
    var provider: String {
        return model.isp
    }
    
    // MARK: - Initialize -
    
    init(model: GeoLookup) {
        self.model = model
    }
    
}
