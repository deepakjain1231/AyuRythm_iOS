//
//	ARAyuverseCategoryModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARAyuverseCategoryModel{

	var name : String!
	var status : String!
	var id : String!
    
    var isSelected = false
    
    var textWidth: CGFloat {
        let textSize = name.size(withAttributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
        return textSize.width
    }
    init(name: String, status: String, id: String){
        self.name = name
        self.status = status
        self.id = id
    }

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		name = json["category_name"].stringValue
		status = json["category_status"].stringValue
		id = json["id"].stringValue
	}

}
extension ARAyuverseCategoryModel: Equatable {
    static func == (lhs: ARAyuverseCategoryModel, rhs: ARAyuverseCategoryModel) -> Bool {
        return lhs.name == rhs.name && lhs.id == rhs.id && lhs.status == rhs.status
    }
}
