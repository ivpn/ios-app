//
//  InfoAlertViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 13/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class InfoAlertViewModel {
    
    // MARK: - Properties -
    
    var text: String {
        let days = Application.shared.serviceStatus.daysUntilSubscriptionExpiration()
        switch infoAlert {
        case .trialPeriod:
            return "Trial period will expire in \(days) days"
        case .subscriptionExpiration:
            return "Subscription will expire in \(days) days"
        }
    }
    
    var actionText: String {
        switch infoAlert {
        case .trialPeriod:
            return ""
        case .subscriptionExpiration:
            return "RENEW"
        }
    }
    
    var type: InfoAlertViewType {
        switch infoAlert {
        case .trialPeriod:
            return .info
        case .subscriptionExpiration:
            return .alert
        }
    }
    
    var shouldDisplay: Bool {
        return Application.shared.serviceStatus.daysUntilSubscriptionExpiration() <= 3 && Application.shared.authentication.isLoggedIn
    }
    
    var infoAlert: InfoAlert = .subscriptionExpiration
    
    // MARK: - Methods -
    
    func update() {
        if Application.shared.serviceStatus.isOnFreeTrial && shouldDisplay {
            infoAlert = .trialPeriod
            return
        }
        
        if shouldDisplay {
            infoAlert = .subscriptionExpiration
        }
    }
    
}

// MARK: - InfoAlertViewModel extension -

extension InfoAlertViewModel {
    
    enum InfoAlert {
        case trialPeriod
        case subscriptionExpiration
    }
    
}

// MARK: - InfoAlertViewDelegate -

extension InfoAlertViewModel: InfoAlertViewDelegate {
    
    func action() {
        switch infoAlert {
        case .trialPeriod:
            break
        case .subscriptionExpiration:
            if let topViewController = UIApplication.topViewController() {
                topViewController.manageSubscription()
            }
        }
    }
    
}
