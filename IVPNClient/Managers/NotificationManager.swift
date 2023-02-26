//
//  NotificationManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-02-22.
//  Copyright (c) 2023 Privatus Limited.
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
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    let identifier = "ipvn.notification"
    let categoryIdentifier = "ipvn.notification.pauseVPN"
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert]) { granted, _ in
            completion(granted)
        }
    }
    
    func setCategory() {
        let actions = [
            UNNotificationAction(identifier: "\(categoryIdentifier).resume", title: "Resume", options: []),
            UNNotificationAction(identifier: "\(categoryIdentifier).stop", title: "Stop", options: [])
        ]
        let pauseVPNCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: actions, intentIdentifiers: [], options: .customDismissAction)

        notificationCenter.setNotificationCategories([pauseVPNCategory])
    }
    
    func setNotification(title: String, message: String) {
        requestAuthorization { [self] granted in
            guard granted else {
                return
            }
            
            setCategory()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.categoryIdentifier = categoryIdentifier
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
            notificationCenter.add(request) { error in
                if let error = error {
                    print("error:", error.localizedDescription)
                }
            }
        }
    }
    
    func removeNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
}
