//
//  ARFeedCommentReplyCell.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 23/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ActiveLabel

protocol ARFeedCommentReplyCellDelegate {
    func commentCell(cell: ARFeedCommentReplyCell, didPressOptionBtn data: Commentarray?, index: Int?)
}

class ARFeedCommentReplyCell:UITableViewCell {
    
    @IBOutlet weak var profilePicIV: UIImageView!
    @IBOutlet weak var commentL: ActiveLabel!
    @IBOutlet weak var commentBGView: UIView!
    @IBOutlet weak var btn_Option: UIButton!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lbl_Edited: UILabel!
    @IBOutlet weak var badgeIV: UIImageView!
    var delegate: ARFeedCommentReplyCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicIV.makeItRounded()
    }
    
    var comment: Commentarray? {
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
            if comment.userProfile?.userBadge != "" {
                badgeIV.af_setImage(withURLString: comment.userProfile?.userBadge)
                badgeView.isHidden = false
            }else{
                badgeView.isHidden = true
            }
            nameLbl.text = comment.userProfile?.userName
            let strCreatedTime = comment.createdAt ?? ""
            let strUpdatedTime = comment.updatedAt ?? ""
            lbl_Edited.text = strUpdatedTime == "" ? "" : strCreatedTime == strUpdatedTime ? "" : comment.userProfile?.userID == kSharedAppDelegate.userId ? "(Edited)".localized()  : ""
            
            if #available(iOS 13.0, *) {
                timeLbl.text = comment.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
            } else {
                // Fallback on earlier versions
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
    
    
    @IBAction func btn_Option(sender: UIButton) {
        self.delegate?.commentCell(cell: self, didPressOptionBtn: comment, index: index)
    }
    
    
    //MARK:- tappedOnLabel
    func tappedonLabel(_ title: String, message: String) {
        
        if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
    }
}

