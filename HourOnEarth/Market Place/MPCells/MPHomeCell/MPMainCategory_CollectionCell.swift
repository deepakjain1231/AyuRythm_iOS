//
//  MPMainCategory_CollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 19/02/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class MPMainCategory_CollectionCell: UICollectionViewCell, delegate_recomded {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var collectionList: UICollectionView!
    @IBOutlet weak var viewDisable: UIView!
    
    //MARK: - Veriable
    var isLockScreen = true
    var screenFrom = ScreenType.k_none
    var completionAddToCart: (() -> ())? = nil
    var completionRecommendedContinue: (() -> ())? = nil
    var data: MPData? {
        didSet {
            self.viewDisable.isHidden = isLockScreen

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
            objDialouge.screenFrom = .MP_categories
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

extension MPMainCategory_CollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func manageSection() {
        self.collectionList.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width/2, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dic_categroy = self.data?.subData.first as? MPCategoryModel else { return 0 }
        return dic_categroy.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: MPCategoryCell.self, for: indexPath)
        
        let dic_category = self.data?.subData.first as! MPCategoryModel
        
        cell.titleL.text = dic_category.data[indexPath.row].name
        
        let urlString = dic_category.data[indexPath.row].icon
        if let url = URL(string: urlString) {
            cell.picIV.af.setImage(withURL: url)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }
    
}
