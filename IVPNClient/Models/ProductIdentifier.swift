//
//  ProductIdentifier.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ProductIdentifier {
    
    static let standardWeek = "net.ivpn.subscriptions.standard.week"
    static let standardMonth = "net.ivpn.subscriptions.standard.month"
    static let standardYear = "net.ivpn.subscriptions.standard.year"
    static let standardTwoYears = "net.ivpn.subscriptions.standard.twoYears"
    static let standardThreeYears = "net.ivpn.subscriptions.standard.threeYears"
    static let proWeek = "net.ivpn.subscriptions.pro.week"
    static let proMonth = "net.ivpn.subscriptions.pro.month"
    static let proYear = "net.ivpn.subscriptions.pro.year"
    static let proTwoYears = "net.ivpn.subscriptions.pro.twoYears"
    static let proThreeYears = "net.ivpn.subscriptions.pro.threeYears"
    
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
