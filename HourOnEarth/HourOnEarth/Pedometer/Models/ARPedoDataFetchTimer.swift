//
//  ARPedoDataFetchTimer.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 14/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class ARPedoDataFetchTimer {
    
    static let dataFetchInterval: Double = 90 //1.5 min interval
    static let shared = ARPedoDataFetchTimer()
    
    var timer: Timer?
    var interval: Double = dataFetchInterval
    var timerFireHandler: ((Double)->Void)?
    
    init(interval: Double = dataFetchInterval, timerFireHandler: ((Double)->Void)? = nil) {
        self.interval = interval
        self.timerFireHandler = timerFireHandler
    }
    
    func startTimer() {
        print("@@ Pedo timer : start")
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerFire(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        print("@@ Pedo timer : stop")
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFire(_ timer: Timer) {
        print("@@ Pedo timer : fetch data")
        ARPedometerManager.shared.fetchPedometerDataFromHealthKit(doUpdateOnServer: false)
        timerFireHandler?(interval)
    }
}
