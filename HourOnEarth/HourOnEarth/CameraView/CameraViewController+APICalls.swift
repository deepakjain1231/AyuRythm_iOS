//
//  CameraViewController+APICalls.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/5/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

extension CameraViewController {
    static func uploadMeasumentDataOnServer(graphParams: String, sparshnaResult: String, fromVC: UIViewController) {
        if Utils.isConnectedToNetwork() {
            let dateOfSparshna = Date().dateString(format: "dd-MM-yyyy hh:mm:ss a")
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                //REGISTERED USER
                let userIdOld = (empData["id"] as? String ?? "")
                
                //graphParams
                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : userIdOld]
                
                //fromVC.showActivityIndicator()
                Utils.doAPICall(endPoint: .savesparshnatest, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                    if isSuccess  || status.caseInsensitiveEqualTo("Sucess") {
                        fromVC.hideActivityIndicator()
                        //DebugLog(">> Response : \(responseJSON?.rawString() ?? "-")")
                    } else {
                        fromVC.hideActivityIndicator()
                        //fromVC.hideActivityIndicator(withTitle: APP_NAME, Message: message)
                    }
                }
            } else {
                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : ""]
                kUserDefaults.set(params, forKey: kUserMeasurementData)
            }
            kUserDefaults.set(sparshnaResult, forKey: LAST_ASSESSMENT_DATA)
        }
    }
    
    static func postSparshnaData(value: String, sparshnaResult: String, sparshnaValue: String, graphParams: String, fromVC: UIViewController) {
        guard kUserDefaults.object(forKey: USER_DATA) as? [String: Any] != nil else {
            let newValues = Utils.parseValidValue(string: value)
            kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
            kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
            handleBackNavigationForSparshna(fromVC: fromVC)
            return
        }
        
        if Utils.isConnectedToNetwork() {
            //fromVC.showActivityIndicator()
            var params = ["user_vikriti": value, "vikriti_sprashna": "true", "sparshna": sparshnaResult, "vikriti_sprashnavalue": sparshnaValue/*, "suryathon_count": kUserDefaults.suryaNamaskarCount*/, "graph_params": graphParams] as [String : Any]
            params.addVikritiResultFinalValue()
            
            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
                    
                    let newValues = Utils.parseValidValue(string: value)
                    kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
                    kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
                    kUserDefaults.suryaNamaskarCount = 0 //reset count
                    fromVC.hideActivityIndicator()
                    
                    handleBackNavigationForSparshna(fromVC: fromVC)
                } else {
                    var finalMessage = message
                    if finalMessage.isEmpty {
                        finalMessage = responseJSON?["error"].stringValue ?? ""
                    }
                    fromVC.hideActivityIndicator()
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: fromVC) {
                        fromVC.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            handleBackNavigationForSparshna(fromVC: fromVC)
            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    static func handleBackNavigationForSparshna(fromVC: UIViewController) {

#if !APPCLIP
        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
            let vc = PrakritiResult1VC.instantiate(fromAppStoryboard: .Questionnaire)
            vc.hidesBottomBarWhenPushed = true
            vc.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
            fromVC.hidesBottomBarWhenPushed = true
            fromVC.navigationController?.pushViewController(vc, animated: true)
            return
        }
#else
#endif

        let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "LastAssessmentVC") as! LastAssessmentVC
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        //objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
        #else
        // Code your app clip may access.
        //objDescription.isRegisteredUser = false
        #endif
        objDescription.isFromCameraView = true
        fromVC.navigationController?.pushViewController(objDescription, animated: true)

    }
}


//MARK: - API Call
extension CameraViewController {
    
    static func callAPIforUpdateGraphaperAPI_forSparshna(vikrati_value: String, sparshnaResult: String, graphParams: String, fromVC: UIViewController, completion: @escaping (_ success: Bool)->Void) {
        guard kUserDefaults.object(forKey: USER_DATA) as? [String: Any] != nil else {
            let newValues = Utils.parseValidValue(string: vikrati_value)
            kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
            kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
            handleBackNavigationForSparshna(fromVC: fromVC)
            return
        }
        
        if Utils.isConnectedToNetwork() {

            var params = ["user_ffs": "",
                          "user_ppf": "",
                          "sparshna": sparshnaResult,
                          "graph_params": graphParams,
                          "type_of_assessment": "sparshna"]

            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
                    completion(true)
                } else {
                    var finalMessage = message
                    if finalMessage.isEmpty {
                        finalMessage = responseJSON?["error"].stringValue ?? ""
                    }
                    fromVC.hideActivityIndicator()
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: fromVC) {
                        fromVC.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            handleBackNavigationForSparshna(fromVC: fromVC)
        }
    }
    
    static func postSparshan_Assessment_Data(vikriti_value: String, fromVC: UIViewController) {
        
        if Utils.isConnectedToNetwork() {
            //fromVC.showActivityIndicator()
            var params = ["user_vikriti": vikriti_value,
                          "vikriti_sprashna": "true"] as [String : Any]
            
#if !APPCLIP
            params["aggravation"] = appDelegate.cloud_vikriti_status
#endif
            
            //params.addVikritiResultFinalValue()
            
            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
                    
                    let newValues = Utils.parseValidValue(string: vikriti_value)
                    kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
                    kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
                    kUserDefaults.suryaNamaskarCount = 0 //reset count
                    fromVC.hideActivityIndicator()
                    
                    handleBackNavigationForSparshna(fromVC: fromVC)
                } else {
                    var finalMessage = message
                    if finalMessage.isEmpty {
                        finalMessage = responseJSON?["error"].stringValue ?? ""
                    }
                    fromVC.hideActivityIndicator()
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: fromVC) {
                        fromVC.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            handleBackNavigationForSparshna(fromVC: fromVC)
        }
    }
}
