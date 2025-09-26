//
//  LocalNotification.swift
//  Field_Engineer
//
//  Created by Shilpa on 1/5/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

class LocalNotification {
    
    /**
     This function is used to schedule a local notification on the device
     
     - parameter dateTime:   date of notification
     - parameter userInfo:   dictionary to store the userInfo
     - parameter alertTitle: alertTitle to display
     - parameter alertBody:  alertBody text to display
     */
    class func scheduleNotification(_ dateTime: Date, userInfo: [String: Any], alertTitle: String, alertBody: String, repeatValue: String = "") {
        let localNotification = UILocalNotification()
        localNotification.alertTitle = alertTitle
        localNotification.alertBody = alertBody
        localNotification.timeZone = NSTimeZone.default
        localNotification.fireDate = dateTime
        localNotification.userInfo = userInfo
        
      
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        switch repeatValue {
        case "Minute":
            localNotification.repeatInterval = .minute
        case "Hour":
            localNotification.repeatInterval = .hour
        case "Day":
            localNotification.repeatInterval = .day
        default:
            break
        }
        localNotification.repeatInterval = .day

        
        localNotification.category = "notificationYoga"
//        localNotification.alertAction = "Call"
        UIApplication.shared.scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    /**
     This function is used to cancel a local notifcation of given maintenance opportunity ID
     
     - parameter id: maintenance opportunity ID
     */
    class func cancelNotificationWithId(_ id: Int, completion: @escaping ()->Void) {
        DispatchQueue.main.async {
            if let arrayOfNotifications: [UILocalNotification] = UIApplication.shared.scheduledLocalNotifications {
                for notification in arrayOfNotifications {
                    let userInfo = notification.userInfo as! [String:AnyObject]
                    if let alertId = userInfo["alertId"] as? Int, alertId == id {
                        UIApplication.shared.cancelLocalNotification(notification)
                        break
                    }
                }
            }
            completion()
        }
    }
    
    /**
     This function is used to cancel local notifications of the device
     */
    class func cancelNotification(notification: UILocalNotification) {
        UIApplication.shared.cancelLocalNotification(notification)
    }
    
    /**
     This function is used to cancel all the scheduled local notifications of the device
     */
    class func cancelAllNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
}
