//
//  ARPedometerManager.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class ARPedometerManager {

    static let shared = ARPedometerManager()
    var pedometerData: ARPedometerData
    
    init() {
        pedometerData =  ARPedometerData.loadUserFromUserDefault()
    }
}

extension ARPedometerManager {
    func fetchPedometerDataFromHealthKit(doUpdateOnServer: Bool = true) {
        let defaultFetchDate = Date().adding(.month, value: -1) //Default fetch one month data from today
        HealthKitManager.shared.fetchLatestPedometerData(fromDate: pedometerData.lastSyncDate ?? defaultFetchDate) { isLiveUpdate, datas in
            //print("\n### update pedo UI ")
            ARPedometerManager.shared.pedometerData.updateDatas(datas)
            if !isLiveUpdate {
                self.updatePedometerDataOnServer()
            }
            NotificationCenter.default.post(name: .refreshPedometerData, object: nil)
        }
        
        /*let defaultFetchDate = Date().adding(.month, value: -1) //Default fetch one month data from today
        HealthKitManager.shared.fetchPedometerData(startDate: pedometerData.lastSyncDate ?? defaultFetchDate, endDate: Date()) { startDate, endDate, datas in
            ARPedometerManager.shared.pedometerData.updateDatas(datas)
            if doUpdateOnServer {
                self.updatePedometerDataOnServer()
            }
            NotificationCenter.default.post(name: .refreshPedometerData, object: nil)
        }*/
    }
    
    func updatePedometerDataOnServer() {
        guard let syncData = ARPedometerManager.shared.pedometerData.getDataToSyncOnserver() else {
            print("??? no pedometer data to sync on server")
            if let topVC = UIApplication.topViewController, topVC.isKind(of:  MyHomeViewController.self) {
                if (topVC as! MyHomeViewController).is_showcaseAccess == false {
                    (topVC as! MyHomeViewController).is_showcaseAccess = true
                    (topVC as! MyHomeViewController).allDataFetchCompleted()
                }
            }
            return
        }
        
        let params = ["pedoarray": syncData, "language_id" : Utils.getLanguageId(), "device_type": "ios", "user_id": kSharedAppDelegate.userId] as [String : Any]
        
        Utils.doAPICall(endPoint: .bulkUpdatePedometer, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                ARPedometerManager.shared.pedometerData.removeSyncedData()
                
                if let topVC = UIApplication.topViewController, topVC.isKind(of:  MyHomeViewController.self) {
                    if (topVC as! MyHomeViewController).is_showcaseAccess == false {
                        (topVC as! MyHomeViewController).is_showcaseAccess = true
                        (topVC as! MyHomeViewController).allDataFetchCompleted()
                    }
                }
            }
        }
    }
}
