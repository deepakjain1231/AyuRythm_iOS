//
//  RegisterTableViewCell.swift
//  HourOnEarth
//
//  Created by Apple on 01/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol RegisterDelegeate: class {
    func registerClicked()
}

class RegisterTableViewCell: UITableViewCell {

    weak var delegate: RegisterDelegeate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func registerClicked(_ sender: UIButton) {
        self.delegate?.registerClicked()
    }
}
