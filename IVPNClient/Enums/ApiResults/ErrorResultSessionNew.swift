//
//  ErrorResultSessionNew.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 14/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct SessionLimitData: Decodable {
    let limit: Int
    let currentPlan: String
    let upgradable: Bool
    let upgradeToPlan: String
    let upgradeToUrl: String
    let paymentMethod: String
}

struct ErrorResultSessionNew: Decodable {
    let status: Int
    let message: String
    let data: SessionLimitData?
}
