//
//  HOETalaCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 22/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class TalaCell: UITableViewCell {

    
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblKaphaRange: UILabel!
    @IBOutlet weak var lblVataRange: UILabel!
    @IBOutlet weak var lblDescriptionFirst: UILabel!
    @IBOutlet weak var viewReqular: RoundView!
    @IBOutlet weak var viewIrregular: RoundView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(istrue : Bool, value : String)
       {
            let attributestring = NSAttributedString(string: istrue == true ? value : "")
                self.lblDescriptionFirst.attributedText = attributestring
            self.dropDownButton.setImage(UIImage(named: istrue == true ? "arrowCircularUP" : "arrowCircularDown"), for: .normal)

       }
    
}
