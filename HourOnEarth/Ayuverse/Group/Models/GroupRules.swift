//
//  GroupRules.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 25/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
class GroupRules: Codable {
    var status, message: String?
    var data: [RuleData]?

    init(status: String?, message: String?, data: [RuleData]?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

// MARK: - Datum
class RuleData: Codable {
    var number: Int?
    var rule: String?

    init(number: Int?, rule: String?) {
        self.number = number
        self.rule = rule
    }
}



//MARK: - Model For Report Message Data
class ReportMessage: Codable {
    var status, message: String?
    var data: [ReportData]?

    init(status: String?, message: String?, data: [ReportData]?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

// MARK: - Datum
class ReportData: Codable {
    var language_id: String?
    var message: String?
    var report_id: String?

    init(language_id: String?, message: String?, report_id: String?) {
        self.language_id = language_id
        self.message = message
        self.report_id = report_id
    }
}

