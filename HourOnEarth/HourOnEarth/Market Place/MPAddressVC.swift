//
//  MPAddressVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import CoreLocation
import Razorpay

class MPAddressVC: UIViewController {//}, delegatePlaceOrder {

    var dataSource = [MPData]()
    var arr_OrderSummary = [MPData]()
    var arr_AddedAddress = [MPData]()
    
//    var razorpayObj : RazorpayCheckout? = nil
    
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var viewStepsBg: UIView!
    @IBOutlet weak var constraint_view_stepsbg_height: NSLayoutConstraint!
    @IBOutlet weak var view_step1: UIView!
    @IBOutlet weak var view_step2: UIView!
    @IBOutlet weak var view_step3: UIView!
    @IBOutlet weak var lbl_step1: UILabel!
    @IBOutlet weak var lbl_step2: UILabel!
    @IBOutlet weak var lbl_step3: UILabel!
    @IBOutlet weak var view_OrderSummary: UIView!
    @IBOutlet weak var tbl_View_addedAddress: UITableView!
    @IBOutlet weak var tbl_View_OrderSummary: UITableView!
    @IBOutlet weak var view_addedAddress: UIView!
    @IBOutlet weak var view_addAddress: UIView!
    @IBOutlet weak var btn_AddNewAddress: UIControl!
    @IBOutlet weak var btn_SaveAddress: UIControl!
    @IBOutlet weak var lbl_BottomButtonTitle: UILabel!
    @IBOutlet weak var constraint_view_odrdersummary_Leading: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_SelectedAddressName: UILabel!
    @IBOutlet weak var lbl_SelectedAddressTYpe: UILabel!
    @IBOutlet weak var lbl_SelectedAddress: UILabel!
    
    @IBOutlet weak var lbl_primeDiscount: UILabel!
    @IBOutlet weak var lbl_primeDiscount_Title: UILabel!
    @IBOutlet weak var view_primeDiscount: UIStackView!
    
    @IBOutlet weak var lbl_ItemCount: UILabel!
    @IBOutlet var viewCartPricing: UIView!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblCGST: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblApplyCouponPrice: UILabel!
    @IBOutlet weak var lblApplyCouponPrice_Title: UILabel!
    @IBOutlet weak var lblTotalPayableAmount: UILabel!
    @IBOutlet weak var lblTotalSaving: UILabel!
    @IBOutlet weak var stackforCoupon: UIStackView!

    //MARK:- Variables
    var addressData: MPAddressModel?
    var selectedAddress = 0
    var isEditAddress = false
    var isAddingAddress = false
    var addAddressDict = [String: Any]()
    let locationManager = CLLocationManager()
    var dataSourceCart = MPProductModel()
    var deliveryModel: MPCartDeliveryModel?
    var totalorder = ""
    var totalQty = ""
    var isFromChangeAddress = false
    var completionSelectAddress: (() -> ())!
    var isLoadFirstTime = true
    var orderId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Address"
        self.view_primeDiscount.isHidden = true

