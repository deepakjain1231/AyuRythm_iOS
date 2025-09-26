//
//  LikeQAModel.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 27/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - LikeQAModel
class LikeQAModel: Codable {
    var status, message: String?

    init(status: String?, message: String?) {
        self.status = status
        self.message = message
    }
}
