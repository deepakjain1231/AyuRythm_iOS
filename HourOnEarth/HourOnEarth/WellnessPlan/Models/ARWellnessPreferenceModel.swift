//
//	ARWellnessPreferenceModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import UIKit

class ARWellnessPreferenceModel {

    var id : String!
	var info : String!
	var multipleSelection : Bool!
	var preference : String!
	var values : [ARWellnessPreferenceValueModel]!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        id = json["id"].stringValue
		info = json["info"].stringValue
		multipleSelection = json["multipleSelection"].boolValue
		preference = json["preference"].stringValue
		values = [ARWellnessPreferenceValueModel]()
		let valuesArray = json["values"].arrayValue
		for valuesJson in valuesArray{
			let value = ARWellnessPreferenceValueModel(fromJson: valuesJson)
            value.multipleSelection = multipleSelection
			values.append(value)
		}
	}

    func getSelectedItemsString() -> String {
        let values = values.filter{ $0.selected == true }.compactMap{ $0.id }.joined(separator: ",")
        return values
    }
}

extension ARWellnessPreferenceModel {
    func selectItem(at index: Int) {
        if !multipleSelection {
            values.forEach{ $0.selected = false }
        }
        let selectedItems = values.filter{ $0.selected == true }
        if selectedItems.count == 1, let item = values[safe: index], item.selected {
            //do nothing
        } else {
            values[index].selected.toggle()
        }
    }
}

// MARK: -
class ARWellnessPreferenceValueModel {

    var id : String!
    var selected : Bool!
    var title : String!
    var multipleSelection = false

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        selected = json["selected"].boolValue
        title = json["title"].stringValue
    }
}

extension ARWellnessPreferenceValueModel {
    var cellImage: UIImage {
        if selected {
            if multipleSelection {
                return #imageLiteral(resourceName: "icon_task_done")
            } else {
                return #imageLiteral(resourceName: "checkmark-selected-black-1")
            }
        } else {
            return #imageLiteral(resourceName: "checkmark-black-1")
        }
    }
}
