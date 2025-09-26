//
//  Favourite+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 14/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Favourite)
public class Favourite: NSManagedObject {
    class func createFavouriteData(arrData: [[String: Any]]) {
        for dicData in arrData {
            guard let desc_id = dicData["favourite_type"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("Favourite", uniqueKey: "favourite_type", value: desc_id) as? Favourite else {
                return
            }
            
            print("favourite_type=",dicData["favourite_type"]!)
            print("count=",dicData["count"]!)
            entity.favourite_type = dicData["favourite_type"] as? String ?? ""
            entity.count = Int64(dicData["count"] as? Int64 ?? 0)
            
            if entity.favourite_type == "Yoga" {
                let yogas = dicData["details"] as? [[String: Any]] ?? []
                var arrYoga = [FavouriteYoga]()
                for yoga in yogas {
                    if let entityYoga =  FavouriteYoga.createYogaData(dicYoga: yoga) {
                        arrYoga.append(entityYoga)
                    }
                }
                entity.addToFavYoga( NSSet(array: arrYoga))
            }
            else if  entity.favourite_type == "Meditation" {
                let meditations = dicData["details"] as? [[String: Any]] ?? []
                var arrMeditation = [FavouriteMeditation]()
                for meditation in meditations {
                    if let entityMeditation =  FavouriteMeditation.createMeditationData(dicData: meditation) {
                        arrMeditation.append(entityMeditation)
                    }
                }
                entity.addToFavMeditation( NSSet(array: arrMeditation))
            }
            else if  entity.favourite_type == "Pranayama" {
                let pranayamas = dicData["details"] as? [[String: Any]] ?? []
                var arrpranayama = [FavouritePranayama]()
                for pranayama in pranayamas {
                    if let entityPranayama =  FavouritePranayama.createPranayamaData(dicData: pranayama) {
                        arrpranayama.append(entityPranayama)
                    }
                }
                entity.addToFavPranayama( NSSet(array: arrpranayama))
            }
            else if  entity.favourite_type == "Mudras" {
                let mudras = dicData["details"] as? [[String: Any]] ?? []
                var arrMudra = [FavouriteMudra]()
                for mudra in mudras {
                    if let entityMudra =  FavouriteMudra.createMudraData(dicData: mudra) {
                        arrMudra.append(entityMudra)
                    }
                }
                entity.addToFavMudra( NSSet(array: arrMudra))
            }
            else if  entity.favourite_type == "Kriyas" {
                let kriyas = dicData["details"] as? [[String: Any]] ?? []
                var arrKriya = [FavouriteKriya]()
                for kriya in kriyas {
                    if let entityKriya =  FavouriteKriya.createKriyaData(dicData: kriya) {
                        arrKriya.append(entityKriya)
                    }
                }
                entity.addToFavKriya( NSSet(array: arrKriya))
            }
            else if  entity.favourite_type == "Food" {
                let Food = dicData["details"] as? [[String: Any]] ?? []
                var arrFood = [FavouriteFood]()
                for food in Food {
                    if let entityFood =  FavouriteFood.createFoodData(dicData: food) {
                        arrFood.append(entityFood)
                    }
                }
                entity.addToFavFood( NSSet(array: arrFood))
            }
            else if  entity.favourite_type == "Herbs" {
                let Food = dicData["details"] as? [[String: Any]] ?? []
                var arrFood = [FavouriteHerb]()
                for food in Food {
                    if let entityFood =  FavouriteHerb.createHerbData(dicData: food) {
                        arrFood.append(entityFood)
                    }
                }
                entity.addToFavHerb( NSSet(array: arrFood))
            }
            else {
                let remedies = dicData["details"] as? [[String: Any]] ?? []
                var arrRemedy = [FavouriteHomeRemedies]()
                for remedy in remedies {
                    if let entity =  FavouriteHomeRemedies.createHomeRemediesData(dicData: remedy) {
                        arrRemedy.append(entity)
                    }
                }
                entity.addToFavRemedies(NSSet(array: arrRemedy))
            }
        }
        CoreDataHelper.sharedInstance.saveContext()
    }
}
