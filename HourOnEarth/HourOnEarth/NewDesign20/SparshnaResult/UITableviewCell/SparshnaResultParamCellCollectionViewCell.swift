//
//  SparshnaResultParamCellCollectionViewCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class SparshnaResultParamCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var kpvDisplayValueL: UILabel!
    @IBOutlet weak var paramIconIV: UIImageView!
    @IBOutlet weak var kpvIconIV: UIImageView!
    @IBOutlet weak var infoBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var paramData : SparshnaResultParamModel? {
        didSet {
            guard let paramData = paramData else { return }
            
            titleL.text = paramData.title
            subtitleL.text = paramData.subtitle
            kpvDisplayValueL.text = paramData.paramDisplayValue
            paramIconIV.image = paramData.paramIcon
            
            kpvIconIV.isHidden = false
            switch paramData.paramKPVValue {
            case .Kapha:
                kpvIconIV.image = #imageLiteral(resourceName: "Kaphaa")
            case .Pitta:
                kpvIconIV.image = #imageLiteral(resourceName: "PittaN")
            case .Vata:
                kpvIconIV.image = #imageLiteral(resourceName: "VataN")
            default:
                kpvIconIV.isHidden = true
            }
            
            /*if let img = paramData.KPVIcon {
                kpvIconIV.image = img
                kpvIconIV.isHidden = false
            } else {
                kpvIconIV.isHidden = true
            }*/
        }
    }
}
