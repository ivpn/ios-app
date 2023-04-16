//
//  LocationViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-12.
//  Copyright (c) 2023 Privatus Limited.
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

import SwiftUI
import WidgetKit

extension LocationView {
    class ViewModel: ObservableObject {
        
        let apiService: APIService
        
        init(apiService: APIService = WidgetAPIService()) {
            self.apiService = apiService
        }
        
        func getLocation() -> String {
            guard let model = UserDefaults.shared.geoLookup else {
                return ""
            }
            
            guard !model.city.isEmpty else {
                return model.country
            }
            
            return "\(model.city), \(model.countryCode)"
        }
        
        func getCountryCode() -> String {
            guard let model = UserDefaults.shared.geoLookup else {
                return ""
            }
            
            return model.countryCode.uppercased()
        }
        
        func geoLookup() {
            guard Date().timeIntervalSince(UserDefaults.shared.lastWidgetUpdate) > 3 else {
                return
            }
            
            UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.lastWidgetUpdate)
            
            let requestIPv4 = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup, addressType: .IPv4)
            apiService.request(requestIPv4) { (result: Result<GeoLookup>) in
                switch result {
                case .success(let model):
                    model.save()
                    WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
                case .failure:
                    break
                }
            }
        }
        
    }
}
