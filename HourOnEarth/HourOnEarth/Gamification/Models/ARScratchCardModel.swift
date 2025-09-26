//
//	ARScratchCardModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARScratchCardModel{
    
    enum ARScratchCardType: Int {
        case betterLuckNextTime
        case ayuseeds
        case promocode
        case other
    }

	var cardcode : String!
	var cardexpiry : Double!    //In days
	var cardlabel : String!
    var cardSubtitle : String!
	var cardprobability : String!
	var cardstatus : String!
	var cardtype : String!
	var cardvalue : String!
	var createdAt : String!
	var id : String!
	var scratchid : String!
	var type : String!
    var openStatus : String!
    var redeemed : String!
    var offerDetails : String!
    var steps : String!

    var cardTypeValue = ARScratchCardType.betterLuckNextTime
    
	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		cardcode = json["cardcode"].stringValue
		cardexpiry = json["cardexpiry"].doubleValue
		cardlabel = json["cardlabel"].stringValue
        cardSubtitle = json["card_subtitle"].stringValue
		cardprobability = json["cardprobability"].stringValue
		cardstatus = json["cardstatus"].stringValue
		cardtype = json["cardtype"].stringValue
        cardTypeValue = ARScratchCardType(rawValue: cardtype.intValue) ?? .betterLuckNextTime
		cardvalue = json["cardvalue"].stringValue
		createdAt = json["created_at"].stringValue
		id = json["id"].stringValue
		scratchid = json["scratchid"].stringValue
		type = json["type"].stringValue
        openStatus = json["status"].stringValue
        redeemed = json["redeemed"].stringValue
        offerDetails = json["offer_details"].stringValue
        steps = json["steps"].stringValue
	}

}

extension ARScratchCardModel {
    var isAyuseedRewardCard: Bool {
        return cardtype == "1"
    }
    
    var isClaimed: Bool {
        return openStatus == "1"
    }
    
    var isExpired: Bool {
        return Date() > cardExpiryDate
    }
    
    var expiresInString: String {
        let diffDateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: cardExpiryDate)
        
        var label = "" //"Expires in".localized() + " "
        let totalHours = diffDateComponents.hour ?? 0
        let days = totalHours/24
        if days >= 1 {
            label = String(format: "Expires in %@ %@".localized(), days.stringValue, (days > 1 ? "days".localized() : "day".localized()))
        } else {
            let hours = (totalHours%24)
            if hours >= 1 {
                label = String(format: "Expires in %@ %@".localized(), hours.stringValue, (hours > 1 ? "hours".localized() : "hour".localized()))
            } else {
                let minutes = diffDateComponents.minute ?? 0
                if minutes >= 1 {
                    label = String(format: "Expires in %@ %@".localized(), minutes.stringValue, (minutes > 1 ? "minutes".localized() : "minute".localized()))
                } else {
                    label = "Expired"
                }
            }
        }
        //print(">> Card Expiry date : ", cardExpiryDate)
        //print(">> Card Expires in ::: Day-%@, Hour-%@, Minute-%@", (totalHours/24).twoDigitStringValue, (totalHours%24).twoDigitStringValue, (diffDateComponents.minute ?? 0).twoDigitStringValue)
        return label
    }
    
    var cardExpiryDate : Date {
        let createdAtDate = createdAt.UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
        return createdAtDate.addingTimeInterval(cardexpiry*24*60*60)
    }
}
