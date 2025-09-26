//
//  DeleteFeed.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 30/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - DeleteFeed
class DeleteFeed: Codable {
    var status, message: String?

    init(status: String?, message: String?) {
        self.status = status
        self.message = message
    }
}
