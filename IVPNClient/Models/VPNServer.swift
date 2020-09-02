//
//  VPNServer.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-16.
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
import CoreLocation

class VPNServer {
    
    // MARK: - Properties -
    
    var pingMs: Int?
    var pingRelative: Double?
    var status: NEVPNStatus = .invalid {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: "SelectedServerStatus")
            UserDefaults.standard.synchronize()
        }
    }
    
    var fastest = false {
        didSet {
            UserDefaults.standard.set(fastest, forKey: "SelectedServerFastest")
            UserDefaults.standard.synchronize()
        }
    }
    
    var random = false
    
    var fastestServerLabelShouldBePresented: Bool {
        return fastest && pingMs == nil && Application.shared.connectionManager.status.isDisconnected()
    }
    
    var randomServerLabelShouldBePresented: Bool {
        return random && Application.shared.connectionManager.status.isDisconnected()
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private (set) var gateway: String
    private (set) var countryCode: String
    private (set) var country: String
    private (set) var city: String
    private (set) var latitude: Double
    private (set) var longitude: Double
    private (set) var ipAddresses: [String]
    private (set) var hosts: [Host]
    
    // MARK: - Initialize -
    
    init(gateway: String, countryCode: String, country: String, city: String, latitude: Double = 0, longitude: Double = 0, ipAddresses: [String] = [], hosts: [Host] = [], fastest: Bool = false) {
        self.gateway = gateway
        self.countryCode = countryCode
        self.country = country
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.ipAddresses = ipAddresses
        self.hosts = hosts
        self.fastest = fastest
    }
    
    // MARK: - Methods -
    
    func getLocationFromGateway() -> String {
        let gatewayParts = gateway.components(separatedBy: ".")
        if let location = gatewayParts.first { return location }
        return ""
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
    
    static func == (lhs: VPNServer, rhs: VPNServer) -> Bool {
        return lhs.city == rhs.city && lhs.countryCode == rhs.countryCode
    }

}
