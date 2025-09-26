//
//  Constants.swift
//  AlertEm
//
//  Created by Pradeep on 4/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import SystemConfiguration

class Utils {
    
    /**
     Function call to show the alert in the given viewcontroller
     
     - parameter title:      title of the alert
     - parameter message:    message of the alert
     - parameter controller: controller on which to show
     */
    
    class func showAlertWithTitleInController(_ title:String , message:String,controller:UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertAction.Style.default, handler: nil))
        
        if kSharedAppDelegate.window?.rootViewController?.presentedViewController != nil {
            //Present the alert view on the current presented view controller
            kSharedAppDelegate.window?.rootViewController?.presentedViewController?.present(alertController, animated: true, completion: nil)

        }else {
            controller.present(alertController, animated: true, completion: nil)
        }
        
    }

    /**
     This method is used to check network connectivity
     
     - returns: true if connected to internet
     */
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    /**
     This function is used to display the Activity Indicator in the given view.
     
     - parameter view: The view on which Activity Indicator is to be added
     */
    class func startActivityIndicatorInView(_ view: UIView,userInteraction:Bool,isGray:Bool = false) {
        ProgressView.sharedInstance?.startViewWithUserInteractionInView(view, userInteraction: userInteraction,isGray: isGray)
    }
    
    /**
     This function is used to stop the Activity Indicator in the given view
     
     - parameter view: The view from which Activity Indicator is to stop
     */
    class func stopActivityIndicatorinView(_ view : UIView){
        
        ProgressView.sharedInstance?.stopView()
    }
    
    /**
     This function is used to get the screen bounds keeping the orientation fixed in portrait mode
     
     - returns: returns screen bounds
     */
    class func screenBoundsFixedToPortraitOrientation()->CGRect {
        let screen = UIScreen.main;
        
        if screen.responds(to: #selector(getter: UIScreen.fixedCoordinateSpace)) {
            return screen.coordinateSpace.convert(screen.bounds, to: screen.fixedCoordinateSpace)
        }
        return screen.bounds
    }
    
    class func showAlertWithTitleInControllerWithCompletion(_ title: String?, message: String,cancelTitle: String, okTitle:String ,controller: UIViewController, completionHandler: @escaping () -> Void, completionHandlerCancel: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { (_) in
            completionHandlerCancel()
        }))
        alertController.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (_) in
            completionHandler()
        }))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func showAlertWithTitleInControllerWithCompletion(_ title: String?, message: String, okTitle:String ,controller: UIViewController, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (_) in
            completionHandler()
        }))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func setUpAppAppearance() {
        if #available(iOS 13.0, *) {
            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.configureWithOpaqueBackground()
            coloredAppearance.backgroundColor = UIColor.white
            coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            UINavigationBar.appearance().standardAppearance = coloredAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
            UINavigationBar.appearance().tintColor = UIColor.systemBlue
        } else {
            // Fallback on earlier versions
            UINavigationBar.appearance().tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            UINavigationBar.appearance().backgroundColor = UIColor.white
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        }
    }
    
    class func getVikritiValue() -> String {
        
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_PRASHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_DARSHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_SPARSHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        let total = kaphaCount + pittaCount + vataCount
        
        let percentKapha = kaphaCount*100.0/total
        let percentPitta = pittaCount*100.0/total
        let percentVata = vataCount*100.0/total
        
        if total == 0 {
            return ""
        }
        
        return "\"\(percentKapha.roundToOnePlace)\",\"\(percentPitta.roundToOnePlace)\",\"\(percentVata.roundToOnePlace)\""
    }
    
    
    class func getVikritiValue_Double() -> [Double] {
        
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_PRASHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_DARSHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_SPARSHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        let total = kaphaCount + pittaCount + vataCount
        
        let percentKapha = kaphaCount*100.0/total
        let percentPitta = pittaCount*100.0/total
        let percentVata = vataCount*100.0/total
        
        var arr_Data = [0.0, 0.0, 0.0]
        if total == 0 {
            return arr_Data
        }
        
        arr_Data = [percentKapha.roundToOnePlace, percentPitta.roundToOnePlace, percentVata.roundToOnePlace]
        
        return arr_Data
    }
    
    class func getPrakritiValue() -> String {
        
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }
        
        let total = kaphaCount + pittaCount + vataCount
        
        let percentKapha = kaphaCount*100.0/total
        let percentPitta = pittaCount*100.0/total
        let percentVata = vataCount*100.0/total
        
        if total == 0 {
            return ""
        }
        
        return "\"\(percentKapha.roundToOnePlace)\",\"\(percentPitta.roundToOnePlace)\",\"\(percentVata.roundToOnePlace)\""
    }
    
    class func parseValidValue(string: String) -> String {
        let seprated = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "\"", with: "")
        return seprated
    }
   
    class func convertKgToPounds(kg: String) -> String {
        let lb = (Double(kg) ?? 0.0) *  2.20462
        return "\(lb.rounded(.up))"
    }
    
    class func convertPoundsToKg(lb: String) -> String {
        let kg = (Double(lb) ?? 0.0) *  0.45359237
        let kgs = "\(kg)".components(separatedBy: ".")
        return "\(kgs[0])"
    }
    
    class func convertHeightInCms(ft: String, inc: String) -> Double {
        let inches = ((Double(inc) ?? 0) * 2.54)
        return ((Double(ft) ?? 0) * 30.48) + inches
    }
    
    class func convertHeightInFtIn(cms: Double) -> (Int, Int) {
        let feet = cms*0.0328084
        let feetShow = Int(floor(feet)) // 1234
        let feetRest = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100) // 0.56789
        let inches = Int(floor(feetRest * 12))
        return (Int(feetShow), Int(inches))
    }
    
    //Differential
    class func getRecommendationType() -> String {
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return "kapha"
        }
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                // new - original / original *100
                let percentIncreaseK = (kapha - kaphaP) //*100/kaphaP
                let percentIncreaseP = (pitta - pittaP) //*100/pittaP
                let percentIncreaseV = (vata - vataP) //*100/vataP
                
                var arrIncreasedValues = [String]()
                
                if percentIncreaseV > 5 {
                    arrIncreasedValues.append("vata")
                }
                
                if percentIncreaseP > 5 {
                    arrIncreasedValues.append("pitta")
                }
                
                if percentIncreaseK > 5 {
                    arrIncreasedValues.append("kapha")
                }
                
                if arrIncreasedValues.count > 0 {
                    if arrIncreasedValues.first == "vata" {
                        return "vata"
                    } else if arrIncreasedValues.first == "pitta" {
                        return "pitta"
                    } else {
                        return "kapha"
                    }
                } else {
                    if vataP >= kaphaP && vataP >= pittaP {
                        return "vata"
                    }else  if pittaP >= vataP && pittaP >= kaphaP {
                        return "pitta"
                    } else {
                        return "kapha"
                    }
                }
            }
        }
        return "kapha"
    }
    
    class func getRecommendationTypePercentage() -> (kapha:Double, pitta: Double, vata: Double) {
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_PRASHNA) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return (0,0,0)
        }
        
        if let strPrashna = kUserDefaults.value(forKey: VIKRITI_SPARSHNA) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                kaphaP += Double(arrPrashnaScore[0]) ?? 0
                pittaP += Double(arrPrashnaScore[1]) ?? 0
                vataP += Double(arrPrashnaScore[2]) ?? 0
                
                let total = kaphaP + pittaP + vataP
                
                let percentKapha = round(kaphaP*100.0/total)
                let percentPitta =  round(pittaP*100.0/total)
                let percentVata =  round(vataP*100.0/total)
        
                return (percentKapha, percentPitta, percentVata)
            }
        }
        return (0,0,0)
    }
    
    //PRAKRITI - FOR YOU
    class func getPrakritiIncreaseValue() -> RecommendationType {
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
                
                if vataP > kaphaP && vataP > pittaP {
                    return .vata
                } else  if pittaP > kaphaP && pittaP > vataP {
                    return .pitta
                } else {
                    return .kapha
                }
            }
        }
        return .kapha
    }
    
    class func getIncreasedValues() -> [KPVType] {
        var increasedValues = [KPVType]()
        
        func setStatus(prakriti: Double, vikriti: Double, kpvType: KPVType) {
            if abs(vikriti - prakriti) <= 5 {
                //if value is less than or equal to 5 then normal
            } else if vikriti > prakriti {
                //If vikriti value is higher than prakriti= aggrevated
                increasedValues.append(kpvType)
            }
        }
        
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return increasedValues
        }
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
        #else
        
        kaphaP = 33.0
        pittaP = 33.0
        vataP = 34.0
        
        // Code your app clip may access.
        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
        #endif
        return increasedValues
    }
    
    class func getYourCurrentKPVState(isHandleBalanced: Bool = true) -> CurrentKPVStatus {
        let increasedValues = getIncreasedValues()
        if increasedValues.contains(.VATA) && increasedValues.contains(.PITTA) {
            return .Vata
        } else if increasedValues.contains(.VATA) && increasedValues.contains(.KAPHA)  {
            return .Vata
        } else if increasedValues.contains(.PITTA) && increasedValues.contains(.KAPHA)  {
            return .Pitta
        } else if increasedValues.contains(.VATA) {
            return .Vata
        } else if increasedValues.contains(.PITTA) {
            return .Pitta
        } else if increasedValues.contains(.KAPHA) {
            return .Kapha
        } else {
            if isHandleBalanced {
                if let _ = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
                    //prakriti test given
                    let prakritiIncreaseValue = Utils.getPrakritiIncreaseValue()
                    switch prakritiIncreaseValue {
                    case .vata:
                        return .Vata
                    case .pitta:
                        return .Pitta
                    default:
                        return .Kapha
                    }
                } else {
                    //prakriti test not given
                    let percentage = Utils.getRecommendationTypePercentage()
                    if percentage.vata >= percentage.kapha && percentage.vata >= percentage.pitta {
                        return .Vata
                    } else if percentage.pitta >= percentage.kapha && percentage.pitta >= percentage.vata {
                        return .Pitta
                    } else {
                        return .Kapha
                    }
                }
            } else {
                return .Balanced
            }
        }
    }
    
    class func getYourCurrentPrakritiStatus() -> CurrentPrakritiStatus {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            }
        }

        var prakritiDosha = CurrentPrakritiStatus.KAPHA
        if (kaphaCount == vataCount && vataCount == pittaCount && pittaCount == kaphaCount) {
            prakritiDosha = .TRIDOSHIC
        } else if (kaphaCount == vataCount || vataCount == pittaCount || pittaCount == kaphaCount) {
            if (kaphaCount == vataCount) {
                if (pittaCount > kaphaCount) {
                    let pvDif = pittaCount - vataCount;
                    let pkDif = pittaCount - kaphaCount;

                    if (pvDif <= 5 && pkDif <= 5) {
                        prakritiDosha = .TRIDOSHIC
                    } else if (pvDif <= 5) {
                        prakritiDosha = .PITTA_VATA
                    } else if (pkDif <= 5) {
                        prakritiDosha = .PITTA_KAPHA
                    } else {
                        prakritiDosha = .PITTA
                    }
                } else {
                    let pittaDif = kaphaCount - pittaCount;
                    if (pittaDif <= 5) {
                        prakritiDosha = .TRIDOSHIC
                    } else {
                        prakritiDosha = .KAPHA_VATA
                    }
                }
            } else if (vataCount == pittaCount) {
                if (kaphaCount > vataCount) {
                    let kvDif = kaphaCount - vataCount;
                    let kpDif = kaphaCount - pittaCount;

                    if (kvDif <= 5 && kpDif <= 5) {
                        prakritiDosha = .TRIDOSHIC
                    } else if (kvDif <= 5) {
                        prakritiDosha = .KAPHA_VATA
                    } else if (kpDif <= 5) {
                        prakritiDosha = .KAPHA_PITTA
                    } else {
                        prakritiDosha = .KAPHA
                    }
                } else {
                    let kaphaDif = pittaCount - kaphaCount;
                    if (kaphaDif <= 5) {
                        prakritiDosha = .TRIDOSHIC
                    } else {
                        prakritiDosha = .VATA_PITTA
                    }
                }
            } else if (pittaCount == kaphaCount) {
                if (vataCount > pittaCount) {
                    let vkDif = vataCount - kaphaCount;
                    let vpDif = vataCount - pittaCount;
                    
                    if (vkDif <= 5 && vpDif <= 5) {
                        prakritiDosha = .TRIDOSHIC
                    } else if (vkDif <= 5) {
                        prakritiDosha = .VATA_KAPHA
                    } else if (vpDif <= 5) {
                        prakritiDosha = .VATA_PITTA
                    } else {
                        prakritiDosha = .VATA
                    }
                } else {
                    let vataDif = kaphaCount - vataCount;
                    if (vataDif <= 5) {
                        prakritiDosha = .TRIDOSHIC
                    } else {
                        prakritiDosha = .PITTA_KAPHA
                    }
                }
            }
        } else {
            if (kaphaCount > vataCount && kaphaCount > pittaCount) {
                let kvDif = kaphaCount - vataCount;
                let kpDif = kaphaCount - pittaCount;
                
                if (kvDif <= 5 && kpDif <= 5) {
                    prakritiDosha = .TRIDOSHIC
                } else if (kvDif <= 5) {
                    prakritiDosha = .KAPHA_VATA
                } else if (kpDif <= 5) {
                    prakritiDosha = .KAPHA_PITTA
                } else {
                    prakritiDosha = .KAPHA
                }
            } else if (vataCount > kaphaCount && vataCount > pittaCount) {
                let vkDif = vataCount - kaphaCount;
                let vpDif = vataCount - pittaCount;
                
                if (vkDif <= 5 && vpDif <= 5) {
                    prakritiDosha = .TRIDOSHIC
                } else if (vkDif <= 5) {
                    prakritiDosha = .VATA_KAPHA
                } else if (vpDif <= 5) {
                    prakritiDosha = .VATA_PITTA
                } else {
                    prakritiDosha = .VATA
                }
            } else {
                let pvDif = pittaCount - vataCount;
                let pkDif = pittaCount - kaphaCount;
                
                if (pvDif <= 5 && pkDif <= 5) {
                    prakritiDosha = .TRIDOSHIC
                } else if (pvDif <= 5) {
                    prakritiDosha = .PITTA_VATA
                } else if (pkDif <= 5) {
                    prakritiDosha = .PITTA_KAPHA
                } else {
                    prakritiDosha = .PITTA
                }
            }
        }
        
        return prakritiDosha
        
        /*
        //3 5 % diff
        if (abs(pittaCount - kaphaCount) <= 5) && (abs(pittaCount - vataCount) <= 5) && (abs(vataCount - kaphaCount) <= 5) {
            // 3 doshas
            return .TRIDOSHIC
        } else {
            if pittaCount >= kaphaCount && pittaCount >= vataCount {
                if (abs(pittaCount - kaphaCount) <= 5) && ((abs(kaphaCount - vataCount) > 5) || (abs(vataCount - pittaCount) > 5)){
                    // Pitta-Kapha
                    return .PITTA_KAPHA
                }
                else  if (abs(vataCount - pittaCount) <= 5) && ((abs(pittaCount - vataCount) > 5) || (abs(kaphaCount - pittaCount) > 5)) {
                    // Vata-Pitta
                    return .VATA_PITTA
                } else {
                    // Pitta
                    return .PITTA
                }
            } else if vataCount >= kaphaCount && vataCount >= pittaCount {
                if (abs(kaphaCount - vataCount) <= 5) && ((abs(kaphaCount - pittaCount) > 5) || (abs(vataCount - pittaCount) > 5)) {
                    // Kapha and Vata
                    return .KAPHA_VATA
                }
                else  if (abs(vataCount - pittaCount) <= 5) && ((abs(pittaCount - vataCount) > 5) || (abs(kaphaCount - pittaCount) > 5)) {
                    // Vata-Pitta
                    return .VATA_PITTA
                } else {
                    // Vata
                    return .VATA
                }
            } else {
                // Kapha
                if (abs(kaphaCount - vataCount) <= 5) && ((abs(kaphaCount - pittaCount) > 5) || (abs(vataCount - pittaCount) > 5)) {
                    // Kapha and Vata
                    return .KAPHA_VATA
                }
                else  if (abs(pittaCount - kaphaCount) <= 5) && ((abs(kaphaCount - vataCount) > 5) || (abs(vataCount - pittaCount) > 5)){
                    // Pitta-Kapha
                    return .PITTA_KAPHA
                } else {
                    // Kapha
                    return .KAPHA
                }
            }
        }
        */
    }
    
    
    class func applyBottomLine(_ obj:AnyObject) {
        
        if let textField = obj as? UITextField{
            let lbl = UILabel.init(frame: CGRect(x: 0, y: textField.frame.size.height - 2, width: textField.frame.size.width, height: 1))
            lbl.backgroundColor = UIColor.lightGray
            textField.addSubview(lbl)
        }
        if let uC = obj as? UIControl{
            
            let lbl = UILabel.init(frame: CGRect(x: 0, y: uC.frame.size.height - 2, width: uC.frame.size.width, height: 1))
            lbl.backgroundColor = UIColor.lightGray
            uC.addSubview(lbl)
            //            uC.addSubview(lblT)
        }
        if let btn = obj as? UIButton {
            let lbl = UILabel.init(frame: CGRect(x: 0, y: btn.frame.size.height - 2, width: btn.frame.size.width, height: 1))
            lbl.backgroundColor = UIColor.lightGray
            btn.addSubview(lbl)
        }
        if let lblN = obj as? UILabel {
            let lbl = UILabel.init(frame: CGRect(x: 0, y: lblN.frame.size.height - 2, width: lblN.frame.size.width, height: 1))
            lbl.backgroundColor = UIColor.lightGray
            lblN.addSubview(lbl)
        }
        if let uCC = obj as? UIView{
            
            let lbl = UILabel.init(frame: CGRect(x: 0, y: uCC.frame.size.height - 2, width: uCC.frame.size.width, height: 1))
            lbl.backgroundColor = UIColor.lightGray
            uCC.addSubview(lbl)
        }
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func getStringFromDate(_ date: Date, format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.locale = Locale(identifier: "en_US")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    class func getDateFromString(_ date: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.locale = Locale(identifier: "en_US")
        let dateString = dateFormatter.date(from: date)
        return dateString
    }
    
    class func getAnswersString(dicAnswers: [Int: Any]) -> String {
        var strAnswers = "["
        for (key, value) in dicAnswers {
            strAnswers += "{\(key),\(value)},"
        }
        strAnswers.removeLast()
        strAnswers += "]"
        return strAnswers
    }
    
    class func getLastAssessmentData()  -> [String: Any]  {
        guard let lastAssData = kUserDefaults.value(forKey: LAST_ASSESSMENT_DATA) as? String, !lastAssData.isEmpty else {
            return [:]
        }
        let resultString = lastAssData
        guard let dataStr = resultString.data(using: .utf8) else {
            return [:]
        }
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: dataStr, options: .allowFragments)
            let resultDic = jsonData as! [String: Any]
            print(resultDic)
            return resultDic
        } catch let error {
            print(error)
            return [:]
        }
    }
    
    class func getLanguageId() -> NSInteger {
        let appLanguage = kUserDefaults.string(forKey: kAppLanguage)
        if appLanguage == "hi" {
            return 2
        } else {
            return 1
        }
    }
    
    class var isAppInHindiLanguage: Bool {
        return getLanguageId() == 2
    }
    
    class func clearUserDataBaseData() {
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Yoga")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Meditation")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Pranayama")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Mudra")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Kriya")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Food")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "FoodDemo")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Herb")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HerbType")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PlayList")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HomeRemedies")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HomeRemediesDetail")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HomeRemediesDescription")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Trainer")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "TrainerPackage")
        CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PackageTimeSlot")
    }
    
    class func getLinkfromString(str_msggggg: String) -> [String] {
        var str_urllll = [String]()
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: str_msggggg, options: [], range: NSRange(location: 0, length: str_msggggg.utf16.count))
        for match in matches {
            guard let range = Range(match.range, in: str_msggggg) else { continue }
            str_urllll.append(String(str_msggggg[range]))
            print("Message link:=======>>\(str_urllll)")
        }
        return str_urllll
    }
}

