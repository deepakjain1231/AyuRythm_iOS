//
//  MPAllReviewVC.swift
//  HourOnEarth
//
//  Created by Sachin Patoliya on 03/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Cosmos

class MPAllReviewVC: UIViewController {
    
    @IBOutlet weak var img_ReviewStar_1: UIImageView!
    @IBOutlet weak var img_ReviewStar_2: UIImageView!
    @IBOutlet weak var img_ReviewStar_3: UIImageView!
    @IBOutlet weak var img_ReviewStar_4: UIImageView!
    @IBOutlet weak var img_ReviewStar_5: UIImageView!
    
    @IBOutlet weak var lblReviewStarWiseCount1: UILabel!
    @IBOutlet weak var lblReviewStarWiseCount2: UILabel!
    @IBOutlet weak var lblReviewStarWiseCount3: UILabel!
    @IBOutlet weak var lblReviewStarWiseCount4: UILabel!
    @IBOutlet weak var lblReviewStarWiseCount5: UILabel!
    
    @IBOutlet weak var progressReviewStarWise1: UIProgressView!
    @IBOutlet weak var progressReviewStarWise2: UIProgressView!
    @IBOutlet weak var progressReviewStarWise3: UIProgressView!
    @IBOutlet weak var progressReviewStarWise4: UIProgressView!
    @IBOutlet weak var progressReviewStarWise5: UIProgressView!
    
    @IBOutlet weak var btnTotalReviewCount: UIButton!
    @IBOutlet weak var lblTotalReview: UILabel!
    @IBOutlet weak var viewCosmosReview: CosmosView!
    
    @IBOutlet weak var viewbgReviewImg: UIView!
    @IBOutlet weak var viewbgReviewImage_height: NSLayoutConstraint!
    @IBOutlet weak var collectionReviewImg: UICollectionView!
    @IBOutlet weak var btnRating: UIButton!
    
    @IBOutlet weak var viewbgReviewList_height: NSLayoutConstraint!
    @IBOutlet weak var tblReviewList: UITableView!
    @IBOutlet weak var viewbgReviewList: UIView!
    
    var str_productID = ""
    var productReviews: MPReviewModel?
    var reviewImages: [MPProductImages] = []
    var mpSelectProductData:MPProductData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reviews"
        self.navigationController?.navigationItem.backButtonTitle = ""
        registerCell()
        
