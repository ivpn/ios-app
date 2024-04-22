//
//  Service.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-27.
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

struct Service {
    
    // MARK: - Properties -
    
    var type: ServiceType
    var duration: ServiceDuration
    
    // MARK: - Computed properties -
    
    var priceText: String {
        guard let product = PurchaseManager.shared.getProduct(id: productId) else {
            return ""
        }
        
        return product.displayPrice
    }
    
    var durationText: String {
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
    
    var discountText: String? {
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
    
    var productId: String {
        switch type {
        case .standard:
            switch duration {
            case .week:
                return ProductId.standardWeek
            case .month:
                return ProductId.standardMonth
            case .year:
                return ProductId.standardYear
            case .twoYears:
                return ProductId.standardTwoYears
            case .threeYears:
                return ProductId.standardThreeYears
            }
        case .pro:
            switch duration {
            case .week:
                return ProductId.proWeek
            case .month:
                return ProductId.proMonth
            case .year:
                return ProductId.proYear
            case .twoYears:
                return ProductId.proTwoYears
            case .threeYears:
                return ProductId.proThreeYears
            }
        }
    }
    
    var typeText: String {
        switch type {
        case .standard:
            return "Standard"
        case .pro:
            return "Pro"
        }
    }
    
    var collection: [Service] {
        if Application.shared.authentication.isLoggedIn && !Application.shared.serviceStatus.isNewStyleAccount() {
            return [
                Service(type: type, duration: .month),
                Service(type: type, duration: .year)
            ]
        }
        
        return ServiceDuration.allCases.map { Service(type: type, duration: $0) }
    }
    
    var willBeActiveUntil: String {
        var timestamp = Application.shared.serviceStatus.activeUntil
        
        if !Application.shared.serviceStatus.isActive {
            timestamp = Int(Date().timeIntervalSince1970)
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp ?? 0))
        return duration.willBeActiveUntilFrom(date: date)
    }
    
    // MARK: - Methods -
    
    static func == (lhs: Service, rhs: Service) -> Bool {
        return (lhs.type == rhs.type && lhs.duration == rhs.duration)
    }
    
}
