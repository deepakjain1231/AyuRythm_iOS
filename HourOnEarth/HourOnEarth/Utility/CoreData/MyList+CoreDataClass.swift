//
//  MyList+CoreDataClass.swift
//  
//
//  Created by Ayu on 28/07/20.
//
//

import Foundation
import CoreData

@objc(MyList)
public class MyList: NSManagedObject {
    
    class func createMyList(list: [String: Any]) -> MyList? {
        let id = list["id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("MyList", uniqueKey: "id", value: id) as? MyList else {
            return nil
        }
        
        entity.id = Int32(id)  ?? 0
        entity.list_name = list["list_name"] as? String ?? ""
        entity.userid = list["userid"] as? String ?? ""
        entity.image = list["image"] as? String ?? ""
        
        CoreDataHelper.sharedInstance.saveContext()
        return entity
    }

    class func createMyListDetails(listDetails: [String: Any]) -> MyList? {
        let id = listDetails["id"] as? String ?? ""
        let type = listDetails["favourite_type"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("MyList", uniqueKey: "id", value: id) as? MyList else {
            return nil
        }
        
        entity.id = Int32(id)  ?? 0
//        entity.listid = listDetails["listid"] as? String ?? ""
//        entity.favourite_id = listDetails["favourite_id"] as? String ?? ""
//        entity.favourite_type = listDetails["favourite_type"] as? String ?? ""
        
        if let detailsData = listDetails["details"] as? [[String: Any]] {
            if type == "Yoga" {
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
                        arrData.append(entity)
                    }
                }
                entity.addToMudras(NSSet(array: arrData))
            }
        }
        
        CoreDataHelper.sharedInstance.saveContext()
        return entity
    }
    
}
