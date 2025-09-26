
//
//  MPProductViewAllVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 06/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
//import MoEngage

class MPProductViewAllVC: UIViewController, delegateSelectPincode {
    //MARK: - @IBOutlet
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_EnterPincode: UIButton!
    @IBOutlet weak var view_Bottom: UIView!
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var lbl_nodata: UILabel!
    @IBOutlet weak var view_enterPincode: UIView!
    @IBOutlet weak var costraint_view_Bottom_Height: NSLayoutConstraint!
    @IBOutlet weak var collectionList: UICollectionView!
    @IBOutlet weak var btn_cart: UIBarButtonItem!
    
    //MARK: - Veriable
    var str_Title = ""
    var screenFromm = ""
    var selected_productID = ""
    var screenFrom = ScreenType.k_none
    var mpDataType = MPDataType.none
    var dataSource = [MPData]()
    var arr_Products = [MPProductModel]()
    var selectCategory: MPCategoryData?
    
    var arr_Category = [MPCategoryModel]()
    var arr_HerbsProducts = [MPProductModel]()
    var arr_PopularProducts = [MPProductModel]()
    var arr_PopularBrand = [MPCategoryModel]()
    var arr_ProductTranding = [MPProductModel]()
    var arr_TopDealsForYou = [MPProductModel]()
    var arr_Newlylaunched = [MPProductModel]()
    var arr_RecmmendedProduct = [MPProductModel]()
    var arr_RecentProducts = [MPProductModel]()
    
    var selectedSortBy = ""
    var dic_Filter = [String: Any]()
    
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setupView()
        self.title = self.str_Title
        self.view_Nodata.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.btn_EnterPincode.setTitle("Delivering to: \(MPSelectPinCode)", for: .normal)
        
        //Call API
        callAPI()
        
