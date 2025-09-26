//
//  HOEForYouHomeVC+Shared.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 26/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation

protocol RecommendationSeeAllDelegate: class {
    func didSelectedSelectRow(indexPath: IndexPath, index: Int?)
    func didSelectedSelectRowForRedeem(indexPath: IndexPath, index: Int?)
}
