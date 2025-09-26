//
//  YogasanaPranayamTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/06/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class YogasanaPranayamTableCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_sub_title: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var btn_checkmark: UIButton!
    @IBOutlet weak var img_selection: UIImageView!
    @IBOutlet weak var constraint_view_Base_leading: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Base_trilling: NSLayoutConstraint!
    @IBOutlet weak var constraint_img_Base_Height: NSLayoutConstraint!
    
    var didTappedonLockView: ((UIButton)->Void)? = nil
    var didTappedoncheckmark: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgThumb.layer.cornerRadius = 12
        self.imgThumb.clipsToBounds = true
        self.imgThumb.layer.masksToBounds = true
    }
    
    func configureUI(yoga: Yoga) {
        self.lbl_title.text = yoga.name
        self.lbl_sub_title.text = yoga.english_name
        self.lbl_time.text = ""// "\(yoga.video_duration ?? "") min"
        self.lbl_title.isHidden = yoga.name == "" ? true : false
        self.lbl_sub_title.isHidden = yoga.english_name == "" ? true : false
        self.img_selection.image = (yoga.is_video_watch ?? "") == "no" ? UIImage.init(named: "icon_unseleccted") : UIImage.init(named: "icon_selected")
        self.btn_checkmark.isUserInteractionEnabled = (yoga.is_video_watch ?? "") == "no" ? true : false

        guard let urlString = yoga.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIMudra(mudra: Mudra) {
        self.lockView.isHidden = true
        self.lbl_title.text = mudra.name
        self.lbl_sub_title.text = mudra.english_name
        self.lbl_time.text = ""// "\(mudra.video_duration ?? "") min"
        self.lbl_title.isHidden = mudra.name == "" ? true : false
        self.lbl_sub_title.isHidden = mudra.english_name == "" ? true : false
        self.img_selection.image = (mudra.is_video_watch ?? "") == "no" ? UIImage.init(named: "icon_unseleccted") : UIImage.init(named: "icon_selected")
        self.btn_checkmark.isUserInteractionEnabled = (mudra.is_video_watch ?? "") == "no" ? true : false
        
        guard let urlString = mudra.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }

    func configureUIMeditation(meditation: Meditation) {
        self.lbl_title.text = meditation.name
        self.lbl_sub_title.text = meditation.english_name
        self.lbl_time.text = ""// "\(meditation.video_duration ?? "") min"
        self.lbl_title.isHidden = meditation.name == "" ? true : false
        self.lbl_sub_title.isHidden = meditation.english_name == "" ? true : false
        self.img_selection.image = (meditation.is_video_watch ?? "") == "no" ? UIImage.init(named: "icon_unseleccted") : UIImage.init(named: "icon_selected")
        self.btn_checkmark.isUserInteractionEnabled = (meditation.is_video_watch ?? "") == "no" ? true : false
        
        guard let urlString = meditation.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIPranayama(Pranayama: Pranayama) {
        self.lbl_title.text = Pranayama.name
        self.lbl_sub_title.text = Pranayama.english_name
        self.lbl_time.text = ""// "\(Pranayama.video_duration ?? "") min"
        self.lbl_title.isHidden = Pranayama.name == "" ? true : false
        self.lbl_sub_title.isHidden = Pranayama.english_name == "" ? true : false
        self.img_selection.image = (Pranayama.is_video_watch ?? "") == "no" ? UIImage.init(named: "icon_unseleccted") : UIImage.init(named: "icon_selected")
        self.btn_checkmark.isUserInteractionEnabled = (Pranayama.is_video_watch ?? "") == "no" ? true : false
        
        guard let urlString = Pranayama.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIKriya(kriya: Kriya) {
        self.lockView.isHidden = true
        self.lbl_title.text = kriya.name
        self.lbl_sub_title.text = kriya.english_name
        self.lbl_time.text = ""// "\(kriya.video_duration ?? "") min"
        self.lbl_title.isHidden = kriya.name == "" ? true : false
        self.lbl_sub_title.isHidden = kriya.english_name == "" ? true : false
        self.img_selection.image = (kriya.is_video_watch ?? "") == "no" ? UIImage.init(named: "icon_unseleccted") : UIImage.init(named: "icon_selected")
        self.btn_checkmark.isUserInteractionEnabled = (kriya.is_video_watch ?? "") == "no" ? true : false
        
        guard let urlString = kriya.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    
    @IBAction func lockClicked(_ sender: UIButton) {
        if self.didTappedonLockView != nil {
            self.didTappedonLockView!(sender)
        }
    }
    
    @IBAction func btn_checkmark_Action(_ sender: UIButton) {
        if self.didTappedoncheckmark != nil {
            self.didTappedoncheckmark!(sender)
        }
    }

}
