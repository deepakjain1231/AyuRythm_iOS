//
//  AddReplyOnComment.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 23/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - AddReplyComment
class AddReplyComment: Codable {
    var status, message: String?
    var data: ReplyDataClass?

    init(status: String?, message: String?, data: ReplyDataClass?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

// MARK: - DataClass
class ReplyDataClass: Codable {
    var userID, feedcommentsID, userId1, message: String?
    var createdAt: String?
    var commentID: Int?
    var feedID: String?
    var likes, mylike, shares, isReported: Int?
    var userProfile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case feedcommentsID = "feedcomments_id"
        case userId1 = "user_id1"
        case message
        case createdAt = "created_at"
        case commentID = "comment_id"
        case feedID = "feed_id"
        case likes, mylike, shares
        case isReported = "is_reported"
        case userProfile = "user_profile"
    }

    init(userID: String?, feedcommentsID: String?, userId1: String?, message: String?, createdAt: String?, commentID: Int?, feedID: String?, likes: Int?, mylike: Int?, shares: Int?, isReported: Int?, userProfile: UserProfile?) {
        self.userID = userID
        self.feedcommentsID = feedcommentsID
        self.userId1 = userId1
        self.message = message
        self.createdAt = createdAt
        self.commentID = commentID
        self.feedID = feedID
        self.likes = likes
        self.mylike = mylike
        self.shares = shares
        self.isReported = isReported
        self.userProfile = userProfile
    }
}


