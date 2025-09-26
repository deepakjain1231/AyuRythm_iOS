//
//	ARStreakLevelModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARStreakLevelModel{

	var backgroundColor : String!
	var days : Int!
	var rankId : String!
	var id : String!
	var label : String!
	var languageId : String!
	var missday : Int!
	var percent : Double!
	var rank : String!
	var seedsIcon : String!
	var titleIcon : String!
    var lock: Bool!
    var isMoreRewards: Bool!
    
    var isNext = false
    var progress: Float = 0

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		backgroundColor = json["background_color"].stringValue
		days = json["days"].intValue
        rankId = json["rank_id"].stringValue
		id = json["id"].stringValue
		label = json["label"].stringValue
		languageId = json["language_id"].stringValue
		missday = json["missday"].intValue
		percent = json["percent"].doubleValue
		rank = json["rank"].stringValue
		seedsIcon = json["seeds_icon"].stringValue
		titleIcon = json["title_icon"].stringValue
        lock = json["lock"].boolValue
        isNext = json["isnext"].boolValue
        isMoreRewards = json["is_more_rewards"].boolValue
        
        //set level progress
        if !lock {
            progress = 1
        }
	}

}

extension ARStreakLevelModel {
    var daysToCompleteLevel: Double {
        let daysToComplete = ceil(Double(days) * (percent/100))
        return daysToComplete
    }
    
    func getProgress(for totalSparshnaCount: Int) -> Float {
        let progress = Float(totalSparshnaCount) / Float(daysToCompleteLevel)
        return progress
    }
}
