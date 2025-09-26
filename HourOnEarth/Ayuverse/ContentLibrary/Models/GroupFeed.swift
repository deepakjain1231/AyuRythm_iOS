//
//  GroupFeed.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 24/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - GroupFeed
class GroupFeed: Codable {
    var status, message: String?
    var data: [Feed]?

    init(status: String?, message: String?, data: [Feed]?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

// MARK: - Datum
class GroupFeedData: Codable {
    var groupID, feedID, message, tags: String?
    var files: [String]?
    var likes, mylikes, shares: Int?
    var category: JSONNull?
    var createdAt, updatedAt: String?
    var isReported: String?
    var comments: Int?
    var userProfile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case feedID = "feed_id"
        case message, files, likes, mylikes, shares, category, tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case comments
        case userProfile = "user_profile"
    }

    init(groupID: String?, feedID: String?, message: String?, tags: String?, files: [String]?, likes: Int?, mylikes: Int?, shares: Int?, category: JSONNull?, createdAt: String?, updatedAt: String?, isReported: String?, comments: Int?, userProfile: UserProfile?) {
        self.tags = tags
        self.groupID = groupID
        self.feedID = feedID
        self.message = message
        self.files = files
        self.likes = likes
        self.mylikes = mylikes
        self.shares = shares
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.comments = comments
        self.userProfile = userProfile
    }
}



