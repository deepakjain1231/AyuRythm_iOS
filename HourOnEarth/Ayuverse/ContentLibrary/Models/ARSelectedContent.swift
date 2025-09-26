//
//  ARSelectedContent.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 07/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class ARSelectedContent {
    var type: ForYouSectionType
    var id : String
    var image: String
    
    internal init(type: ForYouSectionType, id: String, image: String) {
        self.type = type
        self.id = id
        self.image = image
    }
}

extension ARSelectedContent: Equatable {
    static func == (lhs: ARSelectedContent, rhs: ARSelectedContent) -> Bool {
        return lhs.type == rhs.type && lhs.id == rhs.id
    }
}

extension ARSelectedContent: CustomStringConvertible {
    var description: String {
        let desc = ">>>> [\(type) : \(id)]\n"
        return desc
    }
}
