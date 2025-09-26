//
//  HOESparshnaResultCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 22/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class SparshnaResultsCell: UITableViewCell {
    
    @IBOutlet weak var lblKaphaPercentage: UILabel!
    @IBOutlet weak var lblPittaPercentage: UILabel!
    @IBOutlet weak var lblVataPercentage: UILabel!
    @IBOutlet weak var lblTitleImbalance: UILabel!
    @IBOutlet weak var imgImbalance: UIImageView!
    @IBOutlet weak var lblCurrentState: UILabel!
    @IBOutlet weak var viewBg: UIView!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblWhatShouldYouDo: UILabel!
    @IBOutlet weak var viewSuggestionsBtn: UIButton!
    @IBOutlet weak var resultDetailSV: UIStackView!
    
    private var increasedValues = [KPVType]()
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureUI(withData data: SparshnaResultHeaderData) {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        imgImbalance.isHidden = true
        lblTitleImbalance.isHidden = true
        lblCurrentState.isHidden = true
        resultDetailSV.isHidden = false
        increasedValues = Utils.getIncreasedValues()
        
        if let vikritiPrashna = kUserDefaults.value(forKey: VIKRITI_PRASHNA) as? String, !vikritiPrashna.isEmpty {
            //If both given then differential
            let percentage = Utils.getRecommendationTypePercentage()
            self.lblKaphaPercentage.text = "\(Int(percentage.kapha))%"
            self.lblPittaPercentage.text = "\(Int(percentage.pitta))%"
            self.lblVataPercentage.text = "\(Int(percentage.vata))%"
            
            kaphaCount += Double(percentage.kapha)
            pittaCount += Double(percentage.pitta)
            vataCount += Double(percentage.vata)
            
            if vataCount > kaphaCount && vataCount > pittaCount {
                // populateDescription(kpvType: .vata)
            } else  if pittaCount > kaphaCount && pittaCount > vataCount {
                //  populateDescription(kpvType: .pitta)
            } else {
                // populateDescription(kpvType: .kapha)
            }
            self.populateHeader(withData: data)
            imgImbalance.isHidden = false
            lblTitleImbalance.isHidden = false
            
        } else {
            //PRAKRITI NOT GIVEN
            //VIKRITI_SPARSHNA
            
            
            if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
                let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
                if  arrPrashnaScore.count == 3 {
                    kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                    pittaCount += Double(arrPrashnaScore[1]) ?? 0
                    vataCount += Double(arrPrashnaScore[2]) ?? 0
                    
                } else  {
                    return
                }
            } else {
                return
            }
            
            let total = kaphaCount + pittaCount + vataCount
            
            let percentKapha = round(kaphaCount*100.0/total)
            let percentPitta =  round(pittaCount*100.0/total)
            let percentVata =  round(vataCount*100.0/total)
            
            self.lblKaphaPercentage.text = "\(Int(percentKapha))%"
            self.lblPittaPercentage.text = "\(Int(percentPitta))%"
            //self.lblVataPercentage.text = "\(Int(percentVata))%"
            //temp fix by paresh to get 100% max
            if (Int(percentKapha) + Int(percentPitta) + Int(percentVata)) == 100 {
                self.lblVataPercentage.text = "\(Int(percentVata))%"
            } else {
                self.lblVataPercentage.text = "\(Int(100 - (percentKapha + percentPitta)))%"
            }
            
            if vataCount > kaphaCount && vataCount > pittaCount {
                //  populateDescription(kpvType: .vata)
            } else  if pittaCount > kaphaCount && pittaCount > vataCount {
                // populateDescription(kpvType: .pitta)
            } else {
                // populateDescription(kpvType: .kapha)
            }
            #if !APPCLIP
            // Code you don't want to use in your app clip.
            if kUserDefaults.value(forKey: VIKRITI_PRASHNA) == nil &&  kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                lblCurrentState.isHidden = false
                lblDescription.text = data.what_it_means
                lblWhatShouldYouDo.text = data.what_to_do
                //lblTitle.text = ""
                resultDetailSV.isHidden = true
            } else {
                //lblTitle.text = "What does this mean?".localized()
                imgImbalance.isHidden = false
                lblTitleImbalance.isHidden = false
                self.populateHeader(withData: data)
            }
            #else
            // Code your app clip may access.
            //lblTitle.text = "What does this mean?".localized()
            
            imgImbalance.isHidden = false
            lblTitleImbalance.isHidden = false
            self.populateHeader(withData: data)
            #endif
        }
    }
    
    func populateHeader(withData data: SparshnaResultHeaderData) {
        self.lblDescription.text = data.what_it_means
        self.lblWhatShouldYouDo.text = data.what_to_do
        
        let currentKPVStatus = Utils.getYourCurrentKPVState(isHandleBalanced: false)
        
        switch currentKPVStatus {
        case .Kapha:
            self.lblTitleImbalance.text = "Your Kapha is aggravated".localized()
            viewBg.backgroundColor = kSparshnaBgGreen
            imgImbalance.image = UIImage(named: "Kaphaa")
            
        case .Pitta:
            self.lblTitleImbalance.text = "Your Pitta is aggravated".localized()
            viewBg.backgroundColor = kSparshnaBgPink
            imgImbalance.image = UIImage(named: "PittaN")
            
        case .Vata:
            self.lblTitleImbalance.text = "Your Vata is aggravated".localized()
            viewBg.backgroundColor = kSparshnaBgBlue
            imgImbalance.image = UIImage(named: "VataN")
            
        default:
            self.lblTitleImbalance.text = "You are in balance".localized()
            viewBg.backgroundColor = kSparshnaBgYellow
            imgImbalance.image = UIImage(named: "sparshnaNormal")
            
            //self.lblDescription.text = "Congratulations! You have achieved the dosha balance as per your Prakriti.\nPlease follow the  recommendations to maintain the healthy lifestyle and balance.".localized()
            //self.lblWhatShouldYouDo.text = ""
        }
    }
}

