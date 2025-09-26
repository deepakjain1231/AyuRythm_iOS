//
//  MoreKpvCell.swift
//  HourOnEarth
//
//  Created by Apple on 26/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol MoreExpandCollapseDelagate: class {
    func expandCollapseClicked(indexPath: IndexPath)
}

class MoreKpvCell: UITableViewCell {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnDisclosure: UIButton!

    weak var delegate: MoreExpandCollapseDelagate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(image: String, title: String, subTitle: String, isSelected: Bool) {
        imgLogo.image = UIImage(named: image)
        lblHeading.text = title.uppercased().localized()
        var textArray = subTitle.localized().components(separatedBy: "\n• ")
        if !textArray.isEmpty {
            textArray[0] = textArray[0].replacingOccurrences(of: "• ", with: "")
        }
        if isSelected {
            lblDetail.setBulletListedAttributedText(stringList: textArray)
        } else {
            lblDetail.attributedText = NSAttributedString()
        }
        //lblDetail.text = isSelected ? subTitle.localized() : ""
        lblHeading.textColor = isSelected ? UIColor().hexStringToUIColor(hex: "#3E8B3A") : UIColor().hexStringToUIColor(hex: "#403F2C")
        imgLogo.tintColor = isSelected ? UIColor().hexStringToUIColor(hex: "#3E8B3A") : UIColor().hexStringToUIColor(hex: "#403F2C")
        self.btnDisclosure.isSelected = isSelected
    }
    
    @IBAction func expandCollapseClicked(_ sender: UIButton) {
        guard let index = indexPath else {
            return
        }
        self.delegate?.expandCollapseClicked(indexPath: index)
    }
    
}
