//
//  SubscriptionType.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

// TODO: Remove SubscriptionDuartion enum

enum SubscriptionDuartion {
    case yearly
    case monthly
}

// TODO: Remove SubscriptionType enum

enum SubscriptionType {
    
    case standard(SubscriptionDuartion)
    case pro(SubscriptionDuartion)
    
    func getProductId() -> String {
        switch self {
        case .standard(let duration):
            switch duration {
            case .yearly:
                return ProductIdentifier.standardYear
            case .monthly:
                return ProductIdentifier.standardMonth
            }
        case .pro(let duration):
            switch duration {
            case .yearly:
                return ProductIdentifier.proYear
            case .monthly:
                return ProductIdentifier.proMonth
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