        // Do any additional setup after loading the view.
//        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.back(sender:)))
//        self.navigationItem.leftBarButtonItem = newBackButton
//        addCustomBackButton()
        self.view_step1.layer.borderWidth = 3
        self.view_step2.layer.borderWidth = 3
        self.view_step3.layer.borderWidth = 3
        self.constraint_view_odrdersummary_Leading.constant = UIScreen.main.bounds.width
        self.view_step1.layer.borderColor = UIColor.fromHex(hexString: "#017AFF").cgColor
        self.view_step2.layer.borderColor = UIColor.fromHex(hexString: "#017AFF").cgColor
        self.view_step3.layer.borderColor = UIColor.fromHex(hexString: "#017AFF").cgColor
        self.tbl_View.register(nibWithCellClass: MPAddAddressTableCell.self)
        self.tbl_View_OrderSummary.register(nibWithCellClass: MPPriceDetailTableCell.self)
        getCartData()
        callAPIfor_GetAddress()
        self.manageSection_AddAddress()
        self.tbl_View_addedAddress.reloadData()
        initCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(self.back(sender:)))
    }
    
    func getCartData(){
        dataSourceCart = MPCartManager.getCartData()
        tbl_View_OrderSummary.reloadData()
        setUpPricing()
    }
    
    func setUpPricing(){
        lbl_ItemCount.text = "Price detail  (\(dataSourceCart.data.count) Items)"
        var subTotal: Float = 0
        for item in dataSourceCart.data{
            subTotal += Float(item.cartData?.size_price.floatValue ?? 0) * Float((item.cartData?.added_quantity ?? 0))
        }
        
        var quantity: Int = 0
        for item in dataSourceCart.data{
            quantity += (item.cartData?.added_quantity ?? 0)
        }

        lblSubtotal.text = self.settwo_desimalValue(deliveryModel?.singleData?.Total_MRP)
        lblDiscount.text = "-" + self.settwo_desimalValue(deliveryModel?.singleData?.Discount)
        
        //For Prime Discount
        let prime_discount = deliveryModel?.singleData?.PrimeDiscount ?? 0
        if prime_discount != 0 {
            self.view_primeDiscount.isHidden = false
            self.lbl_primeDiscount.text = "-" + self.settwo_desimalValue(deliveryModel?.singleData?.PrimeDiscount)
            self.lbl_primeDiscount_Title.text = "Prime Discount (\(deliveryModel?.singleData?.PrimeDiscountPercentage ?? 0)%)"
        }
        
        lblDeliveryCharge.text = self.settwo_desimalValue(deliveryModel?.singleData?.Delivery_Charge)
        lblCGST.text = self.settwo_desimalValue(deliveryModel?.singleData?.Taxes)
        totalorder = "\(deliveryModel?.singleData?.Total_Order_Amount.floatValue.rounded(toPlaces: 2) ?? 0)"
        totalQty = "\(quantity)"
        lblTotalPayableAmount.text = self.settwo_desimalValue(deliveryModel?.singleData?.Total_Payable)
        
        var copopnAmount: NSNumber = 0
        
        if deliveryModel?.singleData?.Applied_Coupon_Amount == 0 {
            
            if deliveryModel?.singleData?.Ayuseeds_Applied_Coupon_Amount == "0" || deliveryModel?.singleData?.Ayuseeds_Applied_Coupon_Amount == "" {
                self.stackforCoupon.isHidden = true
            }
            else {
                self.stackforCoupon.isHidden = false
                let double_Ayuseeds_Applied_Coupon_Amount: Double = Double(deliveryModel?.singleData?.Ayuseeds_Applied_Coupon_Amount ?? "") ?? 0
                copopnAmount = double_Ayuseeds_Applied_Coupon_Amount as NSNumber
                lblApplyCouponPrice.text = "-" + self.settwo_desimalValue(copopnAmount)
            }
            
            if deliveryModel?.singleData?.Wallet_Applied == "Yes" {
                self.stackforCoupon.isHidden = false
                lblApplyCouponPrice_Title.text = "Wallet Amount"
                lblApplyCouponPrice.text = "-" + self.settwo_desimalValue(deliveryModel?.singleData?.Wallet_Amount_Used)
            }
        }
        else {
            self.stackforCoupon.isHidden = false
            let coupon_applied = deliveryModel?.singleData?.Applied_Coupon_Amount.doubleValue ?? 0
            let ayuseed_copon_applied: Double = Double(deliveryModel?.singleData?.Ayuseeds_Applied_Coupon_Amount ?? "0") ?? 0.0
            copopnAmount = coupon_applied + ayuseed_copon_applied as NSNumber
            lblApplyCouponPrice.text = "-" + self.settwo_desimalValue(copopnAmount)
        }

        let savings = (deliveryModel?.singleData?.Discount.floatValue.rounded(toPlaces: 2) ?? 0) + (copopnAmount.floatValue.rounded(toPlaces: 2) ?? 0)
        lblTotalSaving.text = savings > 0 ? "Total saving on this order is ₹\(savings)" : ""
    }
    
    func settwo_desimalValue(_ value: NSNumber?) -> String {
        return String(format: "₹ %.2f", value?.doubleValue ?? 0.0)
    }

    func initCurrentLocation(){
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func addCustomBackButton()  {
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "back.png"), for: .normal)
        backbutton.tintColor = UIColor.systemBlue
        backbutton.addTarget(self, action: #selector(self.back(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    @objc func back(sender: UIButton) {
        if view_addedAddress.isHidden == true && isAddingAddress{
            self.showAddressList()
        }else if view_addedAddress.isHidden == true && self.view_addAddress.isHidden == true{
            self.showAddressList()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UIButton Method Action
    @IBAction func btn_SaveAddress(_ sender: UIControl) {
        
        if self.lbl_BottomButtonTitle.text == "DELIVER HERE" {
//            self.lbl_step1.textColor = .black
            self.lbl_step2.textColor = .white
//            self.view_step1.backgroundColor = .white
            self.lbl_BottomButtonTitle.text = "CONTINUE"
            self.view_step2.backgroundColor = UIColor.fromHex(hexString: "#017AFF")
            self.lbl_SelectedAddress.text = MPAddressLocalDB.showWholeAddress(addressModel: addressData?.data[self.selectedAddress])
            
            let userFullName = addressData?.data[self.selectedAddress].full_name ?? ""
            self.lbl_SelectedAddressName.text = "Deliver to: \(userFullName)"
            self.lbl_SelectedAddressTYpe.text = addressData?.data[self.selectedAddress].address_type ?? ""
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIView.AnimationOptions.curveEaseInOut) {
                self.constraint_view_odrdersummary_Leading.constant = 0
                self.view.layoutIfNeeded()
            } completion: { success in
            }
        }else if self.lbl_BottomButtonTitle.text == "CHANGE ADDRESS" {
            let data = self.addressData?.data[selectedAddress]
            var strUsername = data?.full_name ?? ""
            if strUsername != "" {
                strUsername = "\(strUsername) - "
            }
            let selectedPincode = "\(strUsername) \(data?.pincode ?? "")"
            setDeliveryPincode(selectedPincode, selected_address_id: "\(data?.id ?? 0)")
            MPAddressLocalDB.saveAddress(strData: self.addressData?.data[selectedAddress].toJSONString() ?? "")
            if self.completionSelectAddress != nil{
                self.completionSelectAddress!()
            }
            self.navigationController?.popViewController(animated: true)
        }else if self.lbl_BottomButtonTitle.text == "CONTINUE" {
            let vc = MPPaymentModeVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.delivery_Model = self.deliveryModel
            vc.address_Data = self.addressData?.data[self.selectedAddress]
            vc.totalPayableAmount = self.settwo_desimalValue(deliveryModel?.singleData?.Total_Payable)
            self.navigationController?.pushViewController(vc, animated: true)
            
            
//            self.showPaymentForm(orderId: getRandomNumber())
            //self.saveDataForRazorPay()
//            let vc = MPPaymentVC.instantiate(fromAppStoryboard: .MarketPlace)
//            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            self.view.endEditing(true)
            showValidationToAddAddress()
        }
    }
    
    @IBAction func btn_AddNewAddress(_ sender: UIControl) {
        self.isEditAddress = false
        showAddAddress()
    }
    
    func setDeliveryPincode(_ pincode: String, selected_address_id: String = "") {
        UserDefaults.standard.set(pincode, forKey: kDeliveryPincode)
        UserDefaults.standard.set(selected_address_id, forKey: kDeliveryAddressID)
        UserDefaults.standard.synchronize()
    }
    
    func setAddressData()  {
        if addressData?.data.count ?? 0 > 0{
            self.showAddressList()
        }else{
            showAddAddress()
        }
        self.tbl_View_addedAddress.reloadData()
    }
    
    func showAddressList()  {
        self.lbl_BottomButtonTitle.text = isFromChangeAddress ? "CHANGE ADDRESS" : "DELIVER HERE"
        self.viewStepsBg.isHidden = isFromChangeAddress ? true : false
        self.constraint_view_stepsbg_height.constant = isFromChangeAddress ? 0 : 120
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
        isAddingAddress = false
        self.view_addedAddress.isHidden = false
        self.view_addAddress.isHidden = true
    }
    
    func showAddAddress() {
        self.lbl_BottomButtonTitle.text = "SAVE ADDRESS"
        isAddingAddress = true
        self.view_addedAddress.isHidden = true
        self.view_addAddress.isHidden = false
        self.manageSection_AddAddress()
    }
    
    func deleteSelectedAddress() {
        self.callAPIfor_DeleteAddress()
    }
    
    func showDeliverHereView() {
    
    }
    
    func showValidationToAddAddress() {
        var isSuccess = true
        addAddressDict = [:]
        for item in dataSource{
            if item.type == .pincode {
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please enter pincode")
                    isSuccess = false
                    break
                }else if item.subData[0] as? String == ""{
                    self.showErroMessage(title: "Please enter pincode")
                    isSuccess = false
                    break
                }else if (item.subData[0] as? String ?? "").count < MAX_LENGTH_PINCODE {
                    self.showErroMessage(title: "Please enter valid pincode")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["pincode"] = item.subData[0] as? String ?? ""
                }
            }else if item.type == .houseNo{
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please enter house no")
                    isSuccess = false
                    break
                }else if item.subData[0] as? String == ""{
                    self.showErroMessage(title: "Please enter house no")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["building_name"] = item.subData[0] as? String ?? ""
                }
            }else if item.type == .area{
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please enter your area")
                    isSuccess = false
                    break
                }else if item.subData[0] as? String == ""{
                    self.showErroMessage(title: "Please enter your area")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["address"] = item.subData[0] as? String ?? ""
                }
            }else if item.type == .city_state {
                var index = 0
                for _ in item.subData{
                    if index == 0{
                        if item.subData.count <= 0{
                            self.showErroMessage(title: "Please enter your city")
                            isSuccess = false
                            break
                        }else if item.subData[0] as? String == ""{
                            self.showErroMessage(title: "Please enter your city")
                            isSuccess = false
                            break
                        }else{
                            addAddressDict["city"] = item.subData[0] as? String ?? ""
                        }
                    }else if index == 1{
                        if item.subData.count <= 1{
                            self.showErroMessage(title: "Please enter your state")
                            isSuccess = false
                            break
                        }else if item.subData[1] as? String == ""{
                            self.showErroMessage(title: "Please enter your state")
                            isSuccess = false
                            break
                        }else{
                            addAddressDict["state"] = item.subData[1] as? String ?? ""
                        }
                    }
                    index += 1
                }
            }else if item.type == .city_state {
                if item.subData.count <= 1{
                    self.showErroMessage(title: "Please enter your state")
                    isSuccess = false
                    break
                }else if item.subData[1] as? String == ""{
                    self.showErroMessage(title: "Please enter your state")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["state"] = item.subData[1] as? String ?? ""
                }
            }else if item.type == .landmark {
                if item.subData.count <= 0{
                    addAddressDict["landmark"] = ""
                }else{
                    addAddressDict["landmark"] = item.subData[0] as? String ?? ""
                }
            }else if item.type == .fullName {
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please enter your full name")
                    isSuccess = false
                    break
                }else if item.subData[0] as? String == ""{
                    self.showErroMessage(title: "Please enter your full name")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["full_name"] = item.subData[0] as? String ?? ""
                }
            }else if item.type == .mobile {
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please enter your phone number")
                    isSuccess = false
                    break
                }else if  item.subData[0] as? String == ""{
                    self.showErroMessage(title: "Please enter your phone number")
                    isSuccess = false
                    break
                }else if (item.subData[0] as? String ?? "").count < MAX_LENGTH_PHONENUMBER {
                    self.showErroMessage(title: "Please enter valid phone number")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["phone_number"] = item.subData[0] as? String ?? ""
                }
            }
            else if item.type == .email {
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please enter email")
                    isSuccess = false
                    break
                }else if  item.subData[0] as? String == "" {
                    self.showErroMessage(title: "Please enter email")
                    isSuccess = false
                    break
                }
                else if !isValidEmail(testStr: (item.subData[0] as? String ?? "")) {
                    self.showErroMessage(title: "Please enter valid email.".localized())
                    isSuccess = false
                    break
                }else{
                    addAddressDict["email"] = item.subData[0] as? String ?? ""
                }
            }
            else if item.type == .address_Type {
                if item.subData.count <= 0{
                    self.showErroMessage(title: "Please select address type")
                    isSuccess = false
                    break
                }else if item.subData[0] as? String == ""{
                    self.showErroMessage(title: "Please select address type")
                    isSuccess = false
                    break
                }else{
                    addAddressDict["address_type"] = item.subData[0] as? String ?? ""
                }
            }
        }
        
        if isSuccess{
            callAPIfor_AddEditAddress()
        }
    }
                                      
                                      func isValidEmail(testStr:String) -> Bool {
                                          let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                                          
                                          let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                                          return emailTest.evaluate(with: testStr)
                                      }
    
    func showErroMessage(title: String) {
        Utils.showAlertWithTitleInControllerWithCompletion("", message: title.localized(), okTitle: "Ok".localized(), controller: findtopViewController()!) {}
    }
    
    func selectLocationAddress() {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else {
            initCurrentLocation()
            return
        }
        MPLocation.getAddressFromLatLon(pdblLatitude: "\(locValue.latitude)", withLongitude: "\(locValue.longitude)") { (pinCode, address) in
            print(pinCode)
            self.dataSource[1] = MPData(title: "Pincode (required) *", type: .pincode, subData: [address?.pincode ?? ""])
            self.dataSource[2] = MPData(title: "House No, Buidling Name (required)*", type: .houseNo, subData: [address?.landmark ?? ""])
            self.dataSource[3] = MPData.init(title: "Road, Colony, Area (required)*", type: .area, subData: [address?.address ?? ""])
            self.dataSource[4] = MPData.init(title: "City", type: .city_state, subData: [address?.city ?? "", address?.state ?? ""])
            self.tbl_View.reloadData()
        }

    }
    
    
