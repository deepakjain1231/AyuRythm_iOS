//
//	ARContestResult.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARContestResultModel {

	var answers : String!
	var completion : Int!
	var correctCount : Int!
	var points : Int!
	var totalQuestion : Int!
	var wrongCount : Int!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		answers = json["answers"].stringValue
		completion = json["completion"].intValue
		correctCount = json["correct_count"].intValue
		points = json["points"].intValue
		totalQuestion = json["total_question"].intValue
		wrongCount = json["wrong_count"].intValue
	}

}

extension ARContestResultModel {
    var resultPercentage: Float {
        return (Float(correctCount) / Float(totalQuestion)) * 100
    }
}
