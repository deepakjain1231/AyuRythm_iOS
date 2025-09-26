//
//  CreateGroup.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 28/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - CreateGroup
class CreateGroup: Codable {
    var status, message: String?
    var data: CreateGroupData?

    init(status: String?, message: String?, data: CreateGroupData?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

// MARK: - DataClass
class CreateGroupData: Codable {
    var groupLabel, groupDescription, groupImage, groupType: String?
    var groupCategories: String?
    var groupMembers: Int?
    var groupMemberLimit, groupAdmin, createdAt, updatedAt: String?
    var isReported, groupID: Int?

    enum CodingKeys: String, CodingKey {
        case groupLabel = "group_label"
        case groupDescription = "group_description"
        case groupImage = "group_image"
        case groupType = "group_type"
        case groupCategories = "group_categories"
        case groupMembers = "group_members"
        case groupMemberLimit = "group_member_limit"
        case groupAdmin = "group_admin"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
        case groupID = "group_id"
    }

    init(groupLabel: String?, groupDescription: String?, groupImage: String?, groupType: String?, groupCategories: String?, groupMembers: Int?, groupMemberLimit: String?, groupAdmin: String?, createdAt: String?, updatedAt: String?, isReported: Int?, groupID: Int?) {
        self.groupLabel = groupLabel
        self.groupDescription = groupDescription
        self.groupImage = groupImage
        self.groupType = groupType
        self.groupCategories = groupCategories
        self.groupMembers = groupMembers
        self.groupMemberLimit = groupMemberLimit
        self.groupAdmin = groupAdmin
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
        self.groupID = groupID
    }
}
