//
//  TrainerPackage+CoreDataClass.swift
//  
//
//  Created by Ayu on 20/08/20.
//
//

import Foundation
import CoreData

@objc(TrainerPackage)
public class TrainerPackage: NSManagedObject {

    class func createTrainerPackageData(dicData: [String: Any]) -> TrainerPackage? {
        let id = dicData["id"] as? String ?? "0"
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("TrainerPackage", uniqueKey: "name", value: id) as? TrainerPackage else {
            return nil
        }
        entity.name = dicData["name"] as? String ?? ""
        entity.available_week_days = dicData["available_week_days"] as? String ?? ""
        entity.descriptions = dicData["description"] as? String ?? ""
        entity.price_per_session = dicData["price_per_session"] as? String ?? ""
        entity.price_per_session_usd = dicData["price_per_session_usd"] as? String ?? ""
        
        entity.dis_per_session_price = dicData["dis_per_session_price"] as? String ?? ""
        entity.dis_per_session_price_usd = dicData["dis_per_session_price_usd"] as? String ?? ""
        
        entity.discount_per = dicData["discount_per"] as? Float ?? 0
        entity.discount_per_usd = dicData["discount_per_usd"] as? Float ?? 0
        entity.seed_discount_price = dicData["seed_discount_price"] as? Float ?? 0
        
        let discount_price_usd = dicData["seed_discount_price_usd"] as? Float
        if discount_price_usd == nil {
            entity.seed_discount_price_usd = Float(dicData["seed_discount_price_usd"] as? Double ?? 0.0)
        }
        else {
            entity.seed_discount_price_usd = dicData["seed_discount_price_usd"] as? Float ?? 0
        }
        
        
        
        entity.seeds_used = Int32(dicData["seeds_used"] as? Int ?? 0)
        entity.seeds_used_usd = Int32(dicData["seeds_used_usd"] as? Int ?? 0)
        
        entity.session_type = dicData["session_type"] as? String ?? ""
        entity.time_per_session = dicData["time_per_session"] as? String ?? ""
        entity.total_cost = dicData["total_cost"] as? String ?? ""
        entity.total_cost_usd = dicData["total_cost_usd"] as? String ?? ""
        
        let favorite_id = dicData["favorite_id"] as? String ?? ""
        entity.favorite_id = Int32(favorite_id) ?? 0
        
        let max_session_week = dicData["max_session_week"] as? String ?? ""
        entity.max_session_week = Int16(max_session_week) ?? 0
        
        let max_week = dicData["max_week"] as? String ?? ""
        entity.max_week = Int16(max_week) ?? 0
        
        let total_session = dicData["total_session"] as? String ?? ""
        entity.total_session = Int16(total_session) ?? 0

        if let detailsData = dicData["time_slot"] as? [[String: Any]] {
            var arrData = [PackageTimeSlot]()
            for details in detailsData {
                if let entity = PackageTimeSlot.createPackageTimeSlotData(dicData: details) {
                    arrData.append(entity)
                }
            }
            entity.addToTimeslot(NSSet(array: arrData))
        }
        
        
        CoreDataHelper.sharedInstance.saveContext()
        return entity
    }
    
}

extension TrainerPackage {
    var final_price_per_session: String {
        let pricePerSession = Locale.current.isCurrencyCodeInINR ? price_per_session : price_per_session_usd
        return pricePerSession ?? "0"
    }
    
    var final_dis_price_per_session: String {
        let pricePerSession = Locale.current.isCurrencyCodeInINR ? dis_per_session_price : dis_per_session_price_usd
        if let pricePerSession = pricePerSession, !pricePerSession.isEmpty, let pricePerSessionIntValue = Float(pricePerSession), pricePerSessionIntValue != 0, final_discount_per_session > 0 {
            return pricePerSession
        } else {
            return final_price_per_session
        }
    }
    
    var final_discount_per_session: Float {
        let discount_per_session = Locale.current.isCurrencyCodeInINR ? discount_per : discount_per_usd
        return discount_per_session
    }
    
    var final_seeds_used: Int {
        let seed_used = Locale.current.isCurrencyCodeInINR ? seeds_used : seeds_used_usd
        return Int(seed_used)
    }
    
    var final_seed_discount_price: Float {
        let f_seed_discount_price = Locale.current.isCurrencyCodeInINR ? seed_discount_price : seed_discount_price_usd
        return f_seed_discount_price
    }
    
    var final_total_cost: String {
        let totalCost = Locale.current.isCurrencyCodeInINR ? total_cost : total_cost_usd
        return totalCost ?? "0"
    }
    
    var total_session_string: String {
        return "\(total_session) " + (total_session > 1 ? "sessions".localized() : "session".localized())
    }
}