        self.showActivityIndicator()
        callAPIfor_product_Ratings(pID: str_productID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func registerCell(){
        tblReviewList.register(nibWithCellClass: MPReviewTblCell.self)
        collectionReviewImg.register(nibWithCellClass: MPImageCollectionCell.self)
    }
    func setProductData(){
        collectionReviewImg.reloadData()
        tblReviewList.reloadData()
        
        btnTotalReviewCount.setTitle("\(mpSelectProductData?.rating ?? 0)", for: .normal)
        if (mpSelectProductData?.rating ?? 0) == 0 {
            self.btnTotalReviewCount.setImage(appImage.default_unselected_star, for: .normal)
        }
        else {
            self.btnTotalReviewCount.setImage(appImage.default_selected_star, for: .normal)
        }
        
        if productReviews != nil{
            self.setRatings()
        }
        self.view.layoutIfNeeded()
        self.view.updateConstraintsIfNeeded()
    }
    
    func setRatings(){
        self.tblReviewList.reloadData()
        self.viewbgReviewImage_height.constant = reviewImages.count <= 0 ? 0 : 125
        self.viewbgReviewImg.isHidden = reviewImages.count <= 0 ? true : false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.viewbgReviewList_height.constant = self.productReviews?.data.count ?? 0 <= 0 ? 0 : self.tblReviewList.contentSize.height + 25
            self.view.layoutIfNeeded()
            self.view.updateConstraintsIfNeeded()
        }
        self.viewCosmosReview.rating = Double(self.mpSelectProductData?.rating ?? 0)
        
        let int_total_rating = self.mpSelectProductData?.total_rating_received ?? 0
        let int_total_review = self.mpSelectProductData?.total_review_received ?? 0
                
        if int_total_review == 0 {
            self.lblTotalReview.text = "\(int_total_rating) ratings & no review"
        }
        else {
            self.lblTotalReview.text = "\(int_total_rating) ratings & \(int_total_review) reviews"
        }
        
        self.lblReviewStarWiseCount1.text = "\(getTotalRate(rating: 1))"
        self.lblReviewStarWiseCount2.text = "\(getTotalRate(rating: 2))"
        self.lblReviewStarWiseCount3.text = "\(getTotalRate(rating: 3))"
        self.lblReviewStarWiseCount4.text = "\(getTotalRate(rating: 4))"
        self.lblReviewStarWiseCount5.text = "\(getTotalRate(rating: 5))"
        self.img_ReviewStar_1.image = getTotalRate(rating: 1) == 0 ? appImage.default_unselected_star : appImage.default_selected_star
        self.img_ReviewStar_2.image = getTotalRate(rating: 2) == 0 ? appImage.default_unselected_star : appImage.default_selected_star
        self.img_ReviewStar_3.image = getTotalRate(rating: 3) == 0 ? appImage.default_unselected_star : appImage.default_selected_star
        self.img_ReviewStar_4.image = getTotalRate(rating: 4) == 0 ? appImage.default_unselected_star : appImage.default_selected_star
        self.img_ReviewStar_5.image = getTotalRate(rating: 5) == 0 ? appImage.default_unselected_star : appImage.default_selected_star
        
        
        if int_total_rating <= 0 {
            self.progressReviewStarWise1.setProgress(0, animated: true)
            self.progressReviewStarWise2.setProgress(0, animated: true)
            self.progressReviewStarWise3.setProgress(0, animated: true)
            self.progressReviewStarWise4.setProgress(0, animated: true)
            self.progressReviewStarWise5.setProgress(0, animated: true)
        }else{
            self.progressReviewStarWise1.setProgress(Float(getTotalRate(rating: 1)) / Float(int_total_rating), animated: true)
            self.progressReviewStarWise2.setProgress(Float(getTotalRate(rating: 2)) / Float(int_total_rating), animated: true)
            self.progressReviewStarWise3.setProgress(Float(getTotalRate(rating: 3)) / Float(int_total_rating), animated: true)
            self.progressReviewStarWise4.setProgress(Float(getTotalRate(rating: 4)) / Float(int_total_rating), animated: true)
            self.progressReviewStarWise5.setProgress(Float(getTotalRate(rating: 5)) / Float(int_total_rating), animated: true)
        }
        
        
        
//        let one_review = self.productReviews?.data.filter({$0.review?.rating == 1}).count ?? 0
//        let two_review = self.productReviews?.data.filter({$0.review?.rating == 2}).count ?? 0
//        let three_review = self.productReviews?.data.filter({$0.review?.rating == 3}).count ?? 0
//        let four_review = self.productReviews?.data.filter({$0.review?.rating == 4}).count ?? 0
//        let five_review = self.productReviews?.data.filter({$0.review?.rating == 5}).count ?? 0
//        let totalReview = one_review + two_review + three_review + four_review + five_review
//        
//        self.lblTotalReview.text = "\(totalReview) ratings & \(totalReview) reviews"
        
//        self.lblReviewStarWiseCount1.text = "\(one_review)"
//        self.lblReviewStarWiseCount2.text = "\(two_review)"
//        self.lblReviewStarWiseCount3.text = "\(three_review)"
//        self.lblReviewStarWiseCount4.text = "\(four_review)"
//        self.lblReviewStarWiseCount5.text = "\(five_review)"
//        
//        if totalReview <= 0{
//            self.progressReviewStarWise1.setProgress(0, animated: true)
//            self.progressReviewStarWise2.setProgress(0, animated: true)
//            self.progressReviewStarWise3.setProgress(0, animated: true)
//            self.progressReviewStarWise4.setProgress(0, animated: true)
//            self.progressReviewStarWise5.setProgress(0, animated: true)
//        }else{
//            self.progressReviewStarWise1.setProgress(Float(two_review) / Float(totalReview), animated: true)
//            self.progressReviewStarWise2.setProgress(Float(two_review) / Float(totalReview), animated: true)
//            self.progressReviewStarWise3.setProgress(Float(three_review) / Float(totalReview), animated: true)
//            self.progressReviewStarWise4.setProgress(Float(four_review) / Float(totalReview), animated: true)
//            self.progressReviewStarWise5.setProgress(Float(five_review) / Float(totalReview), animated: true)
//        }
    }
    
    func getTotalRate(rating: Int) -> Int {
        var int_total_rate = 0
        if let indx_rating = self.mpSelectProductData?.total_ratings.firstIndex(where: { dic_rating in
            return dic_rating.rating == rating
        }) {
            int_total_rate = self.mpSelectProductData?.total_ratings[indx_rating].total_rate ?? 0
        }
        return int_total_rate
    }
    
    
}


extension MPAllReviewVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productReviews?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MPReviewTblCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.currentVC = self
        let data = productReviews?.data[indexPath.row].review
        let user_data = productReviews?.data[indexPath.row].user
        cell.reviewData = data
        cell.set_reviewUserData = user_data
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension MPAllReviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPImageCollectionCell.self, for: indexPath)
        let urlString = reviewImages[indexPath.row].image
        if let url = URL(string: urlString) {
            cell.imgP.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
