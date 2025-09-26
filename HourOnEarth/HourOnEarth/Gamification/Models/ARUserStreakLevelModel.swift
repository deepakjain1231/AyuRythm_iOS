//
//	ARUserStreakLevelModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import UIKit

class ARUserStreakLevelModel{

	var totalSparshna : Int!
	var userId : String!
	var userLevel : String!
    var userLevelId : String!
    var nextLevel : String!
    var titleIcon : String!
    var nextLevelDetails : ARStreakLevelModel!
    var allRanks: [ARStreakLevelModel]!
    var streakDays : [ARStreakDayModel]!

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		nextLevel = json["next_level"].stringValue
		let nextLevelDetailsJson = json["next_level_details"]
		if !nextLevelDetailsJson.isEmpty{
			nextLevelDetails = ARStreakLevelModel(fromJson: nextLevelDetailsJson)
		}
		titleIcon = json["title_icon"].stringValue
		totalSparshna = json["total_sparshna"].intValue
		userId = json["user_id"].stringValue
		userLevel = json["user_level"].stringValue
        userLevelId = json["user_level_id"].stringValue
        
        allRanks = [ARStreakLevelModel]()
        let allRanksArray = json["all_ranks"].arrayValue
        for allRanksJson in allRanksArray{
            let value = ARStreakLevelModel(fromJson: allRanksJson)
            allRanks.append(value)
        }
        streakDays = [ARStreakDayModel]()
        let userStreakArray = json["user_streak_days"].arrayValue
        for userStreakJson in userStreakArray{
            let value = ARStreakDayModel(fromJson: userStreakJson)
            streakDays.append(value)
        }
        
        //find and set current streak progress
        allRanks.forEach{ level in
            if level.id == userLevelId {
                level.progress = nextLevelDetails.getProgress(for: totalSparshna)
            }
        }
        
        //if user is on no rank level then hide all not done sparshna days
        if isUserOnNoRankLevel {
            streakDays = streakDays.filter{ !$0.isSparshanNotDone }
        }
	}
}

extension ARUserStreakLevelModel {
    var isUserOnNoRankLevel: Bool {
        return userLevel.isEmpty
    }
    
    var streakRewardSubtitleText: String {
        if nextLevelDetails == nil || nextLevelDetails.rank == nil {
            return ""
        } else {
            let str_days = "\(Int(nextLevelDetails.daysToCompleteLevel))"
            return String(format: "Complete %@ days streak to reach %@ level".localized(), str_days, nextLevelDetails.rank)
        }
    }
}
