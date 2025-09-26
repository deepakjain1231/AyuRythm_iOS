//
//  MPCartVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 14/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import StoreKit
//import MoEngage

class MPCartVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var view_Header: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbl_ItemCount: UILabel!
    @IBOutlet var viewCartPricing: UIView!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblCGST: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblFreeDeliveryText: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblApplyCouponPrice: UILabel!
    @IBOutlet weak var btnApplyCoupon: UIButton!
    @IBOutlet weak var btnApplyWallet: UIButton!
    @IBOutlet weak var lblAppluWallet: UILabel!
    @IBOutlet weak var lblTotalPayableAmount: UILabel!
    @IBOutlet weak var lblTotalSaving: UILabel!
    
    @IBOutlet weak var lbl_primeDiscount: UILabel!
    @IBOutlet weak var lbl_primeDiscount_Title: UILabel!
    @IBOutlet weak var view_primeDiscount: UIStackView!
    
    @IBOutlet weak var lblSelectCouponCode: UILabel!
    @IBOutlet weak var viewbgEmptyCart: UIView!
    @IBOutlet weak var imgApplyCouponCode: UIButton!
    @IBOutlet weak var imgApplyWallet: UIButton!
    //@IBOutlet weak var lblYourCartisEmpty: UILabel!
    @IBOutlet weak var btnShopNow: UIButton!
    @IBOutlet weak var btn_proceed: UIControl!
    //@IBOutlet weak var collectionProductlist_EmptyCart: UICollectionView!
    @IBOutlet weak var viewAppliedCouponCode: UIView!
    @IBOutlet weak var viewAppliedWallet: UIView!
    @IBOutlet weak var lblAppliedWallet: UILabel!
    
    @IBOutlet weak var lblApplyCouponTitle: UILabel!
    @IBOutlet weak var lblApplyWalletTitle: UILabel!
    @IBOutlet weak var lblLineAboveFreeDeliveryText: UILabel!
    
    
    @IBOutlet weak var lblDeliverTo: UILabel!
    @IBOutlet weak var lblDeliverAddressType: UILabel!
    @IBOutlet weak var lblDeliverAddressTypeBG: UIView!
    @IBOutlet weak var lblDeliver_Address: UILabel!
    
    var isCouponCodeApplied = 0
    var couponId = 0
    var couponCode = ""
    var ayuseed_couponId = 0
    var ayuseed_couponCode = ""
    var totalorder = ""
    var totalQty = ""
    var deliveryModel: MPCartDeliveryModel?
    var arr_HerbsProducts = [MPProductModel]()
    var arr_PopularProducts = [MPProductModel]()
    var arr_ProductTranding = [MPProductModel]()
    var dataSourceEmptyCart = [MPData]()
    //MARK: - Veriable
    var str_Title = ""
    var isWalletApplied = 0
    var dataSource = MPProductModel()
    var freeDeliverytext = "Add items of ₹ %@ or more for Free Delivery - ADD NOW"
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.showSearchBar()
        self.title = "Cart"
        viewbgEmptyCart.isHidden = true
        self.view_Header.isHidden = true
        self.tableView.isHidden = true
        self.btn_proceed.isHidden = true
        navigationItem.backButtonTitle = ""
        viewAppliedWallet.isHidden = true
        viewAppliedCouponCode.isHidden = true
        self.view_primeDiscount.isHidden = true
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.GoToCart.rawValue)
        //--
        registerCell()
        
        //--
        self.callAPIfor_GetAddressList()
        getCartData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.productAddedToCart(notification:)), name: Notification.Name("productAddedToCart"), object: nil)
    }
    
    @objc func productAddedToCart(notification: Notification) {
//        getCartData()
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
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let str_GetAddress = MPAddressLocalDB.showWholeAddress(addressModel: MPAddressLocalDB.getAddress())
        if str_GetAddress == "" {
            self.lblDeliver_Address.text = ""
            self.lblDeliverAddressType.text = ""
            self.lblDeliverAddressTypeBG.isHidden = true
            self.lblDeliverTo.text = "Deliver to: Enter pin code to check delivery"
        }
        else {
            self.lblDeliver_Address.text = str_GetAddress
            self.lblDeliverAddressTypeBG.isHidden = false
            self.lblDeliverAddressType.text = MPAddressLocalDB.getAddress().address_type
            let deliver_ToUserName = MPAddressLocalDB.getAddress().full_name

            let text = "Deliver to: \(deliver_ToUserName)"
            let range = (text as NSString).range(of: deliver_ToUserName)
            let attributedString = NSMutableAttributedString(string:text)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 16) , range: range)
            self.lblDeliverTo.attributedText = attributedString
            
            let newText = NSMutableAttributedString.init(string: str_GetAddress)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points
            newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
            self.lblDeliver_Address.attributedText = newText
        }
        
        
        
