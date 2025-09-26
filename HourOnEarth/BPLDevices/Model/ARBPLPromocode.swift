//
//	ARBPLPromocode.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARBPLPromocode{

	var couponCode : String!
	var couponCodeType : String!
	var couponEndDate : String!
	var couponValidity : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		couponCode = json["coupon_code"].stringValue
		couponCodeType = json["coupon_code_type"].stringValue
		couponEndDate = json["coupon_end_date"].stringValue
		couponValidity = json["coupon_validity"].stringValue
	}

}
