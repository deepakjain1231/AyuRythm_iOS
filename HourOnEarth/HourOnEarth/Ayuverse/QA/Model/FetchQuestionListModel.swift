//
//  FetchQuestionListModel.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 26/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - FetchQuestionListModel
class FetchQuestionListModel: Codable {
    var status, message: String?
    var questionsCount: Int?
    var data: [QuestionData]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case questionsCount = "questions_count"
        case data
    }

    init(status: String?, message: String?, questionsCount: Int?, data: [QuestionData]?) {
        self.status = status
        self.message = message
        self.questionsCount = questionsCount
        self.data = data
    }
}

// MARK: - Datum
class QuestionData: Codable {
    var questionID, userID, postType, questionTitle, tags: String?
    var category, files, likes, shares: String?
    var createdAt, updatedAt, isReported, userName: String?
    var userProfile: UserProfile?
    var userBadge, answerCount: String?
    var is_ReadMore: Bool = false

    enum CodingKeys: String, CodingKey {
        case questionID = "question_id"
        case userID = "user_id"
        case postType = "post_type"
        case questionTitle = "question_title"
        case category, files, likes, shares, tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case userName = "user_name"
        case userProfile = "user_profile"
        case userBadge = "user_badge"
        case answerCount = "answer_count"
    }

    init(questionID: String?, userID: String?, postType: String?, tags: String?, questionTitle: String?, category: String?, files: String?, likes: String?, shares: String?, createdAt: String?, updatedAt: String?, isReported: String?, userName: String?, userProfile: UserProfile?, userBadge: String?, answerCount: String?, readmore: Bool = false) {
        self.questionID = questionID
        self.userID = userID
        self.postType = postType
        self.tags = tags
        self.questionTitle = questionTitle
        self.category = category
        self.files = files
        self.likes = likes
        self.shares = shares
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.userName = userName
        self.userProfile = userProfile
        self.userBadge = userBadge
        self.answerCount = answerCount
        self.is_ReadMore = readmore
    }
}

