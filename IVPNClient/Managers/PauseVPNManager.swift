//
//  PauseVPNManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-02-20.
//  Copyright (c) 2021 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

class PauseManager {
    
    // MARK: - Properties -
    
    var pausedUntil = Date()
    var timer = TimerManager(timeInterval: 2)
    
    // MARK: - Methods -
    
    func pause(for duration: PauseDuration) {
        self.pausedUntil = duration.pausedUntil()
        timer.eventHandler = { [self] in
            // Connect VPN if Date() > pausedUntil
            timer.proceed()
        }
        timer.resume()
    }
    
    func suspend() {
        timer.suspend()
    }
    
}

enum PauseDuration: CaseIterable {
    
    case fiveMinutes
    case thirtyMinutes
    case oneHour
    case threeHours
    
    func pausedUntil() -> Date {
        var dateComponent = DateComponents()
        
        switch self {
        case .fiveMinutes:
            dateComponent.minute = 5
        case .thirtyMinutes:
            dateComponent.minute = 30
        case .oneHour:
            dateComponent.hour = 1
        case .threeHours:
            dateComponent.hour = 3
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: Date()) ?? Date()
    }
    
}
