//
//  ARFeedCommentCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 05/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage
import ActiveLabel

protocol ARFeedCommentCellDelegate {
    func commentCell(cell: ARFeedCommentCell, didPressLikeBtn data: Comment?, index: Int?)
    func commentCell(cell: ARFeedCommentCell, didPressReplyBtn data: Comment?)
    func commentCell(cell: ARFeedCommentCell, didPressViewReplyBtn data: Comment?)
    func commentCell(cell: ARFeedCommentCell, didPressEditDeleteBtn data: Comment?, index: Int?)
}

class ARFeedCommentCell: UITableViewCell {

    @IBOutlet weak var profilePicIV: UIImageView!
    @IBOutlet weak var commentL: ActiveLabel!
    @IBOutlet weak var commentBGView: UIView!
    @IBOutlet weak var viewReplyBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var btn_Option: UIButton!
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lbl_Edited: UILabel!
    @IBOutlet weak var badgeIV: UIImageView!
    var delegate: ARFeedCommentCellDelegate?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.lbl_Edited.text = ""
        self.replyBtn.setTitle("Reply".localized(), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicIV.makeItRounded()
    }
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            var strCommentMsg = comment.message?.trimed().base64Decoded()
            if strCommentMsg == nil {
                strCommentMsg = comment.message
            }

            let arr_GetURL = Utils.getLinkfromString(str_msggggg: strCommentMsg ?? "")
            if arr_GetURL.count != 0 {
                for strGetURL in arr_GetURL {
                    if strGetURL.contains("http") {
                    }
                    else {
                        strCommentMsg = strCommentMsg?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                    }
                }
            }
                    
            commentL.customize { label in
                label.text = strCommentMsg ?? ""
                label.textColor = UIColor.black
                label.hashtagColor = UIColor.black
                label.URLColor = kAppBlueColor
                commentL.numberOfLines = 0

                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString) }
            }
            
           
            profilePicIV.sd_setImage(with: URL(string: comment.userProfile?.userProfile ?? ""), placeholderImage: UIImage(named: "default-avatar"))
            if comment.userProfile?.userBadge != ""{
                badgeIV.af_setImage(withURLString: comment.userProfile?.userBadge)
                badgeView.isHidden = false
            }else{
                badgeView.isHidden = true
            }
            nameLbl.text = comment.userProfile?.userName
            let strCreatedTime = comment.createdAt ?? ""
            let strUpdatedTime = comment.updatedAt ?? ""
            lbl_Edited.text = strUpdatedTime == "" ? "" : strCreatedTime == strUpdatedTime ? "" : comment.userProfile?.userID == kSharedAppDelegate.userId ? "(Edited)".localized() : ""
            
            
            if #available(iOS 13.0, *) {
                timeLbl.text = comment.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
            } else {
                // Fallback on earlier versions
            }
            
            let int_LikeCount = comment.likes ?? 0
            if int_LikeCount == 0 {
                likeBtn.setTitle("", for: .normal)
            }
            else {
                likeBtn.setTitle(String(comment.likes ?? 0), for: .normal)
            }
            
            if comment.commentarray?.count ?? 0 > 0{
                viewReplyBtn.isHidden = false
                let strreplyy = String(format: "View_reply".localized(), String(comment.commentarray?.count ?? 0))
                viewReplyBtn.setTitle(strreplyy, for: .normal)
            }else{
                viewReplyBtn.isHidden = true
            }
           
            if comment.mylike == 0{
                likeBtn.setImage(UIImage(named: "like"), for: .normal)
            }else{
                likeBtn.setImage(UIImage(named: "like-selected"), for: .normal)
            }
            
            if comment.userProfile?.userID == kSharedAppDelegate.userId {
                self.btn_Option.isHidden = false
            }
            else {
                self.btn_Option.isHidden = true
            }

            layoutIfNeeded()
            
        }
    }
    var index: Int? {
        didSet {
            guard let index = index else { return }
        }
    }
    @IBAction func viewReplyBtnPressed(sender: UIButton) {
        delegate?.commentCell(cell: self, didPressViewReplyBtn: comment)
    }
    
    @IBAction func replyBtnPressed(sender: UIButton) {
        delegate?.commentCell(cell: self, didPressReplyBtn: comment)
    }
    
    @IBAction func likeBtnPressed(sender: UIButton) {
        delegate?.commentCell(cell: self, didPressLikeBtn: comment,index: index )
    }
    
    @IBAction func btn_Option(sender: UIButton) {
        delegate?.commentCell(cell: self, didPressEditDeleteBtn: comment,index: index)
    }
    
    
    
    //MARK:- tappedOnLabel
    func tappedonLabel(_ title: String, message: String) {
        
        if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
    }
     
}
