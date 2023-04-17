//
//  StatusViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-09.
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

import SwiftUI

extension StatusView {
    class ViewModel: ObservableObject {
        
        @Published var model: Status
        var dataService: DataService
        
        init(dataService: DataService = WidgetDataService()) {
            self.dataService = dataService
            self.model = dataService.getStatus()
        }
        
        func update() {
            model = dataService.getStatus()
        }
        
        func statusText() -> String {
            switch model.vpnStatus {
            case .invalid:
                return "disconnected"
            case .disconnected:
                return "disconnected"
            case .connecting:
                return "connecting"
            case .connected:
                return "connected"
            case .reasserting:
                return "connecting"
            case .disconnecting:
                return "disconnecting"
            @unknown default:
                return ""
            }
        }
        
        func buttonText() -> String {
            if model.vpnStatus == .connected {
                return "Disconnect"
            }
            
            return "Connect"
        }
        
        func buttonColor() -> Color {
            if model.vpnStatus == .connected {
                return Color(red: 57 / 255, green: 143 / 255, blue: 230 / 255)
            }
            
            return Color(.systemGray2)
        }
        
        func actionLink() -> URL {
            if model.vpnStatus == .connected {
                return URL(string: "https://www.ivpn.net/app/disconnect")!
            }
            
            return URL(string: "https://www.ivpn.net/app/connect")!
        }
        
    }
}