//        self.lblDeliverTo.text = str_GetAddress == "" ? "Deliver to: Enter pin code to check delivery" : str_GetAddress
//        navigationItem.backButtonTitle = ""
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }
    
    func registerCell(){
        tableView.register(nibWithCellClass: MPCartProductCell.self)
//        collectionProductlist_EmptyCart.register(UINib(nibName: "MPViewAllCollectionReusableCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MPViewAllCollectionReusableCell")
//        collectionProductlist_EmptyCart.register(nibWithCellClass: MPProductCell.self)
//        collectionProductlist_EmptyCart.register(nibWithCellClass: MPTrendingProductCollectionCell.self)
//        collectionProductlist_EmptyCart.register(nibWithCellClass: MPProductFullCollectionCell.self)
//        collectionProductlist_EmptyCart	.register(nibWithCellClass: MPMainTrendingProductCollectionCell.self)
    }
    
    func getCartData(){
        showActivityIndicator()
        if MPLoginLocalDB.isUserLoggedIn(){
            getProductFromCart { (status, products) in
                if status{
                    self.dataSource = products!
                }else{
                    self.dataSource = MPProductModel()
                }
                self.hideActivityIndicator()
                self.handleShowCartData()
            }
        }else{
            dataSource = MPCartManager.getCartData()
            self.hideActivityIndicator()
            self.handleShowCartData()
        }
    }
    
    func handleShowCartData()  {
        if dataSource.data.count <= 0{
        }else{
            getPrice { status in
                self.hideActivityIndicator()
            }
            tableView.reloadData()
        }
        self.hideShowEmptyView()
    }
    
    func checkCartQuantityOutOfStock(isFromCheckout: Bool = false) -> Bool{
        var isOutOfStock = false
        for i in 0..<dataSource.data.count{
            let data = dataSource.data[i]
            let ids = self.deliveryModel?.singleData?.product.filter({$0.product_id == "\(data.id)"})
            if ids?.count ?? 0 > 0{
                dataSource.data[i].cartData?.available_size_quantity = "\(ids?.first?.current_quantity ?? "0")"

                if Int(ids?.first?.current_quantity ?? "0") ?? 0 < dataSource.data[i].cartData?.added_quantity ?? 0{
                    isOutOfStock = true
                }
            }
        }
        if isOutOfStock && !isFromCheckout{
            Utils.showAlertWithTitleInControllerWithCompletion("", message: "Product is out of stock so, please remove out of stock product from cart.", okTitle: "Ok".localized(), controller: findtopViewController()!) {}
        }
        return isOutOfStock
    }
    func setUpPricing(){
        let bool = checkCartQuantityOutOfStock()
        lbl_ItemCount.text = "Price detail  (\(dataSource.data.count) Items)"
        var subTotal: Float = 0
        for item in dataSource.data{
            subTotal += Float(item.cartData?.size_price.floatValue ?? 0) * Float((item.cartData?.added_quantity ?? 0))
        }
        
        var quantity: Int = 0
        for item in dataSource.data{
            quantity += (item.cartData?.added_quantity ?? 0)
        }
        
        lblSubtotal.text = self.settwo_desimalValue(deliveryModel?.singleData?.Total_MRP)
        lblDiscount.text = "-" + self.settwo_desimalValue(deliveryModel?.singleData?.Discount)
        lblDeliveryCharge.text = self.settwo_desimalValue(deliveryModel?.singleData?.Delivery_Charge)
        lblCGST.text = self.settwo_desimalValue(deliveryModel?.singleData?.Taxes)

        let str_total_order  = deliveryModel?.singleData?.str_Total_Order_Amount ?? ""
        if str_total_order != "" && str_total_order != "0" {
            deliveryModel?.singleData?.Total_Order_Amount = NumberFormatter().number(from: str_total_order) ?? 0
        }
        
        let str_total_payble  = deliveryModel?.singleData?.str_Total_Payable ?? ""
        if str_total_payble != "" && str_total_payble != "0" {
            deliveryModel?.singleData?.Total_Payable = NumberFormatter().number(from: str_total_payble) ?? 0
        }
        
        totalorder = "\(deliveryModel?.singleData?.Total_Order_Amount.floatValue.rounded(toPlaces: 2) ?? 0)"
        totalQty = "\(quantity)"
        lblTotalAmount.text =  "₹ \(totalorder)"
        
        
        lblTotalAmount.text = self.settwo_desimalValue(deliveryModel?.singleData?.Total_Order_Amount)
        lblTotalPayableAmount.text = self.settwo_desimalValue(deliveryModel?.singleData?.Total_Payable)
        
        //For Prime Discount
        let prime_discount = deliveryModel?.singleData?.PrimeDiscount ?? 0
        if prime_discount != 0 {
            self.view_primeDiscount.isHidden = false
            self.lbl_primeDiscount.text = "-" + self.settwo_desimalValue(deliveryModel?.singleData?.PrimeDiscount)
            self.lbl_primeDiscount_Title.text = "Prime Discount (\(deliveryModel?.singleData?.PrimeDiscountPercentage ?? 0)%)"
        }
        
        let coupon_applied = deliveryModel?.singleData?.Applied_Coupon_Amount.doubleValue ?? 0
        let ayuseed_copon_applied: Double = Double(deliveryModel?.singleData?.Ayuseeds_Applied_Coupon_Amount ?? "0") ?? 0.0
        
        let copopnAmount: NSNumber = coupon_applied + ayuseed_copon_applied as NSNumber
        lblApplyCouponPrice.text = self.settwo_desimalValue(copopnAmount)
        
        let int_valueSaving = (deliveryModel?.singleData?.Discount.doubleValue ?? 0.0) + (copopnAmount.doubleValue)
        lblTotalSaving.text = int_valueSaving > 0 ? String(format: "Total saving on this order is ₹ %.2f", int_valueSaving) : ""
        lblLineAboveFreeDeliveryText.isHidden = deliveryModel?.singleData?.Delivery_Charge.floatValue ?? 0 <= 0 ? true : false
        lblFreeDeliveryText.isHidden = deliveryModel?.singleData?.Delivery_Charge.floatValue ?? 0 <= 0 ? true : false
        
        let shippingCharge = self.settwo_desimalValue(deliveryModel?.singleData?.Add_Item_For_Free_Shipping_Charge)
        setAttributedText(colorString: "Free Delivery - ADD NOW", boldText: "ADD NOW", fullText: String(format: freeDeliverytext, "\(shippingCharge)"), lbl: lblFreeDeliveryText)
        hideShowEmptyView()
        setCheckBoxes()
    }
    
    
    func settwo_desimalValue(_ value: NSNumber?) -> String {
        return String(format: "₹ %.2f", value?.doubleValue ?? 0.0)
    }
    
    
    func hideShowEmptyView(){
        if dataSource.data.count == 0{
//            collectionProductlist_EmptyCart.isHidden = true
            viewbgEmptyCart.isHidden = false
            self.view_Header.isHidden = true
            self.tableView.isHidden = true
            self.btn_proceed.isHidden = true
//            callAPIfor_popular_herbs()
        }else{
            viewbgEmptyCart.isHidden = true
            self.view_Header.isHidden = false
            self.tableView.isHidden = false
            self.btn_proceed.isHidden = false
        }
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btnChangeAddress(_ sender: Any) {
        MPAddressLocalDB.redirectToSelectAddress {
            let str_GetAddress = MPAddressLocalDB.showWholeAddress(addressModel: MPAddressLocalDB.getAddress())

            self.lblDeliver_Address.text = str_GetAddress
            self.lblDeliverAddressTypeBG.isHidden = false
            let deliver_ToUserName = MPAddressLocalDB.getAddress().full_name
            self.lblDeliverAddressType.text = MPAddressLocalDB.getAddress().address_type

            let text = "Deliver to: \(deliver_ToUserName)"
            let range = (text as NSString).range(of: deliver_ToUserName)
            let attributedString = NSMutableAttributedString(string:text)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 16) , range: range)
            self.lblDeliverTo.attributedText = attributedString
        }
    }
    
    @IBAction func btnApplyWallet(_ sender: Any) {
        if self.btnApplyWallet.tag == 0 {
            if (deliveryModel?.singleData?.Wallet_Amount_Used ?? 0) == 0 {
                return
            }
            self.couponId = 0
            self.couponCode = ""
            self.isWalletApplied = 1
            self.btnApplyCoupon.tag = 0
            self.btnApplyWallet.tag = 1
            self.isCouponCodeApplied = 0
        }
        else {
            self.isWalletApplied = 0
            self.btnApplyWallet.tag = 0
        }
        
        getPrice { status in
            self.hideActivityIndicator()
        }
        
        
        
        setCheckBoxes()
    }
    
    func setCheckBoxes() {
        self.viewAppliedWallet.isHidden = false
        self.btnApplyWallet.setImage(self.btnApplyWallet.tag == 1 ? MP_appImage.img_CheckBox_selected : MP_appImage.img_CheckBox_unselected, for: .normal)
        self.lblAppluWallet.textColor = self.btnApplyWallet.tag == 1 ? UIColor.systemBlue : UIColor.black
        self.lblApplyWalletTitle.textColor = self.btnApplyWallet.tag == 1 ? UIColor.systemBlue : UIColor.black
        
        let strWalletDisplayText = deliveryModel?.singleData?.Wallet_Display_Text ?? ""
        let intWalletRemainingBal = deliveryModel?.singleData?.Wallet_Remaining_Balance ?? 0
        let intUsedWalletBal = deliveryModel?.singleData?.Wallet_Amount_Used ?? 0
        
        let userWallet_bal = self.settwo_desimalValue(intUsedWalletBal)
        
        self.lblAppliedWallet.text = strWalletDisplayText
        self.lblAppluWallet.text = self.btnApplyWallet.tag == 1 ? userWallet_bal : "₹0.00"
	
        self.viewAppliedCouponCode.isHidden = self.btnApplyCoupon.tag == 1 ? false : true
        self.btnApplyCoupon.setImage(self.btnApplyCoupon.tag == 1 ? MP_appImage.img_CheckBox_selected : MP_appImage.img_CheckBox_unselected, for: .normal)
        self.lblApplyCouponPrice.textColor = self.btnApplyCoupon.tag == 1 ? UIColor.systemBlue : UIColor.black
        self.lblApplyCouponTitle.textColor = self.btnApplyCoupon.tag == 1 ? UIColor.systemBlue : UIColor.black
        
        
        if self.couponCode != "" && self.ayuseed_couponCode != "" {
            self.setAttributedText(colorString: "2 coupons", anothercolorString: "Clear applied coupon", boldText: "", fullText: "2 coupons applied  Clear applied coupon", lbl: self.lblSelectCouponCode)
        }
        else {
            if couponCode != "" {
                self.setAttributedText(colorString: couponCode.uppercased(), boldText: "", fullText: "Code \(couponCode.uppercased()) applied", lbl: self.lblSelectCouponCode)
            }
            else {
                self.setAttributedText(colorString: ayuseed_couponCode.uppercased(), boldText: "", fullText: "Code \(ayuseed_couponCode.uppercased()) applied", lbl: self.lblSelectCouponCode)
            }
        }
    
    }
    
    @IBAction func btnApplyCoupon(_ sender: Any) {
        if self.btnApplyCoupon.tag == 1{
            self.btnApplyCoupon.tag = 0
            self.couponId = 0
            self.couponCode = ""
            self.isCouponCodeApplied = 0
            self.setCheckBoxes()
            getPrice { status in
                self.hideActivityIndicator()
            }
            return
        }
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = MPApplyCouponDialouge(nibName: "MPApplyCouponDialouge", bundle: nil)
            objDialouge.totalQty = totalQty
            objDialouge.orderTotal = totalorder
            objDialouge.completion = { id, couponCode, ayuseedcopnID, ayuseedcopnCODE in
                self.btnApplyCoupon.tag = self.btnApplyCoupon.tag == 1 ? 0 : 1
                self.couponId = id
                self.isWalletApplied = 0
                self.btnApplyWallet.tag = 0
                self.isCouponCodeApplied = 1
                self.viewAppliedCouponCode.isHidden = false
                self.couponCode = couponCode
                self.ayuseed_couponId = ayuseedcopnID
                self.ayuseed_couponCode = ayuseedcopnCODE
                if couponCode != "" && ayuseedcopnCODE != "" {
                    self.setAttributedText(colorString: "2 coupons", anothercolorString: "Clear applied coupon", boldText: "", fullText: "2 coupons applied  Clear applied coupon", lbl: self.lblSelectCouponCode)
                }
                else {
                    if couponCode != "" {
                        self.setAttributedText(colorString: couponCode, boldText: "", fullText: "Code \(couponCode.uppercased()) applied", lbl: self.lblSelectCouponCode)
                    }
                    else {
                        self.setAttributedText(colorString: ayuseedcopnCODE, boldText: "", fullText: "Code \(ayuseedcopnCODE.uppercased()) applied", lbl: self.lblSelectCouponCode)
                    }
                }
                
//                self.lblSelectCouponCode.text = "Code \(coupo	nCode) Applied"
                self.setCheckBoxes()
                self.getPrice { status in
                    self.hideActivityIndicator()
                }
            }
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
        }
    }
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    	
    @IBAction func btnProceedBuy_Action(_ sender: UIButton) {
//        var is_CheckOut = true
//        for dic_data in dataSource.data {
//            if Int(dic_data.cartData?.available_size_quantity ?? "0") ?? 0 > dic_data.cartData?.added_quantity ?? 0 {
//            }else{
//                is_CheckOut = false
//            }
//        }
//
//        if is_CheckOut == false {
//            Utils.showAlertWithTitleInController("Cart Error", message: "Please delete the out of stock product or move to from cart to proceed to checkout", controller: self)
//        }
//        else {
            if MPLoginLocalDB.isUserLoggedIn(){
                if !self.checkCartQuantityOutOfStock(isFromCheckout: true){
                    
                    //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.ProceedtoBuy.rawValue)
                    
                    let vc = MPAddressVC.instantiate(fromAppStoryboard: .MarketPlace)
                    vc.deliveryModel = self.deliveryModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                callAPIfor_LOGIN {
                    if !self.checkCartQuantityOutOfStock(isFromCheckout: true){
                        let vc = MPAddressVC.instantiate(fromAppStoryboard: .MarketPlace)
                        vc.deliveryModel = self.deliveryModel
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        //}

    }
    
    @IBAction func btnShopNow_EmptyCart(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            UIApplication.topViewController?.tabBarController?.selectedIndex = 2
        }
    }
    
    func getPrice(completion: ((Bool) -> ())?) {
        self.showActivityIndicator()
        let productids = dataSource.data.map({"\($0.id)"})
        let size_code = dataSource.data.map({"\($0.cartData?.sizes ?? "")"})
        var sizeKey:[String] = []
        var sizeKeyIndex = -1
        size_code.forEach { size_code in
            sizeKeyIndex = sizeKeyIndex + 1
            sizeKey.append("\(sizeKeyIndex)")
        }
        let color_code = dataSource.data.map({"\($0.cartData?.color_code ?? "")"})

        let price = dataSource.data.map({"\($0.cartData?.size_price ?? "")"})
	
        let quantity = dataSource.data.map({"\($0.cartData?.added_quantity ?? 0)"})
        
        let previous_price = dataSource.data.map({"\($0.cartData?.sizes_wise_previous_price ?? "")"})
        
        
        var nameAPI: endPoint = .mp_front_mycart_getCartPriceDetail
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        var params = ["is_coupon_applied" : isCouponCodeApplied,
                      "coupon_id": couponId,
                      "product_id": productids.joined(separator: ","),
                      "size_code": size_code.joined(separator: ","),
                      "size_key": sizeKey.joined(separator: ","),
                      "color_code": color_code.joined(separator: ","),
                      "price": price.joined(separator: ","),
                      "quantity": quantity.joined(separator: ","),
                      "previous_price": previous_price.joined(separator: ","),
                      "tax_amount": ""] as [String : Any]

        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_mycart_getCartPriceDetail
            getHeader = MPLoginLocalDB.getHeaderToken()
            
            params = ["coupon_id": "",
                      "ayuseed_coupon_id": "",
                      "is_coupon_applied" : isCouponCodeApplied] as [String : Any]
            
            if self.couponId != 0 {
                params["coupon_id"] = couponId
            }
            
            if self.ayuseed_couponId != 0 {
                params["ayuseed_coupon_id"] = ayuseed_couponId
            }
            
            if self.isWalletApplied == 1 {
                params["is_wallet_applied"] = "Yes"
                params["wallet_applied_amount"] = self.deliveryModel?.singleData?.Wallet_Max_Save
            }
            else {
                params["wallet_applied_amount"] = 0
                params["is_wallet_applied"] = "No"
            }
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {

                self.deliveryModel = MPCartDeliveryModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.deliveryModel?.singleData?.Applied_Coupon_ID = self.couponId
                self.deliveryModel?.singleData?.Applied_Ayuseed_Coupon_ID = self.ayuseed_couponId
                self.setUpPricing()
                completion!(true)
                print("response")
//                self.tblView.reloadData()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
                completion!(false)
            } else {
                self.showAlert(title: status, message: message)
                completion!(false)
            }
        }
    }
    
    func callAPIfor_GetAddressList() {
        let nameAPI: endPoint = .mp_user_mycart_getUserAddress

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                var addressData: MPAddressModel?
                let mPaddressData = MPAddressModel(JSON: responseJSON?.rawValue as! [String : Any])!
                addressData = mPaddressData

                if let strAddressID = UserDefaults.standard.object(forKey: kDeliveryAddressID) as? String {
                    if let indxx = addressData?.data.firstIndex(where: { dic_address in
                        let addressid = "\(dic_address.id)"
                        return addressid == strAddressID
                    }) {
                        MPAddressLocalDB.saveAddress(strData: addressData?.data[indxx].toJSONString() ?? "")
                        let str_GetAddress = MPAddressLocalDB.showWholeAddress(addressModel: addressData?.data[indxx])
                        self.lblDeliver_Address.text = str_GetAddress
                        self.lblDeliverAddressTypeBG.isHidden = false
                        self.lblDeliverAddressType.text = MPAddressLocalDB.getAddress().address_type
                        let deliver_ToUserName = MPAddressLocalDB.getAddress().full_name
                        
                        let text = "Deliver to: \(deliver_ToUserName)"
                        let range = (text as NSString).range(of: deliver_ToUserName)
                        let attributedString = NSMutableAttributedString(string:text)
                        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 16) , range: range)
                        self.lblDeliverTo.attributedText = attributedString
                        
                        let newText = NSMutableAttributedString.init(string: str_GetAddress)
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points
                        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
                        self.lblDeliver_Address.attributedText = newText
                    }
                    else {
                        self.lblDeliver_Address.text = ""
                        self.lblDeliverAddressType.text = ""
                        self.lblDeliverAddressTypeBG.isHidden = true
                        self.lblDeliverTo.text = "Deliver to: Enter pin code to check delivery"
                        if MPSelectPinCode != "" {
                            self.lblDeliverTo.text = "Deliver to: \(MPSelectPinCode)"
                        }
                    }
                }
                else {
                    self.lblDeliver_Address.text = ""
                    self.lblDeliverAddressType.text = ""
                    self.lblDeliverAddressTypeBG.isHidden = true
                    self.lblDeliverTo.text = "Deliver to: Enter pin code to check delivery"
                }
            }
        }
    }
    
    func setAttributedText(colorString: String, anothercolorString: String = "", boldText: String, fullText: String, lbl: UILabel)  {
        let text = fullText

        let range = (text as NSString).range(of: colorString)
        let range_one = (text as NSString).range(of: anothercolorString)
        let bold_Text_range = (text as NSString).range(of: boldText)

        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: kAppBlueColor, range: range)
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: kAppBlueColor, range: range_one)
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 13), range: bold_Text_range)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: kAppBlueColor , range: bold_Text_range)

        lbl.attributedText = attributedString
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel(gesture:))))
    }
    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        guard let strText = (gesture.view as? UILabel)?.text else { return }
        let termsRange = (strText as NSString).range(of: "Free Delivery - ADD NOW")
        if gesture.didTapAttributedTextInLabel(label: lblFreeDeliveryText, inRange: termsRange) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension MPCartVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func cellForRow(at indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: MPCartProductCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.current_vc = self
        cell.productData = dataSource.data[indexPath.row]
        
        var is_ShowingDiscount = false
        let cruPrice: Double = Double(dataSource.data[indexPath.row].cartData?.sizes_wise_price ?? "0") ?? 0.0
        let prvPrice: Double = Double(dataSource.data[indexPath.row].cartData?.sizes_wise_previous_price ?? "0") ?? 0.0
        cell.titleL.text = dataSource.data[indexPath.row].title
        cell.lbl_currentPrice.text = "₹ \(cruPrice)"
        cell.lblSize.text = dataSource.data[indexPath.row].cartData?.sizes ?? ""
        
        if prvPrice > 0 && prvPrice > cruPrice {
            is_ShowingDiscount = true
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "MRP ₹ \(prvPrice)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
            cell.lbl_old_Price.attributedText = attributeString
        }else{
            cell.lbl_old_Price.text = ""
        }
        
        //Showing Discount
        if is_ShowingDiscount {
            let getDiscount = ((cruPrice * 100)/prvPrice).rounded(.up)
            let intDiscont: Int = Int(100 - getDiscount)
            if 0 < intDiscont {
                cell.lbl_off.text = "\(intDiscont)% OFF"
            }
            else {
                cell.lbl_off.text = ""
            }
        } else{
            cell.lbl_off.text = ""
        }
        
        let int_addedSizeQuentity = data.cartData?.added_quantity ?? 0
        let int_availableSizeQuentity = Int(data.cartData?.available_size_quantity ?? "0") ?? 0
        if int_availableSizeQuentity > 0 {
            if int_availableSizeQuentity <= 5 {
                cell.viewRemoveBackground.backgroundColor = UIColor.red
                cell.btn_Remove.setTitleColor(UIColor.red, for: .normal)
                cell.lbl_outOfStockProduct.text = "Only \(int_availableSizeQuentity) left!"
            }
            else {
                cell.lbl_outOfStockProduct.text = ""
                cell.viewRemoveBackground.backgroundColor = UIColor.clear
                cell.btn_Remove.setTitleColor(cell.btn_AddToFavourite.currentTitleColor, for: .normal)
            }
        }
        else {
            cell.lbl_outOfStockProduct.text = ""
            cell.viewRemoveBackground.backgroundColor = UIColor.clear
            cell.btn_Remove.setTitleColor(cell.btn_AddToFavourite.currentTitleColor, for: .normal)
        }
        /*
        if Int(data.cartData?.available_size_quantity ?? "0") ?? 0 > data.cartData?.added_quantity ?? 0 {
            cell.lbl_outOfStockProduct.text = ""
            cell.viewRemoveBackground.backgroundColor = UIColor.clear
            cell.btn_Remove.setTitleColor(cell.btn_AddToFavourite.currentTitleColor, for: .normal)
        }else{
            cell.lbl_outOfStockProduct.text = ""
            cell.viewRemoveBackground.backgroundColor = UIColor.red
            cell.btn_Remove.setTitleColor(UIColor.red, for: .normal)
        }*/

        cell.checkCountToDisplayDeleteIcon()
        let estimated_shipping_time = dataSource.data[indexPath.row].estimated_shipping_time
        cell.lblEstDeliveryTime.text = estimated_shipping_time.count == 0 ? "" : "Est. Delivery in \(estimated_shipping_time)"
        
        let urlString = dataSource.data[indexPath.row].thumbnail
        if let url = URL(string: urlString) {
            cell.img_product.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
            
        }
        cell.lbl_Quantity.text = "\(dataSource.data[indexPath.row].cartData?.added_quantity ?? 1)"
        cell.btn_AddToFavourite.setTitle("ADD TO FAVOURITE", for: .normal)
        cell.btn_Remove.setTitle("REMOVE", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            cell.constraint_img_Height.constant = cell.view_img_productBG.frame.size.height
            cell.layoutIfNeeded()
        }
        
        
        cell.completioRemove = { isRemoved in
            self.showActivityIndicator()
            self.dataSource.data.remove(at: indexPath.row)
            if self.dataSource.data.count == 0 {
                MPCartManager.removeCartData()
            }
            self.setUpPricing()
            self.tableView.reloadData()
            self.getPrice { status in
                self.hideActivityIndicator()
            }
            self.hideShowEmptyView()
        }
        
        cell.completioCountUpdate = { count, increment in
            self.showActivityIndicator()
            self.dataSource.data[indexPath.row].cartData?.added_quantity = count
            if increment {
                self.dataSource.data[indexPath.row].cartData?.added_quantity = int_addedSizeQuentity + 1
                self.dataSource.data[indexPath.row].cartData?.available_size_quantity = "\(int_availableSizeQuentity - 1)"
            }
            else {
                self.dataSource.data[indexPath.row].cartData?.added_quantity = int_addedSizeQuentity - 1
                self.dataSource.data[indexPath.row].cartData?.available_size_quantity = "\(int_availableSizeQuentity + 1)"
            }
            self.setUpPricing()
            self.getPrice { status in
                self.hideActivityIndicator()
            }
            self.tableView.reloadData()
        }
        
        cell.completioAddToFav = {
            if self.dataSource.data[indexPath.row].WISHLIST == 1 {
                kSharedAppDelegate.window?.rootViewController?.showToast(message: "You have already added this product into the favorite.")
            }
            else {
                MPWishlistManager.addToWishList(product: self.dataSource.data[indexPath.row] ) {
                    self.dataSource.data[indexPath.row].WISHLIST = 1
                    kSharedAppDelegate.window?.rootViewController?.showToast(message: "Successfully Added To Wishlist.")
                }
            }
            
        }
        return cell
    }
    
    func heightForRowAt(at indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        //return 200
        //        let data = dataSource[indexPath.row]
        //        switch data.type {
        //        case .noData:
        //            return 245
        //        case .cartPriceDetail:
        //            return 495
        //        case .cartProduct:
        //            let cellHeight: CGFloat = CGFloat((data.subData.count*225) + 18)
        //            return data.subData.isEmpty ? 220 : cellHeight
        //        default:
        //            let getCount = self.dataSource.last?.subData.count ?? 0
        //            var countInDouble: Double = Double(getCount)
        //            countInDouble = countInDouble/2.0
        //            //let getCoubt: CGFloat = CGFloat((self.dataSource.last?.subData.count ?? 0)/2)
        //            let getheight = countInDouble.rounded(FloatingPointRoundingRule.up)
        //            return ((getheight * 240) + 20)
        //        }
    }
    
    //    func tableView(_ tableView: UITableView,
    //                   heightForFooterInSection section: Int) -> CGFloat {
    //        return 505
    //    }
    //
    //    func tableView(_ tableView: UITableView,
    //                   viewForFooterInSection section: Int) -> UIView? {
    //        viewCartPricing.frame.size = CGSize(width: self.view.frame.width-20, height: viewCartPricing.frame.height)
    //        let aView = UIView()
    //        aView.frame = viewCartPricing.frame
    //        aView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0)
    //
    //        aView.addSubview(viewCartPricing)
    ////
    ////        let footerView = UIView(frame: CGRect(x: 0,
    ////                                              y: 0,
    ////                                              width: self.tableView.frame.width,
    ////                                              height: 505))
    ////        viewCartPricing.frame = footerView.bounds
    ////        footerView.addSubview(viewCartPricing)
    //        return aView
    //    }
    
}

