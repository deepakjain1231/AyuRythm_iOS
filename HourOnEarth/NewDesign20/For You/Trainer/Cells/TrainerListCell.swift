//
//  TrainerListCell.swift
//  HourOnEarth
//
//  Created by Ayu on 15/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class TrainerListCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewYoga: UIImageView!
    @IBOutlet weak var lockView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgViewYoga.contentMode = .scaleAspectFill
        self.imgViewYoga.layer.cornerRadius = 12.0;
        self.imgViewYoga.clipsToBounds = true
        self.imgViewYoga.layer.masksToBounds = true
        
        
    }
    
    func configureCell(title: String, urlString: String) {
        self.lblTitle.text = title
        guard let url = URL(string: urlString) else {
            return
        }
        imgViewYoga.af.setImage(withURL: url)
    }
    
}
