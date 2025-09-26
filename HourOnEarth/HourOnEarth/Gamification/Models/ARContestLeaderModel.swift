//
//	ARContestLeaderModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARContestLeaderModel{

	var rank : String!
    var points : Int!
	var userId : String!
	var userName : String!
    var image : String!
    var levelImage : String!
    var isSubscribed: Int!
    
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


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		rank = json["rank"].stringValue
        points = json["points"].intValue
		userId = json["user_id"].stringValue
		userName = json["user_name"].stringValue
        image = json["image"].stringValue
        levelImage = json["level_image"].stringValue
        isSubscribed = json["isSubscribed"].intValue
	}

}