extension Dictionary where Key == String {
    mutating func addVikritiResultFinalValue() {
        if kUserDefaults.value(forKey: VIKRITI_SPARSHNA) != nil {
            //vikriti (sparshna) test has given
            let currentKPVStatus = Utils.getYourCurrentKPVState(isHandleBalanced: false)
            self["aggravation"] = currentKPVStatus.rawValue.lowercased() as? Value
        }
    }
    
    mutating func addPrakritiResultFinalValue() {
        if kUserDefaults.value(forKey: VIKRITI_SPARSHNA) != nil {
            //vikriti (sparshna) test has given
            let currentPraktitiStatus = Utils.getYourCurrentPrakritiStatus()
            self["prakriti_dosha"] = currentPraktitiStatus.rawValue.lowercased() as? Value
        }
    }
}

// MARK: - String extension

//MARK: Progress View Class
/// ProgressView Class - To make circular progress
class ProgressView:UIView {
    
    var activityIndicator:UIActivityIndicatorView?
    var viewDisable:UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct SharedInstance {
        static var sharedInstance: ProgressView?
    }
    class var sharedInstance : ProgressView?{
        if SharedInstance.sharedInstance == nil
        {
            SharedInstance.sharedInstance = ProgressView()
        }
        return SharedInstance.sharedInstance!
    }
    
