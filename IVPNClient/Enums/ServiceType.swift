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
let StandardDesc = "IVPN on 5 devices"
let PlusTitle = "IVPN Plus"
let PlusDesc = "IVPN on 10 devices, modDNS, Mailx"
let ProTitle = "IVPN Pro Suite"
let ProDesc = "IVPN on 10 devices, modDNS, Mailx, Portmaster Pro"

enum ServiceType {
    case standard
    case plus
    case pro
    
    static func getType(currentPlan: String) -> ServiceType {
        if currentPlan.contains("plus") {
            return .plus
        } else if currentPlan.contains("pro") == true {
            return .pro
        } else {
            return .standard
        }
    }

    static func getTitle(type: ServiceType) -> String {
        switch type {
        case .standard:
            return StandardTitle
        case .plus:
            return PlusTitle
        case .pro:
            return ProTitle
        }
    }

    static func getDesc(type: ServiceType) -> String {
        switch type {
        case .standard:
            return StandardDesc
        case .plus:
            return PlusDesc
        case .pro:
            return ProDesc
        }
    }

    static func getAltTitleOne(type: ServiceType) -> String {
        switch type {
        case .standard:
            return PlusTitle
        case .plus:
            return StandardTitle
        case .pro:
            return StandardTitle
        }
    }

    static func getAltDescOne(type: ServiceType) -> String {
        switch type {
        case .standard:
            return PlusDesc
        case .plus:
            return StandardDesc
        case .pro:
            return StandardDesc
        }
    }

    static func getAltTitleTwo(type: ServiceType) -> String {
        switch type {
        case .standard:
            return ProTitle
        case .plus:
            return ProTitle
        case .pro:
            return PlusTitle
        }
    }

    static func getAltDescTwo(type: ServiceType) -> String {
        switch type {
        case .standard:
            return ProDesc
        case .plus:
            return ProDesc
        case .pro:
            return PlusDesc
        }
    }
}
