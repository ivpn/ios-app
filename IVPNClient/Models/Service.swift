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
    
    // MARK: - Properties -
    
    var type: ServiceType
    var duration: ServiceDuration
    var productId: String
    
    // MARK: - Methods -
    
    func priceText() -> String {
        guard !IAPManager.shared.products.isEmpty else { return "" }
        guard let product = IAPManager.shared.getProduct(identifier: productId) else { return "" }
        return IAPManager.shared.productPrice(product: product)
    }
    
    func durationText() -> String {
        switch duration {
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        case .twoYears:
            return "2 years"
        case .threeYears:
            return "3 years"
        }
    }
    
    func discountText() -> String? {
        switch type {
        case .standard:
            switch duration {
            case .week:
                return nil
            case .month:
                return "-25%"
            case .year:
                return "-42%"
            case .twoYears:
                return "-51%"
            case .threeYears:
                return "-55%"
            }
        case .pro:
            switch duration {
            case .week:
                return nil
            case .month:
                return "-16%"
            case .year:
                return "-35%"
            case .twoYears:
                return "-48%"
            case .threeYears:
                return "-52%"
            }
        }
    }
    
    static func buildCollection(type: ServiceType) -> [Service] {
        switch type {
        case .standard:
            return [
                Service(type: .standard, duration: .week, productId: ProductIdentifier.standardWeek),
                Service(type: .standard, duration: .month, productId: ProductIdentifier.standardMonth),
                Service(type: .standard, duration: .year, productId: ProductIdentifier.standardYear),
                Service(type: .standard, duration: .twoYears, productId: ProductIdentifier.standardTwoYears),
                Service(type: .standard, duration: .threeYears, productId: ProductIdentifier.standardThreeYears)
            ]
        case .pro:
            return [
                Service(type: .pro, duration: .week, productId: ProductIdentifier.proWeek),
                Service(type: .pro, duration: .month, productId: ProductIdentifier.proMonth),
                Service(type: .pro, duration: .year, productId: ProductIdentifier.proYear),
                Service(type: .pro, duration: .twoYears, productId: ProductIdentifier.proTwoYears),
                Service(type: .pro, duration: .threeYears, productId: ProductIdentifier.proThreeYears)
            ]
        }
    }
    
}
