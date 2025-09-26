//
//  AddFeedModel.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 20/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//



// To parse the JSON, add this file to your project and do:
//
//   let addFeed = try? newJSONDecoder().decode(AddFeed.self, from: jsonData)

import Foundation

class AddFeedModel{
    
}
// MARK: - AddFeed
struct AddFeed: Codable {
    let status, message: String
    let data: [Datum]
}

// MARK: - Response Face Analysic
struct ResultFaceAnalysic: Codable {
    let age: [String]?
    let emotion: [String]?
    let eye_color: [String]?
    let hair: [String]?
    let skin_color: [String]?
}






