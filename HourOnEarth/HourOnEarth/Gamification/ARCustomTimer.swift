//
//  ARCustomTimer.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 19/02/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class ARCountDownTimer {
    var timer: Timer?
    var timerCount = 3
    var timerFireHandler: ((Int)->Void)?
    var timerExpiredHandler: (()->Void)?
    
    init(count: Int = 3) {
        timerCount = count
    }
    
    func startTimer(count: Int = 3, timerFireHandler: ((Int)->Void)? = nil, timerExpiredHandler: (()->Void)? = nil) {
        stopTimer()
        self.timerFireHandler = timerFireHandler
        self.timerExpiredHandler = timerExpiredHandler
        timerCount = count
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFire(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerFireHandler = nil
        timerExpiredHandler = nil
    }
    
    @objc func timerFire(_ timer: Timer) {
        if timerCount > 0 {
            print(">>> timer count : ", timerCount)
            timerFireHandler?(timerCount)
            timerCount -= 1
        } else {
            timerExpired(timer)
        }
    }
    
    func timerExpired(_ timer: Timer) {
        timerExpiredHandler?()
        print(">>> timer expired")
        stopTimer()
    }
}
