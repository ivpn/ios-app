//
//  Service.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 27/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation

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
                return "Week"
            case .month:
                return "Month"
            case .year:
                return "Year"
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
                    return nil
                case .year:
                    return "-16%"
                case .twoYears:
                    return "-30%"
                case .threeYears:
                    return "-35%"
                }
            case .pro:
                switch duration {
                case .week:
                    return nil
                case .month:
                    return nil
                case .year:
                    return "-16%"
                case .twoYears:
                    return "-33%"
                case .threeYears:
                    return "-38%"
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
            if Application.shared.authentication.isLoggedIn && !Application.shared.authentication.isNewStyleAccount {
                return [
                    Service(type: type, duration: .month),
                    Service(type: type, duration: .year)
                ]
            }
            
            return ServiceDuration.allCases.map { Service(type: type, duration: $0) }
        }
    }
    
    var willBeActiveUntil: String {
        get {
            var timestamp = Application.shared.serviceStatus.activeUntil
            
            if !Application.shared.serviceStatus.isActive {
                timestamp = Int(Date().timeIntervalSince1970)
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp ?? 0))
            return duration.willBeActiveUntilFrom(date: date)
        }
    }
    
    // Methods
    
    static func == (lhs: Service, rhs: Service) -> Bool {
        return (lhs.type == rhs.type && lhs.duration == rhs.duration)
    }
    
}
