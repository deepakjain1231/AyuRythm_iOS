//
//	ARContentLibraryDataModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

// MARK: -
class ARContentLibraryDataModel{

	var accessPoint : Int!
	var contentType : String!
	var englishName : String!
	var favoriteId : String!
    var foodTypes : String!
	var herbsTypes : String!
	var image : String!
	var name : String!
	var redeemed : Bool!
	var subscriptionType : String!
	var type : String!
	var videoLink : String!
    
    var isSelected = false


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		accessPoint = json["access_point"].intValue
		contentType = json["content_type"].stringValue
		englishName = json["english_name"].stringValue
		favoriteId = json["favorite_id"].stringValue
		herbsTypes = json["herbs_types"].stringValue
        foodTypes = json["food_types"].stringValue
		image = json["image"].stringValue
		name = json["name"].stringValue
		redeemed = json["redeemed"].boolValue
		subscriptionType = json["subscription_type"].stringValue
		type = json["type"].stringValue
		videoLink = json["video_link"].stringValue
        
        if favoriteId.isEmpty {
            favoriteId = json["id"].stringValue
        }
        
        if json["list_name"].exists() {
            name = json["list_name"].stringValue
        }
        
        if json["item"].exists() {
            name = json["item"].stringValue
        }
        
        if !image.hasPrefix("http") {
            image = "https://dev.ayurythm.com/" + image
        }
	}

}

// MARK: -
class ARContentModel {
    var type: ForYouSectionType
    var items: [ARContentLibraryDataModel]
    
    internal init(type: ForYouSectionType, items: [ARContentLibraryDataModel]) {
        self.type = type
        self.items = items
    }
    
    var noOfCells: Int {
        if isCollectionTypeData {
            return 1
        } else {
            return items.count
        }
    }
    
    var isCollectionTypeData: Bool {
        if type == .food || type == .herbs || type == .homeRemedies {
            return true
        } else {
            return false
        }
    }
    
    var getApiEndpoint: endPoint {
        switch type {
        case .playlist:
            return .GetList
//        case .yoga:
//            return .getForYouYoga
//        case .meditation:
//            return .getMeditationios
//        case .pranayama:
//            return .getPranayamaios
//        case .mudra:
//            return .getMudraios
//        case .kriya:
//            return .getKriyaios
        default:
            return .getKriyaiOS_NewAPI
        }
    }
    
    static func getContentData(fromJSON json: JSON) -> [ARContentModel] {
        if json.isEmpty{
            return []
        }
        return [ARContentModel(type: .yoga,
                               items: json["yogasana"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .meditation,
                               items: json["meditation"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .pranayama,
                               items: json["pranayam"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .homeRemedies,
                               items: json["home_remedies"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .food,
                               items: json["foods"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .herbs,
                               items: json["herbs"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .kriya,
                               items: json["kriya"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .mudra,
                               items: json["mudra"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }),
                ARContentModel(type: .playlist,
                               items: json["yogasana"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) })]
    }
}
