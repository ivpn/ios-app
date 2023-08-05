//
//  VmessEndpoint.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-08-05.
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

struct VmessEndpoint: Codable, Hashable {
    
    var url: String? = nil
    var path: String? = nil
    var info: Dictionary<String, Any> = [:]
    
    enum InfoKey: String, CodingKey {
        case address = "add"
        case port
        case type
        case host
        case aid
        case uuid = "id"
        case tls
        case net
        case ps
    }
    
    enum CodingKeys: String, CodingKey {
        case url
        case path
        case info
    }
    
    static func generatePoints(with vmessUrls:[String]) -> [VmessEndpoint] {
        var array: [VmessEndpoint] = Array()
        for url in vmessUrls {
            if url.count > 0 && url.hasPrefix("vmess://") {
                array.append(VmessEndpoint.init(url))
            }
        }
        return array
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        url != nil ? try container.encode(url, forKey: .url) : nil
        path != nil ? try container.encode(path, forKey: .path) : nil
        
        if !info.isEmpty, let jsonData = try? JSONSerialization.data(withJSONObject: info) {
            try container.encode(jsonData, forKey: .info)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = (values.contains(.url) == true) ? try values.decode(String.self, forKey: .url) : nil
        path = (values.contains(.path) == true) ? try values.decode(String.self, forKey: .path) : nil
        
        if values.contains(.info), let jsonData = try? values.decode(Data.self, forKey: .info) {
            info = (try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]) ?? [String: Any]()
        } else {
            info = [String: Any]()
        }
    }
    
    init(_ url: String?) {
        self.url = url?.replacingOccurrences(of: "\r", with: "")
        self.path = self.url?.replacingOccurrences(of: "vmess://", with: "")
        
        guard let path = self.path else {
            return
        }
        
        guard let base64Data = Data.init(base64Encoded: path) else {
            return
        }
        
        guard let dic = try? JSONSerialization.jsonObject(with: base64Data, options: [.allowFragments, .fragmentsAllowed, .mutableContainers, .mutableLeaves]) else {
            return
        }
        
        self.info = dic as! Dictionary<String, Any>
    }
    
    static func == (lhs: VmessEndpoint, rhs: VmessEndpoint) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
}

