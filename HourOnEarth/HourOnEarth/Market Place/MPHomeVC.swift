//
//  MPHomeVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 11/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

enum MPDataType: Int {
    case none
    case category
    case offer_banner
    case recommendedProducts
    case popularProducts
    case popular_brands
    case trendingProducts
    case topDealsForYou
    case newlyLaunched
    case brandAllProduct
    case categoryAllProduct
    case herbsProducts
    case ads
    case cartListings
    case wishlistProduct
    case similarProducts
    case recentViewdProducts
    
    case other
    //case popularHerbs
    case dontKnowWhatToBuy
    case productFeatures
    case topimageCell
    case choosePackSize
    case productInfo
    case delivery_info
    case noData
    case searchKeyword
    case cartProduct
    case cartPriceDetail
    case select_myLocation
    case pincode
    case houseNo
    case area
    case city_state
    case landmark
    case contact_Details_Title
    case fullName
    case mobile
    case address_Type_Title
    case home_office
    case address_Type
    case email
    
}

class MPData {
    var title: String?
    var type: MPDataType
    var subData: [Any]
    
    internal init(title: String? = nil, type: MPDataType = .other, subData: [Any]) {
        self.title = title
        self.type = type
        self.subData = subData
    }
}

class MPHomeVC: BaseViewController, delegateSelectPincode {
    //MARK: - @IBOutlet
    @IBOutlet weak var collectionList: UICollectionView!
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_EnterPincode: UIButton!
    @IBOutlet weak var btn_cart: UIBarButtonItem!
    
    //MARK: - Veriable
    var recommendedProductsLocked = true
    var personilizedProductsLocked = true
    
    var arr_Category = [MPCategoryModel]()
    var arr_PopularProducts = [MPProductModel]()
    var arr_PopularBrand = [MPCategoryModel]()
    var arr_ProductTranding = [MPProductModel]()
    var arr_RecmmendedProduct = [MPProductModel]()
    var arr_OfferBanner = [MPOfferData]()
    var arr_TopDealsForYou = [MPProductModel]()
    var arr_Newlylaunched = [MPProductModel]()
    