//    func placeorderOptionSelection(_ success: Bool, selected_PlaceOrderOption: String) {
//        if success {
//            if selected_PlaceOrderOption == "Cash On Delivery" {
//                //self.saveOrderForCashOnDelivery()
//            }
//            else {
////                self.saveDataForRazorPay()
//            }
//        }
//    }
}

extension MPAddressVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

//MARK: - UITableView Delegate Datasource
extension MPAddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection_AddAddress() {
        let isAddress = isEditAddress && (addressData?.data.count ?? 0 > 0) ? true : false
        self.dataSource.removeAll()
        self.dataSource.append(MPData.init(title: "Use my location", type: .select_myLocation, subData: []))
        self.dataSource.append(MPData(title: "Pincode (required) *", type: .pincode, subData: [isAddress ? addressData?.data[selectedAddress].pincode ?? "" : ""]))
        self.dataSource.append(MPData(title: "House No, Buidling Name (required)*", type: .houseNo, subData: [isAddress ? addressData?.data[selectedAddress].building_no ?? "" : ""]))
        self.dataSource.append(MPData.init(title: "Road, Colony, Area (required)*", type: .area, subData: [isAddress ? addressData?.data[selectedAddress].address ?? "" : ""]))
        self.dataSource.append(MPData.init(title: "City", type: .city_state, subData: [isAddress ? addressData?.data[selectedAddress].city ?? "" : "", isAddress ? addressData?.data[selectedAddress].state ?? "" : ""]))
        self.dataSource.append(MPData.init(title: "Landmark (optional)", type: .landmark, subData: [isAddress ? addressData?.data[selectedAddress].landmark ?? "" : ""]))
        self.dataSource.append(MPData.init(title: "Contact Details", type: .address_Type_Title, subData: []))
        self.dataSource.append(MPData.init(title: "Full Name (required)*", type: .fullName, subData: [isAddress ? addressData?.data[selectedAddress].full_name ?? "" : Utils.getLoginUserData()["name"].stringValue]))
        self.dataSource.append(MPData.init(title: "Phone Number (required)*", type: .mobile, subData: [isAddress ? addressData?.data[selectedAddress].phone_number ?? "" : Utils.getLoginUserData()["mobile"].stringValue]))
        self.dataSource.append(MPData.init(title: "Email (required)*", type: .email, subData: [isAddress ? addressData?.data[selectedAddress].email ?? "" : Utils.getLoginUserData()["email"].stringValue]))
        
