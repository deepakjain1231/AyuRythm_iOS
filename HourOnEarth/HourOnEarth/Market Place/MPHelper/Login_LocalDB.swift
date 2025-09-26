//
//  MPLoginLocalDB.swift
//
//
//  Created by Maulik Vinodbhai Vora on 24/09/19.
//  Copyright © 2019 Maulik Vora. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class MPLoginLocalDB: NSObject
{
    class func saveLoginInfo(strData: String)
    {
        //--
        UserDefaults.standard.set(strData, forKey: "login_response")
        UserDefaults.standard.synchronize()
    }
    class func getLoginUserModel() -> MPLoginDataModel
    {
        let login_response = UserDefaults.standard.object(forKey: "login_response") as? String ?? ""
        if login_response.count != 0
        {
            return MPLoginDataModel(JSONString: login_response)!
        }
        else
        {
            return MPLoginDataModel()
        }
    }
    
    class func getHeader_GuestUser() -> HTTPHeaders{
        return ["Accept": "application/json"]
    }
    
    class func getHeaderToken(_ forImage: Bool = false) -> HTTPHeaders{
        //return ["Authorization": "Bearer \(MPLoginLocalDB.getLoginUserModel().token)"]
        debugPrint("Header Token====>>>\("Bearer \(Utils.getAuthToken())")")
        if forImage {
            return ["enctype": "multipart/form-data",
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(Utils.getAuthToken())"]
        }
        else {
            return ["Authorization": "Bearer \(Utils.getAuthToken())"]
        }
    }
    
    class func isUserLoggedIn() -> Bool{
        guard !kSharedAppDelegate.userId.isEmpty else {
            return false
        }
        return true
        /*if MPLoginLocalDB.getLoginUserModel().token != nil &&  MPLoginLocalDB.getLoginUserModel().token != ""{
            return true
        }else{
            return false
        }*/
    }
}

class MPLocation: NSObject {
    class func getCurrentLocation() -> (String, String){
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation!
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
        }
        
        return ("\(currentLocation.coordinate.latitude)", "\(currentLocation.coordinate.longitude)")
    }
    
    class func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String, completion: @escaping (String, MPAddressData?)->Void) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if let pm = placemarks{
                if pm.count > 0 {
                    let pm = placemarks![0]
                    let addressdata = MPAddressData()
                    addressdata.pincode = pm.postalCode ?? ""
                    addressdata.state = pm.locality ?? ""
                    addressdata.city = pm.subLocality ?? ""
                    addressdata.address = pm.thoroughfare ?? ""
                    addressdata.landmark = pm.subThoroughfare ?? ""
                    completion("\(pm.postalCode ?? "")", addressdata)
                    
                    /*print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    print(addressString)*/
                }else{
                    completion("", nil)
                }
            }else{
                completion("", nil)
            }
        })
        
    }
    
    class func getCity_From_Lat_Long(pdblatitude: String, withLongitude pdblLongitude: String, completion: @escaping (String)->Void) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblatitude)") ?? 0.0
        //21.228124
        let lon: Double = Double("\(pdblLongitude)") ?? 0.0
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if let pm = placemarks{
                if pm.count > 0 {
                    let pm = placemarks![0]
                    let str_citty = "\(pm.subLocality ?? ""), \(pm.locality ?? ""), \(pm.country ?? "")"
                    completion(str_citty)
                }else{
                    completion("")
                }
            }else{
                completion("")
            }
        })
        
    }
}
