//
//	ARActiveSubscription.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARActiveSubscription{

	var amount : String!
	var bonusDays : String!
	var endDate : String!
	var favoriteId : String!
	var id : String!
	var packName : String!
	var pauseDate : String!
	var remainingDay : String!
	var remainingHour : String!
	var remainingMinute : String!
	var remainingMonth : String!
	var remainingSecond : String!
	var remainingYear : String!
	var resumeDate : String!
	var startDate : String!
	var userId : String!
	var validityDays : String!
    var pauseFlag : Bool!
    var pauseMaxDays : String!
    var pauseTotalCount : String!
    var subscription_name: String = ""


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		amount = json["amount"].stringValue
		bonusDays = json["bonus_days"].stringValue
		endDate = json["end_date"].stringValue
		favoriteId = json["favorite_id"].stringValue
		id = json["id"].stringValue
		packName = json["pack_name"].stringValue
		pauseDate = json["pause_date"].stringValue
		remainingDay = json["remaining_day"].stringValue
		remainingHour = json["remaining_hour"].stringValue
		remainingMinute = json["remaining_minute"].stringValue
		remainingMonth = json["remaining_month"].stringValue
		remainingSecond = json["remaining_second"].stringValue
		remainingYear = json["remaining_year"].stringValue
		resumeDate = json["resume_date"].stringValue
		startDate = json["start_date"].stringValue
		userId = json["user_id"].stringValue
		validityDays = json["validity_days"].stringValue
        pauseFlag = json["pause_flag"].boolValue
        pauseMaxDays = json["pause_max_days"].stringValue
        pauseTotalCount = json["pause_total_count"].stringValue
        subscription_name = json["subscription_name"].stringValue

        //endDate = "2022-06-28 23:59:59"
	}

}

extension ARActiveSubscription {
    var isPlanPaused: Bool {
        if !pauseDate.isEmpty, !resumeDate.isEmpty {
            return pauseFlag
        } else {
            return false
        }
    }
    
    var planExpiryDateString: String {
        return planEndDateValue.dateString(format: "dd/MM/yyyy")
    }
    
    var planEndDateValue: Date {
        var date = endDate.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)
        if date == nil {
            date = endDate.UTCToLocalDate(incomingFormat: App.dateFormat.yyyyMMdd)
        }
        return date ?? Date()
    }
    
    var planPauseDateValue: Date? {
        let date = pauseDate.UTCToLocalDate(incomingFormat: App.dateFormat.yyyyMMdd)
        return date
    }
    
    var planResumeDateValue: Date? {
        let date = pauseDate.UTCToLocalDate(incomingFormat: App.dateFormat.yyyyMMdd)
        return date
    }
    
    var isPlanExpired: Bool {
        return planEndDateValue < Date()
    }
    //Temp comment
    func getPlanExpiresInData() -> (days: Int, hours: Int)? {
        let diffDateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: planEndDateValue)
        
        let totalHours = diffDateComponents.hour ?? 0
        let days = totalHours/24
        if days < 6, !isPlanExpired, !isPlanPaused {
            let hours = (totalHours%24)
            print(">> Plan expires in - Days: \(days), Hours: \(hours)")
            return (days, hours)
        } else {
            return nil
        }
    }
    
    func planPauseDateLimits() -> (start: Date, end: Date) {
        let startD = Date().tomorrow
        let endD = startD.adding(.day, value: pauseMaxDays.intValue)
        return (startD, endD)
    }
}
