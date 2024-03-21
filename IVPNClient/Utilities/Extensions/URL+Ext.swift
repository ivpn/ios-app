//
//  URL+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-03-01.
//  Copyright (c) 2021 IVPN Limited.
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

extension URL {
    
    func getTopLevelSubdomain() -> String {
        if let hostName = host {
            let subStrings = hostName.components(separatedBy: ".")
            var domainName = ""
            let count = subStrings.count
            
            if count > 2 {
                domainName = subStrings[count - 3] + "." + subStrings[count - 2] + "." + subStrings[count - 1]
            } else if count <= 2 {
                domainName = hostName
            }
            
            return domainName
        }
        
        return ""
    }
    
    func trailingContent(bytes: UInt64) -> String {
        var file: FileHandle?
        
        defer {
            try? file?.close()
        }
        
        do {
            file = try FileHandle(forReadingFrom: self)
            
            guard let size = try file?.seekToEnd() else {
                log(.error, message: "Cannot seek")
                return ""
            }
            
            var offset: UInt64
            if bytes < size {
                offset = size - bytes
            } else {
                offset = 0
            }
            
            try file?.seek(toOffset: offset)
            
            guard let data = try file?.readToEnd() else {
                log(.error, message: "No data")
                return ""
            }
            
            guard let string = String(data: data, encoding: .utf8) else {
                log(.error, message: "Cannot encode string")
                return ""
            }
            
            return string
        } catch {
            log(.error, message: "Error while reading file: \(error)")
            return ""
        }
    }
    
    func trailingLines(bytes: UInt64) -> [String] {
        return trailingContent(bytes: bytes)
            .components(separatedBy: "\n")
            .filter {
                !$0.isEmpty
            }
    }
    
}
