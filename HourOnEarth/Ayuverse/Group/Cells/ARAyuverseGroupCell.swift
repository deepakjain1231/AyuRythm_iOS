//
//  ARAyuverseGroupCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

protocol AyuverseGroupCellDelegate{
    func ayuverseGroupCell(cell: ARAyuverseGroupCell, didPressedJoinBtn btn: UIButton, data: GroupData?)
    func ayuverseGroupCell(cell: ARAyuverseGroupCell, didPressedRequestToJoinBtn btn: UIButton, data: GroupData?)
}

class ARAyuverseGroupCell: UITableViewCell {
    
    @IBOutlet weak var groupType: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var groupCatLbl: PaddingLabel!
    @IBOutlet weak var groupIv: UIImageView!
    @IBOutlet weak var memberCountLbl: PaddingLabel!
    @IBOutlet weak var memberLbl: UILabel!
    @IBOutlet weak var postCountLbl: PaddingLabel!
    @IBOutlet weak var postLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var requestToJoinBtn: UIButton!
    @IBOutlet weak var view_img_group_BG: UIView!
    @IBOutlet weak var view_cat_BG: UIView!
    @IBOutlet weak var lbl_friend_rrequest: UILabel!
    @IBOutlet weak var view_friend_rrequest_BG: UIView!
    
    var delegate: AyuverseGroupCellDelegate?
    //var section = 1
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.groupIv.layer.cornerRadius = 8
        self.groupIv.layer.masksToBounds = true
        self.view_img_group_BG.layer.cornerRadius = 8
        self.view_img_group_BG.layer.masksToBounds = true
        self.postLbl.text = "New posts".localized()
        self.memberLbl.text = "Members".localized()
        self.joinBtn.setTitle("Join".localized(), for: .normal)
        self.requestToJoinBtn.setTitle("Request to join".localized(), for: .normal)
    }
    
    var group: GroupData? {
        didSet {
            guard let group = group else { return }
            if group.groupType == "1"{
                groupType.text = "Private".localized()
            }else{
                groupType.text = "Public".localized()
            }
            var strgroupName = group.groupLabel?.trimed().base64Decoded()
            if strgroupName == nil {
                strgroupName = group.groupLabel
            }
            groupNameLbl.text = strgroupName
            //            groupIv.af_setImage(withURLString: group.groupImage)
            groupCatLbl.text = group.groupCategories
            self.view_cat_BG.isHidden = group.groupCategories == "" ? true : false
            
            memberCountLbl.text = group.groupMembers
            postCountLbl.text = group.newPost
            
            let str_img_URL = group.groupImage ?? ""
            if str_img_URL == "" {
                groupIv.image = appImage.group_default_pic
            }
            else {
                groupIv.sd_setImage(with: URL.init(string: str_img_URL), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
            }
            
        }
    }
    var myGroup: MyGroupData? {
        didSet {
            guard let group = myGroup else { return }
            if group.groupType == "1"{
                groupType.text = "Private".localized()
            }else{
                groupType.text = "Public".localized()
            }
            
            var strgroupName = group.groupLabel?.trimed().base64Decoded()
            if strgroupName == nil {
                strgroupName = group.groupLabel
            }
            groupNameLbl.text = strgroupName
            
//            groupIv.af_setImage(withURLString: group.groupImage)
            groupCatLbl.text = group.groupCategories
            self.view_cat_BG.isHidden = group.groupCategories == "" ? true : false
            memberCountLbl.text = group.groupMembers
            postCountLbl.text = group.newPost
            
            let waitingUsersCount = group.waitingUsersCount ?? ""
            if waitingUsersCount == "" || waitingUsersCount == "0" {
                self.view_friend_rrequest_BG.isHidden = true
            }
            else if waitingUsersCount == "1" {
                self.view_friend_rrequest_BG.isHidden = false
                lbl_friend_rrequest.text = "\(waitingUsersCount) " + "Request".localized()
            }
            else {
                self.view_friend_rrequest_BG.isHidden = false
                lbl_friend_rrequest.text = "\(waitingUsersCount) " + "Requests".localized()
            }

            var str_img_URL = group.groupImage ?? ""
            if str_img_URL == "" {
                groupIv.image = appImage.group_default_pic
            }
            else {
                if !(str_img_URL.contains("https")) {
                    str_img_URL = image_BaseURL + str_img_URL
                }

                groupIv.sd_setImage(with: URL.init(string: str_img_URL), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
            }

            self.view_friend_rrequest_BG.roundCornerss([UIRectCorner.topRight, .bottomLeft], radius: 15)
        }
    }
    @IBAction func joinAct(_ sender: Any) {
        delegate?.ayuverseGroupCell(cell: self, didPressedJoinBtn: sender as! UIButton, data: group)
    }
    @IBAction func requestToJoinAct(_ sender: Any) {
        delegate?.ayuverseGroupCell(cell: self, didPressedRequestToJoinBtn: sender as! UIButton, data: group)
    }
}
