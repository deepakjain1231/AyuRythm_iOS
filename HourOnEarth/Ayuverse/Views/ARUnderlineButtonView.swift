//
//  ARUnderlineButtonView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

protocol ARUnderlineButtonViewDelegate {
    func underlineButtonViewDidSelected(view: ARUnderlineButtonView)
}

class ARUnderlineButtonView: UIView {
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var countL: UILabel!
    @IBOutlet weak var underLineL: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var delegate: ARUnderlineButtonViewDelegate?
    var isSelected: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        titleL.textColor = isSelected ? UIColor.fromHex(hexString: "6CC068") : UIColor.fromHex(hexString: "888888")
        underLineL.isHidden = !isSelected
    }
    
    @IBAction func buttonBtnPressed(sender: UIButton) {
        delegate?.underlineButtonViewDidSelected(view: self)
    }
}