//extension MPCartVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func manageSection() {
//        self.dataSourceEmptyCart.removeAll()
//        if self.arr_HerbsProducts.count > 0 {
//            self.dataSourceEmptyCart.append(MPData(title: "POPULAR HERBS", type: .herbsProducts, subData: self.arr_HerbsProducts))
//        }
//        
//        if self.arr_PopularProducts.count > 0 {
//            self.dataSourceEmptyCart.append(MPData(title: "ALL PRODUCTS", type: .popularProducts, subData: self.arr_PopularProducts))
//        }
//        
//        if self.arr_ProductTranding.count > 0 {
//            self.dataSourceEmptyCart.append(MPData(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: self.arr_ProductTranding))
//        }
//        self.collectionProductlist_EmptyCart.reloadData()
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width-30, height: 50.0)
//    }
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return dataSourceEmptyCart.count
//    }
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MPViewAllCollectionReusableCell", for: indexPath) as! MPViewAllCollectionReusableCell
//            //--
//            header.btnViewAll.tag = indexPath.section
//            header.btnViewAll.addTarget(self, action: #selector(btnViewAllCollectionSection(sender:)), for: .touchUpInside)
//            
//            //--
//            let data = dataSourceEmptyCart[indexPath.section]
//            header.lblTitle.text = data.title
//            
//            if data.subData.count == 0 { return header }
//            switch data.type {
//            case .herbsProducts:
//                let dic_product = data.subData.first as! MPProductModel
//                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
//                break
//            case .popularProducts:
//                let dic_product = data.subData.first as! MPProductModel
//                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
//                break
//            case .trendingProducts:
//                let dic_product = data.subData.first as! MPProductModel
//                header.btnViewAll.isHidden = dic_product.data.count >= 6 ? false : true
//                break
//            default:
//                
//                break
//            }
//            return header
//        default:
//            fatalError("Unexpected element kind")
//        }
//    }
//    @objc func btnViewAllCollectionSection(sender: UIButton){
//        let index = sender.tag
//        let data = dataSourceEmptyCart[index]
//        
//        let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
//        switch data.type {
//        case .popularProducts:
//            vc.screenFrom = .MP_ViewALL_PopularProducts
//            vc.mpDataType = .popularProducts
//            break
//        case .popular_brands:
//            vc.screenFrom = .MP_ViewALL_Popular_brands
//            vc.mpDataType = .popular_brands
//            break
//        case .trendingProducts:
//            vc.screenFrom = .MP_ViewALL_TrendingProducts
//            vc.mpDataType = .trendingProducts
//            break
//        case .herbsProducts:
//            vc.screenFrom = .MP_ViewALL_HerdsProduct
//            vc.mpDataType = .herbsProducts
//            break
//        default:
//            break
//        }
//        vc.str_Title = data.title ?? ""
//        
//        vc.arr_PopularProducts = arr_PopularProducts
//        vc.arr_HerbsProducts = arr_HerbsProducts
//        vc.arr_ProductTranding = arr_ProductTranding
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let data = dataSourceEmptyCart[section]
//        if data.subData.count == 0 { return 0 }
//        switch data.type {
//        case .popularProducts:
//            let dic_product = data.subData.first as! MPProductModel
//            return dic_product.data.count > 0 ? 1 : 0
//        case .trendingProducts:
//            let dic_product = data.subData.first as! MPProductModel
//            return dic_product.data.count > 0 ? 1 : 0
//        case .herbsProducts:
//            let dic_product = data.subData.first as! MPProductModel
//            return dic_product.data.count > 0 ? 1 : 0
//        default:
//            return 0
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = UIScreen.main.bounds.width
//        //let height = UIScreen.main.bounds.height
//        
//        let data = dataSourceEmptyCart[indexPath.section]
//        switch data.type {
//        case .popularProducts:
//            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
//        case .trendingProducts:
//            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
//        case .herbsProducts:
//            return CGSize(width: width, height: heightMPMainTrendingProductCollectionCell)
//        default:
//            return CGSize(width: 0, height: 0)
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let data = dataSourceEmptyCart[indexPath.section]
//        switch data.type {
//        case .popularProducts:
//            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
//            
//        case .trendingProducts:
//            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
//   
//        case .herbsProducts:
//            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
//        default:
//            let cell = collectionView.dequeueReusableCell(withClass: MPProductCell.self, for: indexPath)
//            
//            return cell
//        }
//    }
//    
//    func cellForRow_MPMainTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withClass: MPMainTrendingProductCollectionCell.self, for: indexPath)
//        cell.data = dataSourceEmptyCart[indexPath.section]
//        cell.completionAddToCart = {
//
//        }
//        return cell
//    }
//    func cellForRow_MPProductFullCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withClass: MPProductFullCollectionCell.self, for: indexPath)
//        
//        let data = dataSourceEmptyCart[indexPath.section]
//        let dic_product = data.subData.first as! MPProductModel
//        cell.productData = dic_product.data[indexPath.row]
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let data = dataSourceEmptyCart[indexPath.section]
//        
//        switch data.type {
//        case .popularProducts:
//            //--
//            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
//            break
//        case .trendingProducts:
//            //--
//            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
//            break
//        case .herbsProducts:
//            //--
//            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
//            break
//        default:
//            
//            break
//        }
//    }
//    
//    func didSelectProduct(collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
//        let data = dataSourceEmptyCart[indexPath.section]
//        let dic_product = data.subData.first as! MPProductModel
//        //--
//        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
//        vc.str_productID = "\(dic_product.data[indexPath.row].id)"
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}


public func calculatePercentage(value:Double,percentageVal:Double)->Double{
    let val = value * percentageVal
    return val / 100.0
}

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
