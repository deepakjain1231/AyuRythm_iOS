//
//  ARStepsDeatilsVC+API.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 06/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import Charts

extension ARStepsDeatilsVC {
    static func fetchAndUpdateStepGoalFromServer() {
        Utils.doAPICall(endPoint: .getUserGoal, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess, let goalValue = responseJSON?["goal"]["goal"].string {
                ARPedometerManager.shared.pedometerData.goal = Int(goalValue) ?? DefaultStepGoalValue
                NotificationCenter.default.post(name: .refreshPedometerData, object: nil)
            }
        }
    }
    
    func updateStepGoalOnServer(goal: Int) {
        self.showActivityIndicator()
        let params = ["set_goal": goal, "language_id" : Utils.getLanguageId(), "device_type": "ios"] as [String : Any]
        Utils.doAPICall(endPoint: .setUserPedometerGoal, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                ARPedometerManager.shared.pedometerData.goal = goal
                NotificationCenter.default.post(name: .refreshPedometerData, object: nil)
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func fetchChartData() {
        //showActivityIndicator(view: barChartView)
        var ePoint = endPoint.getYearlyPedometer
        var params = ["yearnumber": chartData.year!] as [String : Any]
        if selectChartFilter == .month {
            params["monthnumber"] = chartData.month
            ePoint = endPoint.getMonthlyPedometer
        } else if selectChartFilter == .week {
            params["weeknumber"] = chartData.weeknumber
            ePoint = endPoint.getWeeklyPedometer
        }
        
        Utils.doAPICall(endPoint: ePoint, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON  {
                self.chartData = ARGraphDataModel(fromJson: responseJSON)
                self.updateChart()
                //self.hideActivityIndicator(view: self.barChartView)
            } else {
                //self.hideActivityIndicator(view: self.barChartView)
                //self.showAlert(title: status, message: message)
            }
        }
    }
}
