//
//  AccountViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 24/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
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
        return serviceStatus.isActive ? UIColor.init(named: Theme.Key.ivpnGreen)! : UIColor.init(named: Theme.Key.ivpnRedOff)!
    }
    
    var subscriptionText: String {
        return serviceStatus.isActive ? serviceStatus.currentPlan ?? "" : "No active subscription"
    }
    
    var billingCycleText: String {
        #warning("TODO: Implement after service status API is updated")
        return "{ billingCycle }"
    }
    
    var nextBillingText: String {
        #warning("TODO: Implement after service status API is updated")
        return "{ nextBilling }"
    }
    
    var recurringAmountText: String {
        #warning("TODO: Implement after service status API is updated")
        return "{ recurringAmount }"
    }
    
    var logOutActionText: String {
        return authentication.isLoggedIn ? "Log Out" : "Log In or Sign Up"
    }
    
    var subscriptionActionText: String {
        return serviceStatus.isActive ? "Manage Subscription" : "Activate Subscription"
    }
    
    var showSubscriptionAction: Bool {
        if let paymentMethod = serviceStatus.paymentMethod, paymentMethod == "ivpniosiap" {
            return true
        }
        
        return false
    }
    
    // MARK: - Initialize -
    
    init(serviceStatus: ServiceStatus, authentication: Authentication) {
        self.serviceStatus = serviceStatus
        self.authentication = authentication
    }
    
}
