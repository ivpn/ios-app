//
//  Session.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 25/07/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct WireGuardResult: Codable {
    let status: Int?
    let message: String?
    let ipAddress: String?
}

struct Session: Decodable {
    let token: String?
    let vpnUsername: String?
    let vpnPassword: String?
    let serviceStatus: ServiceStatus
    let wireguard: WireGuardResult?
}
