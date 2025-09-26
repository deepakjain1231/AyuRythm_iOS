//
//  ARFeedCommentReplyVC.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 23/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

class ARFeedCommentReplyVC: UIViewController {
    @IBOutlet weak var profileIV: UIImageView!
    @IBOutlet weak var badgeIv: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var replyTableView: UITableView!
    @IBOutlet weak var commentBGView: UIView!
    @IBOutlet weak var badgeView: UIView!
    var comment: Comment?
    override func viewDidLoad() {
        super.viewDidLoad()
        profileIV.makeItRounded()
        commentBGView.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
        replyTableView.delegate = self
        replyTableView.dataSource = self
        replyTableView.register(nibWithCellClass: ARFeedCommentReplyCell.self)
        profileIV.sd_setImage(with: URL(string: comment?.userProfile?.userProfile ?? ""), placeholderImage: UIImage(named: "default-avatar"))
        if comment?.userProfile?.userBadge != ""{
            badgeIv.af_setImage(withURLString: comment?.userProfile?.userBadge)
            badgeView.isHidden = false
        }else{
            badgeView.isHidden = true
        }
        nameL.text = comment?.userProfile?.userName
        var strCommentMsg = comment?.message?.trimed().base64Decoded()
        if strCommentMsg == nil {
            strCommentMsg = comment?.message
        }
        messageLbl.text = strCommentMsg
        if #available(iOS 13.0, *) {
            timeLbl.text = comment?.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ARFeedCommentReplyVC: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //print((comment?.commentarray?.count)!)
        return (comment?.commentarray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARFeedCommentReplyCell.self, for: indexPath)
        let commentReply = comment?.commentarray?[indexPath.row]
        
        var strCommentMsg = commentReply?.message?.trimed().base64Decoded()
        if strCommentMsg == nil {
            strCommentMsg = commentReply?.message
        }
        cell.commentL.text = strCommentMsg
        
        cell.profilePicIV.sd_setImage(with: URL(string: commentReply?.userProfile?.userProfile ?? ""), placeholderImage: appImage.default_avatar_pic)
        if commentReply?.userProfile?.userBadge != ""{
            cell.badgeIV.af_setImage(withURLString: commentReply?.userProfile?.userBadge)
            cell.badgeView.isHidden = false
        }else{
            cell.badgeView.isHidden = true
        }
        cell.nameLbl.text = commentReply?.userProfile?.userName
        if #available(iOS 13.0, *) {
            cell.timeLbl.text = commentReply?.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
        } else {
            // Fallback on earlier versions
        }
        return cell
    }
    
}