    func startViewWithUserInteractionInView(_ view:UIView,userInteraction:Bool,isGray:Bool?){
        self.stopView()
        if !userInteraction {
        viewDisable = UIView(frame:UIScreen.main.bounds)
        viewDisable!.backgroundColor = UIColor.black
        viewDisable!.alpha = 0.5
        kSharedAppDelegate.window?.addSubview(viewDisable!)

        }
        activityIndicator = UIActivityIndicatorView(style: isGray == true ? .gray : .white)
        activityIndicator?.color = UIColor.black
        activityIndicator!.startAnimating()
        view.addSubview(activityIndicator!)
        activityIndicator!.center = view.center
    }
    
    func stopView(){
        
        if let indicator = self.activityIndicator {
            indicator.removeFromSuperview()
        }
        
        if let viewBg = self.viewDisable {
            viewBg.removeFromSuperview()
        }
    }
}

@IBDesignable
class RoundView: UIView {

    @IBInspectable public var cornerRadius: CGFloat = 10.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    @IBInspectable public var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
    
    // For boader width
    
    @IBInspectable public var boaderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = self.boaderWidth
        }
    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.layer.cornerRadius = cornerRadius
//        self.clipsToBounds = true
//    }
}

@IBDesignable
class RoundedButton: UIButton {
    @IBInspectable public var cornerRadius: CGFloat = 10.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    @IBInspectable public var borderColor: UIColor = UIColor.clear{
           didSet{
               self.layer.borderColor = self.borderColor.cgColor
           }
       }
       
