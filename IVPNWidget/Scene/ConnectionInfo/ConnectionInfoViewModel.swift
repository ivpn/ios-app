//
//  ConnectionInfoViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-17.
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

import SwiftUI

extension ConnectionInfoView {
    class ViewModel: ObservableObject {
        
        @Published var model: ConnectionInfo
        var dataService: DataService
        
        init(dataService: DataService = WidgetDataService()) {
            self.dataService = dataService
            self.model = dataService.getConnectionInfo()
        }
        
        func update() {
            model = dataService.getConnectionInfo()
        }
        
        func getIpAddress() -> String {
            return model.geoLookup.ipAddress
        }
        
        func getProvider() -> String {
            return model.geoLookup.isIvpnServer ? "IVPN" : model.geoLookup.isp
        }
        
        func getProtocolPortTitle() -> String {
            let components = model.selectedProtocol.components(separatedBy: "-")
            
            if let protocolName = components[safeIndex: 0] {
                if protocolName == "ikev2" {
                    return "Protocol"
                }
            }
            
            return "Protocol, Port"
        }
        
        func getProtocol() -> String {
            var name = ""
            var proto = ""
            var port = 0
            let components = model.selectedProtocol.components(separatedBy: "-")
            
            if let protocolType = components[safeIndex: 1] {
                proto = protocolType.uppercased()
            }
            
            if let protocolPort = components[safeIndex: 2] {
                port = Int(protocolPort) ?? 0
            }
            
            if let protocolName = components[safeIndex: 0] {
                if protocolName == "wireguard" {
                    name = "WireGuard"
                    proto = wireguardProtocol()
                    if model.multiHop && model.isV2ray {
                        return "\(name), \(proto) \(port)"
                    }
                }
                if protocolName == "openvpn" {
                    name = "OpenVPN"
                }
                if protocolName == "ikev2" {
                    return "IKEv2"
                }
            }
            
            if model.multiHop {
                return "\(name), \(proto)"
            }
            
            return "\(name), \(proto) \(port)"
        }
        
        func getAntiTracker() -> String {
            return model.antiTracker ? "ON" : "OFF"
        }
        
        func wireguardProtocol() -> String {
            if model.isV2ray && model.v2rayProtocol == "tcp" {
                return "TCP"
            }
            
            return "UDP"
        }
        
    }
}
