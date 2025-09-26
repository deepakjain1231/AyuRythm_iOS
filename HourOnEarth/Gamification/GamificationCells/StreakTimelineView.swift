//
//  StreakTimelineView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class StreakTimelineView: PDDesignableXibView {
    
    @IBOutlet weak var currenLevelL: UILabel!
    @IBOutlet weak var currenLevelIconIV: UIImageView!
    @IBOutlet weak var currenLevelView: UIView!
    
    @IBOutlet weak var nextLevelL: UILabel!
    @IBOutlet weak var nextLevelIconIV: UIImageView!
    
    @IBOutlet weak var day1L: UILabel!
    @IBOutlet weak var day2L: UILabel!
    @IBOutlet weak var day3L: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func initialSetUp() {
        super.initialSetUp()
    }
    
    func updateUI(from userStreakLevel: ARUserStreakLevelModel?) {
        guard let userStreakLevel = userStreakLevel else {
            print("no userStreakLevel !!!!")
            return
        }
        
        //update UI now
        currenLevelView.isHidden = userStreakLevel.isUserOnNoRankLevel
        currenLevelIconIV.af_setImage(withURLString: userStreakLevel.titleIcon)
        currenLevelL.text = userStreakLevel.userLevel
        
        let daysToComplete = userStreakLevel.nextLevelDetails.daysToCompleteLevel
        day1L.text = "Day".localized() + " 1"
        day2L.text = "Day".localized() + " " + String(format: "%0.f", ceil(daysToComplete/2.0))
        day3L.text = "Day".localized() + " "  + String(format: "%0.f", daysToComplete)
        nextLevelIconIV.af_setImage(withURLString: userStreakLevel.nextLevelDetails.titleIcon)
        nextLevelL.text = userStreakLevel.nextLevelDetails.rank
        
        progressView.progress = userStreakLevel.nextLevelDetails.getProgress(for: userStreakLevel.totalSparshna)
    }
    
    func refreshUIByAPICall(completion: ((ARUserStreakLevelModel?) -> Void)? = nil) {
        StreakDetailVC.getUserStreakDetails { success, status, message, userStreakLevel in
            self.updateUI(from: userStreakLevel)
            completion?(userStreakLevel)
        }
    }
}
