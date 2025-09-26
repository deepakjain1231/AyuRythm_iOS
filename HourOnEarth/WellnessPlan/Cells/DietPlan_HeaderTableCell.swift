//
//  DietPlan_HeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 15/01/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit

class DietPlan_HeaderTableCell: UITableViewCell {

    @IBOutlet weak var img_header: UIImageView!
    @IBOutlet weak var view_DietHeader: UIView!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var stack_view: UIStackView!
    //@IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_infoText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //lbl_Title.text = "Diet Plan".localized()
        self.lbl_subTitle.text = "Your personalized diet schedule for a healthier and happier life.".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

