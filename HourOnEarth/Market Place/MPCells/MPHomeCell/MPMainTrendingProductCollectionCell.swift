//
//  MPMainTrendingProductCollectionCell.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 10/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPMainTrendingProductCollectionCell: UICollectionViewCell, delegate_recomded {

    var current_vc = UIViewController()
    //MARK: - @IBOutlet
    @IBOutlet weak var collectionList: UICollectionView!
    @IBOutlet weak var viewDisable: UIView!
    
    //MARK: - Veriable
    var isLockScreen = true
    var screenFrom = ScreenType.k_none
    var main_screenFrom = ScreenType.k_none
    var completionAddToCart: (() -> ())? = nil
    var completionRecommendedContinue: (() -> ())? = nil
    var data: MPData? {
        didSet {
            //guard let data = data else { return }
            if self.data?.type == .recommendedProducts{
                self.viewDisable.isHidden = isLockScreen
                
                if let flowLayout = collectionList.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.scrollDirection = .horizontal
                }
                
            }else if self.data?.type == .category {
                self.viewDisable.isHidden = isLockScreen
                
                if let flowLayout = collectionList.collectionViewLayout as? UICollectionViewFlowLayout {
                    if self.main_screenFrom == .MP_SearchScreen {
                        flowLayout.scrollDirection = .horizontal
                    }
                    else {
                        flowLayout.scrollDirection = .vertical
                    }
                }
            }else{
                self.viewDisable.isHidden = true
                
                if let flowLayout = collectionList.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.scrollDirection = .horizontal
                }
            }
            collectionList.reloadData()
            NotificationCenter.default.addObserver(self, selector: #selector(self.productAddedToCart(notification:)), name: Notification.Name("productAddedToCart"), object: nil)
        }
    }
    
    @objc func productAddedToCart(notification: Notification) {
        collectionList.reloadData()
    }
    
    //MARK: - Func
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionList.register(nibWithCellClass: MPTrendingProductCollectionCell.self)
        collectionList.register(nibWithCellClass: MPCategoryCell.self)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionList.reloadData()
    }
    
    @IBAction func btnLockAction(_ sender: UIButton){
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = RecommendedProductAlertDialouge(nibName: "RecommendedProductAlertDialouge", bundle: nil)
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    //MARK: - Clk on Recomeded Product
    func clkOnContuniforRecomendedProduct(is_success: Bool) {
        if self.completionRecommendedContinue != nil{
            self.completionRecommendedContinue!()
        }
    }
}

extension MPMainTrendingProductCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func manageSection() {
        //self.dataSource.removeAll()
        
        self.collectionList.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        //let height = UIScreen.main.bounds.height
        if screenFrom == .MP_categories
        {
            return CGSize(width: width/3, height: 150)
        }else{
            return CGSize(width: width/2, height: 300)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if screenFrom == .MP_categories
        {
            guard let dic_categroy = self.data?.subData.first as? MPCategoryModel else { return 0 }
            return dic_categroy.data.count
        }else{
            guard let dic_product = self.data?.subData.first as? MPProductModel else { return 0 }
            return dic_product.data.count >= 5 ? 5 : dic_product.data.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if screenFrom == .MP_categories
        {
            let cell = collectionView.dequeueReusableCell(withClass: MPCategoryCell.self, for: indexPath)
            
            let dic_category = self.data?.subData.first as! MPCategoryModel
                
            cell.titleL.text = dic_category.data[indexPath.row].name
            
            let urlString = dic_category.data[indexPath.row].icon
            if let url = URL(string: urlString) {
                cell.picIV.af.setImage(withURL: url)
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withClass: MPTrendingProductCollectionCell.self, for: indexPath)
            cell.current_vc = self.current_vc
            
            let dic_product = self.data?.subData.first as! MPProductModel
            cell.productData = dic_product.data[indexPath.row]
            cell.completionAddToCart = {
                if self.completionAddToCart != nil{
                    self.completionAddToCart!()
                }
            }
            return cell
        }

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if screenFrom == .MP_categories {
            //--
            let dic_category = self.data?.subData.first as! MPCategoryModel
            //--
            let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.str_Title = dic_category.data[indexPath.row].name
            vc.selectCategory = dic_category.data[indexPath.row]
            vc.screenFrom = .MP_categoryProductOnly
            vc.mpDataType = .categoryAllProduct
            vc.selected_productID = "\(dic_category.data[indexPath.row].id)"
            findtopViewController()?.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
        }
    }
    func didSelectProduct(collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let dic_product = data?.subData.first as! MPProductModel
        //--
        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.str_productID = "\(dic_product.data[indexPath.row].id)"
        findtopViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
