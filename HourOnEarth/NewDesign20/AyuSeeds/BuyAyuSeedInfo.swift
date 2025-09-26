//
//  BuyAyuSeedInfo.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 09/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation

class BuyAyuSeedInfo{

	var amount : Float!
	var bonusMessage : String!
	var bonusPercentage : Float!
	var bonusTitle : String!
	var currency : String!
	var favoriteId : String!
	var id : String!
	var languageId : String!
	var minimumBonusAmount : Float!
	var multiplesAmount : Float!
	var multiplesMessage : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		amount = Float(dictionary["amount"] as? String ?? "0")
		bonusMessage = dictionary["bonus_message"] as? String
		bonusPercentage = Float(dictionary["bonus_percentage"] as? String ?? "0")
		bonusTitle = dictionary["bonus_title"] as? String
		currency = dictionary["currency"] as? String
		favoriteId = dictionary["favorite_id"] as? String
		id = dictionary["id"] as? String
		languageId = dictionary["language_id"] as? String
		minimumBonusAmount = Float(dictionary["minimum_bonus_amount"] as? String ?? "0")
		multiplesAmount = Float(dictionary["multiples_amount"] as? String ?? "1")
		multiplesMessage = dictionary["multiples_message"] as? String
	}

}
