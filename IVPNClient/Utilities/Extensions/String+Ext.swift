//
//  String.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 24/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
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
