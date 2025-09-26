//
//  ARGroupMemberCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

protocol ARGroupMemberCellDelegate {
    func groupMemberCell(cell: ARGroupMemberCell, deleteMember member: MemberList)
    func groupMemberCell(cell: ARGroupMemberCell, acceptMember member: MemberList)
    func groupMemberCell(cell: ARGroupMemberCell, rejectMember member: MemberList)
}

extension ARGroupMemberCellDelegate {
    func groupMemberCell(cell: ARGroupMemberCell, deleteMember member: MemberList) {}
    func groupMemberCell(cell: ARGroupMemberCell, acceptMember member: MemberList) {}
    func groupMemberCell(cell: ARGroupMemberCell, rejectMember member: MemberList) {}
}

class ARGroupMemberCell: UITableViewCell {

    @IBOutlet weak var userProfileView: ARUserProfileView!
    @IBOutlet weak var acceptRejectBtnView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: ARGroupMemberCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileView.updateUI(for: .groupMember)
    }
    
    var member: MemberList? {
        didSet {
            guard let member = member else { return }
            userProfileView.usernameL.text = member.userName
            
            let str_UserProfile = member.userProfile?.userProfile ?? ""
            let str_UserBadge = member.userProfile?.userBadge ?? ""
            if str_UserBadge == "" {
                userProfileView.badgeView.isHidden = true
            }
            else {
                userProfileView.badgeView.isHidden = false
            }
            
            let defaultt_Avtarrr = appImage.default_avatar_pic
//            if member.userProfile?.userProfile == male {
//                defaultt_Avtarrr = appImage.default_male_avatar_pic
//            }
//            else {
//                defaultt_Avtarrr = appImage.default_female_avatar_pic
//            }
            
            

            userProfileView.profilePicIV.sd_setImage(with: URL.init(string: str_UserProfile), placeholderImage: defaultt_Avtarrr, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
            
            userProfileView.badgeIV.sd_setImage(with: URL.init(string: str_UserBadge), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
            
//            userProfileView.profilePicIV.af_setImage(withURLString: member.userProfile?.userProfile)
//            userProfileView.badgeIV.af_setImage(withURLString: member.userProfile?.userBadge)
            
            layoutIfNeeded()
        }
    }
    
    func updateUI(isShowDeleteBtn: Bool, isShowRequestBtns: Bool = false) {
        deleteBtn.isHidden = !isShowDeleteBtn
        acceptRejectBtnView.isHidden = !isShowRequestBtns
    }
    
    @IBAction func deleteBtnPressed(sender: UIButton) {
        guard let member = member else { return }
        delegate?.groupMemberCell(cell: self, deleteMember: member)
    }
    
    @IBAction func acceptBtnPressed(sender: UIButton) {
        guard let member = member else { return }
        delegate?.groupMemberCell(cell: self, acceptMember: member)
    }
    
    @IBAction func rejectBtnPressed(sender: UIButton) {
        guard let member = member else { return }
        delegate?.groupMemberCell(cell: self, rejectMember: member)
    }
    
}
