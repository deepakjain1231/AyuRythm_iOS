//
//  HomeDetailCell.swift
//  HourOnEarth
//
//  Created by Apple on 25/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol HomeInfoDelegate: class {
    func infoClickedFor(type: KPVType)
}

class HomeDetailCell: UITableViewCell {

    @IBOutlet weak var lblIdealPercentage: UILabel!
    @IBOutlet weak var lblCurrentPercentage: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var trailingConstantCurrent: NSLayoutConstraint!
    @IBOutlet weak var trailingConstantIdeal: NSLayoutConstraint!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgType: UIImageView!
    @IBOutlet weak var stackView: UIStackView!

    var kpvType: KPVType = .KAPHA
    weak var delegate: HomeInfoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(heading: String, image: String, ideal: Double?, current: Double?, description: String) {
        self.lblHeading.text = heading.uppercased().localized()
        self.imgType.image = UIImage(named: image)
        let fullWidth = UIScreen.main.bounds.width - 64
        if let idealValue = ideal {
            self.lblIdealPercentage.text = "Ideal You".localized() + ": \(idealValue) %"
            let idealPercentage = fullWidth * CGFloat(idealValue)/100.0
            let remainingWidth = fullWidth - idealPercentage
            self.trailingConstantIdeal.constant = -remainingWidth
            
        }
        
        if let currentValue = current {
            self.lblCurrentPercentage.text = "Current You".localized() + ": \(currentValue) %"
            let currentPercentage = fullWidth * CGFloat(currentValue)/100.0
            let remainingWidth = fullWidth - currentPercentage
            self.trailingConstantCurrent.constant = -remainingWidth
        }
        self.lblDescription.text = description
        kpvType =  KPVType(rawValue: heading) ?? .KAPHA
    }

    @IBAction func infoClicked(_ sender: UIButton) {
        self.delegate?.infoClickedFor(type: kpvType)
    }
    
}
