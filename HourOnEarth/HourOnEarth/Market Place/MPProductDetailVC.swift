//
//  MPProductDetailVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 08/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Cosmos
import AVKit
import CoreData
//import MoEngage
//import HCVimeoVideoExtractor

class MPProductDetailVC: UIViewController, delegateSelectPincode, delegateScreenRefresh {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var collectionSlider: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var lbl_choosePackTitle: UILabel!
    @IBOutlet weak var lbl_choosePackOption: UILabel!
    @IBOutlet weak var viewbgSizeList: UIView!
    @IBOutlet weak var collectionSize: UICollectionView!
    @IBOutlet weak var viewbgcollectionSize_Height: NSLayoutConstraint!
    
    @IBOutlet weak var viewbgDescription: UIView!
    @IBOutlet weak var tblDescriptinList: UITableView!
    @IBOutlet weak var viewbgDescriptionList_height: NSLayoutConstraint!
    
    @IBOutlet weak var viewbgSimilarProduct: UIView!
    @IBOutlet weak var btn_SimilarProductViewAll: UIButton!
    @IBOutlet weak var collectionSimilarProduct: UICollectionView!
    @IBOutlet weak var collectionSimilarProduct_height: NSLayoutConstraint!
    
    @IBOutlet weak var viewbgReviewImg: UIView!
    @IBOutlet weak var viewbgReviewImage_height: NSLayoutConstraint!
    @IBOutlet weak var collectionReviewImg: UICollectionView!
    @IBOutlet weak var viewAllReview: UIView!
    @IBOutlet weak var lblAllReview: UILabel!
    
    @IBOutlet weak var viewbgReviewList_height: NSLayoutConstraint!
    @IBOutlet weak var tblReviewList: UITableView!
    @IBOutlet weak var viewbgReviewList: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblsubTitle: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    
    @IBOutlet weak var btnRateProduct: UIButton!
    @IBOutlet weak var constraint_btnRateProduct_Height: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_rating_count: UILabel!
    @IBOutlet weak var view_Rating_star: CosmosView!
    
    @IBOutlet weak var lblReviewCount: UILabel!
    @IBOutlet weak var lblCurrentPrice: UILabel!
    @IBOutlet weak var lblOldPrice: UILabel!
    @IBOutlet weak var lblOff: UILabel!
    @IBOutlet weak var lblEstDeliveryTime: UILabel!
    @IBOutlet weak var lblDeliveryTo: UILabel!
    
    @IBOutlet weak var lblDetailBelowDeliverTo1: UILabel!
    @IBOutlet weak var lblDetailBelowDeliverTo2: UILabel!
    @IBOutlet weak var lblDetailBelowDeliverTo3: UILabel!
    
    @IBOutlet weak var lblBestBefore: UILabel!
    
    @IBOutlet weak var lblSellerDetail1: UILabel!
    @IBOutlet weak var lblSellerDetail2: UILabel!
    @IBOutlet weak var lblSellerDetail3: UILabel!
    
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var viewAddToCart: UIView!
    @IBOutlet weak var viewOutOfStock: UIView!
    @IBOutlet weak var viewBestBefore: UIView!
    @IBOutlet weak var lblsellerRating: UIView!
    @IBOutlet weak var heightViewBestBefore: NSLayoutConstraint!
    @IBOutlet weak var btn_cart: UIBarButtonItem!
    
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
    
    @IBOutlet weak var btn_Fav: UIButton!
    @IBOutlet weak var view_Blank: UIView!
    
    //MARK: - Veriable
    var str_productID = ""
    var arr_ImageVideo = [MPProductImages]()
    var arr_RelatedProduct = [MPProductData]()
    var mpSelectProductData:MPProductData?
    var productReviews: MPReviewModel?
    var reviewImages: [MPProductImages] = []
    var selectedSizeIndex = 0
    var arrDetails = [[String: Any]]()
    //@IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        viewOutOfStock.isHidden = true
        self.view_Blank.isHidden = false

        self.title = "Shop"
        self.navigationController?.navigationItem.backButtonTitle = ""
        