       // For boader width
       
       @IBInspectable public var boaderWidth: CGFloat = 0.0 {
           didSet{
               self.layer.borderWidth = self.boaderWidth
           }
       }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.layer.cornerRadius = cornerRadius
//        self.clipsToBounds = true
//    }
}

extension UIColor{
    func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
        }
    }
}


extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension Double {
    var roundToOnePlace: Double {
        let str = String(format: "%0.1f", self)
        return Double(str) ?? 0.0
    }
}

// UIViewcontroller show alert, activityIndication show/hide helper methods
extension UIViewController {
    func showAlert(title:String = "", message: String) {
        Utils.showAlertWithTitleInController(title, message: message, controller: self)
    }
    
    func showAlert(error: Error) {
        showAlert(message: error.localizedDescription)
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error".localized(), message: message)
    }
    
    func showActivityIndicator(view: UIView? = nil, userInteraction: Bool = false) {
        Utils.startActivityIndicatorInView(view ?? self.view, userInteraction: userInteraction)
    }
    
    func hideActivityIndicator(view: UIView? = nil) {
        Utils.stopActivityIndicatorinView(view ?? self.view)
    }
    
    func hideActivityIndicator(withMessage message: String) {
        Utils.stopActivityIndicatorinView(self.view)
        showAlert(message: message)
    }
    
