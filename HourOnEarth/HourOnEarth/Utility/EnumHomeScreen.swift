//
//  EnumHomeScreen.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import Foundation


enum RecommendationCellType {
    case noTestDone(title: String, isSparshna: Bool, isPrashna: Bool)
    case noSparshnaTest(isSparshna: Bool, isPrashna: Bool)
    case noQuestionnaires(isSparshna: Bool, isPrashna: Bool)
    case noQuestionnairesVikrati
    case lastAssessment(title: String)
    case explore
    case yoga(title: String, data:[Yoga])
    case pranayam(title: String, data:[Pranayama])
    case meditation(title: String, data:[Meditation])
    case mudra(title: String, data:[Mudra])
    case kriya(title: String, data:[Kriya])
    case food(title: String, data: [Food])
    case herbs(title: String, data: [Herb])
    case homeremedies(title: String, data: [[String: Any]])
    case products(title:String)
    case register
    case homeremedies_banner
    case subscription
    case pedometer
    case wellnessPlan
    case rewards
    case todaygoal_header
    case goal_Meditation(type: TodayGoal_Type, data: response_Data?)
    case explore_foodHerb
    case daily_planner
    case todaysGoalLoading
    
    var sortOrder: Int {
        switch self {
        case .noTestDone:
            return 0
        case .noSparshnaTest:
            return 1
        case .noQuestionnaires:
            return 2
        case .lastAssessment:
            return 3
        case .register:
            return 4
        case .pedometer:
            return 5
        case .wellnessPlan:
            return 6
        case .homeremedies_banner:
            return 7
        case .subscription:
            return 8
        case .food:
            return 9
        case .herbs:
            return 10
        case .yoga:
            return 11
        case .pranayam:
            return 12
        case .meditation:
            return 13
        case .mudra:
            return 14
        case .kriya:
            return 15
        case .products:
            return 16
        case .homeremedies:
            return 17
        case .explore:
            return 18
        case .rewards:
            return 19
        case .todaygoal_header:
            return 20
        case .goal_Meditation:
            return 21
        case .explore_foodHerb:
            return 22
        case .daily_planner:
            return 23
        case .noQuestionnairesVikrati:
            return 24
        case .todaysGoalLoading:
            return 25
        
        }
    }
    
    static func < (lhs: RecommendationCellType, rhs: RecommendationCellType) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}


//MARK: - For Home Screen
enum HomeScreenRecommendationType {
    case noTestDone(title: String, isSparshna: Bool, isPrashna: Bool)
    case noSparshnaTest(isSparshna: Bool, isPrashna: Bool)
    case noQuestionnaires(isSparshna: Bool, isPrashna: Bool)
    case lastAssessment(title: String)
    case noQuestionnairesVikrati
    case todaygoal_header
    case goal_Meditation(type: TodayGoal_Type, data: response_Data?)
    case rewards
    case todaysGoalLoading
    case pedometer
    case homeremedies_banner
    case explore
    case subscription
    case wellnessPlan
    case daily_planner
    case explore_foodHerb
    case voucher
    case shop_banner
    case weightTracker
    case ayumonk
    case meeLohaBanner

    var sortOrder: Int {
        switch self {
        case .noTestDone:
            return 0
        case .noSparshnaTest:
            return 1
        case .noQuestionnaires:
            return 2
        case .lastAssessment:
            return 3
        case .pedometer:
            return 5
        case .wellnessPlan:
            return 6
        case .homeremedies_banner:
            return 7
        case .subscription:
            return 8
        case .explore:
            return 9
        case .rewards:
            return 10
        case .todaygoal_header:
            return 11
        case .goal_Meditation:
            return 12
        case .explore_foodHerb:
            return 13
        case .daily_planner:
            return 14
        case .noQuestionnairesVikrati:
            return 15
        case .todaysGoalLoading:
            return 16
        case .voucher:
            return 17
        case .shop_banner:
            return 18
        case .weightTracker:
            return 19
        case .ayumonk:
            return 20
        case .meeLohaBanner:
            return 21
        }
    }
    
    static func < (lhs: HomeScreenRecommendationType, rhs: HomeScreenRecommendationType) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
