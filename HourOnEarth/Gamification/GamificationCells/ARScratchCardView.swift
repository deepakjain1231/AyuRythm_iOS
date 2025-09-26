//
//  ARScratchCardView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 01/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

// MARK: -
class ARAyuSeedScratchCardOfferView: DesignableView {
    @IBOutlet weak var seedsCountL: UILabel!
}

class ARDiscountScratchCardOfferView: UIView {
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var codeL: UILabel!
}

// MARK: -
protocol ARScratchCardViewDelegate: AnyObject {
    func scratchCardViewDidBeginScratch(view: ARScratchCardView)
    func scratchCardViewDidFinishScratch(view: ARScratchCardView)
}

class ARScratchCardView: PDDesignableXibView {
    
    @IBOutlet weak var scratchImageView: ScratchImageView!
    @IBOutlet weak var discountOfferView: ARDiscountScratchCardOfferView!
    @IBOutlet weak var ayuseedOfferView: ARAyuSeedScratchCardOfferView!
    
    weak var delegate: ARScratchCardViewDelegate?
    var isCardScratched = false
    var isCardScratchedDidBeginScratch = false
    
    override func initialSetUp() {
        super.initialSetUp()
        scratchImageView.delegate = self
//        layer.cornerRadius = 10
        layer.applySketchShadow(color: .gray, alpha: 0.4, x: 1, y: 1, blur: 4, spread: 0)
    }
    
    func configureCard(scratchCard: ARScratchCardModel?) {
        discountOfferView.isHidden = true
        ayuseedOfferView.isHidden = true
        discountOfferView.codeL.isHidden = true
        
        guard let scratchCard = scratchCard else {
            //no scratch card
            return
        }
        
        switch scratchCard.cardTypeValue {
        case .betterLuckNextTime:
            //Better Luck Next Time Card
            discountOfferView.isHidden = false
            discountOfferView.titleL.text = scratchCard.cardlabel
            
        case .ayuseeds:
            //AyuSeed Card
            ayuseedOfferView.isHidden = false
            ayuseedOfferView.seedsCountL.text = scratchCard.cardvalue
            
        default:
            //Other card
            discountOfferView.isHidden = false
            discountOfferView.titleL.text = scratchCard.cardlabel
            discountOfferView.codeL.text = scratchCard.cardcode
            discountOfferView.codeL.isHidden = false
        }
    }
}

extension ARScratchCardView: ScratchCardDelegate {
    func scratchCardEraseProgress(is progress: Double) {
        if !isCardScratchedDidBeginScratch {
            delegate?.scratchCardViewDidBeginScratch(view: self)
            isCardScratchedDidBeginScratch = true
        }
        
        if progress > 50 {
            if !isCardScratched {
                scratchImageView.fadeOut()
                delegate?.scratchCardViewDidFinishScratch(view: self)
                isCardScratched = true
            }
        }
    }
}
