//
//  ARModels.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 05/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 
class ARAyuverseCategory {
    var name: String
    var isSelected = false
    
    internal init(name: String, isSelected: Bool = false) {
        self.name = name
        self.isSelected = isSelected
    }
    
    var textWidth: CGFloat {
        let textSize = name.size(withAttributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
        return textSize.width
    }
    
    static func getAllCategories() -> [ARAyuverseCategory] {
        return [ARAyuverseCategory(name: "Kriya"),
                ARAyuverseCategory(name: "Mudra"),
                ARAyuverseCategory(name: "Meditation"),
                ARAyuverseCategory(name: "Pranayama"),
                ARAyuverseCategory(name: "Yogasana"),
                ARAyuverseCategory(name: "Food"),
                ARAyuverseCategory(name: "Home Remedies"),
                ARAyuverseCategory(name: "Herbs"),
                ARAyuverseCategory(name: "Others",isSelected: true)]
    }
}

// MARK: -
class ARQuestionModel {
    var userName: String
    var question: String
    var answerCount: Int
    
    var isMyQuestion: Bool {
        return userName == Utils.getLoginUserUsername()
    }
    
    internal init(userName: String, question: String, answerCount: Int) {
        self.userName = userName
        self.question = question
        self.answerCount = answerCount
    }
    
    static func getDummyQuestions() -> [ARQuestionModel] {
        return [ARQuestionModel(userName: "Paresh D", question: "What are the benefits of doing meditation everyday?", answerCount: 12),
                ARQuestionModel(userName: "Paresh", question: "What are the benefits of doing meditation everyday?", answerCount: 9),
                ARQuestionModel(userName: "Paresh Dafda", question: "What are the benefits of doing meditation everyday?", answerCount: 23)]
    }
}

// MARK: - 
class ARAnwerModel {
    var userName: String
    var answer: String
    var upvoteCount: Int
    
    var isMyAnswer: Bool {
        return userName == "Paresh D"
    }
    
    internal init(userName: String, answer: String, upvoteCount: Int) {
        self.userName = userName
        self.answer = answer
        self.upvoteCount = upvoteCount
    }
    
    static func getDummyAnswers() -> [ARAnwerModel] {
        return [ARAnwerModel(userName: "Paresh D", answer: "Use common sense when choosing your avatar and username, anything deemed inappropriate will be removed.", upvoteCount: 12),
                ARAnwerModel(userName: "Paresh D", answer: "Use common sense when choosing your avatar and username, anything deemed inappropriate will be removed.", upvoteCount: 9),
                ARAnwerModel(userName: "Paresh D", answer: "Use common sense when choosing your avatar and username, anything deemed inappropriate will be removed.", upvoteCount: 23)]
    }
}

// MARK: -
class ARAyuverseGroupSection {
    var title: String
    var myGroups: [GroupData]
    var groups: [GroupData]
    
    
    internal init(title: String, groups: [GroupData],myGroups: [GroupData]) {
        self.title = title
        self.groups = groups
        self.myGroups = myGroups
    }
    
    
}

