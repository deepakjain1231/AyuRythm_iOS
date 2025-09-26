//
//  seasons+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

@objc(Seasons)
public class Seasons: NSManagedObject {
    class func createSeasonsData(dicData: [String: Any])  -> Seasons? {
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Seasons", uniqueKey: nil, value: nil) as? Seasons else {
            return nil
        }
        entity.id = Int(id) ?? 0
        entity.season_name = dicData["season_name"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        return entity
    }
}
