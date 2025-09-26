//
//  MyProgress+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/15/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MyProgress)
public class MyProgress: NSManagedObject {
    class func createMyProgressData(dicData: [String: Any]) {
        let id = dicData["id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("MyProgress", uniqueKey: "id", value: id) as? MyProgress else {
            return
        }
        entity.id = Int64(id)  ?? 0
        entity.date = dicData["date"] as? String ?? ""
        entity.duid = dicData["duid"] as? String ?? ""
        entity.percentage = dicData["percentage"] as? String ?? ""
        entity.result = dicData["result"] as? String ?? ""
        CoreDataHelper.sharedInstance.saveContext()
    }
}