        callAPIfor_product_details(pID: str_productID)
        self.callAPIfor_AddRecentlyProduct(pID: str_productID)
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.productAddedToCart(notification:)), name: Notification.Name("productAddedToCart"), object: nil)
        
        NotificationCenter.default.addObserver(forName: .refreshProductData, object: nil, queue: nil) { [weak self] notif in
            self?.setProductData()
        }
        
        
        let dic: NSMutableDictionary = ["product_id": str_productID]
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.PRODUCT_DETAILS.rawValue, properties: MOProperties.init(attributes: dic))
    }
    
    @objc func productAddedToCart(notification: Notification) {
        handleCartBadge()
    }
    
    func handleCartBadge()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let count = MPCartManager.getCartData().data.count
            self.btn_cart.removeBadge()
            self.btn_cart.addBadge(number: count)
            if count <= 0 {
                self.btn_cart.removeBadge()
            }
        }
        collectionSimilarProduct.reloadData()
        if mpSelectProductData != nil{
            setAddToCartButton(product: mpSelectProductData!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        MPSelectPinCode = self.getDeliveryPincode()
        self.lblDeliveryTo.text = "Delivering to: \(MPSelectPinCode)"
        
        handleCartBadge()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //tableView.reloadData()
    }
    
    @IBAction func btnChangeAddress(_ sender: Any) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = SelectPincodeDialouge(nibName: "SelectPincodeDialouge", bundle: nil)
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
        }
