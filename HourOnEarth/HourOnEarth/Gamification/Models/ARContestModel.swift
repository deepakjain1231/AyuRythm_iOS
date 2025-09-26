//
//	ARContestModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARContestModel {
    
    var bonus : String!
    var descriptionField : String!
    var descriptionHtml : String!
    var id : String!
    var name : String!
    var rank : String!
    var startDate : String!
    var endDate : String!
    var serverDateTimeStr : String!
    var contestType : String!
    var status : String!
    var subtitle : String!
    var winnerDeclared : String!
    
    var rowID : Int? //Used for answer submission

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        bonus = json["bonus"].stringValue
        descriptionField = json["description"].stringValue
        descriptionHtml = json["description_html"].stringValue
        id = json["contest_id"].stringValue
        name = json["name"].stringValue
        rank = json["rank"].stringValue
        startDate = json["start_date"].stringValue
        endDate = json["end_date"].stringValue
        serverDateTimeStr = json["server_time"].stringValue
        contestType = json["contest_type"].stringValue
        status = json["status"].stringValue
        subtitle = json["subtitle"].stringValue
        winnerDeclared = json["winner_declared"].stringValue
    }
}

extension ARContestModel {
    var contestStartDate : Date {
        return startDate.UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
    }
    var contestEndDate : Date {
        return endDate.UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
    }
    var serverDateTime : Date {
        return serverDateTimeStr.UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
    }
    var contestCheckWinnerDate : Date {
        return contestEndDate.addingTimeInterval(2*24*60*60) //adding 2 in day in expiry
    }
    
    var isProContest: Bool {
        return contestType == "1"
    }
    
    var isWinnerDeclared: Bool {
        return winnerDeclared == "1"
    }
    
    var isContestExpired: Bool {
        return serverDateTime > contestEndDate
    }
}
