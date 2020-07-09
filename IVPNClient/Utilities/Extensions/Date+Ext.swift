//
//  Date.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 09/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
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
