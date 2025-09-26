//
//  ARWellnessPlanActivityModel.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import CoreData

class ARWellnessPlanActivityModel {
    var id = ""
    var name = ""
    var image = ""
    var videoDuration = "00"
    var videoUrl = ""
    var vimeoVideoUrl: URL?
    var doshaType = ""
    var managedObject: NSManagedObject?
    var activityType = IsSectionType.yoga
    var isComplete = false
    var isLocked = false
    
    internal init(name: String, isComplete: Bool = false) {
        self.name = name
        self.isComplete = isComplete
    }
    
    internal init(managedObject: NSManagedObject) {
        self.managedObject = managedObject
        switch managedObject {
        case let data as Yoga:
            self.id = String(data.id)
            self.name = data.name ?? ""
            self.image = data.image ?? ""
            self.videoDuration = data.video_duration ?? "0"
            self.videoUrl = data.video_link ?? ""
            self.doshaType = data.type ?? ""
            self.isLocked = !data.redeemed
            self.isComplete = data.watchStatus
            self.activityType = .yoga
            
        case let data as Pranayama:
            self.id = String(data.id)
            self.name = data.name ?? ""
            self.image = data.image ?? ""
            self.videoDuration = data.video_duration ?? "0"
            self.videoUrl = data.video_link ?? ""
            self.doshaType = data.type ?? ""
            self.isLocked = !data.redeemed
            self.isComplete = data.watchStatus
            self.activityType = .pranayama
            
        case let data as Meditation:
            self.id = String(data.id)
            self.name = data.name ?? ""
            self.image = data.image ?? ""
            self.videoDuration = data.video_duration ?? "0"
            self.videoUrl = data.video_link ?? ""
            self.doshaType = data.type ?? ""
            self.isLocked = !data.redeemed
            self.isComplete = data.watchStatus
            self.activityType = .meditation
            
        case let data as Kriya:
            self.id = String(data.id)
            self.name = data.name ?? ""
            self.image = data.image ?? ""
            self.videoDuration = data.video_duration ?? "0"
            self.videoUrl = data.video_link ?? ""
            self.doshaType = data.type ?? ""
            self.isLocked = !data.redeemed
            self.isComplete = data.watchStatus
            self.activityType = .kriya
            
        case let data as Mudra:
            self.id = String(data.id)
            self.name = data.name ?? ""
            self.image = data.image ?? ""
            self.videoDuration = data.video_duration ?? "0"
            self.videoUrl = data.video_link ?? ""
            self.doshaType = data.type ?? ""
            self.isLocked = !data.redeemed
            self.isComplete = data.watchStatus
            self.activityType = .mudra
            
        default:
            print("pls handle this case")
        }
        
        extractVimeoURL(current_vc: UIApplication.topViewController())
    }
}

//import IGVimeoExtractor
import AVKit

class ARPlayerItem: AVPlayerItem {
    var activityId = "0"
    var activityType = IsSectionType.yoga
    
    convenience init(url: URL, activityId: String, activityType: IsSectionType) {
        self.init(url: url)
        self.activityId = activityId
        self.activityType = activityType
    }
}

extension ARWellnessPlanActivityModel {
    func extractVimeoURL(current_vc: UIViewController?, completion: ((_ url: URL?, _ playerItem: ARPlayerItem?)->Void)? = nil) {
        if let vimeoVideoUrl = vimeoVideoUrl {
            let playerItem = ARPlayerItem(url: vimeoVideoUrl, activityId: id, activityType: activityType)
            completion?(vimeoVideoUrl, playerItem)
            return
        }
        
        if let super_vc = current_vc {
            kSharedAppDelegate.callAPIforVimeoExtracter(vimeo_url: videoUrl, current_view: super_vc) { is_success, str_videoURL in
                if is_success {
                    guard let videoURL = URL(string: str_videoURL) else {
                        return
                    }
                    
                    self.vimeoVideoUrl = videoURL
                    let playerItem = ARPlayerItem(url: videoURL, activityId: self.id, activityType: self.activityType)
                    completion?(videoURL, playerItem)
                }
                else {
                    completion?(nil, nil)
                    return
                }
            }
        }
        

        
        
        /*
        IGVimeoExtractor.fetchVideoURL(fromURL: videoUrl) { (video, error) in
            guard error == nil else {
                print(">> IGVimeoExtractor error : ", error?.localizedDescription)
                completion?(nil, nil)
                return
            }
            guard let videoURL = video?.first?.videoURL else {
                print(">> IGVimeoExtractor error : video link not found")
                completion?(nil, nil)
                return
            }
            self.vimeoVideoUrl = videoURL
            let playerItem = ARPlayerItem(url: videoURL, activityId: self.id, activityType: self.activityType)
            completion?(videoURL, playerItem)
        }
        */
    }
}
