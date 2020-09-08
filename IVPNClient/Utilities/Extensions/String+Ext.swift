//
//  String+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-24.
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

extension String {
    
    static func commaSeparatedStringFrom(elements: [String]) -> String {
        return elements.joined(separator: ",")
    }
    
    func commaSeparatedToArray() -> [String] {
        return components(separatedBy: .whitespaces)
            .joined()
            .split(separator: ",")
            .map(String.init)
    }
    
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func base64KeyToHex() -> String? {
        let base64 = self
        
        guard base64.count == 44 else {
            return nil
        }
        
        guard base64.last == "=" else {
            return nil
        }
        
        guard let keyData = Data(base64Encoded: base64) else {
            return nil
        }
        
        guard keyData.count == 32 else {
            return nil
        }
        
        let hexKey = keyData.reduce("") {$0 + String(format: "%02x", $1)}
        
        return hexKey
    }
    
    func updateAttribute(key: String, value: String) -> String {
        var array = [String]()
        for setting in self.components(separatedBy: "\n") {
            if setting.hasPrefix(key) {
                array.append("\(key)=\(value)")
            } else {
                array.append(setting)
            }
        }
        return array.joined(separator: "\n")
    }
    
    func findLastSubstring(from: String, to: String) -> String {
        var array = self.split { $0.isNewline }
        array = array.reversed()
        
        for line in array {
            if line.contains(from) {
                let string = line.substring(from: from, to: to)
                return string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
        }
        
        return ""
    }
    
    func camelCaseToCapitalized() -> String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1 $2").lowercased().capitalized
    }
    
}
