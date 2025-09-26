////
////  MPProductCollectionCell.swift
////  HourOnEarth
////
////  Created by Paresh Dafda on 12/11/21.
////  Copyright © 2021 AyuRythm. All rights reserved.
////
//
//import UIKit
//
//class MPProductCollectionCell: UITableViewCell {
//    
//    var current_vc = UIViewController()
//    @IBOutlet weak var titleL: UILabel!
//    @IBOutlet weak var btn_ViewAll: UIButton!
//    @IBOutlet weak var lbl_underline: UILabel!
//    @IBOutlet weak var view_lockLayer: UIControl!
//    @IBOutlet weak var header_stack: UIStackView!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var constraint_btnViewAll_Width: NSLayoutConstraint!
//    @IBOutlet weak var constraint_btnViewAll_Height: NSLayoutConstraint!
//    @IBOutlet weak var constraint_collection_Leading: NSLayoutConstraint!
//    @IBOutlet weak var constraint_collection_Trelling: NSLayoutConstraint!
//    
//    var typee = MPDataType.none
//    var str_ScreenType = ScreenType.k_none
//    var subData = [Any]()
//    var didTappedView_All: ((UIButton)->Void)? = nil
//    var didTappedLockViewLayer: ((UIControl)->Void)? = nil
//    var completionhanlder: ((String)->Void)? = nil
//    
//    var data: MPData? {
//        didSet {
//            guard let data = data else { return }
//            titleL.text = data.title
//            subData = data.subData
//            collectionView.reloadData()
//            NotificationCenter.default.addObserver(self, selector: #selector(self.productAddedToCart(notification:)), name: Notification.Name("productAddedToCart"), object: nil)
//        }
//    }
//
//    @objc func productAddedToCart(notification: Notification) {
//        collectionView.reloadData()
//    }
//
//    var data_typee: MPDataType? {
//        didSet {
//            self.typee = data_typee ?? .none
//            if self.typee == .trendingProducts {
//                self.view_lockLayer.isHidden = true
//                self.constraint_btnViewAll_Width.constant = 75
//                self.titleL.text = "     \(self.titleL.text ?? "")"
//                self.constraint_collection_Leading.constant = 10
//                self.constraint_collection_Trelling.constant = 10
//                self.btn_ViewAll.contentHorizontalAlignment = .left;
//                self.btn_ViewAll.setTitle("VIEW ALL", for: .normal)
//
//                collectionView.setupUISpace(allSide: 0, itemSpacing: 15, lineSpacing: 16 )
//                if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                    flowLayout.scrollDirection = .vertical
//                }
//            }
//            collectionView.reloadData()
//        }
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.view_lockLayer.isHidden = true
//        collectionView.setupUISpace(allSide: 0, itemSpacing: 0, lineSpacing: 16)
//        collectionView.register(nibWithCellClass: MPProductCell.self)
//        collectionView.register(nibWithCellClass: MPRecommendedAdsCell.self)
//        collectionView.register(nibWithCellClass: MPCartProductCollectionCell.self)
//        collectionView.register(nibWithCellClass: MPTrendingProductCollectionCell.self)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        collectionView.reloadData()
//    }
//    
//    @IBAction func viewAllBtnPressed(sender: UIButton) {
//        print("View all btn pressed")
//    }
//    
//    //MARK: - UIButton Method Action
//    @IBAction func btn_viewAll_Action(_ sender: UIButton) {
//        if self.didTappedView_All != nil {
//            self.didTappedView_All!(sender)
//        }
//    }
//    
//    //MARK: - UIButton Method Action
//    @IBAction func btn_productLock_Action(_ sender: UIButton) {
//        if self.didTappedLockViewLayer != nil {
//            self.didTappedLockViewLayer!(sender)
//        }
//    }
//}
//
//extension MPProductCollectionCell {
//    var isShowRecommendedProductsAd: Bool {
//        return subData.isEmpty && data?.type == .recommendedProducts
//    }
//}
//
//
//extension MPProductCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if self.typee == .trendingProducts {
//            guard let dic_product = self.data?.subData.first as? MPProductModel else { return 0 }
//            return dic_product.data.count > 6 ? 6 : dic_product.data.count
//        }else {
//            return 0
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        var cellWidth = collectionView.frame.size.width/2 - 8
//        cellWidth = min(cellWidth, 170)
//        return CGSize(width: cellWidth, height: collectionView.frame.size.height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        let cell = collectionView.dequeueReusableCell(withClass: MPTrendingProductCollectionCell.self, for: indexPath)
//        cell.current_vc = self
//        
//        if let dic_product = self.data?.subData.first as? MPProductModel{
//            let cruPrice: Double = Double(dic_product.data[indexPath.row].current_price)
//            let prvPrice: Double = Double(dic_product.data[indexPath.row].previous_price)
//            cell.lblTitle.text = dic_product.data[indexPath.row].title
//            cell.lblPrice.text = "₹ \(cruPrice)"
//            
//            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "MRP ₹ \(prvPrice)")
//            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
//            cell.lblMRP.attributedText = attributeString
//            
//            //cell.lblOff.text = ""
//            
//            let urlString = dic_product.data[indexPath.row].thumbnail
//            if let url = URL(string: urlString) {
//                cell.imgProduct.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
//            }
//        }
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    }
//}
