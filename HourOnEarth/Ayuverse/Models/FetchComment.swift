//
//  FetchComment.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 23/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
class FetchComment: Codable {
    var status, message: String?
    var feed: Feed?
    var comments: [Comment]?

    init(status: String?, message: String?, feed: Feed?, comments: [Comment]?) {
        self.status = status
        self.message = message
        self.feed = feed
        self.comments = comments
    }
}

// MARK: - Comment
class Comment: Codable {
    var commentID, gfeedID, feedID, userID, feedcommentsID: String?
    var userId1, message: String?
    var mylike, likes, shares: Int?
    var createdAt, updatedAt: String?
    var isReported, commentcount: Int?
    var commentarray: [Commentarray]?
    var userProfile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case gfeedID =  "gfeed_id"
        case feedID = "feed_id"
        case userID = "user_id"
        case feedcommentsID = "feedcomments_id"
        case userId1 = "user_id1"
        case message, mylike, likes, shares
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case commentcount, commentarray
        case userProfile = "user_profile"
    }

    init(commentID: String?, gfeedID: String?, feedID: String?, userID: String?, feedcommentsID: String?, userId1: String?, message: String?, mylike: Int?, likes: Int?, shares: Int?, createdAt: String?, updatedAt: String?, isReported: Int?, commentcount: Int?, commentarray: [Commentarray]?, userProfile: UserProfile?) {
        self.commentID = commentID
        self.gfeedID = gfeedID
        self.feedID = feedID
        self.userID = userID
        self.feedcommentsID = feedcommentsID
        self.userId1 = userId1
        self.message = message
        self.mylike = mylike
        self.likes = likes
        self.shares = shares
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.commentcount = commentcount
        self.commentarray = commentarray
        self.userProfile = userProfile
    }
}

// MARK: - Commentarray
class Commentarray: Codable {
    var commentID, feedID, userID, message: String?
    var mylike, likes, shares: Int?
    var createdAt, updatedAt: String?
    var isReported: Int?
    var userProfile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case feedID = "feed_id"
        case userID = "user_id"
        case message, mylike, likes, shares
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case userProfile = "user_profile"
    }

    init(commentID: String?, feedID: String?, userID: String?, message: String?, mylike: Int?, likes: Int?, shares: Int?, createdAt: String?, updatedAt: String?, isReported: Int?, userProfile: UserProfile?) {
        self.commentID = commentID
        self.feedID = feedID
        self.userID = userID
        self.message = message
        self.mylike = mylike
        self.likes = likes
        self.shares = shares
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.userProfile = userProfile
    }
}



enum UserName: String, Codable {
    case anadi = "Anadi"
    case prakashGajera = "Prakash Gajera"
    case prakshGajera = "praksh gajera"
}

// MARK: - Feed
class Feed: Codable {
    var groupID,feedID, message, tags: String?
    var files: [String]?
    var mylikes, likes, shares: Int?
    var category, createdAt, updatedAt, isReported: String?
    var comments: Int?
    var userProfile: UserProfile?
    var is_ReadMore: Bool = false

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case feedID = "feed_id"
        case message, files, mylikes, likes, shares, category, tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case comments
        case userProfile = "user_profile"
    }

    init(groupId: String?,feedID: String?, message: String?, tags: String?, files: [String]?, mylikes: Int?, likes: Int?, shares: Int?, category: String?, createdAt: String?, updatedAt: String?, isReported: String?, comments: Int?, userProfile: UserProfile?, readmore: Bool = false) {
        self.feedID = feedID
        self.groupID = groupId
        self.tags = tags
        self.message = message
        self.files = files
        self.mylikes = mylikes
        self.likes = likes
        self.shares = shares
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.comments = comments
        self.userProfile = userProfile
        self.is_ReadMore = readmore
    }
}
