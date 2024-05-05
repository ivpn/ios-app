//
//  InfoAlertViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-13.
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

import UIKit

class InfoAlertViewModel {
    
    // MARK: - Properties -
    
    var text: String {
        switch infoAlert {
        case .subscriptionExpiration:
            let days = Application.shared.serviceStatus.daysUntilSubscriptionExpiration()
            let activeUntilExpired = Application.shared.serviceStatus.activeUntilExpired()
            
            if days == 0 {
                if !activeUntilExpired {
                    return "Subscription expires today"
                }
                
                if !Application.shared.serviceStatus.isActive {
                    return "Subscription expired"
                }
            }
            
            if days == 1 {
                return "Subscription will expire in \(days) day"
            }
            
            return "Subscription will expire in \(days) days"
        case .connectionInfoFailure:
            return "Loading connection info failed"
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
        if infoAlert == .connectionInfoFailure {
            return true
        }
      
        if Application.shared.serviceStatus.isLegacyAccount() {
            return false
        }
        
        if Application.shared.authentication.isLoggedIn && infoAlert == .subscriptionExpiration && Application.shared.serviceStatus.isActiveUntilValid() && Application.shared.serviceStatus.daysUntilSubscriptionExpiration() <= 3 {
            return true
        }
        
        return false
    }
    
    var infoAlert: InfoAlert = .subscriptionExpiration
    
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
        guard shouldDisplay else {
            return
        }
        
        switch infoAlert {
        case .subscriptionExpiration:
//            if let topViewController = UIApplication.topViewController() as? MainViewController {
//                topViewController.present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
//            }
            break
        case .connectionInfoFailure:
            NotificationCenter.default.post(name: Notification.Name.UpdateGeoLocation, object: nil)
        }
    }
    
}
