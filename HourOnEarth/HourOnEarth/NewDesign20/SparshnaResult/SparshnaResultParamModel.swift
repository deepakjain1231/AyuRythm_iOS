//
//  SparshnaResultParamModel.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 04/12/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation

class SparshnaResultParamModel {
    
    enum ParamType: String {
        case bpm = "bpm"
        case sp = "sp"
        case dp = "dp"
        case bala = "bala"
        case kath = "kath"
        case gati = "gati"
        case rythm = "rhythm"
        case o2r = "o2r"
        case bmi = "bmi"
        case bmr = "bmr"
        case other = "other"
        
        var viewSuggestionType: TodayRecommendations.Types {
            switch self {
            case .bpm, .rythm:
                return .pranayam
            case .kath, .bala:
                return .yoga
            case .dp:
                return .meditation
            case .sp, .gati:
                return .food
            default:
                return .other
            }
        }
    }

    var aggravationType : String!
    var favoriteId : String!
    var parameter : String!
    var shortDescription : String!
    var subtitle : String!
    var whatDoesMeans : String!
    
    var paramStringValue = ""
    var paramDisplayValue = ""
    var paramType = ParamType.other
    var paramIcon: UIImage?
    var paramKPVValue = CurrentKPVStatus.Balanced
    var title = ""
    var subtitle2 = ""

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]) {
        aggravationType = dictionary["aggravation_type"] as? String
        favoriteId = dictionary["favorite_id"] as? String
        parameter = dictionary["parameter"] as? String
        shortDescription = dictionary["short_description"] as? String
        subtitle = dictionary["title"] as? String
        whatDoesMeans = dictionary["what_does_means"] as? String
        paramType = ParamType(rawValue: parameter) ?? .other
        //updateParamDetails()
    }
    
    func updateParamDetails() {
        let paramValue = Int(paramStringValue) ?? 0
        
        switch paramType {
        case .bpm:
            title = "Vega".localized()
            subtitle2 = "Correlates to heart rate".localized()
            paramIcon = #imageLiteral(resourceName: "bala")
            if (paramValue < 70) {
                paramDisplayValue = "Below 70".localized()
                paramKPVValue = .Kapha
            } else if (paramValue >= 70 && paramValue <= 80) {
                paramDisplayValue = "70-80"
                paramKPVValue = .Pitta
            } else {
                paramDisplayValue = "Above 80".localized()
                paramKPVValue = .Vata
            }
            
        case .sp:
            title = "Akruti Matra".localized()
            subtitle2 = "Correlates to systolic BP".localized()
            paramIcon = #imageLiteral(resourceName: "akritiMatra")
            if (paramValue < 90) {
                paramDisplayValue = "Below 90".localized()
                paramKPVValue = .Vata
            } else if (paramValue >= 90 && paramValue <= 120) {
                paramDisplayValue = "90-120"
                paramKPVValue = .Pitta
            } else {
                paramDisplayValue = "Above 120".localized()
                paramKPVValue = .Kapha
            }
            
        case .dp:
            title = "Akruti Tanaav".localized()
            subtitle2 = "Correlates to diastolic BP".localized()
            paramIcon = #imageLiteral(resourceName: "akritiMatra")
            if (paramValue < 60) {
                paramDisplayValue = "Below 60".localized()
                paramKPVValue = .Vata
            } else if (paramValue >= 60 && paramValue <= 80) {
                paramDisplayValue = "60-80"
                paramKPVValue = .Pitta
            } else {
                paramDisplayValue = "Above 80".localized()
                paramKPVValue = .Kapha
            }
            
        case .bala:
            title = "Bala".localized()
            subtitle2 = "Correlates to pulse pressure".localized()
            paramIcon = #imageLiteral(resourceName: "bala")
            if (paramValue < 30) {
                paramDisplayValue = "Below 30".localized()
                paramKPVValue = .Vata
            } else if (paramValue >= 30 && paramValue <= 40) {
                paramDisplayValue = "30-40"
                paramKPVValue = .Kapha
            } else {
                paramDisplayValue = "Above 40".localized()
                paramKPVValue = .Pitta
            }
            
        case .kath:
            title = "Kathinya".localized()
            subtitle2 = "Correlates to stiffness index".localized()
            paramIcon = #imageLiteral(resourceName: "kathinya")
            if (paramValue < 210) {
                paramDisplayValue = "Below 210".localized()
                paramKPVValue = .Pitta
            } else if (paramValue >= 210 && paramValue <= 310) {
                paramDisplayValue = "210-310"
                paramKPVValue = .Kapha
            } else {
                paramDisplayValue = "Above 310".localized()
                paramKPVValue = .Vata
            }
            
        case .gati:
            title = "Gati".localized()
            subtitle2 = "Correlates to pulse morphology".localized()
            paramIcon = #imageLiteral(resourceName: "gati")
            if paramStringValue == "Kapha" {
                paramDisplayValue = "Hamsa".localized()
                paramKPVValue = .Kapha
            } else if paramStringValue == "Pitta" {
                paramDisplayValue = "Manduka".localized()
                paramKPVValue = .Pitta
            } else {
                paramDisplayValue = "Sarpa".localized()
                paramKPVValue = .Vata
            }
            
        case .rythm:
            title = "Tala".localized()
            subtitle2 = "Correlates to HRV".localized()
            paramIcon = #imageLiteral(resourceName: "tala")
            if paramValue == 0 {
                paramDisplayValue = "Irregular".localized()
                paramKPVValue = .Vata
            } else {
                paramDisplayValue = "Regular".localized()
                paramKPVValue = .Balanced
            }
            
        case .o2r:
            title = "SpO₂".localized()
            subtitle2 = "Oxygen saturation".localized()
            paramIcon = #imageLiteral(resourceName: "spO2")
            if (paramValue < 90) {
                paramDisplayValue = "Low".localized()
            } else if (paramValue >= 90 && paramValue <= 95) {
                paramDisplayValue = "Normal".localized()
            } else {
                paramDisplayValue = "Good".localized()
            }
            paramDisplayValue = "\(paramValue)  " + paramDisplayValue
            
        case .bmi:
            title = "BMI".localized()
            subtitle2 = "Body mass index".localized()
            paramIcon = #imageLiteral(resourceName: "bmi")
            
            let doubleValue = Double(paramStringValue) ?? 0
            if (doubleValue <= 18.5) {
                paramDisplayValue = "Underweight".localized()
            } else if (doubleValue > 18.5 && doubleValue <= 24.9) {
                paramDisplayValue = "Normal".localized()
            } else if (doubleValue > 25 && doubleValue <= 30) {
                paramDisplayValue = "Overweight".localized()
            } else {
                paramDisplayValue = "Obese".localized()
            }
            paramDisplayValue = String(format:"%.1f  ", doubleValue) + paramDisplayValue
            
        case .bmr:
            title = "BMR".localized()
            subtitle2 = "Basal metabolic rate".localized()
            paramIcon = #imageLiteral(resourceName: "bmr")
            
            paramDisplayValue = paramStringValue
                
        default:
            print("unhandled cases come here")
        }
    }
}




//Vikriti
struct Vikriti_Prediction_Model: Codable {
    let type: String?
    let agg_kpv: String?
    let xai_result: String?
}
