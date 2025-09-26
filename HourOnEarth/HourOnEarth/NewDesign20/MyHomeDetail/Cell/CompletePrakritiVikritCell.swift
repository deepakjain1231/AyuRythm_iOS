//
//  CompletePrakritiVikritCell.swift
//  HourOnEarth
//
//  Created by Apple on 02/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol CompletePrashnaSparshna: class {
    func completePrashnaOrSparshnaClicked(isPrashna: Bool)
}

class CompletePrakritiVikritCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var roundedView: UIView!
    
    weak var delegate: CompletePrashnaSparshna?
    var isPrashna: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String, btnTitle: String, isPrashna: Bool) {
        lblTitle.text = title
        btnComplete.setTitle(btnTitle, for: .normal)
        self.isPrashna = isPrashna
    }
    
    @IBAction func completeClicked(_ sender: Any) {
        self.delegate?.completePrashnaOrSparshnaClicked(isPrashna: self.isPrashna)
    }
}
