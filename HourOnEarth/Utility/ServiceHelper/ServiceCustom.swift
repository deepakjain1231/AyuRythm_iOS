//
//  ServiceCustom.swift
//  SwiftTutorialDemo
//
//  Created by iMac-4 on 7/4/17.
//  Copyright © 2017 iMac-4. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum RequestMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}


class ServiceCustom: NSObject  {
    
    class var shared : ServiceCustom {
        struct Static {
            static let instance : ServiceCustom = ServiceCustom()
        }
        return Static.instance
    }
    
    
    //MARK: - API CALL
    func requestURL(_ URLString: URLConvertible, Method:RequestMethod, parameters: [String: Any]?, progress: Bool, current_view: UIViewController, completion: @escaping (([String:Any]?, Bool, Error?) -> Void)) {
        
        if Connectivity.isConnectedToInternet {
            debugPrint("URL ===> \(URLString)")
            debugPrint("parameters ===> ",parameters as NSDictionary? ?? "No Parameter")
            let reqMethod = HTTPMethod(rawValue: Method.rawValue)
            
            if progress {
                Utils.startActivityIndicatorInView(current_view.view, userInteraction: false)
            }
            
            AF.request(URLString, method: reqMethod, parameters: parameters, encoding:URLEncoding.default).responseJSON  { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        debugPrint("responseString:-", dicResponse)
                        completion(dicResponse, true, nil)
                    }
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: current_view)
                }

                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(current_view.view)
                })
            }
            
        }
        else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: current_view)
            return
        }
        
    }
    
    
    //MARK:- Multi part request with parameters.
    func requestMultiPartWithUrlAndParameters(_ URLString: URLConvertible, Method:String, headerssss: HTTPHeaders, parameters: [String: Any], fileParameterName: String, arr_ImgMedia : [UIImage], mimeType : String,completion: @escaping ((URLRequest?, HTTPURLResponse?, _ JSON:NSDictionary?, _ Data: Data?) -> Void), failure:@escaping ((Error) -> Void)) {
        
        if Connectivity.isConnectedToInternet {
            AF.upload(multipartFormData: { (multipartFormData) in
                
                var int_Indx = 0
                for img in arr_ImgMedia {
                    let imggggName = "\(fileParameterName)\(int_Indx + 1)"
                    let productImgName = "product_reviewImage\(int_Indx + 1).png"
                    if let imageData = img.jpegData(compressionQuality: 0.50) {
                        multipartFormData.append(imageData, withName: imggggName, fileName: productImgName, mimeType: mimeType)
                    }
                    int_Indx = int_Indx + 1
                }

                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }, to: URLString, headers: headerssss).response { (responseeee) in
                debugPrint(responseeee)
                completion(responseeee.request, responseeee.response, nil, responseeee.data)
            }
        }
        else {
//            appDelegate.window?.rootViewController?.view.makeToast("Please check your internet connection")
            return
        }
    }
    
    
    
    //MARK:- Multipart Request
//    func POSTMultipartRequest(url:String, parameter:[String : Any]?, img_data : Data?, with_Name: String, file_name: String, mime_type: String, header:[String : String]?,success:@escaping (Dictionary<String, AnyObject>) -> Void, failed:@escaping (String?) -> Void) {
//
//        if Connectivity.isConnectedToInternet {
//
//
//            AF.upload(multipartFormData:{ multipartFormData in
//
//                if img_data != nil {
//                    multipartFormData.append(img_data!, withName: with_Name, fileName: file_name, mimeType: mime_type)
//                }
//                if parameter != nil {
//                    for (key, value) in parameter! {
//                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
//                    }
//                }
//            },
//                             usingThreshold:UInt64.init(),
//                             to:url,
//                             method:.post,
//                             encodingCompletion: { encodingResult in
//                                switch encodingResult
//                                {
//
//                                case .success(let upload, _, _):
//                                    upload.responseJSON { response in
//
//                                        upload.responseJSON { response in
//                                            print("Response: \(response.result.value as AnyObject?)")
//
////                                            let dict = JSON(response.result.value ?? "").dictionaryValue
//                                            if response.result.value != nil
//                                            {
//                                                //print(response.result.value!)
//
//                                                if let json = response.result.value
//                                                {
//                                                    let dictemp = json as! NSDictionary
//                                                    success(dictemp as! Dictionary<String, AnyObject>)
//
//                                                }
//                                                else
//                                                {
//                                                    failed("somethingwrong")
//                                                }
//                                            }
//                                            else
//                                            {
//                                                failed("\(response.result.error?.localizedDescription ?? "")")
//                                            }
//                                        }
//                                    }
//                                    break
//                                case .failure( _):
//                                    //print(encodingError)
//                                    failed("The network connection was lost please try again.")
//                                    break
//                                }
//            })
//
//        } else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: "Please check your network connectivity".localized(), controller: (kSharedAppDelegate.sharedInstance().window?.rootViewController)!)
//        }
//    }
    
    func getHeaders() -> (HTTPHeaders) {
        return ["Accept": "application/json"]
    }
    
    func getHeaders_withoutToken() -> (HTTPHeaders) {
        return ["Accept": "application/json"]
    }
    
    func getHTTPMethod(strMethod:String) -> HTTPMethod {
        switch strMethod {
        case "OPTIONS":
            return HTTPMethod.options
        case "GET":
            return HTTPMethod.get
        case "HEAD":
            return HTTPMethod.head
        case "POST":
            return HTTPMethod.post
        case "PUT":
            return HTTPMethod.put
        case "PATCH":
            return HTTPMethod.patch
        case "DELETE":
            return HTTPMethod.delete
        case "TRACE":
            return HTTPMethod.trace
        case "CONNECT":
            return HTTPMethod.connect
        default:
            return HTTPMethod.post
        }
    }
    
}




class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