        /*
         // self.setupView()
         if #available(iOS 15.0, *) {
         self.tableView.sectionHeaderTopPadding = 0
         } else {
         // Fallback on earlier versions
         }
         navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
         
         tableView.register(nibWithCellClass: MPCategoryCollectionCell.self)
         tableView.register(nibWithCellClass: MPAdsCell.self)
         tableView.register(nibWithCellClass: MPDontKnowWhatToBuyCell.self)
         tableView.register(nibWithCellClass: MPProductFeatureCell.self)
         self.manageSecion()*/
        NotificationCenter.default.addObserver(self, selector: #selector(self.productAddedToCart(notification:)), name: Notification.Name("productAddedToCart"), object: nil)
        
        
        if screenFrom == .MP_categoryProductOnly {
            if let catID =  selectCategory?.id {
                let dic: NSMutableDictionary = ["category_id": catID]
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.EVENT_CAT_CLICK.rawValue, properties: MOProperties.init(attributes: dic))
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionList.reloadData()
        MPSelectPinCode = self.getDeliveryPincode()
        self.btn_EnterPincode.setTitle("Delivering to: \(MPSelectPinCode)", for: .normal)
    }
    
    @objc func productAddedToCart(notification: Notification) {
        handleCartBadge()
        collectionList.reloadData()
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
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //tableView.reloadData()
    }
    func registerCell(){
        collectionList.register(UINib(nibName: "MPViewAllCollectionReusableCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MPViewAllCollectionReusableCell")
        collectionList.register(nibWithCellClass: MPCategoryCell.self)
        collectionList.register(nibWithCellClass: MPBrandCell.self)
        collectionList.register(nibWithCellClass: MPProductCell.self)
        collectionList.register(nibWithCellClass: MPRecommendedAdsCell.self)
        collectionList.register(nibWithCellClass: MPCartProductCollectionCell.self)
        collectionList.register(nibWithCellClass: MPTrendingProductCollectionCell.self)
        collectionList.register(nibWithCellClass: MPProductFullCollectionCell.self)
        collectionList.register(nibWithCellClass: MPMainTrendingProductCollectionCell.self)
    }
    
    func callAPI(){
        if screenFrom == .MP_ViewALL_Popular_brands {
            callAPIfor_brands()
        }else if screenFrom == .MP_brandProductOnly{
            if let catID =  selectCategory?.id{
                self.title = selectCategory?.name ?? ""
                callAPIfor_listBrandWise(brandID: "\(catID)")
            }
        }else if screenFrom == .MP_categoryProductOnly{
            if let catID =  selectCategory?.id{
                self.title = selectCategory?.name ?? ""
                callAPIfor_listCategoryWise(categoryID: "\(catID)", SuperVC: self)
            }
            else {
                if self.screenFromm == "home" {
                    self.title = str_Title
                    callAPIfor_listCategoryWise(categoryID: self.selected_productID, SuperVC: self)
                }
            }
        }else if screenFrom == .MP_ViewALL_SimilarProduct{
            callAPIfor_SimilarProducts(productID: selected_productID)
        }
        else {
            manageSection()
        }
    }
    
    func setupView() {
        if screenFrom == .MP_ViewALL_Categories ||  screenFrom == .MP_ViewALL_Popular_brands{
            self.view_Bottom.isHidden = true
            self.costraint_view_Bottom_Height.constant = 0
        }
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btn_EnterPincode_Action(_ sender: UIButton) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = SelectPincodeDialouge(nibName: "SelectPincodeDialouge", bundle: nil)
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    @IBAction func btn_Sort_Action(_ sender: UIControl) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = SortDialougeVC(nibName: "SortDialougeVC", bundle: nil)
            objDialouge.selectedSortBy = selectedSortBy
            
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
            
            objDialouge.didTappedSelectSort = { [self] (title) in
                self.selectedSortBy = title
                
                //
                if screenFrom == .MP_ViewALL_RecommendedProducts{
                    callAPIfor_RecommendedProduct()
                }else if screenFrom == .MP_ViewALL_HerdsProduct{
                    callAPIfor_popular_herbs()
                }else if screenFrom == .MP_ViewALL_PopularProducts{
                    callAPIfor_popularProducts()
                }else if screenFrom == .MP_ViewALL_TrendingProducts{
                    callAPIfor_product_tranding()
                }else if screenFrom == .MP_ViewALL_TopDealsForYou{
                    callAPIfor_product_topProducts()
                }else if screenFrom == .MP_ViewALL_NewlyLaunched{
                    callAPIfor_product_newlylaunched()
                }else if screenFrom == .MP_brandProductOnly{
                    
                }else if screenFrom == .MP_categoryProductOnly{
                    if let catID =  selectCategory?.id{
                        callAPIfor_listCategoryWise(categoryID: "\(catID)", SuperVC: self)
                    }
                }
                else if screenFrom == .MP_ViewALL_SimilarProduct{
                    callAPIfor_SimilarProducts(productID: self.selected_productID)
                }
                else if screenFrom == .MP_ViewALL_RecentProduct {
                    self.showActivityIndicator()
                    callAPIfor_recent_products()
                }
            }
        }
    }
    
    @IBAction func btn_Filter_Action(_ sender: UIControl) {
        //--
        let vc = MPFilterVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.dic_FilterSelection = dic_Filter
        vc.str_ScreenID = self.selected_productID
        
        if screenFrom == .MP_ViewALL_HerdsProduct{
        }else if screenFrom == .MP_ViewALL_PopularProducts{
            vc.str_Screen_Name = "popularProducts"
        }else if screenFrom == .MP_ViewALL_TrendingProducts{
            vc.str_Screen_Name = "tranding"
        }else if screenFrom == .MP_ViewALL_TopDealsForYou{
            vc.str_Screen_Name = "topProducts"
        }else if screenFrom == .MP_ViewALL_NewlyLaunched{
            vc.str_Screen_Name = "newlylaunched"
        }else if screenFrom == .MP_brandProductOnly{
            vc.str_Screen_Name = "featured_brands"
        }else if screenFrom == .MP_categoryProductOnly {
            vc.str_Screen_Name = "listCategoryWise"
        }else if screenFrom == .MP_ViewALL_SimilarProduct{
            vc.str_Screen_Name = "similarProducts"
        }else if screenFrom == .MP_ViewALL_RecommendedProducts {
            vc.str_Screen_Name = "recommendedProducts"
        }else if screenFrom == .MP_ViewALL_RecentProduct {
            vc.str_Screen_Name = "RecentViewed"
        }
        
        
//        vc.arr_PopularBrand = arr_PopularBrand
//        vc.arr_Category = arr_Category
        vc.didTappedApplyFilter = { [self] (sender, dicfilter) in
            self.dic_Filter = dicfilter
            
            if screenFrom == .MP_ViewALL_HerdsProduct{
                if MPApplyFilter{
                    callAPIfor_popular_herbs()
                }
            }
            else if screenFrom == .MP_ViewALL_RecentProduct {
                if MPApplyFilter{
                    callAPIfor_recent_products()
                }
            }
            else if screenFrom == .MP_ViewALL_RecommendedProducts{
                if MPApplyFilter{
                    callAPIfor_RecommendedProduct()
                }
            }else if screenFrom == .MP_ViewALL_PopularProducts{
                if MPApplyFilter{
                    callAPIfor_popularProducts()
                }
            }else if screenFrom == .MP_ViewALL_TrendingProducts{
                if MPApplyFilter{
                    callAPIfor_product_tranding()
                }
            }else if screenFrom == .MP_ViewALL_TopDealsForYou{
                if MPApplyFilter{
                    callAPIfor_product_topProducts()
                }
            }else if screenFrom == .MP_ViewALL_NewlyLaunched{
                if MPApplyFilter{
                    callAPIfor_product_newlylaunched()
                }
            }else if screenFrom == .MP_brandProductOnly{
                if let catID =  selectCategory?.id{
                    callAPIfor_listBrandWise(brandID: "\(catID)")
                }
            }else if screenFrom == .MP_categoryProductOnly{
                if let catID =  selectCategory?.id{
                    callAPIfor_listCategoryWise(categoryID: "\(catID)", SuperVC: self)
                }
            }
            else if screenFrom == .MP_ViewALL_SimilarProduct{
                callAPIfor_SimilarProducts(productID: self.selected_productID)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Cart_Action(_ sender: UIButton) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view cart".localized(), controller: self)
            return
        }
        
        let vc = MPCartVC.instantiate(fromAppStoryboard: .MarketPlace)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Method After Entered Pincode
    func Clk_After_selectPinCode(_ success: Bool, pincode: String, address_id: String) {
        if success {
            if pincode != "" {
                MPSelectPinCode = pincode
                setDeliveryPincode(pincode, selected_address_id: address_id)
                self.btn_EnterPincode.setTitle("Delivering to: \(pincode)", for: .normal)
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
            self.btn_EnterPincode.setTitle("Delivering to: \(strPincode)", for: .normal)
        }
        return deliveryPincode
    }
    
}

extension MPProductViewAllVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func manageSection() {
        //--
        self.hideActivityIndicator()
        self.dataSource.removeAll()
        if screenFrom == .MP_ViewALL_Categories{
            self.dataSource.append(MPData(title: "CATEGORIES", type: .category, subData: self.arr_Category))
            self.dataSource.append(MPData(title: "ALL PRODUCTS", type: .popularProducts, subData: self.arr_PopularProducts))
            self.dataSource.append(MPData(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: self.arr_ProductTranding))
            self.dataSource.append(MPData(title: "TOP DEALS FOR YOU", type: .topDealsForYou, subData: self.arr_TopDealsForYou))
            self.dataSource.append(MPData(title: "NEWLY LAUNCHED", type: .newlyLaunched, subData: self.arr_Newlylaunched))
            
        }else if screenFrom == .MP_ViewALL_RecommendedProducts {
            
            self.view_Nodata.isHidden = arr_RecmmendedProduct.count == 0 ? false : true
            self.dataSource.append(MPData(title: "RECOMMENDED FOR YOU", type: .popularProducts, subData: self.arr_RecmmendedProduct))
        
        }else if screenFrom == .MP_ViewALL_HerdsProduct{
            self.dataSource.append(MPData(title: "POPULAR HERBS", type: .herbsProducts, subData: self.arr_HerbsProducts))
            
            self.view_Nodata.isHidden = arr_PopularProducts.count == 0 ? false : true
        }else if screenFrom == .MP_ViewALL_PopularProducts{
            self.dataSource.append(MPData(title: "ALL PRODUCTS", type: .popularProducts, subData: self.arr_PopularProducts))
            
            self.view_Nodata.isHidden = arr_PopularProducts.count == 0 ? false : true
        }else if screenFrom == .MP_ViewALL_Popular_brands{
            self.dataSource.append(MPData(title: "POPULAR BRANDS", type: .popular_brands, subData: self.arr_PopularBrand))
            self.dataSource.append(MPData(title: "ALL PRODUCTS", type: .popularProducts, subData: self.arr_PopularProducts))
            self.dataSource.append(MPData(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: self.arr_ProductTranding))
            self.dataSource.append(MPData(title: "TOP DEALS FOR YOU", type: .topDealsForYou, subData: self.arr_TopDealsForYou))
            self.dataSource.append(MPData(title: "NEWLY LAUNCHED", type: .newlyLaunched, subData: self.arr_Newlylaunched))
            
        }else if screenFrom == .MP_ViewALL_TrendingProducts{
            self.dataSource.append(MPData(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: self.arr_ProductTranding))
            
            self.view_Nodata.isHidden = arr_ProductTranding.count == 0 ? false : true
        }else if screenFrom == .MP_ViewALL_TopDealsForYou{
            self.dataSource.append(MPData(title: "TOP DEALS FOR YOU", type: .topDealsForYou, subData: self.arr_TopDealsForYou))
            
            self.view_Nodata.isHidden = arr_TopDealsForYou.count == 0 ? false : true
        }else if screenFrom == .MP_ViewALL_NewlyLaunched{
            self.dataSource.append(MPData(title: "NEWLY LAUNCHED", type: .newlyLaunched, subData: self.arr_Newlylaunched))
           
            self.view_Nodata.isHidden = arr_Newlylaunched.count == 0 ? false : true
        }else if screenFrom == .MP_brandProductOnly{
            self.dataSource.removeAll()
            self.dataSource.append(MPData(title: "", type: .brandAllProduct, subData: arr_Products))
            
            self.view_Nodata.isHidden = arr_Products.count == 0 ? false : true
        }else if screenFrom == .MP_categoryProductOnly{
            self.dataSource.removeAll()
            self.dataSource.append(MPData(title: "", type: .categoryAllProduct, subData: arr_Products))
            
            self.view_Nodata.isHidden = arr_Products.count == 0 ? false : true
        }
        else if screenFrom == .MP_ViewALL_SimilarProduct {
            self.dataSource.removeAll()
            self.dataSource.append(MPData(title: "", type: .similarProducts, subData: arr_Products))
            self.view_Nodata.isHidden = arr_Products.count == 0 ? false : true
        }
        else if screenFrom == .MP_ViewALL_RecentProduct{
            self.dataSource.append(MPData(title: "RECENT VIEWED PRODUCTS", type: .recentViewdProducts, subData: self.arr_RecentProducts))
            
            self.view_Nodata.isHidden = arr_RecentProducts.count == 0 ? false : true
        }
        
        self.collectionList.reloadData()

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let data = dataSource[section]
        if mpDataType == data.type || mpDataType == .categoryAllProduct || mpDataType == .brandAllProduct{
            return CGSize(width: 0, height: 0)
        }else{
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
            header.lblTitle.text = data.title
            
            if data.subData.count == 0 { return header }
            switch data.type {
            case .category:
                let dic_category = data.subData.first as! MPCategoryModel
                header.btnViewAll.isHidden = dic_category.data.count >= 6 && screenFrom != .MP_ViewALL_Categories ? false : true
                break
            case .recommendedProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_RecommendedProducts ? false : true
                break
            case .herbsProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_HerdsProduct ? false : true
                break
            case .recentViewdProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_RecentProduct ? false : true
                break
            case .popularProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_PopularProducts ? false : true
                break
            case .popular_brands:
                let dic_category = data.subData.first as! MPCategoryModel
                header.btnViewAll.isHidden = dic_category.data.count >= 6 && screenFrom != .MP_ViewALL_Popular_brands ? false : true
                break
            case .trendingProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_TrendingProducts ? false : true
                break
            case .topDealsForYou:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_TopDealsForYou ? false : true
                break
            case .newlyLaunched:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 && screenFrom != .MP_ViewALL_NewlyLaunched ? false : true
                break
            case .brandAllProduct:
                header.btnViewAll.isHidden = true
                break
            case .categoryAllProduct:
                header.btnViewAll.isHidden = true
                break
            default:
                
                break
            }
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
    @objc func btnViewAllCollectionSection(sender: UIButton){
        let index = sender.tag
        let data = dataSource[index]
        
        let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
        switch data.type {
        case .category:
            vc.screenFrom = .MP_ViewALL_Categories
            vc.mpDataType = .category
            break
        case .recommendedProducts:
            vc.screenFrom = .MP_ViewALL_RecommendedProducts
            vc.mpDataType = .recommendedProducts
            break
        case .herbsProducts:
            vc.screenFrom = .MP_ViewALL_HerdsProduct
            vc.mpDataType = .herbsProducts
            break
        case .popularProducts:
            vc.screenFrom = .MP_ViewALL_PopularProducts
            vc.mpDataType = .popularProducts
            break
        case .popular_brands:
            vc.screenFrom = .MP_ViewALL_Popular_brands
            vc.mpDataType = .popular_brands
            break
        case .trendingProducts:
            vc.screenFrom = .MP_ViewALL_TrendingProducts
            vc.mpDataType = .trendingProducts
            break
        case .topDealsForYou:
            vc.screenFrom = .MP_ViewALL_TopDealsForYou
            vc.mpDataType = .topDealsForYou
            break
        case .newlyLaunched:
            vc.screenFrom = .MP_ViewALL_NewlyLaunched
            vc.mpDataType = .newlyLaunched
            break
        default:
            break
        }
        vc.str_Title = data.title ?? ""
        
        vc.arr_Category = arr_Category
        vc.arr_HerbsProducts = arr_HerbsProducts
        vc.arr_PopularProducts = arr_PopularProducts
        vc.arr_PopularBrand = arr_PopularBrand
        vc.arr_ProductTranding = arr_ProductTranding
        vc.arr_TopDealsForYou = arr_TopDealsForYou
        vc.arr_Newlylaunched = arr_Newlylaunched
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = dataSource[section]
        if data.subData.count == 0 { return 0 }
        switch data.type {
        case .category:
            let dic_category = data.subData.first as! MPCategoryModel
            return dic_category.data.count
            
        case .recommendedProducts:
            return 0
        
        case .herbsProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .recentViewdProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .popularProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .popular_brands:
            let dic_category = data.subData.first as! MPCategoryModel
            return dic_category.data.count
            
        case .trendingProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .topDealsForYou:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .newlyLaunched:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .brandAllProduct:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count
            
        case .similarProducts:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count
            
        case .categoryAllProduct:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count
            
        default:
            return 0
        }
    }
    func collectionViewNumberOfItemsInSection_Product(collectionView: UICollectionView, numberOfItemsInSection section: Int)  -> Int {
        let data = dataSource[section]
        let dic_product = data.subData.first as! MPProductModel
        if screenFrom == .MP_ViewALL_Categories || screenFrom == .MP_ViewALL_Popular_brands{
            return dic_product.data.count > 0  ? 1 : 0
        }else{
            return dic_product.data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        //let height = UIScreen.main.bounds.height
        
        let data = dataSource[indexPath.section]
        switch data.type {
        case .category:
            return CGSize(width: width/3, height: 150)
        case .recommendedProducts:
            return CGSize(width: 0, height: 0)
            
        case .herbsProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .recentViewdProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .popularProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .popular_brands:
            return CGSize(width: width/3, height: 150)
        case .trendingProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .topDealsForYou:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .newlyLaunched:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .brandAllProduct:
            return CGSize(width: width/2, height: 300)
        case .similarProducts:
            return CGSize(width: width/2, height: 300)
        case .categoryAllProduct:
            return CGSize(width: width/2, height: 300)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionViewSizeForItemAt_Product(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = UIScreen.main.bounds.width
        if screenFrom == .MP_ViewALL_Categories || screenFrom == .MP_ViewALL_Popular_brands{
            return CGSize(width: width, height: 300)
        }else{
            return CGSize(width: width/2, height: 300)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.section]
        switch data.type {
        case .category:
            let cell = collectionView.dequeueReusableCell(withClass: MPCategoryCell.self, for: indexPath)
            
            let dic_category = data.subData.first as! MPCategoryModel
            
            cell.titleL.text = dic_category.data[indexPath.row].name
            
            let urlString = dic_category.data[indexPath.row].image
            if let url = URL(string: urlString) {
                cell.picIV.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
            }
            
            return cell
        case .recommendedProducts:
            let cell = collectionView.dequeueReusableCell(withClass: MPProductCell.self, for: indexPath)
            
            return cell
            
        case .herbsProducts:
            return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        case .recentViewdProducts:
            return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        case .popularProducts:
            if screenFrom == .MP_ViewALL_Categories || screenFrom == .MP_ViewALL_Popular_brands{
                return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            }else{
                return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            }

        case .popular_brands:
            let cell = collectionView.dequeueReusableCell(withClass: MPBrandCell.self, for: indexPath)
            cell.viewbgInner.clipsToBounds = true
            
            let dic_category = data.subData.first as! MPCategoryModel
            
            cell.lblTitle.text = dic_category.data[indexPath.row].name
            
            let urlString = dic_category.data[indexPath.row].icon
            if let url = URL(string: urlString) {
                cell.picIV.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
            }
            
            return cell
        case .trendingProducts:
            if screenFrom == .MP_ViewALL_Categories || screenFrom == .MP_ViewALL_Popular_brands{
                return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
                
            }else{
                return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            }
            
        case .topDealsForYou:
            if screenFrom == .MP_ViewALL_Categories || screenFrom == .MP_ViewALL_Popular_brands{
                return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
                
            }else{
                return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
                
            }
        case .newlyLaunched:
            if screenFrom == .MP_ViewALL_Categories || screenFrom == .MP_ViewALL_Popular_brands{
                return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
                
            }else{
                return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            }
        case .brandAllProduct:
            return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        case .similarProducts:
            return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        case .categoryAllProduct:
            return cellForRow_MPTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        default:
            let cell = collectionView.dequeueReusableCell(withClass: MPProductCell.self, for: indexPath)
            
            return cell
        }
    }
    
    func cellForRow_MPMainTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPMainTrendingProductCollectionCell.self, for: indexPath)
        cell.current_vc = self
        
        cell.data = dataSource[indexPath.section]
        cell.screenFrom = screenFrom
        return cell
    }
    func cellForRow_MPTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPTrendingProductCollectionCell.self, for: indexPath)
        cell.current_vc = self
        let data = dataSource[indexPath.section]
        let dic_product = data.subData.first as! MPProductModel
        
        cell.productData = dic_product.data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataSource[indexPath.section]
        
        switch data.type {
        case .category:
            //--
            let dic_category = data.subData.first as! MPCategoryModel
            //--
            let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.str_Title = dic_category.data[indexPath.row].name
            vc.selectCategory = dic_category.data[indexPath.row]
            vc.screenFrom = .MP_categoryProductOnly
            vc.mpDataType = .categoryAllProduct
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .recommendedProducts:
            
            break
        case .herbsProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
            
        case .recentViewdProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
            
        case .popularProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
        case .popular_brands:
            //--
            let dic_category = data.subData.first as! MPCategoryModel
            //--
            let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.str_Title = dic_category.data[indexPath.row].name
            vc.selectCategory = dic_category.data[indexPath.row]
            vc.screenFrom = .MP_brandProductOnly
            vc.mpDataType = .brandAllProduct
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .trendingProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
        case .topDealsForYou:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
        case .newlyLaunched:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
        case .brandAllProduct:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
            
        case .similarProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
            
        case .categoryAllProduct:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
        default:
            
            break
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
