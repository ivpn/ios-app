//
//  AccountViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-24.
//  Copyright (c) 2020 Privatus Limited.
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

import UIKit

struct AccountViewModel {
    
    // MARK: - Properties -
    
    var serviceStatus: ServiceStatus
    var authentication: Authentication
    
    var accountId: String {
        return authentication.getStoredUsername()
    }
    
    var statusText: String {
        return serviceStatus.isActive ? "ACTIVE" : "INACTIVE"
    }
    
    var statusColor: UIColor {
        return serviceStatus.isActive ? UIColor.init(named: Theme.ivpnGreen)! : UIColor.init(named: Theme.ivpnRedOff)!
    }
    
    var subscriptionText: String {
        return serviceStatus.currentPlan
    }
    
    var activeUntilText: String {
        return serviceStatus.isActive ? serviceStatus.activeUntilString() : "No active subscription"
    }
    
    // MARK: - Initialize -
    
    init(serviceStatus: ServiceStatus, authentication: Authentication) {
        self.serviceStatus = serviceStatus
        self.authentication = authentication
    }
    
}
