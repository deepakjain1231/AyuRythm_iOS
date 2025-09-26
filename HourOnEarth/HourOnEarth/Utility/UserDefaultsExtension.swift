import Foundation
import Alamofire

// https://cocoacasts.com/use-extensions-to-add-type-safety-to-user-defaults
extension UserDefaults {
    // MARK: - Keys
    private struct Keys {
        struct app {
            static let baseURL = "baseURL"
        }
        struct user {
            static let main_subscription = "main_subscription"
            
            static let finger_count = "finger_count"
            static let facenaadi_count = "facenaadi_count"
            static let ayumonk_count = "ayumonk_count"
            static let remedies_count = "remedies_count"

            static let finger_assessment_trial = "finger_assessment_trial"
            static let finger_subscribed = "finger_subscribed"
            static let facenaadi_assessment_trial = "facenaadi_assessment_trial"
            static let facenaadi_subscribed = "facenaadi_subscribed"
            static let ayumonk_subscribed = "ayumonk_subscribed"
            static let ayumonk_trial = "ayumonk_trial" //Question
            static let homeRemedies_trial = "homeRemedie_trial"
            static let remedies_subscribed = "remedies_subscribed"
            static let diet_plan_subscribed = "dietplan_subscribed"
            static let user_info_result = "user_info_result"
        }
    }


    struct user {
        
        // MARK: - Finger Assessment
        static var free_finger_count: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.finger_count)
            return storedValue
        }
        
        static var finger_assessment_trial: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.finger_assessment_trial)
            return storedValue
        }
        
        static var is_finger_subscribed: Bool {
            let storedValue = UserDefaults.standard.bool(forKey: UserDefaults.Keys.user.finger_subscribed)
            return storedValue
        }
        
        static func set_finger_Count(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.finger_count)
        }
        
        static func set_finger_trialCount(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.finger_assessment_trial)
        }
        
        static func set_finger_Subscribed(data: Bool) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.finger_subscribed)
        }
        //************************************************************************************//
        //************************************************************************************//
        
        // MARK: - FaceNaadi Assessment
        static var free_facenaadi_count: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.facenaadi_count)
            return storedValue
        }
        
        static var facenaadi_assessment_trial: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.facenaadi_assessment_trial)
            return storedValue
        }
        
        static var is_facenaadi_subscribed: Bool {
            let storedValue = UserDefaults.standard.bool(forKey: UserDefaults.Keys.user.facenaadi_subscribed)
            return storedValue
        }
        
        static func set_facenaadi_Count(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.facenaadi_count)
        }
        
        static func set_facenaadi_trialCount(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.facenaadi_assessment_trial)
        }
        
        static func set_facenaadi_Subscribed(data: Bool) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.facenaadi_subscribed)
        }
        //************************************************************************************//
        
        
        // MARK: - AyuMonk
        static var free_ayumonk_question: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.ayumonk_count)
            return storedValue
        }
        
        static var ayumonk_trial: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.ayumonk_trial)
            return storedValue
        }
        
        static var is_ayumonk_subscribed: Bool {
            let storedValue = UserDefaults.standard.bool(forKey: UserDefaults.Keys.user.ayumonk_subscribed)
            return storedValue
        }
        
        static func set_ayumonk_Count(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.ayumonk_count)
        }
        
        static func set_ayumonk_trialCount(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.ayumonk_trial)
        }
        
        static func set_ayumonk_Subscribed(data: Bool) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.ayumonk_subscribed)
        }
        
        
        // MARK: - Home Remedies
        static var free_remedies_count: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.remedies_count)
            return storedValue
        }
        
        static var home_remedies_trial: Int {
            let storedValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.user.homeRemedies_trial)
            return storedValue
        }
        
        static var is_remedies_subscribed: Bool {
            let storedValue = UserDefaults.standard.bool(forKey: UserDefaults.Keys.user.remedies_subscribed)
            return storedValue
        }
        
        static var is_diet_plan_subscribed: Bool {
            let storedValue = UserDefaults.standard.bool(forKey: UserDefaults.Keys.user.diet_plan_subscribed)
            return storedValue
        }
        
        static func set_remedies_count(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.remedies_count)
        }
        
        static func set_home_remidies_trial_count(data: Int) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.homeRemedies_trial)
        }
        
        static func set_home_remedies_Subscribed(data: Bool) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.remedies_subscribed)
        }
        
        static func set_diet_plan_Subscribed(data: Bool) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.diet_plan_subscribed)
        }
        
        
        // MARK: - MAIN SUBSCRIPTION
        static var is_main_subscription: Bool {
            let storedValue = UserDefaults.standard.bool(forKey: UserDefaults.Keys.user.main_subscription)
            return storedValue
        }
        
        static func set_main_subscription(data: Bool) {
            UserDefaults.standard.set(data, forKey: UserDefaults.Keys.user.main_subscription)
        }
        
        
        
        //MARK: - USER INFO RESULT
        static var get_user_info_result_data: [String: Any] {
            var dic_user_info = [String: Any]()

            if kUserDefaults.object(forKey: UserDefaults.Keys.user.user_info_result) != nil {
                if let data = kUserDefaults.object(forKey: UserDefaults.Keys.user.user_info_result) as? Data {
                    if let dic_info_data = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                        dic_user_info = dic_info_data
                    }
                }
            }
            
            return dic_user_info
        }
        
        static func set_user_info_result(data: [String: Any]) {
            let arch_Data = NSKeyedArchiver.archivedData(withRootObject: data)
            UserDefaults.standard.set(arch_Data, forKey: UserDefaults.Keys.user.user_info_result)
        }
        //************************************************************************************//
    }
}
