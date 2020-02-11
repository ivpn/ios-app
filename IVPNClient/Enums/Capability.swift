//
//  Capability.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 23/09/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

enum Capability: String {
    case multihop = "multihop"
    case portForwarding = "port-forwarding"
    case wireguard = "wireguard"
    case privateEmails = "private-emails"
}
