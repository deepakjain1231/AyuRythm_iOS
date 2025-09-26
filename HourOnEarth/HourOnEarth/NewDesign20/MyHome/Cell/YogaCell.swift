//
//  YogaCell.swift
//  HourOnEarth
//
//  Created by hardik mulani on 04/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class YogaCell: UICollectionViewCell {
    
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lblEngName: UILabel!
    @IBOutlet weak var lblHindiName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        // Initialization code
    }

    func configureUI(yoga: Yoga) {
        lblEngName.text = yoga.english_name
        lblHindiName.text = yoga.name
        guard let urlString = yoga.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
}
