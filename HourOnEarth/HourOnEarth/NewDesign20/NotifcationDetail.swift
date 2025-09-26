//
//  NotifcationDetail.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 26/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation

struct NotifcationDetail {
    
    enum RedirectEvent: String {
        //1st Level
        case Home = "Home"
        case ForYou = "For You"
        case HomeRemedies = "Home Remedies"
        case MyLists = "My Lists"
        case Personalisation = "Personalisation"
        case Sparshna = "Sparshna"
        case Retest = "Retest"
        case ResultHistory = "Result History"
        case ReferAfriend = "Refer a friend (through AyuSeeds)"
        case CuratedLists = "Curated Lists"
        case Offers = "Offers"
        
        //2nd Level
        case Yogasana = "Yogasana"
        case Pranayama = "Pranayama"
        case Meditation = "Meditation"
        case Mudras = "Mudras"
        case Kriyas = "Kriyas"
        case Herbs = "Herbs"
        case Food = "Food"
        case Trainer = "Trainer"
    }
    
    var redirectEvent: RedirectEvent
    var tabSelectedIndex: Int
    var otherInfo: [String: Any]?
    
    var isThereSecondLavelRedirect: Bool {
        if redirectEvent == .Personalisation ||
            redirectEvent == .Sparshna ||
            redirectEvent == .Retest ||
            redirectEvent == .ResultHistory ||
            redirectEvent == .CuratedLists ||
            redirectEvent == .Yogasana ||
            redirectEvent == .Pranayama ||
            redirectEvent == .Meditation ||
            redirectEvent == .Mudras ||
            redirectEvent == .Kriyas ||
            redirectEvent == .Food ||
            redirectEvent == .Herbs ||
            redirectEvent == .Trainer ||
            redirectEvent == .Offers {
            return true
        }
        return false
    }

    public init(redirectEvent: RedirectEvent, tabSelectedIndex:Int = 0, otherInfo: [String: Any]? = nil) {
        self.redirectEvent = redirectEvent
        self.tabSelectedIndex = tabSelectedIndex
        self.otherInfo = otherInfo
    }
}

extension NotifcationDetail {
    static func detail(for event: String, otherInfo: [String: Any]? = nil) -> NotifcationDetail? {
        if let redirectEvent = NotifcationDetail.RedirectEvent(rawValue: event) {
            switch redirectEvent {
            case .ForYou, .CuratedLists, .Trainer:
                print(redirectEvent.rawValue)
                return NotifcationDetail(redirectEvent: redirectEvent, tabSelectedIndex: 1, otherInfo: otherInfo)
                
            case .HomeRemedies:
                print(redirectEvent.rawValue)
                return NotifcationDetail(redirectEvent: redirectEvent, tabSelectedIndex: 3)
                
            case .MyLists:
                print(redirectEvent.rawValue)
                return NotifcationDetail(redirectEvent: redirectEvent, tabSelectedIndex: 4)
                
            case .Personalisation, .Sparshna, .Retest, .ResultHistory, .Offers:
                print(redirectEvent.rawValue) //Redirect in Home screen with 2nd level
                return NotifcationDetail(redirectEvent: redirectEvent)
                
            case .Yogasana, .Pranayama, .Meditation, .Kriyas, .Mudras, .Food, .Herbs:
                print(redirectEvent.rawValue) //Redirect in Home screen with 2nd level
                return NotifcationDetail(redirectEvent: redirectEvent)
                
            case .ReferAfriend:
                print(redirectEvent.rawValue)
                return NotifcationDetail(redirectEvent: redirectEvent, tabSelectedIndex: 2)
                
            default:
                print("Redirect to Home default case")
            }
        }
        return nil
    }
}
