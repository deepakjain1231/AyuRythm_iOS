//
//	ARStreakRewardModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARStreakRewardModel{

	var favoriteId : String!
	var id : String!
	var languageId : String!
	var rewardCode : String!
	var rewardDetails : String!
	var rewardLabel : String!
    var rewardSubtitle : String!
	var rewardSteps : String!
	var rewardType : String!
	var rewardValue : String!
    var rewardExpiry : Double! //In days
    var createdAt : String!
    
    var isDetailExpanded = false
    var isStepsExpanded = false
    var isClaimed = false
    var isExpired = false


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		favoriteId = json["favorite_id"].stringValue
		id = json["id"].stringValue
		languageId = json["language_id"].stringValue
		rewardCode = json["reward_code"].stringValue
		rewardDetails = json["reward_details"].stringValue
		rewardLabel = json["reward_label"].stringValue
        rewardSubtitle = json["reward_subtitle"].stringValue
		rewardSteps = json["reward_steps"].stringValue
		rewardType = json["reward_type"].stringValue
		rewardValue = json["reward_value"].stringValue
        rewardExpiry = json["reward_expiry"].doubleValue
        createdAt = json["created_at"].stringValue
	}

}

extension ARStreakRewardModel {
    var rewardExpiryDate : Date {
        let createdAtDate = createdAt.UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
        return createdAtDate.addingTimeInterval(rewardExpiry*24*60*60)
    }
    
    static func getModel(from scratchCardData: ARScratchCardModel) -> ARStreakRewardModel {
        let data = ARStreakRewardModel(fromJson: JSON())
        data.favoriteId = scratchCardData.scratchid
        data.id = scratchCardData.id
        data.rewardCode = scratchCardData.cardcode
        data.rewardDetails = scratchCardData.offerDetails
        data.rewardSteps = scratchCardData.steps
        data.rewardLabel = scratchCardData.cardlabel
        data.rewardSubtitle = scratchCardData.cardSubtitle
        data.rewardType = scratchCardData.cardtype
        data.rewardValue = scratchCardData.cardvalue
        data.rewardExpiry = scratchCardData.cardexpiry
        data.createdAt = scratchCardData.createdAt
        
        return data
    }
}
