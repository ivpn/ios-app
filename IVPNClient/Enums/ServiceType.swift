//
//  ServiceType.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-05-05.
//  Copyright (c) 2023 IVPN Limited.
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

let StandardTitle = "IVPN Standard"
let PlusTitle = "IVPN Plus"
let ProTitle = "IVPN Pro Suite"

enum ServiceType {
    case standard
    case plus
    case pro
    
    static func getType(currentPlan: String) -> ServiceType {
        if currentPlan.contains("Plus") {
            return .plus
        } else if currentPlan.contains("Pro") == true {
            return .pro
        } else {
            return .standard
        }
    }
    
    func getDeviceLimit(plan: String, plans: [ServicePlan]) -> Int {
        for avaliablePlan in plans where avaliablePlan.name.contains(plan) {
            return avaliablePlan.deviceLimit
        }
        
        return 0
    }

    func getTitle() -> String {
        switch self {
        case .standard:
            return StandardTitle
        case .plus:
            return PlusTitle
        case .pro:
            return ProTitle
        }
    }

    func getDesc(plans: [ServicePlan]) -> String {
        switch self {
        case .standard:
            let deviceLimit = getDeviceLimit(plan: "Standard", plans: plans)
            return getStandardDesc(deviceLimit: deviceLimit)
        case .plus:
            let deviceLimit = getDeviceLimit(plan: "Plus", plans: plans)
            return getPlusDesc(deviceLimit: deviceLimit)
        case .pro:
            let deviceLimit = getDeviceLimit(plan: "Pro", plans: plans)
            return getProDesc(deviceLimit: deviceLimit)
        }
    }

    func getAltTitleOne() -> String {
        switch self {
        case .standard:
            return PlusTitle
        case .plus:
            return StandardTitle
        case .pro:
            return StandardTitle
        }
    }

    func getAltDescOne(plans: [ServicePlan]) -> String {
        switch self {
        case .standard:
            let deviceLimit = getDeviceLimit(plan: "Plus", plans: plans)
            return getPlusDesc(deviceLimit: deviceLimit)
        case .plus:
            let deviceLimit = getDeviceLimit(plan: "Standard", plans: plans)
            return getStandardDesc(deviceLimit: deviceLimit)
        case .pro:
            let deviceLimit = getDeviceLimit(plan: "Standard", plans: plans)
            return getStandardDesc(deviceLimit: deviceLimit)
        }
    }

    func getAltTitleTwo() -> String {
        switch self {
        case .standard:
            return ProTitle
        case .plus:
            return ProTitle
        case .pro:
            return PlusTitle
        }
    }

    func getAltDescTwo(plans: [ServicePlan]) -> String {
        switch self {
        case .standard:
            let deviceLimit = getDeviceLimit(plan: "Pro", plans: plans)
            return getProDesc(deviceLimit: deviceLimit)
        case .plus:
            let deviceLimit = getDeviceLimit(plan: "Pro", plans: plans)
            return getProDesc(deviceLimit: deviceLimit)
        case .pro:
            let deviceLimit = getDeviceLimit(plan: "Plus", plans: plans)
            return getPlusDesc(deviceLimit: deviceLimit)
        }
    }
    
    func getStandardDesc(deviceLimit: Int) -> String {
        "IVPN on \(deviceLimit) devices"
    }
    
    func getPlusDesc(deviceLimit: Int) -> String {
        "IVPN on \(deviceLimit) devices, modDNS, Mailx"
    }
    
    func getProDesc(deviceLimit: Int) -> String {
        "IVPN on \(deviceLimit) devices, modDNS, Mailx, Portmaster Pro"
    }
}
