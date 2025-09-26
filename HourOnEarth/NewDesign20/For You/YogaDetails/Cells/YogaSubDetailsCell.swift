//
//  YogaSubDetailsCell.swift
//  HourOnEarth
//
//  Created by Apple on 19/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol YogaExpandCollapseDelagate: class {
    func expandCollapseClicked(indexPath: IndexPath)
}

class YogaSubDetailsCell: UITableViewCell {

    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnArrow: UIButton!

    weak var delegate: YogaExpandCollapseDelagate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String, subTitle: String, isSelected: Bool) {
        lblHeading.text = title
        lblDetail.text = subTitle
        lblDetail.text = isSelected ? subTitle : ""
        btnArrow.isSelected = isSelected
    }
    
    @IBAction func expandCollapseClicked(_ sender: UIButton) {
        guard let index = indexPath else {
            return
        }
        self.delegate?.expandCollapseClicked(indexPath: index)
    }
}
