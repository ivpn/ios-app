//
//  PauseManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-02-20.
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
import BackgroundTasks

@objc protocol PauseManagerDelegate: AnyObject {
    func updateCountdown(text: String)
}

class PauseManager {
    
    // MARK: - Properties -
    
    static let shared = PauseManager()
    
    var isPaused: Bool {
        return pausedUntil > Date()
    }
    
    var countdown: String {
        return countdownTo(date: pausedUntil)
    }
    
    weak var delegate: PauseManagerDelegate?
    private var pausedUntil = Date()
    private var timer = TimerManager(timeInterval: 1)
    
    // MARK: - Methods -
    
    func pause(for duration: PauseDuration) {
        pausedUntil = duration.pausedUntil()
        NotificationManager.shared.setNotification(title: "Paused", message: "Will resume at \(pausedUntil.formatTime())")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.Disconnect, object: nil)
        }
        
        timer.eventHandler = { [self] in
            if Date() > pausedUntil {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name.Connect, object: nil)
                }
                
                suspend()
            } else {
                timer.proceed()
                
                DispatchQueue.main.async { [self] in
                    delegate?.updateCountdown(text: countdown)
                }
            }
        }
        timer.resume()
    }
    
    func suspend() {
        pausedUntil = Date()
        timer.suspend()
        cancelBackgroundTasks()
        NotificationManager.shared.removeNotifications()
    }
    
    private func countdownTo(date: Date) -> String {
        let countdown = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
        let hours = countdown.hour!
        let minutes = countdown.minute!
        let seconds = countdown.second!
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Background Tasks -
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "ipvn.backgroundTask", using: nil) { [self] task in
            handleBackgroundTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleBackgroundTask() {
        guard isPaused else {
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: "ipvn.backgroundTask")
        request.earliestBeginDate = pausedUntil
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            log(.error, message: "Could not schedule background task: \(error)")
        }
    }
    
    private func handleBackgroundTask(task: BGAppRefreshTask) {
        task.setTaskCompleted(success: true)
    }
    
    private func cancelBackgroundTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
}

enum PauseDuration: CaseIterable {
    
    case fiveMinutes
    case thirtyMinutes
    case oneHour
    case threeHours
    
    func pausedUntil() -> Date {
        var dateComponent = DateComponents()
        
        switch self {
        case .fiveMinutes:
            dateComponent.minute = 5
        case .thirtyMinutes:
            dateComponent.minute = 30
        case .oneHour:
            dateComponent.hour = 1
        case .threeHours:
            dateComponent.hour = 3
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: Date()) ?? Date()
    }
    
}
