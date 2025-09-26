//
//  JoinGroup.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 24/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class JoinGroup: Codable {
    var status, message: String?
    var data: JoinGroupDataClass?

    init(status: String?, message: String?, data: JoinGroupDataClass?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

// MARK: - DataClass
class JoinGroupDataClass: Codable {
    var groupID, userID: String?
    var userStatus: Int?
    var createdAt, updatedAt: String?
    var isReported: Int?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case userID = "user_id"
        case userStatus = "user_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isReported = "is_reported"
    }

    init(groupID: String?, userID: String?, userStatus: Int?, createdAt: String?, updatedAt: String?, isReported: Int?) {
        self.groupID = groupID
        self.userID = userID
        self.userStatus = userStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isReported = isReported
    }
}
