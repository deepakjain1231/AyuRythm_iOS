//
//  MPFavoriteVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 14/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPFavoriteVC: UIViewController {
    
    var str_Title = ""
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    
    var dataSource = [MPData]()
    var arr_Category = [MPCategoryModel]()
    var arr_FavoriteProduct = [MPProductModel]()
    var arr_ProductTranding = [MPProductModel]()
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSearchBar()
        self.title = "Favourite"
        self.view_NoData.isHidden = true
        navigationItem.backButtonTitle = ""
        registerCell()
        callAPIforGetWishListProduct()
        
        
        NotificationCenter.default.addObserver(forName: .refreshProductData, object: nil, queue: nil) { [weak self] notif in
            self?.callAPIforGetWishListProduct()
        }
        
        NotificationCenter.default.addObserver(forName: .refreshWishlistProductData, object: nil, queue: nil) { [weak self] notif in
            self?.callAPIforGetWishListProduct()
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func registerCell(){
        collection_view.register(UINib(nibName: "MPViewAllCollectionReusableCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MPViewAllCollectionReusableCell")
        collection_view.register(nibWithCellClass: MPCategoryCell.self)
        collection_view.register(nibWithCellClass: NoDataCollectionCell.self)
        collection_view.register(nibWithCellClass: MPTrendingProductCollectionCell.self)
        collection_view.register(nibWithCellClass: MPMainTrendingProductCollectionCell.self)
    }
    
    func manageSection() {
        self.dataSource.removeAll()
        if self.arr_FavoriteProduct.count == 0 {
            self.view_NoData.isHidden = false
            //self.dataSource.append(MPData.init(title: "No favorites yet", type: .noData, subData: []))
            //self.dataSource.append(MPData.init(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: arr_ProductTranding))
        }
        else {
            self.view_NoData.isHidden = true
            //self.dataSource.append(MPData(title: "CATEGORIES", type: .category, subData: self.arr_Category))
            self.dataSource.append(MPData.init(title: "", type: .wishlistProduct, subData: arr_FavoriteProduct))
        }
        
        self.collection_view.reloadData()
    }
    
    private func showSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func hideSearchBar() {
        navigationItem.searchController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_ShopNow_Action(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            UIApplication.topViewController?.tabBarController?.selectedIndex = 2
        }
    }
    
}


extension MPFavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let data = dataSource[section]
        if data.type == .noData || data.type == .wishlistProduct {
            return CGSize(width: 0, height: 0)
        }
        else {
            return CGSize(width: UIScreen.main.bounds.width-30, height: 50.0)
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MPViewAllCollectionReusableCell", for: indexPath) as! MPViewAllCollectionReusableCell
            //--
            header.btnViewAll.tag = indexPath.section
            header.btnViewAll.addTarget(self, action: #selector(btnViewAllCollectionSection(sender:)), for: .touchUpInside)
            
            //--
            let data = dataSource[indexPath.section]
            if data.type == .noData {
                header.lblTitle.text = ""
                header.btnViewAll.isHidden = true
            }
            else if data.type == .category {
                header.lblTitle.text = data.title
                header.btnViewAll.isHidden = true
                if let dic_category = data.subData.first as? MPCategoryModel {
                    header.btnViewAll.isHidden = dic_category.data.count >= 6 ? false : true
                }
            }
            else if data.type == .trendingProducts {
                header.lblTitle.text = data.title
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
            }
            if data.subData.count == 0 { return header }
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
    @objc func btnViewAllCollectionSection(sender: UIButton){
        let index = sender.tag
        let data = dataSource[index]
        let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
        if data.type == .trendingProducts {
            vc.screenFrom = .MP_ViewALL_TrendingProducts
            vc.mpDataType = .trendingProducts
        }
        vc.str_Title = data.title ?? ""
        //        vc.arr_Category = arr_Category
//        vc.arr_PopularProducts = arr_PopularProducts
//        vc.arr_PopularBrand = arr_PopularBrand
//        vc.arr_ProductTranding = arr_ProductTranding
//        vc.arr_TopDealsForYou = arr_TopDealsForYou
//        vc.arr_Newlylaunched = arr_Newlylaunched
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = dataSource[section]
        if data.type == .noData {
            return 1
        }
        else {
            if data.subData.count == 0 { return 0 }
            if data.type == .category {
                let dic_category = data.subData.first as! MPCategoryModel
                return dic_category.data.count >= 6 ? 6 : dic_category.data.count
            }
            else if data.type == .trendingProducts {
                let dic_product = data.subData.first as! MPProductModel
                return dic_product.data.count > 0 ? 1 : 0
            }
            else if data.type == .wishlistProduct {
                let dic_product = data.subData.first as! MPProductModel
                return dic_product.data.count
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let data = dataSource[indexPath.section]
        if data.type == .noData {
            return CGSize(width: width, height: 275)
        }
        else if data.type == .category {
            return CGSize(width: width/3, height: 150)
        }
        else if data.type == .wishlistProduct {
            return CGSize(width: width/2, height: heightMPMainTrendingProductCollectionCell)
        }
        else if data.type == .trendingProducts {
            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.section]
        if data.type == .noData {
            let cell = collectionView.dequeueReusableCell(withClass: NoDataCollectionCell.self, for: indexPath)
            cell.lbl_subTitle.text = ""
            cell.btn_ShopNow.isHidden = false
            cell.lbl_Title.text = "No favorites yet"
            cell.constraint_lbl_Title_TOP.constant = 60
            cell.img_icon.image = UIImage.init(named: "icon_no_fav")
            
            cell.did_TappedShopNow = { (sender) in
                self.navigationController?.popViewController(animated: true)
            }
            
            return cell
        }
        else if  data.type == .category {
            let cell = collectionView.dequeueReusableCell(withClass: MPCategoryCell.self, for: indexPath)
            
            let dic_category = data.subData.first as! MPCategoryModel
                
            cell.titleL.text = dic_category.data[indexPath.row].name
            
            let urlString = dic_category.data[indexPath.row].icon
            if let url = URL(string: urlString) {
                cell.picIV.af.setImage(withURL: url)
            }
            
            return cell
        }
        else if  data.type == .trendingProducts {
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
        }
        else if data.type == .wishlistProduct {
            return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
        }
        else {
            let cell = collectionView.dequeueReusableCell(withClass: MPProductCell.self, for: indexPath)
            
            return cell
        }
    }
    
    func cellForRow_MPMainTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPMainTrendingProductCollectionCell.self, for: indexPath)
        cell.current_vc = self
        cell.data = dataSource[indexPath.section]
        return cell
    }
    
    func cellForRow_MPTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPTrendingProductCollectionCell.self, for: indexPath)
        cell.current_vc = self
        
        let data = dataSource[indexPath.section]
        let dic_product = data.subData.first as! MPProductModel
        cell.screenFrommm = .MP_Product_Wishlist
        cell.productData = dic_product.data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataSource[indexPath.section]
        
        if data.type == .trendingProducts || data.type == .wishlistProduct {
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
        }
    }
    
    func didSelectProduct(collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let data = dataSource[indexPath.section]
        let dic_product = data.subData.first as! MPProductModel
        //--
        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.str_productID = "\(dic_product.data[indexPath.row].id)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

