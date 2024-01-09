//
//  ServiceStatus.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-08-09.
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

struct ServiceStatus: Codable {
    
    // MARK: - Properties -
    
    var isActive: Bool
    var currentPlan: String
    var activeUntil: Int?
    var isOnFreeTrial: Bool?
    var username: String?
    let upgradeToUrl: String?
    let paymentMethod: String?
    let capabilities: [String]?
    let deviceManagement: Bool
    
    // MARK: - Initialize -
    
    init() {
        let service = ServiceStatus.load()
        isActive = service?.isActive ?? true
        currentPlan = service?.currentPlan ?? ""
        activeUntil = service?.activeUntil ?? nil
        isOnFreeTrial = service?.isOnFreeTrial ?? false
        username = service?.username ?? nil
        upgradeToUrl = service?.upgradeToUrl ?? nil
        paymentMethod = service?.paymentMethod ?? nil
        capabilities = service?.capabilities ?? nil
        deviceManagement = service?.deviceManagement ?? false
    }
    
    // MARK: - Methods -
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Key.serviceStatus)
        }
    }
    
    static func load() -> ServiceStatus? {
        if let saved = UserDefaults.standard.object(forKey: UserDefaults.Key.serviceStatus) as? Data {
            if let loaded = try? JSONDecoder().decode(ServiceStatus.self, from: saved) {
                return loaded
            }
        }
        
        return nil
    }
    
    func activeUntilString() -> String {
        return Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0)).formatDate()
    }
    
    func isEnabled(capability: Capability) -> Bool {
        if let capabilities = self.capabilities {
            return capabilities.contains(capability.rawValue)
        }
        
        return false
    }
    
    static func isValid(username: String) -> Bool {
        return username.hasPrefix("ivpn") || username.hasPrefix("i-")
    }
    
    static func isValid(verificationCode: String) -> Bool {
        return !verificationCode.isEmpty && verificationCode.count == 6 && NumberFormatter().number(from: verificationCode) != nil
    }
    
    func isNewStyleAccount() -> Bool {
        return paymentMethod == "prepaid"
    }
    
    func daysUntilSubscriptionExpiration() -> Int {
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0))
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let diff = components.day ?? 0
        
        return diff > 0 ? diff : 0
    }
    
    func isActiveUntilValid() -> Bool {
        return activeUntil != nil
    }
    
    func activeUntilExpired() -> Bool {
        let activeUntilDate = Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0))
        return Date() > activeUntilDate
    }
    
    func isLegacyAccount() -> Bool {
        let accountId = KeyChain.username ?? ""
        
        if accountId.hasPrefix("ivpn") && currentPlan.contains("VPN Pro") && currentPlan != "IVPN Pro" {
            return true
        }
        
        return false
    }
    
}