    func hideActivityIndicator(withTitle title: String, Message message: String) {
        Utils.stopActivityIndicatorinView(self.view)
        showAlert(title: title, message: message)
    }
    
    func hideActivityIndicator(withError error: Error) {
        Utils.stopActivityIndicatorinView(self.view)
        showAlert(message: error.localizedDescription)
    }
}

extension UILabel {
    func setBulletListedAttributedText(stringList: [String], bullet: String = "•", paragraphSpacing: CGFloat = 0) {
        let capitalizingFirstLetterStringList = stringList.map{ $0.capitalizingFirstLetter() }
        attributedText = NSAttributedString.bulletListedAttributedString(stringList: capitalizingFirstLetterStringList, font: font, bullet: bullet, paragraphSpacing: paragraphSpacing, textColor: textColor, bulletColor: textColor)
    }
}

extension NSAttributedString {
    static func bulletListedAttributedString(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 12,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 0,
             textColor: UIColor = .gray,
             bulletColor: UIColor = .green) -> NSAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }
}

extension UITableView {
    func isValid(indexPath: IndexPath) -> Bool {
        guard indexPath.section < numberOfSections,
              indexPath.row < numberOfRows(inSection: indexPath.section)
            else { return false }
        return true
    }
}

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

   func truncated(limit: Int = 130, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count >= limit else { return self }

        switch position {
        case .head:
            return leader + self.suffix(limit)
        
        case .middle:
            let halfCount = (limit - leader.count).quotientAndRemainder(dividingBy: 2)
            let headCharactersCount = halfCount.quotient + halfCount.remainder
            let tailCharactersCount = halfCount.quotient
            return String(self.prefix(headCharactersCount)) + leader + String(self.suffix(tailCharactersCount))
        
        case .tail:
            return self.prefix(limit) + leader
        }
    }
    
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func getBoldTextForSharing() -> String {
        return "*" + self + "*"
    }
}

extension String {
    
    /*
     Example :
     Note:- eventStartDate is the string which you have to converted in your format like this:- "2018-07-11T16:22:00.000Z"

     let finalDate = eventStartDate.UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy h:mm a")
     */
    
    //MARK:- Convert UTC To Local Date by passing date formats value
    func UTCToLocal(incomingFormat: String, outGoingFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = incomingFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")
        dateFormatter.locale = Locale(identifier: "en")
        
        let dt = dateFormatter.date(from: self)
        //dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        dateFormatter.dateFormat = outGoingFormat
        
        return dateFormatter.string(from: dt ?? Date())
    }
    
    func UTCToLocalDate(incomingFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = incomingFormat
        dateFormatter.timeZone =  TimeZone(abbreviation: "IST")
        
        let dt = dateFormatter.date(from: self)
        return dt
    }
    
    //MARK:- Convert Local To UTC Date by passing date formats value
    func localToUTC(incomingFormat: String, outGoingFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = incomingFormat
        dateFormatter.calendar = NSCalendar.current
        //dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")
        dateFormatter.dateFormat = outGoingFormat
        
        return dateFormatter.string(from: dt ?? Date())
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension Dictionary {
    func nullKeyRemoval() -> Dictionary {
        var dict = self

        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }

        return dict
    }
}

extension UIApplication {
    public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

extension UserDefaults {
    func save<T:Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }
    
    func retrieve<T:Decodable>(object type:T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            }else {
                print("Couldnt decode object")
                return nil
            }
        }else {
            print("Couldnt find key")
            return nil
        }
    }
    /*
     Usage:

     let updateProfile = UpdateProfile()

     //To save the object
     UserDefaults.standard.save(customObject: updateProfile, inKey: "YourKey")

     //To retrieve the saved object
     let obj = UserDefaults.standard.retrieve(object: UpdateProfile.self, fromKey: "YourKey")
     */
}

extension UIViewController {
    
    class func instantiateFromStoryboard(_ name: String = "Main") -> Self {
        return instantiateFromStoryboardHelper(name)
    }

    fileprivate class func instantiateFromStoryboardHelper<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }
}

extension UIView {
    func fillToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            let left = leftAnchor.constraint(equalTo: superview.leftAnchor)
            let right = rightAnchor.constraint(equalTo: superview.rightAnchor)
            let top = topAnchor.constraint(equalTo: superview.topAnchor)
            let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            NSLayoutConstraint.activate([left, right, top, bottom])
        }
    }
    
    /// SwifterSwift: Fade in view.
    ///
    /// - Parameters:
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func fadeIn(duration: TimeInterval = 0.36, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }

    /// SwifterSwift: Fade out view.
    ///
    /// - Parameters:
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func fadeOut(duration: TimeInterval = 0.36, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
    }
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
            layer.masksToBounds = false
            layer.shadowOffset = offset
            layer.shadowColor = color.cgColor
            layer.shadowRadius = radius
            layer.shadowOpacity = opacity

            let backgroundCGColor = backgroundColor?.cgColor
            backgroundColor = nil
            layer.backgroundColor =  backgroundCGColor
        }
}

// MARK: - Comma Seperated Values
extension String {
    var spaceSeperatedValues: [String] {
        return components(separatedBy: " ")
    }
    
    var commaSeperatedValues: [String] {
        return components(separatedBy: ",")
    }
    
    var newlineSeperatedValues: [String] {
        return self.replacingOccurrences(of: "\\n", with: "\n").components(separatedBy: "\n")
    }
    
