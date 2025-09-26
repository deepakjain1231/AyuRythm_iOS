//
//  MPMyAddressVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 08/11/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import CoreLocation

class MPMyAddressVC: UIViewController {

    var dataSource = [MPData]()
    var arr_AddedAddress = [MPData]()

    
    @IBOutlet weak var lbl_address_title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var tbl_View_addedAddress: UITableView!
    @IBOutlet weak var view_addedAddress: UIView!
    @IBOutlet weak var view_addAddress: UIView!
    @IBOutlet weak var btn_AddNewAddress: UIControl!
    @IBOutlet weak var btn_SaveAddress: UIControl!
    @IBOutlet weak var lbl_BottomButtonTitle: UILabel!
    @IBOutlet weak var constraint_btn_SaveAddress_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_odrdersummary_Leading: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_SelectedAddressName: UILabel!
    @IBOutlet weak var lbl_SelectedAddressTYpe: UILabel!
    @IBOutlet weak var lbl_SelectedAddress: UILabel!
    

    //MARK:- Variables
    var addressData: MPAddressModel?
    var selectedAddress = 0
    var isEditAddress = false
    var isAddingAddress = false
    var addAddressDict = [String: Any]()
    let locationManager = CLLocationManager()
    var isFromChangeAddress = false
    var completionSelectAddress: (() -> ())!
    var isLoadFirstTime = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Address"
        self.btn_SaveAddress.isHidden = true
        self.constraint_btn_SaveAddress_Height.constant = 0
        self.tbl_View.register(nibWithCellClass: MPAddAddressTableCell.self)
        callAPIfor_GetAddress()
        self.manageSection_AddAddress()
        self.tbl_View_addedAddress.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back(sender:)))
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
    
    @objc func back(sender: UIBarButtonItem) {
        if view_addedAddress.isHidden == true && isAddingAddress {
            self.showAddressList()
        }else if view_addedAddress.isHidden == true && self.view_addAddress.isHidden == true {
            self.showAddressList()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UIButton Method Action
    @IBAction func btn_SaveAddress(_ sender: UIControl) {
        
        if self.lbl_BottomButtonTitle.text == "CHANGE ADDRESS" {
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
        }else {
            self.view.endEditing(true)
            showValidationToAddAddress()
        }
    }
    
    @IBAction func btn_AddNewAddress(_ sender: UIControl) {
        self.isEditAddress = false
        self.title = "Add Address"
        showAddAddress()
        initCurrentLocation()
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
        self.lbl_BottomButtonTitle.text = isFromChangeAddress ? "CHANGE ADDRESS" : "SAVE ADDRESS"
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
        self.btn_SaveAddress.isHidden = false
        self.constraint_btn_SaveAddress_Height.constant = 50
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
        if isLocationPermissionGranted() {
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
        else {
            let alertController = UIAlertController (title: "", message: "Please enable location permission and try again", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func isLocationPermissionGranted() -> Bool {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
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

extension MPMyAddressVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

//MARK: - UITableView Delegate Datasource
extension MPMyAddressVC: UITableViewDelegate, UITableViewDataSource {
    
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
        self.dataSource.append(MPData.init(title: "Full Name (required)*", type: .fullName, subData: [isAddress ? addressData?.data[selectedAddress].full_name ?? "" : ""]))
        self.dataSource.append(MPData.init(title: "Phone Number (required)*", type: .mobile, subData: [isAddress ? addressData?.data[selectedAddress].phone_number ?? "" : ""]))
        self.dataSource.append(MPData.init(title: "Email (required)*", type: .email, subData: [isAddress ? addressData?.data[selectedAddress].email ?? "" : ""]))
        
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
                self.title = "Edit Address"
                self.showAddAddress()
            }
            
            cell.completionDeleteAdress = {
                self.deleteSelectedAddress()
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
        }else{
            let typeee = self.dataSource[indexPath.item].type
            if typeee == .select_myLocation {
                selectLocationAddress()
            }
        }
    }
}