    var dataSource = [MPData]()
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = true
        return controller
    }()
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()

        //API CALLING
        showActivityIndicator()
        self.callAPIfor_GETCATEGORY()

        NotificationCenter.default.addObserver(self, selector: #selector(self.productAddedToCart(notification:)), name: Notification.Name("productAddedToCart"), object: nil)
        
        NotificationCenter.default.addObserver(forName: .refreshProductData, object: nil, queue: nil) { [weak self] notif in
            self?.callAPIfor_popularProducts()
        }
        
        handleCartBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MPSelectPinCode = self.getDeliveryPincode()
        self.btn_EnterPincode.setTitle("Delivering to: \(MPSelectPinCode)", for: .normal)
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
        collectionList.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        handleCartBadge()
        super.viewWillAppear(animated)
        NotificationFromServer()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //tableView.reloadData()
    }
    
    private func showSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func hideSearchBar() {
        navigationItem.searchController = nil
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
        collectionList.register(nibWithCellClass: OfferBannerCollectionCell.self)
        collectionList.register(nibWithCellClass: MPMainCategory_CollectionCell.self)
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btn_SearchVC_Action(_ sender: UIButton) {
        //--
        let vc = MPSearchVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.arr_Category = arr_Category
        vc.arr_PopularProducts = arr_PopularProducts
        vc.arr_ProductTranding = arr_ProductTranding
        self.navigationController?.pushViewController(vc, animated: true)
        
        //let vc = MPWalletVC.instantiate(fromAppStoryboard: .MarketPlace)
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Favorite_Action(_ sender: UIButton) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view favourite".localized(), controller: self)
            return
        }
        let vc = MPFavoriteVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.arr_Category = self.arr_Category
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

extension MPHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func manageSection() {
        self.dataSource.removeAll()
        
        if arr_Category.count != 0 {
            self.dataSource.append(MPData(title: "PERSONALIZED FOR YOU", type: .category, subData: self.arr_Category))
        }
        
        if arr_RecmmendedProduct.count != 0 {
            self.dataSource.append(MPData(title: "RECOMMENDED FOR YOU", type: .recommendedProducts, subData: arr_RecmmendedProduct))
        }
        
        //Banner
        print(arr_OfferBanner.count)
        if arr_OfferBanner.count != 0 {
            self.dataSource.append(MPData(title: "", type: .offer_banner, subData: [arr_OfferBanner[0]]))
        }
        
        if arr_PopularProducts.first?.data.count != 0 {
            self.dataSource.append(MPData(title: "ALL PRODUCTS", type: .popularProducts, subData: self.arr_PopularProducts))
        }
        
        //Banner
        if arr_OfferBanner.count != 0 {
            if arr_OfferBanner.count >= 2 {
                self.dataSource.append(MPData(title: "", type: .offer_banner, subData: [arr_OfferBanner[1]]))
            }
        }
        
        if arr_ProductTranding.first?.data.count != 0 {
            self.dataSource.append(MPData(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: self.arr_ProductTranding))
        }
        
        //Banner
        if arr_OfferBanner.count != 0 {
            if arr_OfferBanner.count >= 3 {
                self.dataSource.append(MPData(title: "", type: .offer_banner, subData: [arr_OfferBanner[2]]))
            }
        }
        
        
        if arr_TopDealsForYou.first?.data.count != 0 {
            self.dataSource.append(MPData(title: "TOP DEALS FOR YOU", type: .topDealsForYou, subData: self.arr_TopDealsForYou))
        }
        
        //Banner
        if arr_OfferBanner.count != 0 {
            if arr_OfferBanner.count >= 4 {
                self.dataSource.append(MPData(title: "", type: .offer_banner, subData: [arr_OfferBanner[3]]))
            }
        }
        
        if arr_Newlylaunched.first?.data.count != 0 {
            self.dataSource.append(MPData(title: "NEWLY LAUNCHED", type: .newlyLaunched, subData: self.arr_Newlylaunched))
        }
        
        //Banner
        if arr_OfferBanner.count != 0 {
            if arr_OfferBanner.count >= 5 {
                self.dataSource.append(MPData(title: "", type: .offer_banner, subData: [arr_OfferBanner[4]]))
            }
        }
        
        hideActivityIndicator()
        self.collectionList.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let data = dataSource[section]
        if data.type == .offer_banner {
            return CGSize.init(width: 0, height: 0)
        }
        return CGSize(width: UIScreen.main.bounds.width-30, height: 50.0)
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
                header.btnViewAll.isHidden = dic_category.data.count >= 6 ? false : true
                break
            case .recommendedProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
                break
            case .offer_banner:
                header.btnViewAll.isHidden = true
                break
            case .popularProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
                break
            case .popular_brands:
                let dic_category = data.subData.first as! MPCategoryModel
                header.btnViewAll.isHidden = dic_category.data.count >= 6 ? false : true
                break
            case .trendingProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
                break
            case .topDealsForYou:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
                break
            case .newlyLaunched:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
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
        vc.arr_PopularProducts = arr_PopularProducts
        vc.arr_PopularBrand = arr_PopularBrand
        vc.arr_ProductTranding = arr_ProductTranding
        vc.arr_TopDealsForYou = arr_TopDealsForYou
        vc.arr_Newlylaunched = arr_Newlylaunched
        vc.arr_RecmmendedProduct = arr_RecmmendedProduct
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = dataSource[section]
        if data.subData.count == 0 { return 0 }
        switch data.type {
        case .category:
//            let dic_category = data.subData.first as! MPCategoryModel
//            return dic_category.data.count >= 6 ? 6 : dic_category.data.count
            
            let dic_category = data.subData.first as! MPCategoryModel
            return dic_category.data.count > 0 ? 1 : 0
            
        case .recommendedProducts:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count > 0 ? 1 : 0
        case .offer_banner:
            //let dic_product = data.subData.first as! MPOfferListModel
            return 1//dic_product.data.count > 0 ? 1 : 0
        case .popularProducts:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count >= 5 ? 5 : dic_product.data.count
        case .popular_brands:
            let dic_category = data.subData.first as! MPCategoryModel
            return dic_category.data.count >= 6 ? 6 : dic_category.data.count
        case .trendingProducts:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count > 0 ? 1 : 0
        case .topDealsForYou:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count >= 5 ? 5 : dic_product.data.count
        case .newlyLaunched:
            let dic_product = data.subData.first as! MPProductModel
            return dic_product.data.count > 0 ? 1 : 0
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        //let height = UIScreen.main.bounds.height
        
        let data = dataSource[indexPath.section]
        switch data.type {
        case .category:
//            return CGSize(width: width/3, height: 150)
            return CGSize(width: width, height: 290)
        case .recommendedProducts:
            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
        case .offer_banner:
            return CGSize(width: width, height: 150)
        case .popularProducts:
            return CGSize(width: width, height: 151)
        case .popular_brands:
            return CGSize(width: width/3, height: 150)
        case .trendingProducts:
            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
        case .topDealsForYou:
            return CGSize(width: width, height: 151)
        case .newlyLaunched:
            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.section]
        switch data.type {
        case .category:
            
            return cellForRow_MPCategoryCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
//            let cell = collectionView.dequeueReusableCell(withClass: MPCategoryCell.self, for: indexPath)
//
//            let dic_category = data.subData.first as! MPCategoryModel
//
//            cell.titleL.text = dic_category.data[indexPath.row].name
//
//            let urlString = dic_category.data[indexPath.row].icon
//            if let url = URL(string: urlString) {
//                cell.picIV.af.setImage(withURL: url)
//            }
//
//            return cell
        case .offer_banner:
            let cell = collectionView.dequeueReusableCell(withClass: OfferBannerCollectionCell.self, for: indexPath)
            
            let dic_category = data.subData.first as! MPOfferData
            let str_imgURL = dic_category.image

            if str_imgURL != "" {
                cell.img_Banner.sd_setImage(with: URL.init(string: str_imgURL), placeholderImage: UIImage.init(named: "icon_Empty_state"), progress: nil)
            }
            else {
                cell.img_Banner.image = UIImage.init(named: "icon_Empty_state")
            }
            
            return cell
        
        case .recommendedProducts:
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
        case .popularProducts:
            return cellForRow_MPProductFullCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
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
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
   
        case .topDealsForYou:
            return cellForRow_MPProductFullCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        case .newlyLaunched:
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
   
        default:
            let cell = collectionView.dequeueReusableCell(withClass: MPProductCell.self, for: indexPath)
            
            return cell
        }
    }
    
    func cellForRow_MPCategoryCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: MPMainCategory_CollectionCell.self, for: indexPath)
        cell.data = dataSource[indexPath.section]
        cell.isLockScreen = self.personilizedProductsLocked
        cell.screenFrom = .MP_categories

        
        cell.completionRecommendedContinue = {
            print("Comple Sign Up")
            if kSharedAppDelegate.userId.isEmpty {
                kSharedAppDelegate.showSignUpScreen()
            }
            else {
                self.tabBarController?.selectedIndex = 0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    let btn = UIButton()
                    (UIApplication.topViewController() as? MyHomeViewController)?.completeNowClicked(btn)
                }
            }
        }
        
        return cell
    }
    
    func cellForRow_MPMainTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPMainTrendingProductCollectionCell.self, for: indexPath)
        cell.current_vc = self
        cell.isLockScreen = self.recommendedProductsLocked
        cell.data = dataSource[indexPath.section]

        cell.completionRecommendedContinue = {
            print("Comple Sign Up")
            if kSharedAppDelegate.userId.isEmpty {
                kSharedAppDelegate.showSignUpScreen()
            }
            else {
                self.tabBarController?.selectedIndex = 0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    let btn = UIButton()
                    (UIApplication.topViewController() as? MyHomeViewController)?.completeNowClicked(btn)
                }
            }
        }
        
        return cell
    }
    func cellForRow_MPProductFullCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPProductFullCollectionCell.self, for: indexPath)
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
            vc.selected_productID = "\(dic_category.data[indexPath.row].id)"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .recommendedProducts:
            
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


extension UITableView {
    func hideSearchBar() {
        if let bar = self.tableHeaderView as? UISearchBar {
            let height = bar.frame.height
            let offset = self.contentOffset.y
            if offset < height {
                self.contentOffset = CGPoint(x: 0, y: height)
            }
        }
    }
}

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }

    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }

        badgeLayer?.removeFromSuperlayer()

        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)

        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)

        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }

    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}


var heightMPMainTrendingProductCollectionCell: CGFloat = 315
