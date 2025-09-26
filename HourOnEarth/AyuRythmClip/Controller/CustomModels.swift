//
//  CustomModels.swift
//  AyuRythmClip
//
//  Created by Paresh Dafda on 27/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation

enum RecommendationsSectionType {
    case food
    case yoga
    case meditation
    case pranayama
    case mudra
    case kriya

    var title: String {
        switch self {
        case .food:
            return "Food".localized()
        case .yoga:
            return "Yoga".localized()
        case .meditation:
            return "Meditation".localized()
        case .pranayama:
            return "Pranayama".localized()
        case .mudra:
            return "Mudras".localized()
        case .kriya:
            return "Kriyas".localized()
        }
    }
}

enum RecommendationsCellType {
    case yoga(section: RecommendationsSectionType, data:[Yoga])
    case meditation(section: RecommendationsSectionType, data:[Meditation])
    case pranayama(section: RecommendationsSectionType, data:[Pranayama])
    case mudra(section: RecommendationsSectionType, data:[Mudra])
    case kriya(section: RecommendationsSectionType, data:[Kriya])
    case food(section: RecommendationsSectionType, data: [Food])

    var sortOrder: Int {
        switch self {
        case .food:
            return 1
        case .yoga:
            return 2
        case .meditation:
            return 3
        case .pranayama:
            return 4
        case .mudra:
            return 5
        case .kriya:
            return 6
        }
    }
    
    static func < (lhs: RecommendationsCellType, rhs: RecommendationsCellType) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

extension UIViewController {
    func showAppClipsShareActivityViewController(text: String) {
        let finalShareText = text + "\n\n" + String(format: "Personalized holistic wellness assessment, recommendations and home remedies on AyuRythm App. \nCheck out this on : %@".localized(), AppClipsLink)
        let shareAll = [ finalShareText ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print,
//                                                        UIActivity.ActivityType.postToFacebook,
//                                                        UIActivity.ActivityType.postToWeibo,
//                                                        UIActivity.ActivityType.postToFlickr,
//                                                        UIActivity.ActivityType.postToTencentWeibo,
//                                                        UIActivity.ActivityType.postToTwitter,
//                                                        UIActivity.ActivityType.postToVimeo,
//                                                        UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),];
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
