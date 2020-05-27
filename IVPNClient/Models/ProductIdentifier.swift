//
//  ProductIdentifier.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ProductIdentifier {
    
    static let standardWeek = "net.ivpn.subscriptions.standard.1week"
    static let standardMonth = "net.ivpn.subscriptions.standard.1month"
    static let standardYear = "net.ivpn.subscriptions.standard.1year"
    static let standardTwoYears = "net.ivpn.subscriptions.standard.2year"
    static let standardThreeYears = "net.ivpn.subscriptions.standard.3year"
    static let proWeek = "net.ivpn.subscriptions.pro.1week"
    static let proMonth = "net.ivpn.subscriptions.pro.1month"
    static let proYear = "net.ivpn.subscriptions.pro.1year"
    static let proTwoYears = "net.ivpn.subscriptions.pro.2year"
    static let proThreeYears = "net.ivpn.subscriptions.pro.3year"
    
    static var all: Set<String> {
        return [
            standardWeek,
            standardMonth,
            standardYear,
            standardTwoYears,
            standardThreeYears,
            proWeek,
            proMonth,
            proYear,
            proTwoYears,
            proThreeYears
        ]
    }
    
}
