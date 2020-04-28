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

enum ServiceDuration: CaseIterable {
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
    
    // MARK: - Computed properties -
    
    var priceText: String {
        get {
            guard !IAPManager.shared.products.isEmpty else { return "" }
            guard let product = IAPManager.shared.getProduct(identifier: productId) else { return "" }
            return IAPManager.shared.productPrice(product: product)
        }
    }
    
    var durationText: String {
        get {
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
    }
    
    var discountText: String? {
        get {
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
    }
    
    var productId: String {
        get {
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
    }
    
    var typeText: String {
        get {
            switch type {
            case .standard:
                return "Standard"
            case .pro:
                return "Pro"
            }
        }
    }
    
    var collection: [Service] {
        get {
            return ServiceDuration.allCases.map { Service(type: type, duration: $0) }
        }
    }
    
    // Methods
    
    static func == (lhs: Service, rhs: Service) -> Bool {
        return (lhs.type == rhs.type && lhs.duration == rhs.duration)
    }
    
}
