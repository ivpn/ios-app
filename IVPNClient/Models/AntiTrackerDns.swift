//
//  AntiTrackerDns.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-07-05.
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

struct AntiTrackerDns: Codable {
    
    let name: String
    let description: String
    let normal: String
    let hardcore: String
    
    static let basicLists = ["Basic", "Comprehensive", "Restrictive"]
    static let basicList = "Basic"
    static let oisdbigList = "Oisdbig"
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.shared.set(encoded, forKey: UserDefaults.Key.antiTrackerDns)
        }
    }
    
    static func load() -> AntiTrackerDns? {
        if let saved = UserDefaults.shared.object(forKey: UserDefaults.Key.antiTrackerDns) as? Data {
            if let loaded = try? JSONDecoder().decode(AntiTrackerDns.self, from: saved) {
                return loaded
            }
        }
        
        return nil
    }
    
    static func == (lhs: AntiTrackerDns, rhs: AntiTrackerDns) -> Bool {
        return lhs.name == rhs.name && lhs.normal == rhs.normal
    }
    
    static func defaultList(lists: [AntiTrackerDns]) -> AntiTrackerDns? {
        if !(KeyChain.sessionToken ?? "").isEmpty || UserDefaults.shared.isAntiTracker || UserDefaults.shared.isAntiTrackerHardcore {
            let filteredList = lists.filter { $0.name == oisdbigList }
            return filteredList.first
        }
        
        let filteredList = lists.filter { $0.name == basicList }
        return filteredList.first
    }
    
}
