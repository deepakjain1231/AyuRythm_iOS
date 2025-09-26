//
//  SpO2Cell.swift
//  HourOnEarth
//
//  Created by Apple on 09/07/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class SpO2HomeCell: UITableViewCell {

    @IBOutlet weak var lblSpo2: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureUI(value: String) {
        lblSpo2.text = "\(value) %"
    }
    
    @IBAction func infoBtnPressed(sender: UIButton) {
        Utils.showSpO2DisclaimerAlert()
    }
}
