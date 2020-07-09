//
//  Date+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-09.
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

extension Date {
    
    private static let logFormat = "dd.MM.yyyy HH:mm:ss"
    private static let fileNameFormat = "MMddyyyyHHmmss"
    private static let dateFormat = "d MMM yyyy"
    private static let dateTimeFormat = "d MMM yyyy HH:mm"
    
    static func logTime() -> String {
        return formatted(format: logFormat)
    }
    
    static func logFileName() -> String {
        return formatted(format: fileNameFormat)
    }
    
    static func changeDays(by days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days
        return Calendar.current.date(byAdding: dateComponents, to: Date())!
    }
    
    static func changeMinutes(by minutes: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.minute = minutes
        return Calendar.current.date(byAdding: dateComponents, to: Date())!
    }
    
    func changeDays(by days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    func changeMinutes(by minutes: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.minute = minutes
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    func formatDate() -> String {
        let formater = DateFormatter()
        formater.dateFormat = Date.dateFormat
        return formater.string(from: self)
    }
    
    func formatDateTime() -> String {
        let formater = DateFormatter()
        formater.dateFormat = Date.dateTimeFormat
        return formater.string(from: self)
    }
    
    private static func formatted(format: String) -> String {
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: Date())
    }
    
}
