//
//  LastAssesmentTableViewCell.swift
//  HourOnEarth
//
//  Created by Apple on 15/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class LastAssesmentTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLastAssesment: UILabel!
    @IBOutlet weak var lastAssesmentHighLightView: UIView!
    
    weak var delegate: PendingTestDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureUI(value: String) {
        lblLastAssesment.text = value
    }
    
    @IBAction func fingerPrintClicked(_ sender: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.completePendingTestDelegate(isSparshna: true)
    }
}
