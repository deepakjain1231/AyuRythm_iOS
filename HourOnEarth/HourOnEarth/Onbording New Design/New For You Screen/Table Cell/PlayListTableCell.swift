//
//  PlayListTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 24/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PlayListTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_sub_title: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var lbl_unlock_ayuseed: UILabel!
    @IBOutlet weak var view_unlock_ayuseed: UIView!
    @IBOutlet weak var lbl_unlock_ayuseed_title: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    var didTappedonLockView: ((UIButton)->Void)? = nil
    weak var delegate: PlayListDelegate?
    var indexPath: IndexPath?
    var isFromPlayListDetailScreen = false
    
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
        self.lbl_time.text = (yoga.video_duration ?? "") == "" ? "" : "\(yoga.video_duration ?? "") min"
        self.lbl_title.isHidden = yoga.name == "" ? true : false
        self.lbl_sub_title.isHidden = yoga.english_name == "" ? true : false
        self.lbl_unlock_ayuseed.text = "\(yoga.access_point)"
        self.lbl_unlock_ayuseed_title.text = yoga.redeemed ? "" : "Unlock with"
        
        guard let urlString = yoga.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIMudra(mudra: Mudra) {
        self.lockView.isHidden = true
        self.lbl_title.text = mudra.name
        self.lbl_sub_title.text = mudra.english_name
        self.lbl_time.text = (mudra.video_duration ?? "") == "" ? "" : "\(mudra.video_duration ?? "") min"
        self.lbl_title.isHidden = mudra.name == "" ? true : false
        self.lbl_sub_title.isHidden = mudra.english_name == "" ? true : false
        self.lbl_unlock_ayuseed.text = "\(mudra.access_point)"
        self.lbl_unlock_ayuseed_title.text = mudra.redeemed ? "" : "Unlock with"
        
        guard let urlString = mudra.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIMeditation(meditation: Meditation) {
        self.lbl_title.text = meditation.name
        self.lbl_sub_title.text = meditation.english_name
        self.lbl_time.text = (meditation.video_duration ?? "") == "" ? "" :  "\(meditation.video_duration ?? "") min"
        self.lbl_title.isHidden = meditation.name == "" ? true : false
        self.lbl_sub_title.isHidden = meditation.english_name == "" ? true : false
        self.lbl_unlock_ayuseed.text = "\(meditation.access_point)"
        self.lbl_unlock_ayuseed_title.text = meditation.redeemed ? "" : "Unlock with"
        
        guard let urlString = meditation.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIPranayama(pranayama: Pranayama) {
        self.lbl_title.text = pranayama.name
        self.lbl_sub_title.text = pranayama.english_name
        self.lbl_time.text = (pranayama.video_duration ?? "") == "" ? "" : "\(pranayama.video_duration ?? "") min"
        self.lbl_title.isHidden = pranayama.name == "" ? true : false
        self.lbl_sub_title.isHidden = pranayama.english_name == "" ? true : false
        self.lbl_unlock_ayuseed.text = "\(pranayama.access_point)"
        self.lbl_unlock_ayuseed_title.text = pranayama.redeemed ? "" : "Unlock with"
        
        guard let urlString = pranayama.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUIKriya(kriya: Kriya) {
        self.lockView.isHidden = true
        self.lbl_title.text = kriya.name
        self.lbl_sub_title.text = kriya.english_name
        self.lbl_time.text = (kriya.video_duration ?? "") == "" ? "" : "\(kriya.video_duration ?? "") min"
        self.lbl_title.isHidden = kriya.name == "" ? true : false
        self.lbl_sub_title.isHidden = kriya.english_name == "" ? true : false
        self.lbl_unlock_ayuseed.text = "\(kriya.access_point)"
        self.lbl_unlock_ayuseed_title.text = kriya.redeemed ? "" : "Unlock with"
        
        guard let urlString = kriya.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    
    @IBAction func lockClicked(_ sender: UIButton) {
        //if self.didTappedonLockView != nil {
            //self.didTappedonLockView?(sender)
        //}
        
        if let indexPath = self.indexPath {
            if indexPath.section == 0 && !isFromPlayListDetailScreen {
                delegate?.lockMyListClicked(index: sender.tag)
            } else {
                delegate?.lockBenfitsClikced(indexPath: indexPath)
            }
        }
    }
    
}


extension PlayListTableCell {
    func toggleLockView(isLock: Bool) {
        lockView.isHidden = !isLock
        view_unlock_ayuseed.isHidden = !isLock
    }
}
