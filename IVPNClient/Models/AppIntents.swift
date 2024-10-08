//
//  AddNoteIntent.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2024-09-04.
//  Copyright (c) 2024 IVPN Limited.
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


import AppIntents

@available(iOS 16, *)
struct Connect: AppIntent {
    static var title = LocalizedStringResource("Connect VPN")
    static var description = IntentDescription("Connect to the VPN")
    
    func perform() async throws -> some IntentResult {
        log(.info, message: "App Intent handler: Connect")
        NotificationCenter.default.post(name: Notification.Name.IntentConnect, object: nil)
        return .result()
    }
}

@available(iOS 16, *)
struct Disconnect: AppIntent {
    static var title = LocalizedStringResource("Disconnect VPN")
    static var description = IntentDescription("Disconnect from the VPN")
    
    func perform() async throws -> some IntentResult {
        log(.info, message: "App Intent handler: Disconnect")
        NotificationCenter.default.post(name: Notification.Name.IntentDisconnect, object: nil)
        return .result()
    }
}

@available(iOS 16, *)
struct AntiTrackerEnable: AppIntent {
    static var title = LocalizedStringResource("Enable AntiTracker")
    static var description = IntentDescription("Enables the AntiTracker")

    func perform() async throws -> some IntentResult {
        log(.info, message: "App Intent handler: EnableAntiTracker")
        NotificationCenter.default.post(name: Notification.Name.IntentAntiTrackerEnable, object: nil)
        return .result()
    }
}

@available(iOS 16, *)
struct AntiTrackerDisable: AppIntent {
    static var title = LocalizedStringResource("Disable AntiTracker")
    static var description = IntentDescription("Disables the AntiTracker")
    
    func perform() async throws -> some IntentResult {
        log(.info, message: "App Intent handler: DisableAntiTracker")
        NotificationCenter.default.post(name: Notification.Name.IntentAntiTrackerDisable, object: nil)
        return .result()
    }
}

@available(iOS 16, *)
struct CustomDNSEnable: AppIntent {
    static var title = LocalizedStringResource("Enable Custom DNS")
    static var description = IntentDescription("Enables the Custom DNS")
    
    func perform() async throws -> some IntentResult {
        log(.info, message: "App Intent handler: EnableCustomDNS")
        NotificationCenter.default.post(name: Notification.Name.IntentCustomDNSEnable, object: nil)
        return .result()
    }
}

@available(iOS 16, *)
struct CustomDNSDisable: AppIntent {
    static var title = LocalizedStringResource("Disable Custom DNS")
    static var description = IntentDescription("Disables the Custom DNS")
    
    func perform() async throws -> some IntentResult {
        log(.info, message: "App Intent handler: DisableCustomDNS")
        NotificationCenter.default.post(name: Notification.Name.IntentCustomDNSDisable, object: nil)
        return .result()
    }
}
