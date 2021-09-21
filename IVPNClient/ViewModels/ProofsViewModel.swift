//
//  ProofsViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-02-11.
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

import UIKit
import NetworkExtension

struct ProofsViewModel {
    
    // MARK: - Properties -
    
    var model: GeoLookup?
    var displayMode: DisplayMode?
    
    var imageNameForCountryCode: String {
        return model?.countryCode.uppercased() ?? ""
    }
    
    var ipAddress: String {
        return model?.ipAddress ?? ""
    }
    
    var city: String {
        return model?.city ?? ""
    }
    
    var latitude: Double {
        return model?.latitude ?? 0
    }
    
    var longitude: Double {
        return model?.longitude ?? 0
    }
    
    var countryCode: String {
        return model?.countryCode ?? ""
    }
    
    var location: String {
        guard let model = model else {
            return ""
        }
        
        guard !model.city.isEmpty else {
            return model.country
        }
        
        return "\(model.city), \(model.countryCode)"
    }
    
    var provider: String {
        guard let model = model else {
            return ""
        }
        
        return model.isIvpnServer ? "IVPN" : model.isp
    }
    
    var isIvpnServer: Bool {
        guard let model = model else {
            return false
        }
        
        return model.isIvpnServer
    }
    
    // MARK: - Initialize -
    
    init(model: GeoLookup? = nil, displayMode: DisplayMode? = nil) {
        self.model = model
        self.displayMode = displayMode
    }
    
}

extension ProofsViewModel {
    
    enum DisplayMode {
        case loading
        case content
        case error
    }
    
}