    func newlineSeperatedValues(bullet: String = "-") -> String {
        return bullet + " " + self.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\n", with: "\n\(bullet) ")
    }
}

extension Array where Element == String {
    var commaSeperatedString: String {
        return joined(separator: ",")
    }
}

extension Set where Element == String {
    var commaSeperatedString: String {
        return joined(separator: ",")
    }
}

// MARK: -
extension DispatchQueue {
    static func delay(_ delay: DispatchTimeInterval, closure: @escaping () -> ()) {
        let timeInterval = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: timeInterval, execute: closure)
    }
    /*
     USAGE ::
     DispatchQueue.delay(.seconds(1)) {
         print("This is after delay")
     }
     */
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

// MARK: -
extension UITableViewCell {
    func changeCellSelectionBackgroundColor(color: UIColor = .clear) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = color
        self.selectedBackgroundView = backgroundView
    }
}

//extension UIDevice {
//    var modelName: String {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//        let identifier = machineMirror.children.reduce("") { identifier, element in
//            guard let value = element.value as? Int8, value != 0 else { return identifier }
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//        return identifier
//    }
//}

// MARK: -
extension UserDefaults {
    
    var referralCode: String {
        get {
            return string(forKey: kUserReferralCode) ?? ""
        }
        set {
            set(newValue, forKey: kUserReferralCode)
        }
    }
    
    var referralPointValue: String {
        get {
            return string(forKey: kReferralPointValue) ?? ""
        }
        set {
            set(newValue, forKey: kReferralPointValue)
        }
    }
    
    var isCCRYNChallengeUnlocked: Bool {
        get {
            return bool(forKey: kIsCCRYNChallengeUnlocked)
        }
        set {
            setValue(newValue, forKey: kIsCCRYNChallengeUnlocked)
        }
    }
    
    var suryaNamaskarCount: Int {
        get {
            return integer(forKey: kSuryaNamaskarCount)
        }
        set {
            set(newValue, forKey: kSuryaNamaskarCount)
        }
    }
    
    var isResetSuryathonUnlockStatus: Bool {
        get {
            return bool(forKey: "isResetSuryathonUnlockStatus")
        }
        set {
            set(newValue, forKey: "isResetSuryathonUnlockStatus")
        }
    }
    
    var isNadiBandProjectUnlocked: Bool {
        get {
            return bool(forKey: "isNadiBandProjectUnlocked")
        }
        set {
            setValue(newValue, forKey: "isNadiBandProjectUnlocked")
        }
    }
    
    var isWellnessPreferenceSet: Bool {
        get {
            return bool(forKey: "isWellnessPreferenceSet")
        }
        set {
            setValue(newValue, forKey: "isWellnessPreferenceSet")
        }
    }
    
    var isWellnessActivityAutoplayOn: Bool {
        get {
            if value(forKey: "isWellnessActivityAutoplayOn") == nil {
                //default make this value true
                return true
            } else {
                return bool(forKey: "isWellnessActivityAutoplayOn")
            }
        }
        set {
            setValue(newValue, forKey: "isWellnessActivityAutoplayOn")
        }
    }
    
    var isGenderFemale: Bool {
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any], let gender = empData["gender"] as? String {
            return (gender == "Female")
        }
        return false
    }
    
    var giftClaimedPrakritiQuestionIndices: [Int] {
        get {
            return value(forKey: kGiftClaimedPrakritiQuestionIndices) as? [Int] ?? []
        }
        set {
            set(newValue, forKey: kGiftClaimedPrakritiQuestionIndices)
        }
    }
    
    var giftClaimedVikritiQuestionIndices: [Int] {
        get {
            return value(forKey: kGiftClaimedVikritiQuestionIndices) as? [Int] ?? []
        }
        set {
            set(newValue, forKey: kGiftClaimedVikritiQuestionIndices)
        }
    }
    
    var storedScratchCards: [String: Any] {
        get {
            return value(forKey: kStoredScratchCards) as? [String: Any] ?? [:]
        }
        set {
            set(newValue, forKey: kStoredScratchCards)
            //print(">>> storedScratchCards : ", newValue)
        }
    }
}

extension Utils {
    static var shareDownloadString: String {
        var text = ""
        let referralCode = kUserDefaults.referralCode
        if referralCode.isEmpty {
            text = "\n" + String(format: "Personalized holistic wellness assessment, recommendations and home remedies at your fingertips!\n\nDownload AyuRythm now!\nDownload on the App Store: %@\nDownload on the Play Store: %@".localized(), AppStoreLink, PlayStoreLink)
        } else {
            //do this bcoz string param order change in hindi and english string
            let param1 = Self.isAppInHindiLanguage ? kUserDefaults.referralPointValue : referralCode.getBoldTextForSharing()
            let param2 = Self.isAppInHindiLanguage ? referralCode.getBoldTextForSharing() :  kUserDefaults.referralPointValue
            text = "\n" + String(format: "Personalized holistic wellness assessment, recommendations and home remedies at your fingertips!\n\nDownload AyuRythm now!\nUse my code %@ to get %@ AyuSeeds and unlock exclusive content.\nDownload on the App Store: %@\nDownload on the Play Store: %@".localized(), param1, param2, AppStoreLink, PlayStoreLink)
        }
        return text
    }
    
    static var shareRegisterDownloadString: String {
        let text = String(format: "Register using my code %@ on the AyuRythm App & get %@ AyuSeeds to unlock exclusive and curated content.\nPersonalized holistic wellness assessment, recommendations and home remedies on AyuRythm App. Check out this and many more on the app.\nDownload on the App Store: %@ \nDownload on the Play Store: %@".localized(), kUserDefaults.referralCode.getBoldTextForSharing(), kUserDefaults.referralPointValue, AppStoreLink, PlayStoreLink)
        return text
    }
    
    static var shareContestDownloadString: String {
        let text = String(format: "Healthy habits are rewarding!! Exercise, meditate or participate in contests to win exciting rewards. Personalized holistic wellness at your fingertips!\n\nDownload AyuRythm now!Use my code %@ to get %@ AyuSeeds and unlock exclusive content.\nDownload on the App Store: %@ \nDownload on the Play Store: %@".localized(), kUserDefaults.referralCode.getBoldTextForSharing(), kUserDefaults.referralPointValue, AppStoreLink, PlayStoreLink)
        return text
    }
}

