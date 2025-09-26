//
//  FetchAnswerListModel.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 26/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - FetchAnswerListModel
class FetchAnswerListModel: Codable {
    var status, message: String?
    var answersCount: Int?
    var data: [AnswerData]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case answersCount = "answers_count"
        case data
    }

    init(status: String?, message: String?, answersCount: Int?, data: [AnswerData]?) {
        self.status = status
        self.message = message
        self.answersCount = answersCount
        self.data = data
    }
}

// MARK: - Datum
class AnswerData: Codable {
    var answerID, questionID, userID, answer, tags: String?
    var sharedlibraryid, sharedlibrarytype: JSONNull?
    var files, upvotes, shares, createdAt: String?
    var updatedAt, isReported, userName: String?
    var userProfile: UserProfile?
    var userBadge, mylike: String?
    var is_ReadMore: Bool = false

    enum CodingKeys: String, CodingKey {
        case answerID = "answer_id"
        case questionID = "question_id"
        case userID = "user_id"
        case answer, sharedlibraryid, sharedlibrarytype, files, upvotes, shares, tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case userName = "user_name"
        case userProfile = "user_profile"
        case userBadge = "user_badge"
        case mylike
    }

    init(answerID: String?, questionID: String?, userID: String?, tags: String?, answer: String?, sharedlibraryid: JSONNull?, sharedlibrarytype: JSONNull?, files: String?, upvotes: String?, shares: String?, createdAt: String?, updatedAt: String?, isReported: String?, userName: String?, userProfile: UserProfile?, userBadge: String?, mylike: String?, readmore: Bool = false) {
        self.answerID = answerID
        self.questionID = questionID
        self.userID = userID
        self.tags = tags
        self.answer = answer
        self.sharedlibraryid = sharedlibraryid
        self.sharedlibrarytype = sharedlibrarytype
        self.files = files
        self.upvotes = upvotes
        self.shares = shares
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.userName = userName
        self.userProfile = userProfile
        self.userBadge = userBadge
        self.mylike = mylike
        self.is_ReadMore = readmore
    }
}



