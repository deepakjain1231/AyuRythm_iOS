//
//  ContestWinnerCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/03/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ContestWinnerCell: UITableViewCell {
    
    @IBOutlet weak var rankL: UILabel!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var prizeL: UILabel!
    @IBOutlet weak var proTagL: UILabel!
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var levelIV: UIImageView!
    @IBOutlet weak var levelBGIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageIV.makeItRounded()
        imageIV.layer.borderWidth = 2.0
        levelIV.makeItRounded()
    }
    
    var data: ARContestWinnerModel? {
        didSet {
            guard let data = data else { return }
            
            rankL.text = data.rankId
            nameL.text = data.isMySelf ? "Me" : data.name
            prizeL.text = data.prizeWon
            proTagL.isHidden = (data.isSubscribe == 0)
            proTagL.cornerRadiuss = 4
            proTagL.clipsToBounds = true
            
            if let imageURL = data.imageURL {
                imageIV.af.setImage(withURL: imageURL)
            }
            imageIV.layer.borderColor = (data.isMySelf ? UIColor.app.gamificationOrangeDark : UIColor.clear).cgColor
            
            levelIV.isHidden = data.levelImage.isEmpty
            levelBGIV.isHidden = data.levelImage.isEmpty
            levelIV.af_setImage(withURLString: data.levelImage)
        }
    }
}
