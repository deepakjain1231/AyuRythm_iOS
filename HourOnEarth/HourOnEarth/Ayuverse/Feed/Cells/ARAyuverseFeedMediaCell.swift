//
//  ARAyuverseFeedMediaCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import AVKit
import DropDown
import ActiveLabel

class ARFeedMediaModel {
    var image: String
    
    internal init(image: String) {
        self.image = image
    }
    
    static func getDummyMediaList() -> [ARFeedMediaModel] {
        return [ARFeedMediaModel(image: "https://dev.ayurythm.com/assets/images/yoga/Agnisar_Kriya.jpg"),
                ARFeedMediaModel(image: "https://dev.ayurythm.com/assets/images/yoga/Agnisar_Kriya.jpg"),
                ARFeedMediaModel(image: "https://dev.ayurythm.com/assets/images/yoga/Agnisar_Kriya.jpg"),
                ARFeedMediaModel(image: "https://dev.ayurythm.com/assets/images/yoga/Agnisar_Kriya.jpg")]
    }
}

class ARAyuverseFeedMediaCell: ARAyuverseFeedCell {

    var currentController = UIViewController()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var postBtn1: UIButton!
    @IBOutlet weak var userIv1: UIImageView!
    @IBOutlet weak var moreBtn1: UIButton!
    @IBOutlet weak var commentTV1: UITextField!
    @IBOutlet weak var commentStView1: UIStackView!
    
    var mediaList: [String] = [] {
        didSet {
            if mediaList.count == 1 {
                pageControl.isHidden = true
            }else{
                pageControl.isHidden = false
            }
            pageControl.numberOfPages = mediaList.count
            scrollViewDidEndDecelerating(collectionView)
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.postBtn1.setTitle("Post".localized(), for: .normal)
        self.commentTV1.placeholder = "Write a comment".localized()
        collectionView.register(nibWithCellClass: ARFeedPostMediaCell.self)
        collectionView.setupUISpace(allSide: 0, itemSpacing: 0, lineSpacing: 0)
        
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
            userIv1.sd_setImage(with: url, placeholderImage: defaultPic)
        }
        else {
            userIv1.image = defaultPic
        }
    }
    
    
    override func setupData(_ dic_Feed: Feed) {
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
        self.userIv1?.layer.cornerRadius = 14
        self.postBtn1.titleLabel?.font = self.postBtn1.titleLabel?.font.withSize(12)
        self.userIv1.clipsToBounds  = true
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    @IBAction func postBtnAct1(_ sender: Any) {
        print("post1")
        delegate?.ayuverseFeedCell(cell: self, didPressedPostBtn: sender as! UIButton, data: feed)
    }
    
    override var feed: Feed? {
        didSet {
            guard let feed = feed else { return }
            
            mediaList = feed.files ?? []
            
        }
    }
    
    @IBAction func moreBtnClicked(_ sender: Any) {
        delegate?.ayuverseFeedCell(cell: self, didSelectMoreOption: feed)
    }
}

extension ARAyuverseFeedMediaCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ARFeedPostMediaCell.self, for: indexPath)
        cell.mediaData = mediaList[indexPath.row]
        
        cell.thumbIV.accessibilityLabel = mediaList[indexPath.row]
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(TapResponce(_:)))
        cell.thumbIV.isUserInteractionEnabled = true
        cell.thumbIV.tag = indexPath.row
        cell.thumbIV.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    
    @objc func TapResponce(_ sender: UITapGestureRecognizer) {
        let indxPath = IndexPath.init(row: sender.view?.tag ?? 0, section: 0)
        if let currentCell = collectionView.cellForItem(at: indxPath) as? ARFeedPostMediaCell {
            let strVideo_Image = currentCell.thumbIV.accessibilityLabel ?? ""
            if let url = URL.init(string: strVideo_Image) {
                if url.lastPathComponent.contains("mp4") || url.lastPathComponent.contains("mov") {
                    let player = AVPlayer(url: url)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    self.currentController.present(playerController, animated: true) {
                        player.play()
                    }
                }
                else {
                    SMPhotoViewer.showImage(toView: self.currentController, image: currentCell.thumbIV.image!, fromView: currentCell.thumbIV)
                }
            }
            else {
                SMPhotoViewer.showImage(toView: self.currentController, image: currentCell.thumbIV.image!, fromView: currentCell.thumbIV)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /*mediaList.forEach{ $0.isSelected = false }
        let category = mediaList[indexPath.row]
        category.isSelected = true
        collectionView.reloadData()
        delegate?.categoryPickerView(view: self, didSelect: category)*/
        
    }
}
