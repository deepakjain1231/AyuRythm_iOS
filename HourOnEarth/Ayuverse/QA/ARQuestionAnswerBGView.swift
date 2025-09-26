//
//  ARQuestionAnswerBGView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

// MARK: -
class ARQuestionAnswerBGView: DesignableView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    func commonSetup() {
        addShadow(shadowColor: UIColor.black.cgColor, shadowOffset: CGSize(width: 0, height: 0), shadowOpacity: 0.4, shadowRadius: 1)
        cornerRadius = 15
    }
}