//        MPAddressLocalDB.redirectToSelectAddress {
//            self.lblDeliveryTo.text = "\(MPAddressLocalDB.showWholeAddress(addressModel: MPAddressLocalDB.getAddress()))"
//        }
    }
    
    @IBAction func btn_RateProduct_Action(_ sender: UIButton) {
        let vc = MPMyOrderReviewVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.delegate = self
        vc.is_fromProductDetail = true
        vc.dic_ProductDetail_fromDetail = self.mpSelectProductData
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btn_addRating_Action(_ sender: UIButton) {
    }
    
    @IBAction func btn_BuyNow_Action(_ sender: UIButton) {
    }
    
    @IBAction func btn_ViewAllReview_Action(_ sender: UIButton) {
        let vc = MPAllReviewVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.str_productID = str_productID
        vc.mpSelectProductData = mpSelectProductData
        vc.reviewImages = reviewImages
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_AddToCart_Action(_ sender: UIButton) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to add to cart".localized(), controller: self)
            return
        }
        
        MPCartManager.addToCartButtonAction(btnCart: sender, view_AddTocartBG: viewAddToCart, productData: mpSelectProductData, current_vc: self) {
            self.setAddToCartButton(product: self.mpSelectProductData!)
        }
    }
    
    @IBAction func btnCartActiob(_ sender: Any) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view cart".localized(), controller: self)
            return
        }
        
        
        let vc = MPCartVC.instantiate(fromAppStoryboard: .MarketPlace)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnWishList_Action(_ sender: UIButton) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view favourite".localized(), controller: self)
            return
        }
        
        
        MPWishlistManager.addToWishlistButton_Action(btnWishlist: sender, productData: self.mpSelectProductData)
        NotificationCenter.default.post(name: .refreshProductData, object: nil)
    }
    
    @IBAction func btnShare_Action(_ sender: UIButton) {
        let str_sharre = "Product Detail"
        self.shareProductOrderDetails(text: str_sharre)
    }
    
    @IBAction func btn_SimilarProductViewAll_Action(_ sender: UIButton) {
        let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.screenFrom = .MP_ViewALL_SimilarProduct
        vc.mpDataType = .similarProducts
        vc.str_Title = "Similar Products"
        vc.selected_productID = self.str_productID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    

    
    func shareProductOrderDetails(text: String) {
        let finalShareText = text
        let shareAll = [ finalShareText ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func registerCell(){
        collectionSlider.register(nibWithCellClass: MPImageCollectionCell.self)
        
        collectionSize.register(nibWithCellClass: MPSizeCollectionCell.self)
        
        tblDescriptinList.register(nibWithCellClass: MPDescriptionTblCell.self)
        collectionSimilarProduct.register(nibWithCellClass: MPTrendingProductCollectionCell.self)
        tblReviewList.register(nibWithCellClass: MPReviewTblCell.self)
        collectionSize.register(nibWithCellClass: MPSizeCollectionCell.self)
        collectionReviewImg.register(nibWithCellClass: MPImageCollectionCell.self)
    }
    func setProductData(){
        self.arrDetails.removeAll()
        collectionSlider.reloadData()
        collectionSize.reloadData()
        collectionReviewImg.reloadData()
        tblReviewList.reloadData()
        tblDescriptinList.reloadData()
        self.view_Blank.isHidden = true
        
        let isAvailable = MPCartManager.checkIfProductAvailable(productId: mpSelectProductData?.id ?? 0)
        if isAvailable{
            mpSelectProductData?.cartData = MPCartManager.getSelectedProductsByProductId(product: mpSelectProductData!)?.cartData
        }

        let cruPrice: Double = isAvailable ? Double(self.mpSelectProductData?.cartData?.size_price.floatValue ?? 0) : Double(self.mpSelectProductData?.current_price ?? 0)
        let prvPrice: Double = isAvailable ? Double(self.mpSelectProductData?.cartData?.sizes_wise_previous_price.floatValue ?? 0) : Double(self.mpSelectProductData?.previous_price ?? 0)
        lblTitle.text = mpSelectProductData?.title
        let str_ayuvedicName = mpSelectProductData?.ayurvedic_name
        if str_ayuvedicName != "" {
            lblsubTitle.isHidden = false
            lblsubTitle.text = str_ayuvedicName
        }
        else {
            lblsubTitle.text = ""
            lblsubTitle.isHidden = true
        }
        
        lblSize.text = ""
        lblCurrentPrice.text = "₹\(cruPrice)"
        
        if prvPrice > 0 && prvPrice > cruPrice {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "MRP ₹ \(prvPrice)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
            self.lblOldPrice.attributedText = attributeString
        }else{
            self.lblOldPrice.text = ""
        }
        
        
        //DISCOUNT LOGIC
        if self.mpSelectProductData?.DISCOUNT ?? 0 > 0{
            self.lblOff.text = "\(self.mpSelectProductData?.DISCOUNT ?? 0)% OFF"
        }else{
            self.lblOff.text = ""
        }
        
        let estimated_shipping_time = mpSelectProductData?.estimated_shipping_time ?? ""
        lblEstDeliveryTime.text = "Inclusive of all taxes"
        lblDetailBelowDeliverTo1.text = estimated_shipping_time.count == 0 ? "" : "• Est. Delivery in \(estimated_shipping_time)"
        lblDetailBelowDeliverTo2.text = ""
        
        if mpSelectProductData?.rating ?? 0 == 0 {
            self.lbl_rating_count.isHidden = true
            self.lblReviewCount.isHidden = true
        }
        else {
            self.lbl_rating_count.isHidden = false
            self.lblReviewCount.isHidden = false
            
        }
        self.view_Rating_star.rating = mpSelectProductData?.rating ?? 0.0
        self.lbl_rating_count.text = "\(mpSelectProductData?.rating ?? 0)"
        self.lblReviewCount.text = "(\(mpSelectProductData?.reviews.count ?? 0))"
        
        
        
        
        self.arr_ImageVideo.removeAll()
        if let arr_Image = mpSelectProductData?.images, arr_Image.count != 0 {
            for dicImage in arr_Image {
                arr_ImageVideo.append(MPProductImages.init(JSON: ["id" : dicImage.id, "image": dicImage.image, "video": ""])!)
            }
        }

        if let arr_Video = mpSelectProductData?.videos, arr_Video.count != 0 {
            for dicVideo in arr_Video {
                arr_ImageVideo.append(MPProductImages.init(JSON: ["id" : dicVideo.id, "image": "", "video": dicVideo.video])!)
            }
        }
        pageController.numberOfPages = arr_ImageVideo.count
        if arr_ImageVideo.count == 0 || arr_ImageVideo.count == 1 {
            pageController.isHidden = true
        }
        else {
            pageController.isHidden = false
        }
        
        
        if let mpProductdata = mpSelectProductData {
            setAddToCartButton(product: mpProductdata)
            
            MPWishlistManager.setWishlistButtonTitle(btnWishlist: self.btn_Fav, product: mpProductdata)
        }
        
        //--
        if let related_products = mpSelectProductData?.related_products, related_products.count != 0{
            arr_RelatedProduct = related_products
            collectionSimilarProduct.reloadData()
        }else{
            collectionSimilarProduct_height.constant = 0
            viewbgSimilarProduct.isHidden = true
        }
        if let sizes = mpSelectProductData?.sizes, sizes.count > 1 {
            //--
            let getCount = sizes.count
            var countInDouble: Double = Double(getCount)
            countInDouble = countInDouble/3.0
            let getheight = countInDouble.rounded(FloatingPointRoundingRule.up)
            viewbgcollectionSize_Height.constant = 54 + (getheight*30)
            self.lbl_choosePackOption.text = "(\(getCount) Options)"
            
            let producCurrentPrice = self.mpSelectProductData?.current_price ?? 0
            let producCurrentPrice_WithSize = Double(producCurrentPrice) + (Double(self.mpSelectProductData?.size_price[self.selectedSizeIndex] ?? "") ?? 0.0)
            
            let producPrvPrice = self.mpSelectProductData?.previous_price ?? 0
            let producPrvPrice_WithSize = Double(producPrvPrice) + (Double(self.mpSelectProductData?.size_price[self.selectedSizeIndex] ?? "") ?? 0.0)
            
            let prvPrice: Double = producPrvPrice_WithSize
            let cruPrice: Double = producCurrentPrice_WithSize
            
            lblCurrentPrice.text = "₹\(cruPrice)"
            if prvPrice > 0 {
                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "MRP ₹ \(prvPrice)")
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                self.lblOldPrice.attributedText = attributeString
                
                let getDiscount = ((cruPrice * 100)/prvPrice).rounded(.up)
                let intDiscont: Int = Int(100 - getDiscount)
                if 0 < intDiscont {
                    self.lblOff.text = "\(intDiscont)% OFF"
                }
                else {
                    self.lblOff.text = ""
                }
            }else{
                self.lblOldPrice.text = ""
            }
        }else{
            self.viewbgSizeList.isHidden = true
            self.lbl_choosePackOption.text = ""
            self.viewbgcollectionSize_Height.constant = 0
            self.lblSize.text = mpSelectProductData?.simple_product_size_label
            
            if prvPrice > 0 {
                let getDiscount = ((cruPrice * 100)/prvPrice).rounded(.up)
                let intDiscont: Int = Int(100 - getDiscount)
                if 0 < intDiscont {
                    self.lblOff.text = "\(intDiscont)% OFF"
                }
                else {
                    self.lblOff.text = ""
                }
            }
        }
        if mpSelectProductData?.details != ""{
            arrDetails.append(["detail": mpSelectProductData?.details ?? "", "title": "Description", "isSelected": false])
        }
        
        if mpSelectProductData?.key_ingredients != ""{
            arrDetails.append(["detail": mpSelectProductData?.key_ingredients ?? "", "title": "Key Ingredients", "isSelected": false])
        }
        
        if mpSelectProductData?.benefits_n_uses != ""{
            arrDetails.append(["detail": mpSelectProductData?.benefits_n_uses ?? "", "title": "Benefits & Uses", "isSelected": false])
        }
        
        if mpSelectProductData?.direction_to_use != ""{
            arrDetails.append(["detail": mpSelectProductData?.direction_to_use ?? "", "title": "Directions to Use", "isSelected": false])
        }
        self.tblDescriptinList.reloadData()
        
        let str_origin = mpSelectProductData?.shop?.country_of_origin ?? ""
        
        self.lblSellerDetail1.text = "Marketed by \(mpSelectProductData?.shop?.name ?? "")"
        if mpSelectProductData?.brand != ""{
            self.lblSellerDetail2.text = "Manufactured by \(mpSelectProductData?.brand ?? "")"
            self.lblSellerDetail3.text = "Country of Origin \(str_origin)"
        }else{
            let str_manufactured_by = mpSelectProductData?.shop?.manufacturer_by ?? ""
            self.lblSellerDetail3.text = "Country of Origin \(str_origin)"
            self.lblSellerDetail2.text = "Manufactured by \(str_manufactured_by)"
        }
        self.viewbgDescriptionList_height.constant = arrDetails.count > 0 ? CGFloat((85 * arrDetails.count) + 25) : 0
        if mpSelectProductData?.best_before != ""{
            self.viewBestBefore.isHidden = false
            self.lblBestBefore.text = mpSelectProductData?.best_before ?? ""
        }else{
            self.viewBestBefore.isHidden = true
            self.heightViewBestBefore.constant = 0
        }
        if productReviews != nil{
            if kSharedAppDelegate.userId != "" {
                self.setRatings()
            }
        }
        
        if kSharedAppDelegate.userId == "" {
            self.viewAllReview.isHidden = true
            self.btnRateProduct.isHidden = true
            self.viewbgReviewList_height.constant = 0
            self.constraint_btnRateProduct_Height.constant = 15
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
        
        
        //Rating button Hide Show Login
        let stt_ratingggg = self.mpSelectProductData?.rating_conditions?.rating_given_or_not ?? ""
        let stt_reviewwww = self.mpSelectProductData?.rating_conditions?.review_given_or_not ?? ""
        if stt_ratingggg.lowercased() == "yes" {
            self.btnRateProduct.isHidden = true
            self.constraint_btnRateProduct_Height.constant = 0
        }

        self.viewAllReview.isHidden = self.productReviews?.data.count ?? 0 <= 0 ? true : false
        self.viewCosmosReview.rating = Double(self.mpSelectProductData?.rating ?? 0)
        
        
        
//        let one_review = self.productReviews?.data.filter({$0.review?.rating == 1}).count ?? 0
//        let two_review = self.productReviews?.data.filter({$0.review?.rating == 2}).count ?? 0
//        let three_review = self.productReviews?.data.filter({$0.review?.rating == 3}).count ?? 0
//        let four_review = self.productReviews?.data.filter({$0.review?.rating == 4}).count ?? 0
//        let five_review = self.productReviews?.data.filter({$0.review?.rating == 5}).count ?? 0
//        let totalReview = one_review + two_review + three_review + four_review + five_review
        
        let int_total_rating = self.mpSelectProductData?.total_rating_received ?? 0
        let int_total_review = self.mpSelectProductData?.total_review_received ?? 0
                
        if int_total_review == 0 {
            self.lblTotalReview.text = "\(int_total_rating) ratings & no review"
        }
        else {
            self.lblTotalReview.text = "\(int_total_rating) ratings & \(int_total_review) reviews"
        }
        
        self.lblAllReview.text = "View all \(int_total_review) reviews"
        self.btnTotalReviewCount.setTitle("\(self.mpSelectProductData?.rating ?? 0)", for: .normal)
        
        if (self.mpSelectProductData?.rating ?? 0) == 0 {
            self.btnTotalReviewCount.setImage(appImage.default_unselected_star, for: .normal)
        }
        else {
            self.btnTotalReviewCount.setImage(appImage.default_selected_star, for: .normal)
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
    
    func setAddToCartButton(product: MPProductData) {
        
        viewAddToCart.backgroundColor = .clear
        
        //==Logic for Out Of Strock Product==========================================================================================//
        let dic_temp = self.checkProductQuentity_andSetData()
        let is_localCalculation = dic_temp["is_localCalculation"] as? Bool ?? false
        let int_productQuentity = dic_temp["productQuentity"] as? Int ?? 0
        //***************************************************************************************************************************//
        var strButtonTitle = ""
        if int_productQuentity == 0 {
            if is_localCalculation {
                strButtonTitle = "Go to cart"
            }
        }
        
        if strButtonTitle == "" {
            //Set color
            if product.is_variable_product.lowercased() == "yes" && product.size_quantity.count > 0 && product.size_quantity.filter({Int($0) ?? 0 > 0}).count > 0{
                let isAvail = MPCartManager.checkIfProductAvailable(productId: product.id)
                btnAddToCart.setTitle(isAvail ? "Go to cart" : "Add to cart", for: .normal)
                btnAddToCart.tag = isAvail ? 1 : 0//1 for availble in cart and 0 for not available in cart
            }else if product.simple_product_stock > 0{
                let isAvail = MPCartManager.checkIfProductAvailable(productId: product.id)
                btnAddToCart.setTitle(isAvail ? "Go to cart" : "Add to cart", for: .normal)
                btnAddToCart.tag = isAvail ? 1 : 0//1 for availble in cart and 0 for not available in cart
            }else{
                btnAddToCart.setTitle("Notify me", for: .normal)
                btnAddToCart.tag = 2//2 for notify me
            }
        }
        else {
            btnAddToCart.setTitle(strButtonTitle, for: .normal)
            btnAddToCart.tag = 1231// for go to cart
        }
        
        
        

        if btnAddToCart.tag == 0{//add to cart
            viewAddToCart.backgroundColor = UIColor.systemBlue
//            btnAddToCart.layer.borderColor = UIColor.systemBlue.cgColor
            btnAddToCart.setTitleColor(UIColor.systemBlue, for: .normal)
        }else if btnAddToCart.tag == 1{// added to cart
            viewAddToCart.backgroundColor = UIColor.systemBlue
            btnAddToCart.setTitleColor(UIColor.systemBlue, for: .normal)
        }else if btnAddToCart.tag == 2{//notify me
            viewOutOfStock.isHidden = false
            viewAddToCart.backgroundColor = UIColor.red
            btnAddToCart.backgroundColor = UIColor.white
//            viewAddToCart.layer.borderColor = UIColor.red.cgColor
            btnAddToCart.setTitleColor(UIColor.red, for: .normal)
        }else if btnAddToCart.tag == 1231 {
            viewOutOfStock.isHidden = false
            viewAddToCart.backgroundColor = UIColor.systemBlue
            btnAddToCart.setTitleColor(UIColor.systemBlue, for: .normal)
        }
    }
    
    func checkProductQuentity_andSetData() -> [String: Any] {
        
        var int_productQuentity: Int = 0
        var is_localCalculation = false
        
        //Check Veriavle Product
        var int_Indx = 0
        if self.mpSelectProductData?.is_variable_product.lowercased() == "yes" {
            if let arr_size_Quentity = self.mpSelectProductData?.size_quantity {
                for product_quentity in arr_size_Quentity {
                    int_productQuentity = Int(product_quentity) ?? 0
                    if int_productQuentity > 0 {
                        let cruSize = self.mpSelectProductData?.sizes[int_Indx] ?? ""
                        
                        if let arr_cartDetail = self.mpSelectProductData?.CART_DETAIL {
                            for dic_cart in arr_cartDetail {
                                let ADDED_SIZE = dic_cart.ADDED_SIZE
                                let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                                if cruSize == ADDED_SIZE {
                                    is_localCalculation = true
                                    int_productQuentity = int_productQuentity - ADDED_QUANTITY
                                }
                            }
                        }
                        
                        //==========================//
                        if int_productQuentity > 0 {
                            if int_productQuentity <= 5 {
                                //self.lbl_leftQuentity.text = "     Only \(int_productQuentity) left!"
                            }
                            else {
                                //self.lbl_leftQuentity.text = ""
                            }
                            break
                        }
                        //**************************//
                    }
                    int_Indx = int_Indx + 1
                }
            }
        }
        else {
            int_productQuentity = self.mpSelectProductData?.simple_product_stock ?? 0
            if int_productQuentity > 0 {
                if let arr_cartDetail = self.mpSelectProductData?.CART_DETAIL {
                    for dic_cart in arr_cartDetail {
                        is_localCalculation = true
                        let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                        int_productQuentity = int_productQuentity - ADDED_QUANTITY
                    }
                }

                if int_productQuentity <= 5 {
                    //self.lbl_leftQuentity.text = "     Only \(int_productQuentity) left!"
                }
                else {
                    //self.lbl_leftQuentity.text = ""
                }
            }
        }

        return ["productQuentity": int_productQuentity, "is_localCalculation": is_localCalculation]
    }
    

    func setUpDescriptionListHeight(fromFirstTime: Bool = false)  {
        if arrDetails.count <= 0 {
            self.viewbgDescription.isHidden = true
            self.viewbgDescriptionList_height.constant = 0
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
        }else{
            DispatchQueue.main.asyncAfter(deadline: fromFirstTime ? .now() + 1 : .now()) {
                self.viewbgDescriptionList_height.constant = self.tblDescriptinList.contentSize.height + 25
                self.view.updateConstraintsIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: - Method After Entered Pincode
    func Clk_After_selectPinCode(_ success: Bool, pincode: String, address_id: String) {
        if success {
            if pincode != "" {
                MPSelectPinCode = pincode
                setDeliveryPincode(pincode, selected_address_id: address_id)
                self.lblDeliveryTo.text = "Delivering to: \(pincode)"
            }
        }
    }
    
    func setDeliveryPincode(_ pincode: String, selected_address_id: String = "") {
        UserDefaults.standard.set(pincode, forKey: kDeliveryPincode)
        UserDefaults.standard.set(selected_address_id, forKey: kDeliveryAddressID)
        UserDefaults.standard.synchronize()
    }
    
    func getDeliveryPincode() -> String {
        var deliveryPincode = ""
        if let strPincode = UserDefaults.standard.object(forKey: kDeliveryPincode) as? String {
            deliveryPincode = strPincode
            self.lblDeliveryTo.text = "Delivering to: \(strPincode)"
        }
        return deliveryPincode
    }
    
    
    func screenRefresh(_ is_success: Bool) {
        if is_success {
            self.callAPIfor_product_details(pID: self.str_productID)
        }
    }
}

extension MPProductDetailVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblDescriptinList{
            return arrDetails.count
        }else{
            return productReviews?.data.count ?? 0 <= 5 ? productReviews?.data.count ?? 0 : 5
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblDescriptinList{
            let cell = tableView.dequeueReusableCell(withClass: MPDescriptionTblCell.self, for: indexPath)
            cell.selectionStyle = .none
            let data = arrDetails[indexPath.row]
            cell.lblTitle.text = data["title"] as? String ?? ""
            cell.lblDetail.text = data["detail"] as? String ?? ""
            cell.imgArrow.image = UIImage.init(named: data["isSelected"] as? Bool == true ? "up-arrow-black" : "arrowDown")
            cell.imgArrow.setImageColor(color: .black)
            cell.lblDetail.numberOfLines = data["isSelected"] as? Bool == true ? 0 : 1
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withClass: MPReviewTblCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.currentVC = self
            let data = productReviews?.data[indexPath.row].review
            let user_data = productReviews?.data[indexPath.row].user
            cell.reviewData = data
            cell.set_reviewUserData = user_data
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblDescriptinList{
            var data = arrDetails[indexPath.row]
            data["isSelected"] =  data["isSelected"] as? Bool == true ? false : true
            arrDetails[indexPath.row] = data
            self.tblDescriptinList.reloadData()
            setUpDescriptionListHeight()
        }else{
            
        }
    }
}

extension MPProductDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        if collectionView == collectionSlider{
            return CGSize(width: width, height: 275)
        }else if collectionView == collectionSize{
            return CGSize(width: (width-24)/3, height: 30)
        }else if collectionView == collectionSimilarProduct{
            return CGSize(width: width/2, height: 300)
        }else{
            return CGSize(width: 100, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionSlider{
            return self.arr_ImageVideo.count // (mpSelectProductData?.images.count ?? 0) + (mpSelectProductData?.videos.count ?? 0)
        }else if collectionView == collectionSize{
            return mpSelectProductData?.sizes.count ?? 0
        }else if collectionView == collectionSimilarProduct{
            return arr_RelatedProduct.count
        }else{
            return reviewImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionSlider{
            let cell = collectionView.dequeueReusableCell(withClass: MPImageCollectionCell.self, for: indexPath)
            
            let url_imgString = self.arr_ImageVideo[indexPath.row].image
            if url_imgString != "" {
                cell.img_playPause.isHidden = true
                if let url = URL(string: url_imgString) {
                    cell.imgP.sd_setImage(with: url, placeholderImage: appImage.default_Rsaience_logo)

                }
            }
            else {
                let url_videoString = self.arr_ImageVideo[indexPath.row].video
                if url_videoString != "" {

                    cell.img_playPause.isHidden = false

                    if let url = URL(string: url_videoString) {
                        //Temp comment
                        /*
                        HCVimeoVideoExtractor.fetchVideoURLFrom(url: url, completion: { ( video:HCVimeoVideo?, error:Error?) -> Void in
                            if let err = error {
                                print("Error = \(err.localizedDescription)")
                                DispatchQueue.main.async() {
                                    cell.imgP.image = nil
                                }
                                return
                            }
                            
                            guard let vid = video else {
                                print("Invalid video object")
                                return
                            }
                            
                            print("Title = \(vid.title), url = \(vid.videoURL), thumbnail = \(vid.thumbnailURL)")
                            
                            DispatchQueue.main.async() {
                                var url_video = vid.videoURL[.quality1080p]
                                if url_video == nil {
                                    url_video = vid.videoURL[.quality960p]
                                }
                                if url_video == nil {
                                    url_video = vid.videoURL[.quality720p]
                                }
                                if url_video == nil {
                                    url_video = vid.videoURL[.quality640p]
                                }
                                if url_video == nil {
                                    url_video = vid.videoURL[.quality540p]
                                }
                                if url_video == nil {
                                    url_video = vid.videoURL[.quality360p]
                                }
                                if url_video == nil {
                                    url_video = vid.videoURL[.qualityUnknown]
                                }
                                cell.imgP.accessibilityLabel = url_video?.absoluteString ?? ""
                                
                                if let url = vid.thumbnailURL[.qualityBase] {
                                    cell.imgP.sd_setImage(with: url, placeholderImage: appImage.default_Rsaience_logo)
                                }
                            }
                        })
                        */
                    }

                }
            }
            
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                cell.viewOutOfStockGradientColor.isHidden = self.btnAddToCart.tag == 2 ? false : true
                self.btnAddToCart.tag == 2 ? cell.viewOutOfStockGradientColor.setGradientBackground() : cell.viewOutOfStockGradientColor.removeOutOfStockGradient()
            }
            
            return cell
        }else if collectionView == collectionSize{
            let cell = collectionView.dequeueReusableCell(withClass: MPSizeCollectionCell.self, for: indexPath)
            
            cell.lbl_title.text = mpSelectProductData?.sizes[indexPath.row] ?? ""
            
            cell.viewBG.borderColor1 = UIColor(named: "mp-bg-blue")
            cell.viewBG.borderWidth1 = 1
            if indexPath.row == selectedSizeIndex{
                cell.viewBG.backgroundColor = UIColor(named: "mp-bg-blue")
                cell.lbl_title.textColor = .white
            }else{
                cell.viewBG.backgroundColor = .white
                cell.lbl_title.textColor = UIColor(named: "mp-bg-blue")
            }
            
            return cell
        }else if collectionView == collectionSimilarProduct{
            let cell = collectionView.dequeueReusableCell(withClass: MPTrendingProductCollectionCell.self, for: indexPath)
            cell.current_vc = self
            
            let dic_product = arr_RelatedProduct[indexPath.row]
            cell.productData = dic_product
            
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withClass: MPImageCollectionCell.self, for: indexPath)
            let urlString = reviewImages[indexPath.row].image
            if let url = URL(string: urlString) {
                cell.imgP.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionSlider{
            
            let dic = self.arr_ImageVideo[indexPath.row]
            let strVideo = dic.video
            if strVideo != "" {
                
                if let current_cell = collectionView.cellForItem(at: indexPath) as? MPImageCollectionCell {
                    let str_videoURL = current_cell.imgP.accessibilityLabel ?? ""
                    if let url = URL.init(string: str_videoURL) {
                        let player = AVPlayer(url: url)
                        let playerController = AVPlayerViewController()
                        playerController.player = player
                        self.present(playerController, animated: true) {
                            player.play()
                        }
                    }
                }
            }
            else {
                if let currentCell = collectionView.cellForItem(at: indexPath) as? MPImageCollectionCell {
                    SMPhotoViewer.showImage(toView: self, image: currentCell.imgP.image!, fromView: currentCell.imgP)
                }
            }
            
        }else if collectionView == collectionSize{
            selectedSizeIndex = indexPath.row
            collectionSize.reloadData()
            self.setProductData()
        }else if collectionView == collectionSimilarProduct{
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
        }else{
            
        }
    }
    
    func didSelectProduct(collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let data = arr_RelatedProduct[indexPath.row]
        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.str_productID = "\(data.id)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MPProductDetailVC: UIScrollViewDelegate
{
    //--ScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = collectionSlider.frame.size.width
        let currentPage = Float(collectionSlider.contentOffset.x / pageWidth)
        
        if 0.0 != fmodf(currentPage, 1.0) {
            pageController.currentPage = Int(currentPage + 1)
        } else {
            pageController.currentPage = Int(currentPage)
        }
        
        if pageController.currentPage == 2{
            //--
            
        }else{
            //--
            
        }
    }
}
