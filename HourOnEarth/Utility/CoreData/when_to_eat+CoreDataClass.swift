//
//  when_to_eat+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

@objc(When_to_eat)
public class When_to_eat: NSManagedObject {
    class func createWhen_to_eatData(dicData: [String: Any])  -> When_to_eat? {
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("When_to_eat", uniqueKey: nil, value: nil) as? When_to_eat else {
            return nil
        }
        entity.id = Int(id) ?? 0
        entity.besttime = dicData["besttime"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        return entity
    }
}
