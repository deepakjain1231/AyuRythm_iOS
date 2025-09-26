//
//  ContestDetailCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 26/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ContestDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var chanceToWinL: UILabel!
    @IBOutlet weak var detailL: UILabel!
    @IBOutlet weak var typeL: UILabel!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var myRankL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        typeL.roundCorners(corners: [.bottomLeft], radius: 14)
        detailL.numberOfLines = 12
    }
    
    var data: ARContestModel? {
        didSet {
            guard let data = data else { return }
            
            chanceToWinL.text = data.isWinnerDeclared ? "Check winners".localized() : "Chance to win".localized()
            chanceToWinL.textColor = data.isWinnerDeclared ? UIColor.app.gamificationOrangeDark : .black
            detailL.text = data.descriptionField
            nameL.text = data.name
            let rank = data.rank.isEmpty ? "---" : data.rank!
            myRankL.text = "My rank: ".localized() + rank
            typeL.isHidden = !data.isProContest
        }
    }

}
