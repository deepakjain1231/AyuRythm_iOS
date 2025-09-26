//
//  PlayList+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PlayList)
public class PlayList: NSManagedObject {
    class func createPlayListData(dicData: [String: Any]) {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let playlistId = dicData["favorite_id"] as? String ?? "0"
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("PlayList", uniqueKey: "id", value: playlistId) as? PlayList else {
            return
        }
        entity.name = dicData["name"] as? String ?? ""
        entity.id = Int64(playlistId) ?? 0
        entity.ayurid = Int64(dicData["ayurid"] as? String ?? "0") ?? 0
        entity.image = dicData["image"] as? String ?? ""
        entity.detail_image = dicData["detail_image"] as? String ?? ""
        entity.type = dicData["type"] as? String ?? ""
        entity.count = Int16(dicData["count"] as? Int ?? 0)
        entity.favorite_id = dicData["favorite_id"] as? String ?? ""
        //Temp Fix Paresh : replace "item" with "favourite_type", "item" hindi text create problem in hindi language
        entity.item = dicData["favourite_type"] as? String ?? ""
        let accessPoints = dicData["access_point"] as? String ?? ""
        entity.access_point = Int16(accessPoints) ?? 0
        entity.redeemed = dicData["redeemed"] as? Bool ?? false
        CoreDataHelper.sharedInstance.saveContext()
    }
}
