////
////  MoEngageHelper.swift
////  HourOnEarth
////
////  Created by Suraj Singh on 28/06/22.
////  Copyright © 2022 AyuRythm. All rights reserved.
////
//
//import Foundation
////import MoEngage
//import SwiftyJSON
//
//class MoEngageHelper {
//    
//    let appID = "CPAI6C10JJ67QXXEI25OHO7S"
//    static let shared = MoEngageHelper()
//    
//    func setup(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        //Add your MoEngage App ID
//        var sdkConfig = MOSDKConfig(appID: appID)
//         //Separate initialization methods for Dev and Prod initializations
//        #if DEBUG
//        MoEngage.sharedInstance().initializeTest(with: sdkConfig, andLaunchOptions: launchOptions)
//        //MoEngage.sharedInstance().initializeDefaultTestInstance(with: sdkConfig, andLaunchOptions: launchOptions)
//        #else
//        MoEngage.sharedInstance().initializeLive(with: sdkConfig, andLaunchOptions: launchOptions)
//        //MoEngage.sharedInstance().initializeDefaultLiveInstance(with: sdkConfig, andLaunchOptions: launchOptions)
//        #endif
//    }
//    
//    func setDefaultAttributes(from userData: [String: Any]) {
//        let userJson = JSON(userData)
//        let moe = MoEngage.sharedInstance()
//        let fullName = userJson["name"].stringValue
//       
//        let gender: UserGender = userJson["gender"].stringValue == "Female" ? FEMALE : MALE
//        //let dob = Utils.getDateFromString(userJson["dob"].stringValue, format: "dd-MM-yyyy")
//        let dob = Utils.getDateFromString(userJson["dob"].stringValue, format: "dd-MM-yyyy")
//        moe.setUserUniqueID(userJson["id"].stringValue)
//        //moe.setUniqueID(userJson["id"].stringValue)
//        moe.setUserName(fullName)
//        //moe.setName(fullName)
//
//        var userNameComponents = fullName.spaceSeperatedValues
//        let firstName = userNameComponents.removeFirst()
//        let lastName = userNameComponents.joined(separator: " ")
//        moe.setUserFirstName(firstName)
//        moe.setUserLastName(lastName)
//        //moe.setFirstName(firstName)
//        //moe.setLastName(lastName)
//        moe.setUserEmailID(userJson["email"].stringValue)
//        //moe.setEmailID(userJson["email"].stringValue)
//        moe.setUserMobileNo(userJson["mobile"].stringValue)
//        //moe.setMobileNo(userJson["mobile"].stringValue)
//       // moe.setGender(gender) //Use UserGender enumerator for this
//        moe.setUserGender(gender)
//        moe.setUserDateOfBirth(dob)
//        //moe.setDateOfBirth(dob) //userBirthdate should be a Date instance
//        //moe.setLocation(MOGeoLocation(withLatitude: userLocationLat, andLongitude: userLocationLng)) //userLocationLat and userLocationLng are double values of the location coordinates
//        
//    }
//}
//
//extension MoEngageHelper {
//    
//    func flush() {
//        //Manual Sync : For syncing the tracked events instantaneously
//        MoEngage.sharedInstance().flush()
//    }
//    
//    func resetUser() {
//        MoEngage.sharedInstance().resetUser()
//    }
//    
//    func updateAppStatusInstall() {
//        //For Fresh Install of App
//        MoEngage.sharedInstance().appStatus(INSTALL)
//        //MoEngage.sharedInstance().appStatus(.install)
//    }
//    
//    func updateAppStatusUpdate() {
//        // For Existing user who has updated the app
//        MoEngage.sharedInstance().appStatus(UPDATE)
//       // MoEngage.sharedInstance().appStatus(.update)
//    }
//    
//   func trackEvent(name: String, properties: MOProperties? = nil) {
//       MoEngage.sharedInstance().trackEvent(name, with: properties)
//   }
////    
////    func trackEventDemo() {
////        var eventAttrDict : Dictionary<String,Any> = Dictionary()
////        eventAttrDict["ProductName"] = "iPhone XS Max"
////        eventAttrDict["BrandName"] = "Apple"
////        eventAttrDict["Items In Stock"] = 109
////
////        let eventProperties = MOProperties(withAttributes: eventAttrDict)
////
////        eventProperties.addAttribute(87000.00, withName: "price")
////        eventProperties.addAttribute("Rupees", withName: "currency")
////        eventProperties.addAttribute(true, withName: "in_stock")
////        eventProperties.addDateEpochAttribute(1439322197, withName: "Time added to cart")
////        eventProperties.addDateISOStringAttribute("2020-02-22T12:37:56Z", withName: "Time of checkout")
////        eventProperties.addDateAttribute(Date(), withName: "Time of purchase")
////
////        eventProperties.addLocationAttribute(MOGeoLocation.init(withLatitude: 12.23, andLongitude: 9.23), withName: "Pickup Location")
////        MoEngage.sharedInstance().trackEvent("Successful Purchase", with: eventProperties)
////    }
//}
////}
