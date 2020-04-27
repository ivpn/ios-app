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
    
    // MARK: - Methods -
    
    func priceText() -> String {
        guard !IAPManager.shared.products.isEmpty else { return "" }
        guard let product = IAPManager.shared.getProduct(identifier: productId()) else { return "" }
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
    
    func productId() -> String {
        switch type {
        case .standard:
            switch duration {
            case .week:
                return ProductIdentifier.standardWeek
            case .month:
                return ProductIdentifier.standardMonth
            case .year:
                return ProductIdentifier.standardYear
            case .twoYears:
                return ProductIdentifier.standardTwoYears
            case .threeYears:
                return ProductIdentifier.standardThreeYears
            }
        case .pro:
            switch duration {
            case .week:
                return ProductIdentifier.proWeek
            case .month:
                return ProductIdentifier.proMonth
            case .year:
                return ProductIdentifier.proYear
            case .twoYears:
                return ProductIdentifier.proTwoYears
            case .threeYears:
                return ProductIdentifier.proThreeYears
            }
        }
    }
    
    static func buildCollection(type: ServiceType) -> [Service] {
        switch type {
        case .standard:
            return [
                Service(type: .standard, duration: .week),
                Service(type: .standard, duration: .month),
                Service(type: .standard, duration: .year),
                Service(type: .standard, duration: .twoYears),
                Service(type: .standard, duration: .threeYears)
            ]
        case .pro:
            return [
                Service(type: .pro, duration: .week),
                Service(type: .pro, duration: .month),
                Service(type: .pro, duration: .year),
                Service(type: .pro, duration: .twoYears),
                Service(type: .pro, duration: .threeYears)
            ]
        }
    }
    
}