extension Utils {
    static func getAuthToken() -> String {
        let token = kUserDefaults.value(forKey: TOKEN) as? String ?? ""
        return token
    }
    
    static func getLoginUserUsername() -> String {
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return ""
        }
        return empData["name"] as? String ?? ""
    }
    
    static func getLoginUserGender() -> String {
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return ""
        }
        return empData["gender"] as? String ?? "Male"
    }
    
    static func getLoginUserHeightIncCM() -> Double {
        let defaultHeight = 148.0
        let userData = getLoginUserData()
        let heightStr = Utils.parseValidValue(string: userData["measurements"].stringValue).components(separatedBy: ",").first ?? "\(defaultHeight)"
        return Double(heightStr) ?? defaultHeight
    }
    
    static func getLoginUserWeightInKg() -> Double {
        let defaultV = 52.0
        let userData = getLoginUserData()
        let parts = Utils.parseValidValue(string: userData["measurements"].stringValue).components(separatedBy: ",")
        let weightStr = parts[safe: 1] ?? "\(defaultV)"
        return Double(weightStr) ?? defaultV
    }
    
    static func getLoginUserData() -> JSON {
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return JSON()
        }
        return JSON(empData)
    }
    
    static func showSpO2DisclaimerAlert() {
        if let vc = UIApplication.topViewController() {
            Utils.showAlertWithTitleInController("DISCLAIMER".localized(), message: "These results are only for Ayurvedic wellness and should not be interpreted or used for diagnosis or treatment.".localized(), controller: vc)
        }
    }
}

// MARK: -
class DynamicTableView: UITableView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        //disable scrolling, bcoz create problem in data entry with keyboard scroll
        if isScrollEnabled {
            isScrollEnabled = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

import Alamofire
import SwiftyJSON

extension UIViewController {
    func doAPICall(endPoint: endPoint,
                   method: HTTPMethod = .post,
                   parameters: Parameters? = nil,
                   encoding: ParameterEncoding = URLEncoding.default,
                   headers: HTTPHeaders? = nil,
                   completion: @escaping (Bool, String, String, JSON?)->Void) {
#if DEBUG
        print(String(format: ">>> API [%@] PARAM: %@ ", endPoint.rawValue, parameters ?? [:]))
#endif
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.rawValue
            AF.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON  { response in
                switch response.result {
                case .success(let value):
//#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] SUCCESS: ", endPoint.rawValue))
                    debugPrint("API Params=== >>\(parameters)")
                    debugPrint("API Header=== >>\(headers)")
        print(response)
        print(">>>>>>>>>>>>>>>>>>>>>>")
//#endif
                    let responseJSON = JSON(value)
                    let status = responseJSON["status"].stringValue
                    let message = responseJSON["message"].string ?? responseJSON["Message"].stringValue
                    let isSuccess = status.caseInsensitiveEqualTo("Success")
                    completion(isSuccess, status, message, responseJSON)
                case .failure(let error):
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] FAIL: %@ \nRESPONSE TEXT: %@", endPoint.rawValue, error.localizedDescription, String(data: response.data ?? Data(), encoding: .utf8) ?? ""))
         print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    completion(false, "", error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, "", NO_NETWORK, nil)
        }
    }
}

extension Utils {
    static func doAPICall(endPoint: endPoint,
                   method: HTTPMethod = .post,
                   parameters: Parameters? = nil,
                   encoding: ParameterEncoding = URLEncoding.default,
                   headers: HTTPHeaders? = nil,
                   completion: @escaping (Bool, String, String, JSON?)->Void) {
//#if DEBUG
        print(String(format: ">>> API [%@] PARAM: %@ ", endPoint.rawValue, parameters ?? [:]))
        print(String(format: ">>> API [%@] HEADER: %@ ", endPoint.rawValue, ["Authorization": Utils.getAuthToken()]))
//#endif
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.rawValue
            AF.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON  { response in
                switch response.result {
                case .success(let value):
                    
                    debugPrint("API URL: - \(urlString)\n\nResponse:-\(value)")
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] SUCCESS: ", endPoint.rawValue))
        print(response)
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    let responseJSON = JSON(value)
                    let status = responseJSON["status"].stringValue
                    let message = responseJSON["message"].string ?? responseJSON["Message"].stringValue
                    let isSuccess = status.caseInsensitiveEqualTo("Success")
                    completion(isSuccess, status, message, responseJSON)
                case .failure(let error):
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] FAIL: %@ \nRESPONSE TEXT: %@", endPoint.rawValue, error.localizedDescription, String(data: response.data ?? Data(), encoding: .utf8) ?? ""))
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    completion(false, "", error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, "", NO_NETWORK, nil)
        }
    }
    
    static func doAyuVerseAPICall(endPoint: endPoint,
                   method: HTTPMethod = .post,
                   parameters: Parameters? = nil,
                   encoding: ParameterEncoding = URLEncoding.default,
                   headers: HTTPHeaders? = nil,
                   completion: @escaping (Bool, String, String, JSON?)->Void) {
//#if DEBUG
        print(String(format: ">>> API [%@] PARAM: %@ ", endPoint.rawValue, parameters ?? [:]))
//#endif
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.rawValue
            AF.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON  { response in
                switch response.result {
                case .success(let value):
//#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] SUCCESS: ", endPoint.rawValue))
        print(response)
        print(">>>>>>>>>>>>>>>>>>>>>>")
//#endif
                    let responseJSON = JSON(value)
                    let status = responseJSON["status"].stringValue
                    let message = responseJSON["message"].string ?? responseJSON["Message"].stringValue
                    let isSuccess = status.caseInsensitiveEqualTo("Success")
                    completion(isSuccess, status, message, responseJSON)
                case .failure(let error):
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] FAIL: %@ \nRESPONSE TEXT: %@", endPoint.rawValue, error.localizedDescription, String(data: response.data ?? Data(), encoding: .utf8) ?? ""))
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    completion(false, "", error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, "", NO_NETWORK, nil)
        }
    }
    
    
    static func doAPICallMartketPlace(endPoint: String,
                   method: HTTPMethod = .post,
                   parameters: Parameters? = nil,
                   encoding: ParameterEncoding = URLEncoding.default,
                   headers: HTTPHeaders? = nil,
                                      is_EastcomAPI: Bool = false,
                   completion: @escaping (Bool, String, String, JSON?)->Void) {
        
#if DEBUG
        print(String(format: ">>> API [%@] PARAM: %@ ", endPoint, parameters ?? [:]))
#endif
        
        if Utils.isConnectedToNetwork() {
            
            let urlString = kBaseUrl_MarketPlace + endPoint
            
            debugPrint("Recently Product API URL=====>>\(urlString)")
            
            AF.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON  { response in
                switch response.result {
                case .success(let value):
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] SUCCESS: ", endPoint))
                    
        print(response)
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    let responseJSON = JSON(value)
                    let status = responseJSON["status"].stringValue
                    let message = responseJSON["message"].string ?? responseJSON["Message"].stringValue
                    let isSuccess = responseJSON["status"].boolValue
                    completion(isSuccess, status, message, responseJSON)
                    
                case .failure(let error):
#if DEBUG
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(String(format: ">>> API [%@] FAIL: %@ \nRESPONSE TEXT: %@", endPoint, error.localizedDescription, String(data: response.data ?? Data(), encoding: .utf8) ?? ""))
        print(">>>>>>>>>>>>>>>>>>>>>>")
#endif
                    completion(false, "", error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, "", NO_NETWORK, nil)
        }
    }
}

extension Utils {
    static func completeDailyTask(favorite_id: String, taskType: String, duration: Int? = nil, str_duration: String = "", completion: ((Bool, String, String) -> Void)? = nil ) {
        var params = ["language_id" : Utils.getLanguageId(),
                      "favorite_id": favorite_id,
                      "type": taskType] as [String : Any]
        if let duration = duration {
            params["duration"] = duration
        }
        
        if str_duration != "" && str_duration != "NULL" {
            params["duration"] = str_duration
        }
        
        params["date"] = Date().dateString(format: App.dateFormat.yyyyMMdd) //for wellness activity check
        Utils.doAPICall(endPoint: .getDailyTaskUpdate, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
            #if !APPCLIP
                appDelegate.apiCallingAsperDataChage = true
            #endif
                NotificationCenter.default.post(name: .refreshWellnessPlanData, object: nil)
                completion?(isSuccess, status, message)
            } else {
                completion?(isSuccess, status, message)
            }
        }
    }
}

