//
//  PendingTestTableViewCell.swift
//  HourOnEarth
//
//  Created by Apple on 15/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol PendingTestDelegate: class {
    func completePendingTestDelegate(isSparshna: Bool)
}

class PendingTestTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    weak var delegate: PendingTestDelegate?
    var isSparshna = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureUI(value: String, isSparshna: Bool) {
        lblTitle.text = value
        self.isSparshna = isSparshna
    }
    
    @IBAction func completeClicked(_ sender: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.completePendingTestDelegate(isSparshna: isSparshna)
    }
    
}
