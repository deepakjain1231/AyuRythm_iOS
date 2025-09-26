//
//  ARPedometerBannerCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 30/03/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//
// https://github.com/malkouz/MKMagneticProgress

import UIKit
import MKMagneticProgress

class ARPedometerBannerCell: UITableViewCell {
    
    @IBOutlet weak var progressView: MKMagneticProgress!
    @IBOutlet weak var lbl_stepTitle: UILabel!
    @IBOutlet weak var lbl_Step: UILabel!
    @IBOutlet weak var lbl_TotalStep: UILabel!
    
    @IBOutlet weak var lbl_CaloriesTitle: UILabel!
    @IBOutlet weak var lbl_Calories: UILabel!
    @IBOutlet weak var lbl_kCal: UILabel!
    
    @IBOutlet weak var lbl_DistanceTitle: UILabel!
    @IBOutlet weak var lbl_Distance: UILabel!
    @IBOutlet weak var lbl_km: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_stepTitle.text = "Steps".localized()
        self.lbl_CaloriesTitle.text = "Calories".localized()
        self.lbl_DistanceTitle.text = "Distance".localized()
    }
    
    func setupUI() {
        let data = ARPedometerManager.shared.pedometerData
        self.lbl_Step.text = data.todayData_StepsProgressString
        self.lbl_TotalStep.text = data.todayData_TotalStepsProgressString
        
        self.lbl_Calories.text = data.todayCalorieStringValue
        self.lbl_Distance.text = data.todayDistanceStringValue
        self.lbl_km.text = data.todayDistanceTypeStringValue
        
//        totalStepsL.text = data.todayStepsProgressString
//        distanceL.text = data.todayDistanceStringValue
//        calorieL.text = data.todayCalorieStringValue
        //timeL.text = data.todayTimeStringValue
        //paceL.text = data.todayPaceStringValue
        
        progressView.setProgress(progress: data.todayStepsProgressValue)
        if data.todaysData.isEmptyModel {
//            infoL.text = HealthKitManager.stepPermissionNotFound
//            infoL.isHidden = false
        } else {
//            infoL.isHidden = true
        }
    }
}
