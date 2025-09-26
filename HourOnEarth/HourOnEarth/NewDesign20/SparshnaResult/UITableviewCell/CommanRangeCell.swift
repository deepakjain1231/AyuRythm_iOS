//
//  HOECommanRangeCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 22/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class CommanRangeCell: UITableViewCell {

    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblKaphaRange: UILabel!
    @IBOutlet weak var lblPittaRange: UILabel!
    @IBOutlet weak var lblVataRange: UILabel!
    @IBOutlet weak var lblDescriptionFirst: UILabel!
    @IBOutlet weak var lblTitalDescription: UILabel!
    
    @IBOutlet weak var viewBelow70: RoundView!
    @IBOutlet weak var view70_80: RoundView!
    @IBOutlet weak var viewAbove80: RoundView!
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureUI(istrue : Bool, value : String)
       {
            let attributestring = NSAttributedString(string: istrue == true ? value : "")
                self.lblDescriptionFirst.attributedText = attributestring
            self.dropDownButton.setImage(UIImage(named: istrue == true ? "arrowCircularUP" : "arrowCircularDown"), for: .normal)

       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
