//
//	ARContestQuestionModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

typealias ARContestQuestionOptionModel = (option: String, value: String)

class ARContestQuestionModel{

	var correctDescription : String!
	var correctOption : String!
	var id : String!
	var optionA : String!
	var optionB : String!
	var optionC : String!
	var optionD : String!
	var question : String!
	var reward : Int!
    
    var selectedOption: String?
    var options = [ARContestQuestionOptionModel]()
    
    var isCurrectAnswer: Bool {
        return selectedOption == correctOption
    }


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		correctDescription = json["correct_description"].stringValue
		correctOption = json["correct_option"].stringValue
		id = json["id"].stringValue
		optionA = json["option_a"].stringValue
		optionB = json["option_b"].stringValue
		optionC = json["option_c"].stringValue
		optionD = json["option_d"].stringValue
		question = json["question"].stringValue
		reward = json["reward"].intValue
        options = [(option: "option_a", value: optionA),
                   (option: "option_b", value: optionB),
                   (option: "option_c", value: optionC),
                   (option: "option_d", value: optionD)]
	}

}
