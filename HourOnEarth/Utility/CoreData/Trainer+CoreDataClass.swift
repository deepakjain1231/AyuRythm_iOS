//
//  Trainer+CoreDataClass.swift
//  
//
//  Created by Ayu on 15/08/20.
//
//

import Foundation
import CoreData

@objc(Trainer)
public class Trainer: NSManagedObject {
    
    class func createTrainerData(dicData: [String: Any]) -> Trainer? {
        let id = dicData["id"] as? String ?? "0"
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Trainer", uniqueKey: "id", value: id) as? Trainer else {
            return nil
        }
        entity.name = dicData["name"] as? String ?? ""
        entity.about = dicData["about"] as? String ?? ""
        entity.id = Int64(id) ?? 0
        entity.image = dicData["image"] as? String ?? ""
        entity.type = dicData["type"] as? String ?? "trainer"
        
        let accessPoints = dicData["access_point"] as? String ?? ""
        entity.access_point = Int16(accessPoints) ?? 0
        entity.redeemed = dicData["redeemed"] as? Bool ?? false
        
        
        if let detailsData = dicData["packages"] as? [[String: Any]] {
            var arrData = [TrainerPackage]()
            for details in detailsData {
                if let entity = TrainerPackage.createTrainerPackageData(dicData: details) {
                    arrData.append(entity)
                }
            }
            entity.addToPackage(NSSet(array: arrData))
        }
        
        CoreDataHelper.sharedInstance.saveContext()
        return entity
    }

}
