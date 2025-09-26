//
//	ARSubsOrderDetailModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ARSubsOrderDetailModel{

	var paymentInfo : ARPaymentInfo?
	var orderDetails : AROrderDetail?
	var status : String!
    var invoiceLink : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		let paymentInfoJson = json["Payment_info"]
		if !paymentInfoJson.isEmpty{
			paymentInfo = ARPaymentInfo(fromJson: paymentInfoJson)
		}
		let orderDetailsJson = json["order_details"]
		if !orderDetailsJson.isEmpty{
			orderDetails = AROrderDetail(fromJson: orderDetailsJson)
		}
		status = json["status"].stringValue
        invoiceLink = json["invoice_link"].stringValue
	}

}

// MARK: -
class ARPaymentInfo{

    var amount : Float!
    var currency : String!
    var id : String!
    var paymentDate : String!
    var receipt : String!
    var taxAmount : Float!
    var totalAmount : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        amount = json["amount"].floatValue
        currency = json["currency"].stringValue
        id = json["id"].stringValue
        paymentDate = json["payment_date"].stringValue
        receipt = json["receipt"].stringValue
        taxAmount = json["tax_amount"].floatValue
        totalAmount = json["total_amount"].stringValue
    }

}

// MARK: -
class AROrderDetail{

    var amount : String!
    var bonusDays : String!
    var createdOn : String!
    var expiredDate : String!
    var favoriteId : String!
    var orderId : String = ""
    var packType : String!
    var receiptId : String = ""
    var startDate : String!
    var subscriptionStatus : String!
    var userId : String!
    var validityDays : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        amount = json["amount"].stringValue
        bonusDays = json["bonus_days"].stringValue
        createdOn = json["created_on"].stringValue
        expiredDate = json["expired_date"].stringValue
        favoriteId = json["favorite_id"].stringValue
        orderId = json["order_id"].string ?? ""
        packType = json["pack_type"].stringValue
        receiptId = json["receipt_id"].string ?? ""
        startDate = json["start_date"].stringValue
        subscriptionStatus = json["subscription_status"].stringValue
        userId = json["user_id"].stringValue
        validityDays = json["validity_days"].stringValue
    }

}
