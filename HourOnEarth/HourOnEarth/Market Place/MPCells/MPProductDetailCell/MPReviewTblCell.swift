//
//  MPReviewTblCell.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 17/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Cosmos

class MPReviewTblCell: UITableViewCell {
    
    var currentVC: UIViewController?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var view_Rating: CosmosView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblWeekday: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblUnlikeCount: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var collectView_Photo: UICollectionView!
    @IBOutlet weak var constraint_collectView_Photo_TOP: NSLayoutConstraint!
    @IBOutlet weak var constraint_collectView_Photo_HEIGHT: NSLayoutConstraint!
    
    var reviewData: MPReviewDetailModel?{
        didSet{
            self.setReviewData()
        }
    }
    
    var set_reviewUserData: MPReviewUserDetailModel?{
        didSet{
            self.setReviewUser_Data()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectView_Photo.register(nibWithCellClass: MPReviewImageCollectionCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton){
        
    }
    
    @IBAction func btnDislikeAction(_ sender: UIButton){
        
    }
    
    func setReviewData()  {
        lblTitle.text = ""
        lblDate.text = convertStringToDate(strDate: reviewData?.created_at  ?? "", fromFormat: MPDateFormat.yyyy_MM_dd_HH_mm_ss, toFormat: MPDateFormat.DD_MMM_yyyy)
        lblComment.text = reviewData?.review == "" ? "Sorry! No Data!" : reviewData?.review ?? ""
        self.view_Rating.rating = Double(reviewData?.rating ?? 0)
        
        if reviewData?.review_images.count == 0 {
            self.constraint_collectView_Photo_TOP.constant = 0
            self.constraint_collectView_Photo_HEIGHT.constant = 0
        }
        else {
            self.constraint_collectView_Photo_TOP.constant = 12
            self.constraint_collectView_Photo_HEIGHT.constant = 75
        }
        self.collectView_Photo.reloadData()
        self.collectView_Photo.layoutIfNeeded()
    }
    
    func setReviewUser_Data()  {
        lblWeekday.text = set_reviewUserData?.user_name ?? "N/A"
    }
}

//MARK: - UICollectionView Delegate Datasource Method
extension MPReviewTblCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewData?.review_images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPReviewImageCollectionCell.self, for: indexPath)
        let urlString = reviewData?.review_images[indexPath.row] as? String ?? ""
        if let url = URL(string: urlString) {
            cell.imgP.af.setImage(withURL: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 75, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cur_Cell = collectionView.cellForItem(at: indexPath) as? MPReviewImageCollectionCell {
            if let imgggg = cur_Cell.imgP.image {
                SMPhotoViewer.showImage(toView: self.currentVC!, image: imgggg, fromView: cur_Cell.imgP)
            }
        }
    }
}
