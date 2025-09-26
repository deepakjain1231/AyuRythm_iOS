//
//  FeedModel.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 18/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

//class FeedModel{
    
//}
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation
class FeedModel{
    
}
// MARK: - Welcome
struct Welcome: Codable {
    let status, message: String
    let data: [Feed]
}

// MARK: - Datum
struct Datum: Codable {
    let feedID, message: String
    let files: [String]
    var mylikes, likes, shares: Int
    let category, createdAt, updatedAt, isReported: String
    let comments: Int
    let userProfile: UserProfile

    enum CodingKeys: String, CodingKey {
        case feedID = "feed_id"
        case message, files, mylikes, likes, shares, category
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case comments
        case userProfile = "user_profile"
    }
}


// MARK: - Search HashTag
struct SearchHashTag: Codable {
    let status, message: String
    let data: [HashTag]
}

// MARK: - Feed
class HashTag: Codable {
    var tagname: String?

    enum CodingKeys: String, CodingKey {
        case tagname = "tagname"
    }

    init(tagname: String?) {
        self.tagname = tagname
    }
}



// MARK: - Datum

// MARK: - UserProfile
struct UserProfile: Codable {
    let userID, userName: String
    let userProfile: String
    let userBadge: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case userName = "user_name"
        case userProfile = "user_profile"
        case userBadge = "user_badge"
    }
}
struct LikeFeedData: Codable {
    let status, message: String
}

// FeedComments

struct FeedComment: Codable {
    let status, message: String
    let feed: Datum
    let comments: [Comment]
}







// MARK: - Welcome
struct Patient_History: Codable {
    let status, message: String
    let data: [PatientData]
}

// MARK: - Datum
struct PatientData: Codable {
    let patient_name, vikriti: String
    

    enum CodingKeys: String, CodingKey {
        case patient_name, vikriti
    }
}