        self.dataSource.append(MPData.init(title: "Address Type", type: .address_Type_Title, subData: []))
        self.dataSource.append(MPData.init(title: "", type: .address_Type, subData: [isAddress ? addressData?.data[selectedAddress].address_type ?? "" : ""]))
        self.tbl_View.reloadData()
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbl_View_addedAddress {
            return addressData?.data.count ?? 0
        }
        else if tableView == tbl_View_OrderSummary {
            return self.dataSourceCart.data.count
        }
        else {
            return self.dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tbl_View_addedAddress {
            let cell = tableView.dequeueReusableCell(withClass: MPAddedAddressTableCell.self, for: indexPath)
//            cell.selectionStyle = .none
            cell.view_BG.layer.borderWidth = 1
            cell.view_BG.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
            let data = addressData?.data[indexPath.row]
            
            cell.lbl_Title.text = data?.full_name ?? "N/A"
            
            cell.lbl_SubTitle.text = MPAddressLocalDB.showWholeAddress(addressModel: data!)
            cell.lbl_Type.text = data?.address_type ?? ""
            cell.btn_Edit.isHidden = selectedAddress == indexPath.row ? false : true
            cell.img_selection.image = UIImage (named: selectedAddress == indexPath.row ? "icon_radio_button_checked" : "icon_radio_button_unchecked")
            cell.view_BG.layer.borderColor = selectedAddress == indexPath.row ? kAppBlueColor.cgColor : UIColor.lightGray.cgColor
            cell.lbl_editButton_line.isHidden = selectedAddress == indexPath.row ? false : true
            cell.btn_Delete.isHidden = selectedAddress == indexPath.row ? false : true
            cell.completionSelectionAdress = {
                self.selectedAddress = indexPath.row
                self.tbl_View_addedAddress.reloadData()
            }
            cell.completionEditAdress = {
                self.isEditAddress = true
                self.showAddAddress()
            }
            
            cell.completionDeleteAdress = {
                self.deleteSelectedAddress()
            }
            
            return cell
        }
        else if tableView == tbl_View_OrderSummary {
            let cell = tableView.dequeueReusableCell(withClass: MPOrderSummaryTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            let data = self.dataSourceCart.data[indexPath.item]
            cell.lbl_Title.text = data.title
                        
            let estimated_shipping_time = data.estimated_shipping_time
            cell.lbl_bottomTItle.text = ""// estimated_shipping_time.count == 0 ? "" : "Est. Delivery in \(estimated_shipping_time)"
            cell.lbl_SubTitle.text = data.cartData?.sizes ?? ""
            let urlString = data.thumbnail
            if let url = URL(string: urlString) {
                cell.img_product.af.setImage(withURL: url)
            }
            
            
            
            return cell
        }
        else {
            
            let typeee = self.dataSource[indexPath.item].type
            if typeee == .address_Type_Title {
                let cell = tableView.dequeueReusableCell(withClass: MPAddressTitleTableCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.lbl_Title.text = self.dataSource[indexPath.item].title ?? ""
                
                return cell
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withClass: MPAddAddressTableCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.view_Location.layer.borderWidth = 1
                cell.view_Single.layer.borderWidth = 1
                cell.view_Dual1.layer.borderWidth = 1
                cell.view_Dual2.layer.borderWidth = 1
                cell.view_Home.layer.borderWidth = 1
                cell.view_Office.layer.borderWidth = 1
                cell.completionDataUpdate = { (values, isState) in
                    if isState{
                        self.dataSource[indexPath.item].subData[1] = values
                    }else{
                        self.dataSource[indexPath.item].subData[0] = values
                    }
                }
                let typeee = self.dataSource[indexPath.item].type
                let data = self.dataSource[indexPath.item].subData
                cell.addressData =  self.dataSource[indexPath.item]
                if typeee == .select_myLocation {
                    cell.view_Dual.isHidden = true
                    cell.view_Single.isHidden = true
                    cell.view_Location.isHidden = false
                    cell.view_Location.layer.borderColor = UIColor.fromHex(hexString: "#007AFF").cgColor
                    cell.completionAddCurrentLocation = {
                        if typeee == .select_myLocation {
                            self.selectLocationAddress()
                        }
                    }
                }
                else {
                    cell.view_Home.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
                    cell.view_Office.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
                    cell.view_Dual1.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
                    cell.view_Dual2.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
                    cell.view_Single.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
                    
                    if typeee == .city_state {
                        cell.view_Dual1.isHidden = false
                        cell.view_Dual2.isHidden = false
                        cell.view_Home.isHidden = true
                        cell.view_Dual.isHidden = false
                        cell.view_Single.isHidden = true
                        cell.view_Office.isHidden = true
                        cell.view_Location.isHidden = true
                        cell.txt_dual1.placeholder = "City (required)*"
                        cell.txt_dual2.placeholder = "State (required)*"
                        cell.txt_dual1.text = data[0] as? String ?? ""
                        cell.txt_dual2.text = data[1] as? String ?? ""
                    }
                    else if typeee == .address_Type {
                        cell.view_Dual1.isHidden = true
                        cell.view_Dual2.isHidden = true
                        cell.view_Home.isHidden = false
                        cell.view_Dual.isHidden = false
                        cell.view_Single.isHidden = true
                        cell.view_Office.isHidden = false
                        cell.view_Location.isHidden = true
                        cell.selectedAddressTYpe = data[0] as? String ?? ""
                        cell.completionAddressType = { selectedType in
                            self.dataSource[indexPath.item].subData[0] = selectedType
                        }
                    }
                    else {
                        cell.view_Dual.isHidden = true
                        cell.view_Single.isHidden = false
                        cell.view_Location.isHidden = true
                        cell.txt_single.placeholder = self.dataSource[indexPath.item].title ?? ""
                        cell.txt_single.text = data[0] as? String ?? ""
                    }
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if tableView == tbl_View_OrderSummary {
//            let data = dataSourceCart.data[indexPath.row]
//            switch data.type {
//            case .cartPriceDetail:
//                return 495
//            default:
//                return UITableView.automaticDimension
//            }
//        }
//        else {
            return UITableView.automaticDimension
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tbl_View_addedAddress{
            selectedAddress = indexPath.row
            self.tbl_View_addedAddress.reloadData()
        }else if tableView == tbl_View_OrderSummary{
            let data = self.dataSourceCart.data[indexPath.item]
            let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.str_productID = "\(data.id)"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            let typeee = self.dataSource[indexPath.item].type
            if typeee == .select_myLocation {
                selectLocationAddress()
            }
        }
    }
}

//MARK:- RazorPay
extension MPAddressVC{
//    internal func showPaymentForm(orderId: String) {
//
//        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
//            return
//        }
//        let ayutythmUserName = empData["name"] as? String ?? ""
//        let ayutythmUserPhone = empData["mobile"] as? String ?? ""
//        let ayutythmUserEmail = empData["email"] as? String ?? ""
//
//        //--
//        let total_Amount = deliveryModel?.singleData?.Total_Payable.floatValue.rounded(toPlaces: 2) ?? 0
//
//        razorpayObj = RazorpayCheckout.initWithKey(kRazorpayKey, andDelegateWithData: self)
//        let options: [String:Any] = ["timeout":900,
//                                     "amount": "\(total_Amount*100)", //This is in currency subunits. 100 = 100 paise= INR 1.
//                                     "currency": "INR",//We support more that 92 international currencies.
//                                     "description": "",
//                                     "name": ayutythmUserName,
//                                     "razorpay_order_id": orderId,
//                                     "image": UIImage.init(named: "Splashlogo")!,
//                                     "prefill": ["contact": ayutythmUserPhone,
//                                                 "email": ayutythmUserEmail],
//                                     "theme": ["color": "#3c91e6"]]
//
//        if let rzp = self.razorpayObj {
//            rzp.open(options)
//        } else {
//            print("Unable to initialize")
//        }
//    }
    
//    func saveDataForRazorPay() {
//        self.showActivityIndicator()
//        let nameAPI: endPoint = .mp_user_order_SaveOrder
//        let data = self.addressData?.data[self.selectedAddress]
//        let param = ["total_payable": deliveryModel?.singleData?.Total_Payable.stringValue ?? "0",
//                    "shipping_cost": "0",
//                    "packing_cost": "0",
//                    "coupon_discount": "0",
//                     "shipping_name": data?.full_name ?? "",
//                    "shipping_phone": data?.phone_number ?? "",
//                    "shipping_address": data?.address ?? "",
//                    "shipping_city": data?.city ?? "",
//                    "shipping_zip": data?.pincode ?? "",
//                    "dp": "0",
//                    "txnid": "0",
//                     "vendor_shipping_id": "0",
//                     "vendor_packing_id": "0",
//                     "tax": "0"] as [String : Any]
//        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
//            self.hideActivityIndicator()
//            if isSuccess {
//                if let response = responseJSON?.rawValue as? [String : Any]{
//                    if let data = response["data"] as? [String: Any]{
//                        self.orderId = "\(data["order_id"] as? Int ?? 0)"
//                        self.showPaymentForm(orderId: "\(data["order_id"] as? Int ?? 0)")
//                    }
//                }
//            }else if status == "Token is Expired"{
//                callAPIfor_LOGIN()
//            } else {
//                self.showAlert(title: status, message: message)
//            }
//        }
//    }
    
//    func orderSuccessfullySentToServer(paymentId: String) {
//        let nameAPI: endPoint = .mp_user_order_UpdateRazorpayPaymentStatus
//        let data = self.addressData?.data[self.selectedAddress]
//        let param = ["order_id": self.orderId,
//                     "razorpay_payment_id": paymentId,
//                     "razorpay_order_id" : self.orderId] as [String : Any]
//        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
//            if isSuccess {
//                debugPrint(responseJSON)
//            }else if status == "Token is Expired"{
//                callAPIfor_LOGIN()
//            } else {
//                self.showAlert(title: status, message: message)
//            }
//        }
//    }
}

//extension MPAddressVC : RazorpayPaymentCompletionProtocol {
//    
//    func onPaymentError(_ code: Int32, description str: String) {
//        print("error1111: ", code, str)
//        let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
//        objDialouge.modalPresentationStyle = .overCurrentContext
//        objDialouge.price = deliveryModel?.singleData?.Total_Payable.stringValue ?? ""
//        objDialouge.screenfrom = .MP_PaymentFailed
//        self.present(objDialouge, animated: false, completion: nil)
//    }
//    
//    func onPaymentSuccess(_ payment_id: String) {
//        print("success: ", payment_id)
//    }
//}
//
//extension MPAddressVC: RazorpayPaymentCompletionProtocolWithData {
//    
//    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
//        print("error: ", code)
//        //self.presentAlert(withTitle: "Alert", message: str)
//    }
//    
//    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
//        print("success1223: ", payment_id)
//        orderSuccessfullySentToServer(paymentId: payment_id)
//        let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
//        objDialouge.modalPresentationStyle = .overCurrentContext
//        objDialouge.price = deliveryModel?.singleData?.Total_Payable.stringValue ?? ""
//        objDialouge.screenfrom = .MP_PaymentSuccess
//        self.present(objDialouge, animated: false, completion: nil)
//    }
//}


//MARK: - Custom Table Cell
class MPAddressTitleTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
}

class MPAddedAddressTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_BG: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_SubTitle: UILabel!
    @IBOutlet weak var btn_Edit: UIButton!
    @IBOutlet weak var btn_Delete: UIButton!
    @IBOutlet weak var lbl_Type: UILabel!
    @IBOutlet weak var lbl_editButton_line: UILabel!
    @IBOutlet weak var img_selection: UIImageView!
    
    var completionEditAdress: (() -> ())!
    var completionDeleteAdress: (() -> ())!
    var completionSelectionAdress: (() -> ())!
    
    @IBAction func btn_edit_action(_ sender: UIButton){
        completionEditAdress()
    }
    
    @IBAction func btn_Delete_action(_ sender: UIButton){
        completionDeleteAdress()
    }
    
    @IBAction func btn_addressSelection_action(_ sender: UIButton){
        completionSelectionAdress()
    }
}


class MPOrderSummaryTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_SubTitle: UILabel!
    @IBOutlet weak var lbl_bottomTItle: UILabel!
    @IBOutlet weak var img_product: UIImageView!
}

