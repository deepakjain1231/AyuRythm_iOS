//
//  MyHomeViewController+Recommendataion.swift
//  HourOnEarth
//
//  Created by Apple on 16/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

extension MyHomeViewController {
    
    //Temp comment//
//    func checkRedGraphValue() {
//        self.increasedValues.removeAll()
//        func setStatus(prakriti: Double, vikriti: Double, lblToSet: UILabel, imageArrow: UIImageView, lblPercentage: UILabel, kpvType: KPVType) {
//            if abs(vikriti - prakriti) <= 5 {
//                //if value is less than or equal to 5 then normal
//                lblToSet.text = "Normal".localized()
//                lblToSet.textColor = kAppBlueColor
//                lblPercentage.textColor = kAppBlueColor
//                imageArrow.image = vikriti > prakriti ? UIImage(named: "arrowBlueUp") : UIImage(named: "arrowBlueDown")
//            } else if vikriti > prakriti {
//                //If vikriti value is higher than prakriti= aggrevated
//                lblToSet.text = "Increased".localized()
//                lblToSet.textColor = kAppPinkColor
//                lblPercentage.textColor = kAppPinkColor
//                increasedValues.append(kpvType)
//                imageArrow.image = UIImage(named: "arrowRedUp")
//
//            } else {
//                //imbalance
//                lblToSet.text = "Decreased".localized()
//                lblToSet.textColor = kAppPinkColor
//                lblPercentage.textColor = kAppPinkColor
//                imageArrow.image = UIImage(named: "arrowRedDown")
//            }
//        }
//
//        var kaphaP = 0.0
//        var pittaP = 0.0
//        var vataP = 0.0
//
//        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
//            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
//            if  arrPrashnaScore.count == 3 {
//                kaphaP = Double(arrPrashnaScore[0]) ?? 0
//                pittaP = Double(arrPrashnaScore[1]) ?? 0
//                vataP = Double(arrPrashnaScore[2]) ?? 0
//            }
//        } else {
//            return
//        }
//
//        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
//            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
//            if arrPrashnaScore.count == 3 {
//                let kapha = Double(arrPrashnaScore[0]) ?? 0
//                let pitta = Double(arrPrashnaScore[1]) ?? 0
//                let vata = Double(arrPrashnaScore[2]) ?? 0
//                // new - original / original *100
//                let percentIncreaseK = (kapha - kaphaP) //*100/kaphaP
//                let percentIncreaseP = (pitta - pittaP) //*100/pittaP
//                let percentIncreaseV = (vata - vataP) //*100/vataP
//
//                lblKpvPer1.text = "\(Int(abs(round(percentIncreaseK))))%"
//                lblKpvPer2.text = "\(Int(abs(round(percentIncreaseP))))%"
//                lblKpvPer3.text = "\(Int(abs(round(percentIncreaseV))))%"
//
//                setStatus(prakriti: kaphaP, vikriti: kapha, lblToSet: lblStatus1, imageArrow: imgArrow1, lblPercentage: lblKpvPer1, kpvType: .KAPHA)
//                setStatus(prakriti: pittaP, vikriti: pitta, lblToSet: lblStatus2, imageArrow: imgArrow2, lblPercentage: lblKpvPer2, kpvType: .PITTA)
//                setStatus(prakriti: vataP, vikriti: vata, lblToSet: lblStatus3, imageArrow: imgArrow3, lblPercentage: lblKpvPer3, kpvType: .VATA)
//            }
//        }
//        self.lblRecommendationTitle.text = self.getDisplayMessage().0.localized()
//        self.lblRecommendation.text = self.getDisplayMessage().1.localized()
//    }
    
                                                          
    /**
     1. Only Kapha is in aggravated: Your Kapha is aggravated. We have recommendation to improve your energy strength and vitality

     2. Only Pitta is in aggravated:  Your Pitta is aggravated. Use our personalized recommendation to balance your metabolism

     3. Only Vata is in aggravated: Your vata is aggravated. Calm yourself using combinations of diet, yoga and breathing exercise

     4. Pitta and Kapha is in imbalance: Your Pitta and Kapha are out of balance. We will pacify your metabolism( Pitta ) first before building energy ( Kapha)

     5. Vata and Pitta are in imbalance: Your vata and Pitta are aggravated. We will calm your vata before managing metabolism

     6. Vata and Kapha are in imbalance: Your vata and kapha are above ideal levels. Let us focus on vata first before pacifying kapha

     7. All the three are not imbalance: Not possible.

     8. All the three are in balance: Congratulations! You have reached the perfect balance. Please continue with your lifestyle!
     
     *** if 2 doshas are aggravated, follow the sequence of V P K  and highlght in that sequence irrespective of the value
     */

    
    func getLastAssesmentValue(date: String?) {
        guard let assDate = date else {
            lastAssessmentValue = "\(0) " + "days ago".localized()
            return
        }
        kUserDefaults.set(assDate, forKey: LAST_ASSESSMENT_DATE)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var lastAssessment = dateFormatter.date(from: assDate)
        lastAssessment = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: lastAssessment ?? Date())
        let today = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date() )
        let diffInDays = Calendar.current.dateComponents([.day], from: lastAssessment ?? Date(), to: today ?? Date()).day
        let days = diffInDays == 0 ? "Today".localized() : "\(diffInDays ?? 0) " + "days ago".localized()
        lastAssessmentValue = "\(days)"
    }
}
