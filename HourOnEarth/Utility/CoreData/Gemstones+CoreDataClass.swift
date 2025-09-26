//
//  Gemstones+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/15/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Gemstones)
public class Gemstones: NSManagedObject {
    class func createGemstonesData(dicData: [String: Any]) {
        let id = dicData["id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Gemstones", uniqueKey: "id", value: id) as? Gemstones else {
            return
        }
        entity.id = Int64(id)  ?? 0
        entity.action = dicData["action"] as? String ?? ""
        entity.gem = dicData["gem"] as? String ?? ""
        entity.gem_hindi = dicData["gem_hindi"] as? String ?? ""
        entity.gem_image = dicData["gem_image"] as? String ?? ""
        entity.kapha = dicData["kapha"] as? String ?? ""
        entity.pitta = dicData["pitta"] as? String ?? ""
        entity.planet = dicData["planet"] as? String ?? ""
        entity.remedies = dicData["remedies"] as? String ?? ""
        entity.status = dicData["status"] as? String ?? ""
        entity.vata = dicData["vata"] as? String ?? ""
        
        CoreDataHelper.sharedInstance.saveContext()
    }
}
