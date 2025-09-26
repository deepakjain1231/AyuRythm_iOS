//
//	ARWellnessDietModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import UIKit

class ARWellnessDietSectionModel{

	var day : String!
	var image : String!
	var section : [ARDietSubSectionModel]!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		day = json["day"].stringValue
		image = json["image"].stringValue
		section = [ARDietSubSectionModel]()
		let sectionArray = json["section"].arrayValue
		for sectionJson in sectionArray{
			let value = ARDietSubSectionModel(fromJson: sectionJson)
			section.append(value)
		}
	}
}

// MARK: -
class ARDietSubSectionModel{

    var items : [ARDietItemModel]!
    var subsection : String?
    var day_name : String?
    var sectionStartImage : String?
    var description_info: String?
    var food_eat_time: String?

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        items = [ARDietItemModel]()
        let dataArray = json["data"].arrayValue
        for dataJson in dataArray{
            let value = ARDietItemModel(fromJson: dataJson)
            items.append(value)
        }
        subsection = json["subsection"].string ?? ""
        description_info = json["description"].string ?? ""
        food_eat_time = json["food_eat_time"].string ?? ""
    }
}

// MARK: -
class ARDietItemModel{
    var id : String = ""
    var image : String = ""
    var name : String = ""
    var food_name : String = ""
    var info : String = ""
    var food_tags: String = ""
    var recipes: String = ""
    var fiber: String = ""
    var protein: String = ""
    var fats: String = ""
    var carbs: String = ""
    var calary: String = ""
    var qauntity: String = ""
    var food_type: String = ""
                                

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].string ?? ""
        image = json["image"].string ?? ""
        name = json["name"].string ?? ""
        food_name = json["food_name"].string ?? ""
        info = json["info"].string ?? ""
        food_tags = json["food_tags"].string ?? ""
        recipes = json["recipes"].string ?? ""
        fiber = json["fiber"].string ?? ""
        protein = json["protein"].string ?? ""
        fats = json["fats"].string ?? ""
        carbs = json["carbs"].string ?? ""
        calary = json["calary"].string ?? ""
        qauntity = json["qauntity"].string ?? ""
        food_type = json["food_type"].string ?? ""
    }
}

extension ARWellnessDietSectionModel {
    func getAllDietSubSections() -> [ARDietSubSectionModel] {
        let data = section
        data?.first?.sectionStartImage = image
        data?.first?.day_name = day
        return data ?? []
    }
}