extension Utils {
    static var isSparshnaDoneToday: Bool {
        if let lastAssessmentDate = kUserDefaults.value(forKey: LAST_ASSESSMENT_DATE) as? String,
           let lastAssessment = Utils.getDateFromString(lastAssessmentDate, format: "yyyy-MM-dd HH:mm:ss") {
            return Calendar.current.isDateInToday(lastAssessment)
        } else {
            return false
        }
    }
}

// MARK: -
extension String {
    func caseInsensitiveContains(_ string: String) -> Bool {
        return self.lowercased().contains(string.lowercased())
    }
    
    func caseInsensitiveEqualTo(_ string: String) -> Bool {
        return self.lowercased() == string.lowercased()
    }
}

// MARK: -
extension UIImageView {
    public func af_setImage(withURLString urlString: String?) {
        if let urlString = urlString, let url = URL(string: urlString) {
            af.setImage(withURL: url)
        } else {
            image = nil
        }
    }
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }

        return String(data: theJSONData, encoding: .utf8)
    }
}

extension Array {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }

        return String(data: theJSONData, encoding: .utf8)
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    mutating func remove(safeAt index: Int) -> Element? {
        return indices ~= index ? remove(at: index) : nil
    }
}

// MARK: -
extension Date {
    var startOfDay: Date {
        return getWholeDate().startDate
    }
    
    var endOfDay: Date {
        return getWholeDate().endDate
    }
    
    func getWholeDate() -> (startDate:Date, endDate: Date) {
        var startDate = self
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }
}

// MARK: -
extension Date {
    func dateString(format: String, locale: Locale? = nil) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    func dateStringEnglishLocale(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.locale = Locale(identifier: "EN")
        return df.string(from: self)
    }
    
}

extension Locale {
    var isCurrencyCodeInINR: Bool {
        return currencyCode == "INR"
    }
    
    var paramCurrencyCode: String {
        return currencyCode == "INR" ? "INR" : "USD"
    }
}

extension Float {
    var priceValueString: String {
        if Locale.current.isCurrencyCodeInINR {
            return String(format: "₹%.2f", self)
        } else {
            return String(format: "$%.2f", self)
        }
    }
    
    var priceValueStringWithoutCurrencySymbol: String {
        if Locale.current.isCurrencyCodeInINR {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.2f", self)
        }
    }
    
    var nonDecimalStringValue: String {
        String(format: "%.0f", self)
    }
    
    var twoDigitStringValue: String {
        return String(format: "%.2f", self)
    }
}

extension String {
    var priceValueString: String {
        let floatValue = Float(self) ?? 0
        if Locale.current.isCurrencyCodeInINR {
            return String(format: "₹%.0f", floatValue)
        } else {
            return String(format: "$%.2f", floatValue)
        }
    }
}

// MARK: - Custom Debug Log
public func ARLog(_ object: Any...) {
    #if DEBUG
    print(">>>>>> ARLog >>>>>>>>>")
    for item in object {
        Swift.print(item)
    }
    print(">>>>>>>>>>>>>>>>>>>>>>")
    #endif
}

// MARK: - Method execution Time Tracking
func DebugLog(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = file.components(separatedBy: "/").last?.replacingOccurrences(of: ".swift", with: "") ?? ""
    print(":: \(fileName) -> \(function) -> Line[\(line)] ::> ", log)
    #endif
}




public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
