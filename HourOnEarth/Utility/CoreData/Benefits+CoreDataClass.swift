//
//  Benefits+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 05/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Benefits)
public class Benefits: NSManagedObject {
    class func createBenefits(dic: [String: Any]) -> Benefits? {
        let benefitsname = dic["benefitsname"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Benefits", uniqueKey: "benefitsname", value: benefitsname) as? Benefits else {
            return nil
        }
        entity.benefitsimage = dic["benefitsimage"] as? String ?? ""
        entity.benefitsname = benefitsname
        return entity
    }
}
