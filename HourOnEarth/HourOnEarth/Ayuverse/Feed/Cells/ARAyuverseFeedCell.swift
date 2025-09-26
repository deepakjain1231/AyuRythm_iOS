//
//  ARAyuverseFeedCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 05/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import DropDown
import ActiveLabel

protocol ARAyuverseFeedCellDelegate {
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didSelectMoreOption data: Feed?)
    func ayuverseFeedCell(cell: ARAyuverseFeedMediaCell, didSelectMoreOption data: Feed?)
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedLikeBtn btn: UIButton, data: Feed?, index: Int?)
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedCommentBtn btn: UIButton, data: Feed?)
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedShareBtn btn: UIButton, data: Feed?, index: Int?)
    func ayuverseFeedCell(cell: ARAyuverseFeedCell,didPressedPostBtn btn: UIButton, data:Feed?)
    func ayuverseFeedCell(cell: ARAyuverseFeedMediaCell,didPressedPostBtn btn: UIButton, data:Feed?)
}

class ARAyuverseFeedCell: UITableViewCell {
    @IBOutlet weak var userIv: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    
    @IBOutlet weak var userProfileView: ARUserProfileView!
    @IBOutlet weak var commentTV: UITextField!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var textL: ActiveLabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    @IBOutlet weak var commentStView: UIStackView!
    
    var delegate: ARAyuverseFeedCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.postBtn?.setTitle("Post".localized(), for: .normal)
        self.commentTV?.placeholder = "Write a comment".localized()
        
        //=====================================================================//
        //=====================================================================//
        var defaultPic = appImage.default_avatar_pic
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any], let gender = empData["gender"] as? String {
            if gender.lowercased() == "male" {
                defaultPic = appImage.default_male_avatar_pic
            }
            if gender.lowercased() == "female" {
                defaultPic = appImage.default_female_avatar_pic
            }
        }

        if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
            if userIv != nil {
                userIv.sd_setImage(with: url, placeholderImage: defaultPic)
            }
        }
        else {
            if userIv != nil {
                userIv.image = defaultPic
            }
        }
        //**********************************************************************//
        //**********************************************************************//
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func setupData(_ dic_Feed: Feed) {
        self.userProfileView.profilePicIV.sd_setImage(with: URL(string: dic_Feed.userProfile?.userProfile ?? ""), placeholderImage: UIImage(named: "default-avatar"))
        if dic_Feed.userProfile?.userBadge != ""{
            self.userProfileView.badgeIV.af_setImage(withURLString: dic_Feed.userProfile?.userBadge)
            self.userProfileView.badgeView.isHidden = false
        }else{
            self.userProfileView.badgeView.isHidden = true
        }
        self.userProfileView.usernameL.text = dic_Feed.userProfile?.userName
        
        let strCreatedTime = dic_Feed.createdAt ?? ""
        let strUpdatedTime = dic_Feed.updatedAt ?? ""
        self.userProfileView.lbl_Edited.text = strUpdatedTime == "" ? "" : strCreatedTime == strUpdatedTime ? "" : dic_Feed.userProfile?.userID == kSharedAppDelegate.userId ? "(Edited)".localized() : ""
        
        if #available(iOS 13.0, *) {
            self.userProfileView.timeL.text = dic_Feed.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
        } else {
            // Fallback on earlier versions
        }
        
        let int_LikeCount = dic_Feed.likes ?? 0
        if int_LikeCount == 0 {
            self.likeBtn.setTitle("", for: .normal)
        }
        else {
            self.likeBtn.setTitle(String(dic_Feed.likes ?? 0), for: .normal)
        }
        
        let int_CommentCount = dic_Feed.comments ?? 0
        if int_CommentCount == 0 {
            self.commentBtn.setTitle("", for: .normal)
        }
        else {
            self.commentBtn.setTitle(String(dic_Feed.comments ?? 0), for: .normal)
        }
        
        let int_ShareCount = dic_Feed.shares ?? 0
        if int_ShareCount == 0 {
            self.shareBtn.setTitle("", for: .normal)
        }
        else {
            self.shareBtn.setTitle(String(dic_Feed.shares ?? 0), for: .normal)
        }
        
        
        if dic_Feed.mylikes == 0{
            self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
        }else{
            self.likeBtn.setImage(UIImage(named: "like-selected"), for: .normal)
        }
        self.userIv?.layer.cornerRadius = 14
        self.postBtn.titleLabel?.font = self.postBtn.titleLabel?.font.withSize(12)
        self.userIv.clipsToBounds  = true
    }
    
    
    
    
    
    
    
    var feed: Feed? {
        didSet {
            guard let feed = feed else { return }
            
        }
    }
    var index: Int? {
        didSet {
            guard let index = index else { return }
        }
    }
    
    
    @IBAction func moreOptionBtnPressed(sender: UIButton) {
        delegate?.ayuverseFeedCell(cell: self, didSelectMoreOption: feed)
    }
    
    @IBAction func likeBtnPressed(sender: UIButton) {
        delegate?.ayuverseFeedCell(cell: self, didPressedLikeBtn: sender, data: feed, index: index)
    }
    
    @IBAction func postBtnAct(_ sender: Any) {
        print("post")
        delegate?.ayuverseFeedCell(cell: self, didPressedPostBtn: sender as! UIButton, data: feed)
    }
    @IBAction func commentBtnPressed(sender: UIButton) {
        delegate?.ayuverseFeedCell(cell: self, didPressedCommentBtn: sender, data: feed)
    }
    
    @IBAction func shareBtnPressed(sender: UIButton) {
        delegate?.ayuverseFeedCell(cell: self, didPressedShareBtn: sender, data: feed, index: index)
    }
}
