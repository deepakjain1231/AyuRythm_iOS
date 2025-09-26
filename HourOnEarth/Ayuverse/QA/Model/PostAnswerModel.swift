//
//  PostAnswerModel.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 27/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
// MARK: - PostAnswerModel
class PostAnswerModel: Codable {
    var status, message: String?
    var data: AnswerData?

    init(status: String?, message: String?, data: AnswerData?) {
        self.status = status
        self.message = message
        self.data = data
    }
}


