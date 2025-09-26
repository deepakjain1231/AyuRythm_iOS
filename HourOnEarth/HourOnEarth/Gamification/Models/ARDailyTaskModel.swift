//
//	ARDailyTaskModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

enum ARDailyTaskType: String {
    case yoga
    case pranayam
    case meditation
    case kriya
    case mudra
    case sparshna
    case suryanamaskaar
    case other
}

class ARDailyTaskModel{

	var completed : Int!
	var favoriteId : String!
	var id : String!
	var taskLabel : String!
	var taskTypeString : String!
    var taskType = ARDailyTaskType.other

    var isCompleted: Bool {
        return completed == 1
    }
    var isNext = false

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		completed = json["completed"].intValue
		favoriteId = json["favorite_id"].stringValue
		id = json["id"].stringValue
		taskLabel = json["task_label"].stringValue
        taskTypeString = json["task_type"].stringValue
        taskType = ARDailyTaskType(rawValue: taskTypeString) ?? .other
	}

}
