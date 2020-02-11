//
//  TimerManager.swift
//  wireguard-tunnel-provider
//
//  Created by Juraj Hilje on 07/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//
//  TimerManager mimics the API of DispatchSourceTimer but in a way that prevents
//  crashes that occur from calling resume multiple times on a timer that is
//  already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
//

import Foundation

class TimerManager {
    
    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let timerObj = DispatchSource.makeTimerSource()
        timerObj.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        timerObj.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return timerObj
    }()
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed { return }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended { return }
        state = .suspended
        timer.suspend()
    }
    
    func proceed() {
        suspend()
        resume()
    }
    
}
