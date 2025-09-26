//
//  RemediesNewCell.swift
//  HourOnEarth
//
//  Created by hardik mulani on 18/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class AyuSeedsEarnCell: UICollectionViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var ayuSeedEarn: AyuSeedEarn? {
        didSet {
            guard let ayuSeedEarn = ayuSeedEarn else { return }
            lblName.text = ayuSeedEarn.title
            imgView.image = UIImage(named: ayuSeedEarn.image)
        }
    }
    
    var ayuSeedRedeem: AyuSeedRedeem? {
        didSet {
            guard let ayuSeedRedeem = ayuSeedRedeem else { return }
            lblName.text = ayuSeedRedeem.title
            imgView.image = UIImage(named: ayuSeedRedeem.image)
        }
    }
}
