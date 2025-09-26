//
//  SparshnaResultCell.swift
//  HourOnEarth
//
//  Created by hardik mulani on 18/03/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class SparshnaResultCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var imgBodyType: UIButton!
    
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblRange: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnExpandable(_ sender: Any) {
    }
    
}
