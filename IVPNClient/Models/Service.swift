//
//  Service.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 27/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation

enum ServiceType {
    case standard
    case pro
}

enum ServiceDuration {
    case week
    case month
    case year
    case twoYears
    case threeYears
}

struct Service {
    var type: ServiceType
    var duration: ServiceDuration
}
