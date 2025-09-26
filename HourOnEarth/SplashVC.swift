//
//  SplashVC.swift
//  Tummoc
//
//  Created by Deepak Jain on 17/07/22.
//

import UIKit
import Lottie
import FirebaseInAppMessaging

class SplashVC: UIViewController, InAppMessagingDisplayDelegate {
    
    @IBOutlet weak var view_Base: AnimationView!
    //    private var animationView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view_Base.contentMode = .scaleAspectFill
        //view_Base.loopMode = .loop
        //view_Base.animationSpeed = 0.5
        view_Base.play()
        
        Timer.scheduledTimer(withTimeInterval: 3.75, repeats: false) { timerrrr in
            self.appScreenRedirection()
        }
        
        //InAppMessaging.inAppMessaging().messageDisplaySuppressed = true
        InAppMessaging.inAppMessaging().delegate = self
        self.inAppMessagingInitialization(setSuppressed: true, eventName: "");
        
        
        //MARK: - Handle Deep Link
//        appDelegate.completation_handle_url = { (str_URL) in
//            let str_click = str_URL.lastPathComponent
//            if str_click == "facenaadi" {
//                debugPrint("FaceNaadi Click Event")
//            }
//            else if str_click == "ayumonk" {
//                debugPrint("Ayumonk Click Event")
//            }
//            else if str_click == "shop" {
//                debugPrint("Shop Click Event")
//            }
//            else if str_click == "subscription" {
//                debugPrint("Subscription Click Event")
//            }
//            else if str_click == "contestlist" {
//                debugPrint("Contestlist Click Event")
//            }
//            else if str_click == "ayuseeds" {
//                debugPrint("Ayuseeds Click Event")
//            }
//            else if str_click == "referafriend" {
//                debugPrint("Refer a friend Click Event")
//            }
//            else if str_click == "ayuverse" {
//                debugPrint("Ayuverse Click Event")
//            }
//        }
        //********************************************//
    }
    
    func inAppMessagingInitialization(setSuppressed: Bool, eventName: String) {
        InAppMessaging.inAppMessaging().messageDisplaySuppressed = setSuppressed //true == Stop inAppMessaging
        
        if eventName != "" {
            InAppMessaging.inAppMessaging().triggerEvent("main_activity_ready");
        }
    }
    
    func appScreenRedirection() {
        kSharedAppDelegate.appRedirection(cueent_vc: self)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //MARK: -
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
        // ...
        let appData = inAppMessage.appData
    }
    
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: FIRInAppMessagingDismissType) {
        // ...
    }
    
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        // ...
    }
    
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        // ...
    }
}
