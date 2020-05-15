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
        case .subscriptionExpiration:
            return "Subscription will expire in \(days) days"
        case .connectionInfoFailure:
            return "Loading connection info failed."
        }
    }
    
    var actionText: String {
        switch infoAlert {
        case .subscriptionExpiration:
            return "RENEW"
        case .connectionInfoFailure:
            return "RETRY"
        }
    }
    
    var type: InfoAlertViewType {
        switch infoAlert {
        case .subscriptionExpiration:
            return .alert
        case .connectionInfoFailure:
            return .alert
        }
    }
    
    var shouldDisplay: Bool {
        return Application.shared.serviceStatus.daysUntilSubscriptionExpiration() <= 3 && Application.shared.authentication.isLoggedIn
    }
    
    var infoAlert: InfoAlert = .subscriptionExpiration
    
    // MARK: - Methods -
    
    func update() {
        if shouldDisplay {
            infoAlert = .subscriptionExpiration
        }
    }
    
}

// MARK: - InfoAlertViewModel extension -

extension InfoAlertViewModel {
    
    enum InfoAlert {
        case subscriptionExpiration
        case connectionInfoFailure
    }
    
}

// MARK: - InfoAlertViewDelegate -

extension InfoAlertViewModel: InfoAlertViewDelegate {
    
    func action() {
        switch infoAlert {
        case .subscriptionExpiration:
            if let topViewController = UIApplication.topViewController() {
                topViewController.manageSubscription()
            }
        case .connectionInfoFailure:
            if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
                topViewController.updateGeoLocation()
            }
        }
    }
    
}
