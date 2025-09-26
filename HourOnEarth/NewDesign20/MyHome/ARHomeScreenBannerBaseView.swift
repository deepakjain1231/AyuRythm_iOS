//
//  ARHomeScreenBannerBaseView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
class ARHomeScreenBannerBaseView: DesignableView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    func commonSetup() {
        //addShadow(shadowColor: UIColor().hexStringToUIColor(hex: "#9E9C9B").cgColor, shadowOffset: CGSize(width: 0, height: 1), shadowOpacity: 0.4, shadowRadius: 3)
        addShadow(shadowColor: UIColor.black.cgColor, shadowOffset: CGSize(width: 0, height: 0), shadowOpacity: 0.25, shadowRadius: 2)
        cornerRadius = 10
    }
}

class ARHomeScreenBannerBaseViewWithBorder: ARHomeScreenBannerBaseView {
    override func commonSetup() {
        super.commonSetup()
        //borderWidth = 0.6
        //borderColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
}
