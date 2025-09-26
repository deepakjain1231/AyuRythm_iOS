//
//  ARExploreContestView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 19/02/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
protocol ARExploreContestViewDelegate {
    func exploreContestViewArrowBtnDidPressed(view: ARExploreContestView)
}

class ARExploreContestView: PDDesignableXibView {
    
    var delegate: ARExploreContestViewDelegate?
    
    override func initialSetUp() {
        super.initialSetUp()
    }
    
    @IBAction func arrowBtnPressed(sender: UIButton) {
        delegate?.exploreContestViewArrowBtnDidPressed(view: self)
    }
}
