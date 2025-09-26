//
//  ARAyuverseManager.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

class ARAyuverseManager {
    var categories = [ARAyuverseCategoryModel]()
    static let shared = ARAyuverseManager()
    
    func fetchCommonData(isForceReload: Bool = false, completion: (() -> Void)? = nil) {
        if categories.isEmpty || isForceReload {
            ARCategoryPickerView.fetchCategoryData { categories in
                self.categories = categories
                //if self.categories.count > 0{
                   // self.categories.remove(at: 0)
                //}
                completion?()
            }
        } else {
            completion?()
        }
    }
}
