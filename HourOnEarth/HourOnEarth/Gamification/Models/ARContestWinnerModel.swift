//
//	ARContestWinnerModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARContestWinnerModel{

	var contestId : String!
	var id : String!
	var image : String!
	var isSubscribe : Int!
	var levelImage : String!
	var name : String!
	var prizeDate : String!
	var prizeType : String!
	var prizeValue : String!
	var prizeWon : String!
	var rankId : String!
	var userId : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		contestId = json["contest_id"].stringValue
		id = json["id"].stringValue
		image = json["image"].stringValue
		isSubscribe = json["isSubscribe"].intValue
		levelImage = json["level_image"].stringValue
		name = json["name"].stringValue
		prizeDate = json["prize_date"].stringValue
		prizeType = json["prize_type"].stringValue
		prizeValue = json["prize_value"].stringValue
		prizeWon = json["prize_won"].stringValue
		rankId = json["rank_id"].stringValue
		userId = json["user_id"].stringValue
	}

}

extension ARContestWinnerModel {
    var isMySelf: Bool {
        return userId == kSharedAppDelegate.userId
    }
    
    var imageURL: URL? {
        if image.hasPrefix("http") {
            return URL(string: image)
        } else {
            return URL(string: kBaseNewURL + image)
        }
    }
}
