//
//  PlayListDetails+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PlayListDetails)
public class PlayListDetails: NSManagedObject {
    class func createPlayListDetailsData(dicData: [String: Any], saveContaxt: Bool = true) -> PlayListDetails? {
        let type = dicData["type"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("PlayListDetails", uniqueKey: "type", value: type) as? PlayListDetails else {
            return nil
        }
        entity.count = Int64(dicData["count"] as? Int ?? 0)
        entity.type = dicData["type"] as? String ?? ""
        
        if let detailsData = dicData["details"] as? [[String: Any]] {
            if type == "Yoga" || type == "Yogasana" {
                var arrData = [Yoga]()
                for details in detailsData {
                    if let entity = Yoga.createYogaData(dicYoga: details) {
                        arrData.append(entity)
                    }
                }
                entity.addToYoga(NSSet(array: arrData))
                
            } else if type == "Kriyas" {
                var arrData = [Kriya]()
                for details in detailsData {
                    if let entity = Kriya.createKriyaData(dicData: details) {
                        arrData.append(entity)
                    }
                }
                entity.addToKriyas(NSSet(array: arrData))
                
            } else if type == "Meditation" {
                var arrData = [Meditation]()
                for details in detailsData {
                    if let entity = Meditation.createMeditationData(dicData: details) {
                        arrData.append(entity)
                    }
                }
                entity.addToMeditation(NSSet(array: arrData))
                
            } else if type == "Pranayama" {
                var arrData = [Pranayama]()
                for details in detailsData {
                    if let entity = Pranayama.createPranayamaData(dicData:details) {
                        arrData.append(entity)
                    }
                }
                entity.addToPranayama(NSSet(array: arrData))
                
            } else if type == "Mudras" {
                var arrData = [Mudra]()
                for details in detailsData {
                    if let entity = Mudra.createMudraData(dicData: details) {
                        //if entity.access_point == 0 || entity.redeemed == true {
                        arrData.append(entity)
                        //}
                    }
                }
                entity.addToMudras(NSSet(array: arrData))
            }
        }
        
        if saveContaxt {
            CoreDataHelper.sharedInstance.saveContext()
        }
        return entity
    }
}
