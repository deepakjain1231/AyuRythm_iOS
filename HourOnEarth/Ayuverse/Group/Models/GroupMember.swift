//
//  GroupMember.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 26/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - GroupMember
class GroupMember: Codable {
    var status, message, group: String?
    var data: [MemberList]?

    init(status: String?, message: String?, group: String?, data: [MemberList]?) {
        self.status = status
        self.message = message
        self.group = group
        self.data = data
    }
}

// MARK: - Datum
class MemberList: Codable {
    var id, groupID, userID, userStatus: String?
    var createdAt, updatedAt, isReported, userName: String?
    var userProfile: UserProfile?
    var userBadge: String?

    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case userID = "user_id"
        case userStatus = "user_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case userName = "user_name"
        case userProfile = "user_profile"
        case userBadge = "user_badge"
    }

    init(id: String?, groupID: String?, userID: String?, userStatus: String?, createdAt: String?, updatedAt: String?, isReported: String?, userName: String?, userProfile: UserProfile?, userBadge: String?) {
        self.id = id
        self.groupID = groupID
        self.userID = userID
        self.userStatus = userStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.userName = userName
        self.userProfile = userProfile
        self.userBadge = userBadge
    }
}

