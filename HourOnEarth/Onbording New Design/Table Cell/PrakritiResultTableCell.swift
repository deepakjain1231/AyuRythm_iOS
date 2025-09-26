//
//  PrakritiResultTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PrakritiResultTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var img_combine: UIImageView!
    @IBOutlet weak var view_tridosic: UIView!
    @IBOutlet weak var view_kpv: UIView!
    @IBOutlet weak var lbl_knowMore: UILabel!
    @IBOutlet weak var lbl_continue: UILabel!
    @IBOutlet weak var btn_continue: UIControl!
    
    @IBOutlet weak var img_kpv: UIImageView!
    @IBOutlet weak var img_tridosic1: UIImageView!
    @IBOutlet weak var img_tridosic2: UIImageView!
    @IBOutlet weak var img_tridosic3: UIImageView!
    
    @IBOutlet weak var constraint_view_tridosic_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_kpv_Height: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_btn_Continue_TOP: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_Continue_Height: NSLayoutConstraint!
    
    var didTappedKnowMoreButton: ((UIControl)->Void)? = nil
    var didTappedContinue: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_continue.text = "Continue".localized()
        self.lbl_knowMore.text = "KNOW MORE".localized().capitalized
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupDetail() {
        let currentPraktitiStatus = Utils.getYourCurrentPrakritiStatus()
        
        switch currentPraktitiStatus {
        case .TRIDOSHIC:
            self.view_kpv.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 275
            self.img_tridosic1.image = UIImage(named: "vataInfoCombined")
            self.img_tridosic2.image = UIImage(named: "pittaInfoCombined")
            self.img_tridosic3.image = UIImage(named: "kaphaInfoCombined")
            
        case .KAPHA_VATA:
            self.view_kpv.isHidden = true
            self.img_tridosic3.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 150
            self.img_tridosic1.image = UIImage(named: "kaphaInfoCombined")
            self.img_tridosic2.image = UIImage(named: "vataInfoCombined")

        case .PITTA_KAPHA:
            self.view_kpv.isHidden = true
            self.img_tridosic3.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 150
            self.img_tridosic1.image = UIImage(named: "pittaInfoCombined")
            self.img_tridosic2.image = UIImage(named: "kaphaInfoCombined")

        case .VATA_PITTA:
            self.view_kpv.isHidden = true
            self.img_tridosic3.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 150
            self.img_tridosic1.image = UIImage(named: "vataInfoCombined")
            self.img_tridosic2.image = UIImage(named: "pittaInfoCombined")

        case .VATA :
            self.view_kpv.isHidden = false
            self.view_tridosic.isHidden = true
            self.constraint_view_kpv_Height.constant = 135
            self.constraint_view_tridosic_Height.constant = 0
            self.img_kpv.image = UIImage(named: "vataInfoCombined")
            self.lbl_subTitle.text = "Spontaneous\nEnthusiastic\nCreative\nFlexible\nEnergetic".localized()

        case .PITTA:
            self.view_kpv.isHidden = false
            self.view_tridosic.isHidden = true
            self.constraint_view_kpv_Height.constant = 135
            self.constraint_view_tridosic_Height.constant = 0
            self.img_kpv.image = UIImage(named: "pittaInfoCombined")
            self.lbl_subTitle.text = "Intellectual\nFocused\nPrecise\nDirect\nPassionate".localized()

        case .KAPHA:
            self.view_kpv.isHidden = false
            self.view_tridosic.isHidden = true
            self.constraint_view_kpv_Height.constant = 135
            self.constraint_view_tridosic_Height.constant = 0
            self.img_kpv.image = UIImage(named: "kaphaInfoCombined")
            self.lbl_subTitle.text = "Calm\nThoughtful\nLoving\nEnjoys life\nComfortable\nwith routine".localized()
            
        case .KAPHA_PITTA:
            self.view_kpv.isHidden = true
            self.img_tridosic3.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 150
            self.img_tridosic2.image = UIImage(named: "pittaInfoCombined")
            self.img_tridosic1.image = UIImage(named: "kaphaInfoCombined")
            
        case .PITTA_VATA:
            self.view_kpv.isHidden = true
            self.img_tridosic3.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 150
            self.img_tridosic2.image = UIImage(named: "vataInfoCombined")
            self.img_tridosic1.image = UIImage(named: "pittaInfoCombined")
            
        case .VATA_KAPHA:
            self.view_kpv.isHidden = true
            self.img_tridosic3.isHidden = true
            self.view_tridosic.isHidden = false
            self.constraint_view_kpv_Height.constant = 0
            self.constraint_view_tridosic_Height.constant = 150
            self.img_tridosic2.image = UIImage(named: "kaphaInfoCombined")
            self.img_tridosic1.image = UIImage(named: "vataInfoCombined")
        }
    }
    
    @IBAction func btn_knowMore(_ sender: UIControl) {
        self.didTappedKnowMoreButton?(sender)
    }
    
    @IBAction func btn_continue(_ sender: UIControl) {
        self.didTappedContinue?(sender)
    }
}
