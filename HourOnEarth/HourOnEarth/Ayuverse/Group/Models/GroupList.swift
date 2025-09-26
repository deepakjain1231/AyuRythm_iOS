//
//  GroupList.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 23/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
class GroupList: Codable {
    var status, message: String?
    var groupsCount: Int?
    var createGroupPermission: Bool?
    var data: [GroupData]?
    var mygroups: [MyGroupData]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case groupsCount = "groups_count"
        case createGroupPermission = "create_group_permission"
        case data, mygroups
    }

    init(status: String?, message: String?, groupsCount: Int?, createGroupPermission: Bool?, data: [GroupData]?, mygroups: [MyGroupData]?) {
        self.status = status
        self.message = message
        self.groupsCount = groupsCount
        self.createGroupPermission = createGroupPermission
        self.data = data
        self.mygroups = mygroups
    }
}

// MARK: - Datum
class GroupData: Codable {
    var groupID, groupLabel, isFeatured, groupDescription: String?
    var groupImage: String?
    var groupType, groupCategories, groupMembers, groupMemberLimit: String?
    var groupAdmin: String?
    var groupRules: String?
    var createdAt, updatedAt: String?
    var deletedAt: JSONNull?
    var isReported, userName: String?
    var userProfile: UserProfile?
    var joinedGroupOrNot: Int?
    var newPost: String?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
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
        case userName = "user_name"
        case userProfile = "user_profile"
        case joinedGroupOrNot = "joined_group_or_not"
        case newPost = "new_post"
    }

    init(groupID: String?, groupLabel: String?, isFeatured: String?, groupDescription: String?, groupImage: String?, groupType: String?, groupCategories: String?, groupMembers: String?, groupMemberLimit: String?, groupAdmin: String?, groupRules: String?, createdAt: String?, updatedAt: String?, deletedAt: JSONNull?, isReported: String?, userName: String?, userProfile: UserProfile?, joinedGroupOrNot: Int?, newPost: String?) {
        self.groupID = groupID
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
        self.userName = userName
        self.userProfile = userProfile
        self.joinedGroupOrNot = joinedGroupOrNot
        self.newPost = newPost
    }
}



// MARK: - Encode/decode helpers


    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }

