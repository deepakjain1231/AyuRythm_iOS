//
//  MyGroupList.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 28/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - MyGroupList
class MyGroupList: Codable {
    var status, message: String?
    var groupsCount: Int?
    var createGroupPermission: Bool?
    var data: [MyGroupData]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case groupsCount = "groups_count"
        case createGroupPermission = "create_group_permission"
        case data
    }

    init(status: String?, message: String?, groupsCount: Int?, createGroupPermission: Bool?, data: [MyGroupData]?) {
        self.status = status
        self.message = message
        self.groupsCount = groupsCount
        self.createGroupPermission = createGroupPermission
        self.data = data
    }
}

// MARK: - Datum
class MyGroupData: Codable {
    var groupID, userID, userStatus, groupLabel: String?
    var isFeatured, groupDescription, groupImage, groupType: String?
    var groupCategories, groupMembers, groupMemberLimit, groupAdmin: String?
    var groupRules: String?
    var createdAt, updatedAt: String?
    var deletedAt: JSONNull1?
    var isReported: String?
    var userProfile: UserProfileData?
    var waitingUsersCount: String?
    var newPost: String?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case userID = "user_id"
        case userStatus = "user_status"
        case groupLabel = "group_label"
        case isFeatured = "is_featured"
        case groupDescription = "group_description"
        case groupImage = "group_image"
        case groupType = "group_type"
        case groupCategories = "group_categories"
        case groupMembers = "group_members"
        case groupMemberLimit = "group_member_limit"
        case groupAdmin = "group_admin"
        case groupRules = "group_rules"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case isReported = "is_reported"
        case userProfile = "user_profile"
        case waitingUsersCount = "waiting_users_count"
        case newPost = "new_post"
    }

    init(groupID: String?, userID: String?, userStatus: String?, groupLabel: String?, isFeatured: String?, groupDescription: String?, groupImage: String?, groupType: String?, groupCategories: String?, groupMembers: String?, groupMemberLimit: String?, groupAdmin: String?, groupRules: String?, createdAt: String?, updatedAt: String?, deletedAt: JSONNull1?, isReported: String?, userProfile: UserProfileData?, waitingUsersCount: String?, newPost: String?) {
        self.groupID = groupID
        self.userID = userID
        self.userStatus = userStatus
        self.groupLabel = groupLabel
        self.isFeatured = isFeatured
        self.groupDescription = groupDescription
        self.groupImage = groupImage
        self.groupType = groupType
        self.groupCategories = groupCategories
        self.groupMembers = groupMembers
        self.groupMemberLimit = groupMemberLimit
        self.groupAdmin = groupAdmin
        self.groupRules = groupRules
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.isReported = isReported
        self.userProfile = userProfile
        self.waitingUsersCount = waitingUsersCount
        self.newPost = newPost
    }
}

// MARK: - UserProfile
class UserProfileData: Codable {
    var userID, userName: String?
    var userProfile: String?
    var userBadge: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case userName = "user_name"
        case userProfile = "user_profile"
        case userBadge = "user_badge"
    }

    init(userID: String?, userName: String?, userProfile: String?, userBadge: String?) {
        self.userID = userID
        self.userName = userName
        self.userProfile = userProfile
        self.userBadge = userBadge
    }
}

// MARK: - Encode/decode helpers

class JSONNull1: Codable, Hashable {

    public static func == (lhs: JSONNull1, rhs: JSONNull1) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
