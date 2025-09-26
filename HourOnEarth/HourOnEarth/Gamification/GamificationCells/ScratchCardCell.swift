//
//  ScratchCardCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 26/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ScratchCardCell: UICollectionViewCell {
    
    @IBOutlet weak var scratchLayerIV: UIImageView!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var withoutScratchStatusL: UILabel!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var otherCardStackView: UIStackView!
    @IBOutlet weak var ayuseedCardStackView: UIStackView!
    @IBOutlet weak var ayuseedCountL: UILabel!
    
    var grayScaleLayer: CALayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var scratchCard: ARScratchCardModel? {
        didSet {
            guard let scratchCard = scratchCard else { return }
            
            titleL.text = scratchCard.cardlabel
            subtitleL.text = scratchCard.cardcode
            scratchLayerIV.isHidden = scratchCard.isClaimed
            statusL.text = scratchCard.expiresInString
            statusL.isHidden = false
            withoutScratchStatusL.isHidden = true
            
            if scratchCard.isAyuseedRewardCard {
                ayuseedCountL.text = scratchCard.cardvalue
                ayuseedCardStackView.isHidden = false
                otherCardStackView.isHidden = true
            } else {
                ayuseedCardStackView.isHidden = true
                otherCardStackView.isHidden = false
            }
            
            if scratchCard.isExpired {
                if grayScaleLayer == nil {
                    grayScaleLayer = CALayer.getGrayScaleLayer(frame: bounds)
                    mainView.layer.addSublayer(grayScaleLayer!)
                }
                if scratchCard.isClaimed {
                    statusL.text = "Expired"
                } else {
                    statusL.isHidden = true
                    withoutScratchStatusL.isHidden = false
                    var text = NSAttributedString(string: "Expired", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium)])
                    text += NSAttributedString(string: "\n" + "On".localized() + " " + scratchCard.cardExpiryDate.dateStringEnglishLocale(format: "dd MMM yyyy"))
                    withoutScratchStatusL.attributedText = text
                }
            } else {
                grayScaleLayer?.removeFromSuperlayer()
                grayScaleLayer = nil
            }
            
            if scratchCard.isAyuseedRewardCard && scratchCard.isClaimed {
                statusL.isHidden = true
            }
        }
    }
}

extension CALayer {
    static func getGrayScaleLayer(frame: CGRect) -> CALayer {
        let grayLayer = CALayer()
        grayLayer.frame = frame
        grayLayer.compositingFilter = "colorBlendMode"
        grayLayer.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        return grayLayer
    }
}
