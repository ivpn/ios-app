//
//  ServiceDuration.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 05/05/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation

enum ServiceDuration: CaseIterable {
    
    case week
    case month
    case year
    case twoYears
    case threeYears
    
    func activeUntilFrom(date: Date) -> Date {
        var dateComponent = DateComponents()
        
        switch self {
        case .week:
            dateComponent.day = 7
        case .month:
            dateComponent.month = 1
        case .year:
            dateComponent.year = 1
        case .twoYears:
            dateComponent.year = 2
        case .threeYears:
            dateComponent.year = 3
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: date) ?? date
    }
    
    func willBeActiveUntilFrom(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: activeUntilFrom(date: date))
    }
    
}
