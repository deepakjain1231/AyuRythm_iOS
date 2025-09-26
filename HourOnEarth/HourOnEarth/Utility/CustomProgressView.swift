//
//  CustomProgressView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 11/11/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class CustomProgressView: UIView {
    @IBOutlet var progressViews: [UIView]!
    
    var progress: Int = 0 {
        didSet {
            var index = 0
            for label in progressViews {
                if index <= progress {
                    label.backgroundColor = kAppGreenD2Color
                } else {
                    label.backgroundColor = .white
                }
                index += 1
            }
        }
    }
}
