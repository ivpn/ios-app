//
//  SubscriptionType.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

enum SubscriptionDuartion {
    case yearly
    case monthly
}

enum SubscriptionType {
    
    case standard(SubscriptionDuartion)
    case pro(SubscriptionDuartion)
    
    func getProductId() -> String {
        switch self {
        case .standard(let duration):
            switch duration {
            case .yearly:
                return ProductIdentifier.standardYearly
            case .monthly:
                return ProductIdentifier.standardMonthly
            }
        case .pro(let duration):
            switch duration {
            case .yearly:
                return ProductIdentifier.proYearly
            case .monthly:
                return ProductIdentifier.proMonthly
            }
        }
    }
    
    func getDurationLabel() -> String {
        switch self {
        case .standard(let duration):
            switch duration {
            case .yearly:
                return "year"
            case .monthly:
                return "month"
            }
        case .pro(let duration):
            switch duration {
            case .yearly:
                return "year"
            case .monthly:
                return "month"
            }
        }
    }
    
}
