//
//  ARQAAnswerCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage
import ActiveLabel

protocol ARQAAnswerCellDelegate {
    func readMoreClicked()
    func answerCell(cell: ARQAAnswerCell, didPressUpvoteBtn data: AnswerData?)
    func answerCell(cell: ARQAAnswerCell, didPressMoreActionBtn data: AnswerData?)
    func answerCell(cell: ARQAAnswerCell, didPressProfileBtn data: AnswerData?)
}

class ARQAAnswerCell: UITableViewCell {

    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var profilePicIV: UIImageView!
    @IBOutlet weak var userNameL: UILabel!
    @IBOutlet weak var answerL: ActiveLabel!
    @IBOutlet weak var upvoteL: UILabel!
    @IBOutlet weak var lbl_Edited: UILabel!
    @IBOutlet weak var upVoteBtn: UIButton!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeIv: UIImageView!
        
    var delegate: ARQAAnswerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicIV.makeItRounded()
    }
    
    var answer: AnswerData? {
        didSet {
            guard let answer = answer else { return }

            upvoteL.text = "Upvotes - ".localized() + "\(answer.upvotes ?? "")"
            profilePicIV.sd_setImage(with: URL(string: answer.userProfile?.userProfile ?? ""), placeholderImage: appImage.default_avatar_pic)
            userNameL.text = answer.userName
            if answer.mylike == "0"{
                upVoteBtn.setImage(UIImage(named: "arrowCircularUP"), for: .normal)
                upVoteBtn.setBackgroundImage(nil, for: .normal)
            }else{
                upVoteBtn.setImage(UIImage(named: "upvote_trans"), for: .normal)
                upVoteBtn.setBackgroundImage(UIImage(named: "green_circle"), for: .normal)
            }
            if answer.userProfile?.userBadge != ""{
                badgeIv.af_setImage(withURLString: answer.userProfile?.userBadge)
                badgeView.isHidden = false
            }else{
                badgeView.isHidden = true
            }
            
            
            let strCreatedTime = answer.createdAt ?? ""
            let strUpdatedTime = answer.updatedAt ?? ""
            lbl_Edited.text = strCreatedTime == strUpdatedTime ? "" : answer.userProfile?.userID == kSharedAppDelegate.userId ? "(Edited)".localized() : ""
            
            
            layoutIfNeeded()
        }
    }
    
    @IBAction func didPressUpvoteBtn(sender: UIButton) {
        delegate?.answerCell(cell: self, didPressUpvoteBtn: answer)
    }
    
    @IBAction func didPressMoreActionBtn(sender: UIButton) {
        delegate?.answerCell(cell: self, didPressMoreActionBtn: answer)
    }
    
    @IBAction func didPressProfileBtn(sender: UIButton) {
        delegate?.answerCell(cell: self, didPressProfileBtn: answer)
    }
    
    @IBAction func readMoreBtnPressed(sender: UIButton) {
        delegate?.readMoreClicked()
    }
}
