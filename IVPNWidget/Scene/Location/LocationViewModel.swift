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

extension LocationView {
    class ViewModel: ObservableObject {
        
        @Published var location: Location?
        let apiService: APIService
        
        init(apiService: APIService = WidgetAPIService()) {
            self.apiService = apiService
        }
        
        func geoLookup() {
            print("🌱 geoLookup()")
            let requestIPv4 = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup, addressType: .IPv4)
            apiService.request(requestIPv4) { (result: Result<Location>) in
                switch result {
                case .success(let model):
                    self.location = model
                    print("🍀 model", model)
                case .failure:
                    print("❌ failure")
                    break
                }
            }
        }
        
    }
}