// MARK: - Old UI
/*extension SparshnaTestInfoViewController {
    func populateHeader() {
           let increasedValues = self.increasedValues
           if increasedValues.contains(.VATA) && increasedValues.contains(.PITTA) {
            self.lblTitleImbalance.text = "Your Vata is aggravated".localized()
            imgImbalance.image = UIImage(named: "VataN")
            viewBg.backgroundColor = kSparshnaBgBlue
            self.lblDescription.text = "• Sinus congestion, poor sense of smell \n• Poor sense of taste, food cravings due to lack of fulfillment \n• Impaired digestion, poor absorption \n• Lethargy, respiratory problems, lower back pain \n• Weight gain, oily skin, loose or painful joints".localized()


           } else if increasedValues.contains(.VATA) && increasedValues.contains(.KAPHA)  {
            self.lblTitleImbalance.text = "Your Vata is aggravated".localized()
            imgImbalance.image = UIImage(named: "VataN")
            viewBg.backgroundColor = kSparshnaBgBlue
            self.lblDescription.text = "• Sinus congestion, poor sense of smell \n• Poor sense of taste, food cravings due to lack of fulfillment \n• Impaired digestion, poor absorption \n• Lethargy, respiratory problems, lower back pain \n• Weight gain, oily skin, loose or painful joints".localized()


           } else if increasedValues.contains(.PITTA) && increasedValues.contains(.KAPHA)  {
            self.lblTitleImbalance.text = "Your Pitta is aggravated".localized()
            viewBg.backgroundColor = kSparshnaBgPink
            imgImbalance.image = UIImage(named: "PittaN")
            
            self.lblDescription.text = "• Bloodshot eyes, poor vision \n• Skin rashes, acne \n• Demanding, perfectionist, workaholic \n• Acid stomach \n• Early graying, anger, toxins in blood".localized()


           } else if increasedValues.contains(.VATA) {
            self.lblTitleImbalance.text = "Your Vata is aggravated".localized()
            viewBg.backgroundColor = kSparshnaBgBlue
            imgImbalance.image = UIImage(named: "VataN")

            self.lblDescription.text = "• Worries, overactive mind, sleep problems, difficulty breathing \n• Dry cough, sore throats, earaches, general fatigue. \n• Slow or rapid digestion, gas, intestinal cramps, poor assimilation, weak tissues. \n• Intestinal cramps, menstrual problems, lower back pain, irregularity, diarrhea, constipation, gas \n• Dry or rough skin, nervousness, shakiness, poor blood flow, stress-related problems".localized()

           } else if increasedValues.contains(.PITTA) {
            self.lblTitleImbalance.text = "Your Pitta is aggravated".localized()
            viewBg.backgroundColor = kSparshnaBgPink
            imgImbalance.image = UIImage(named: "PittaN")

            self.lblDescription.text = "• Bloodshot eyes, poor vision \n• Skin rashes, acne \n• Demanding, perfectionist, workaholic \n• Acid stomach \n• Early graying, anger, toxins in blood".localized()


           } else if increasedValues.contains(.KAPHA) {
            self.lblTitleImbalance.text = "Your Kapha is aggravated".localized()
           viewBg.backgroundColor = kSparshnaBgGreen
            imgImbalance.image = UIImage(named: "Kaphaa")
            
            self.lblDescription.text = "• Sinus congestion, poor sense of smell \n• Poor sense of taste, food cravings due to lack of fulfillment \n• Impaired digestion, poor absorption \n• Lethargy, respiratory problems, lower back pain \n• Weight gain, oily skin, loose or painful joints".localized()

           } else {
            imgImbalance.image = UIImage(named: "sparshnaNormal")
            viewBg.backgroundColor = kSparshnaBgYellow

            self.lblTitleImbalance.text = "You are in balance".localized()
            self.lblDescription.text = "Congratulations! You have achieved the dosha balance as per your Prakriti.\nPlease follow the  recommendations to maintain the healthy lifestyle and balance.".localized()
           }
       }
}*/
