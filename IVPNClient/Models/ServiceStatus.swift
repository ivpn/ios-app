//
//  ServiceStatus.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 09/08/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ServiceStatus: Codable {
    
    // MARK: - Properties -
    
    var isActive: Bool
    #warning("currentPlan should not be optional, change this after API is fixed")
    var currentPlan: String?
    var activeUntil: Int?
    var isOnFreeTrial: Bool
    let username: String?
    let upgradeToUrl: String?
    let paymentMethod: String?
    let capabilities: [String]?
    
    private var activeUntilDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0))
    }
    
    private static let serviceStatusKey = "ServiceStatus"
    
    // MARK: - Initialize -
    
    init() {
        let service = ServiceStatus.load()
        isActive = service?.isActive ?? false
        currentPlan = service?.currentPlan ?? nil
        activeUntil = service?.activeUntil ?? nil
        isOnFreeTrial = service?.isOnFreeTrial ?? false
        username = service?.username ?? nil
        upgradeToUrl = service?.upgradeToUrl ?? nil
        paymentMethod = service?.paymentMethod ?? nil
        capabilities = service?.capabilities ?? nil
    }
    
    // MARK: - Methods -
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: ServiceStatus.serviceStatusKey)
        }
    }
    
    static func load() -> ServiceStatus? {
        if let savedObj = UserDefaults.standard.object(forKey: ServiceStatus.serviceStatusKey) as? Data {
            if let loadedObj = try? JSONDecoder().decode(ServiceStatus.self, from: savedObj) {
                return loadedObj
            }
        }
        
        return nil
    }
    
    func activeUntilString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0)))
    }
    
    func isEnabled(capability: Capability) -> Bool {
        if let capabilities = self.capabilities {
            return capabilities.contains(capability.rawValue)
        }
        
        return false
    }
    
    func getSubscriptionText() -> String {
        if isActive {
            if let currentPlan = currentPlan, !currentPlan.isEmpty {
                return "\(currentPlan), Active until \(activeUntilString())"
            } else {
                return "Active until \(activeUntilString())"
            }
        }
        
        return "No active subscription"
    }
    
    static func isValid(username: String) -> Bool {
        return username.hasPrefix("ivpn")
    }
    
}
