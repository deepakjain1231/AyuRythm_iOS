//
//  PostGroupFeed.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 24/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
class PostGroupFeed: Codable {
    var status, message: String?
    var data: [GroupFeedData]?

    init(status: String?, message: String?, data: [GroupFeedData]?) {
        self.status = status
        self.message = message
        self.data = data
    }
}





