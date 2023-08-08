//
//  PacketTunnelProvider.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-11-06.
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

import Foundation
import TunnelKitOpenVPNAppExtension
import NetworkExtension
import WidgetKit

class PacketTunnelProvider: OpenVPNTunnelProvider {
    
    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        startKeyRotation()
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        try await super.startTunnel(options: options)
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        await super.stopTunnel(with: reason)
    }
    
    private func startKeyRotation() {
        let timer = TimerManager(timeInterval: AppKeyManager.regenerationCheckInterval)
        timer.eventHandler = {
            if AppKeyManager.needToRegenerate() {
                AppKeyManager.shared.setNewKey { _, _, _ in }
            }
            timer.proceed()
        }
        timer.resume()
    }
    
}
