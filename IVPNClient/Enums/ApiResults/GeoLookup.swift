//
//  GeoLookup.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 11/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct GeoLookup: Decodable {
    let ipAddress: String
    let countryCode: String
    let country: String
    let city: String
    let isIvpnServer: Bool
    let isp: String
    let latitude: Double
    let longitude: Double
}
