//
//  V2RayCore.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-08-23.
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
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import V2RayControl

class V2RayCore {
    
    // MARK: - Properties -
    
    static let shared = V2RayCore()
    var instance: V2rayControlInstance?
    var reconnectWithV2ray = false
    
    // MARK: - Methods -
    
    func start() -> Error? {
        let _ = close()
        var error: Error?
        
        guard let config = makeConfig() else {
            return NSError(domain: "", code: 99, userInfo: [NSLocalizedDescriptionKey: "V2Ray configuration cannot be loaded"])
        }
        
        var startError: NSError?
        instance = V2rayControlStart(config.jsonString(), &startError)
        if startError != nil {
            error = startError as Error?
        }
        
        return error
    }
    
    func close() -> Error? {
        var error: Error?
        
        if let instance = instance {
            var stopError: NSError?
            V2rayControlStop(instance, &stopError)
            if stopError != nil {
                error = stopError as Error?
            }
            self.instance = nil
        }

        return error
    }
    
    func makeConfig() -> V2RayConfig? {
        guard let settings = V2RaySettings.load() else {
            return nil
        }
        
        if UserDefaults.shared.v2rayProtocol == "tcp" {
            return V2RayConfig.createTcp(
                outboundIp: settings.outboundIp,
                outboundPort: settings.outboundPort,
                inboundIp: settings.inboundIp,
                inboundPort: settings.inboundPort,
                outboundUserId: settings.id
            )
        }
        
        return V2RayConfig.createQuick(
            outboundIp: settings.outboundIp,
            outboundPort: settings.outboundPort,
            inboundIp: settings.inboundIp,
            inboundPort: settings.inboundPort,
            outboundUserId: settings.id,
            tlsSrvName: settings.tlsSrvName
        )
    }
    
}
