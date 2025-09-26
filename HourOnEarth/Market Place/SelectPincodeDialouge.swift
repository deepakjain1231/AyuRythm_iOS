//
//  SelectPincodeDialouge.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//




import UIKit
import CoreLocation

protocol delegateSelectPincode {
    func Clk_After_selectPinCode(_ success: Bool, pincode: String, address_id: String)
}
var MPSelectPinCode = ""
class SelectPincodeDialouge: UIViewController {

    //MARK: - @IBOutlet
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_Close: UIButton!
    @IBOutlet weak var btn_CurrentLocation: UIButton!
    @IBOutlet weak var img_Location: UIImageView!
    @IBOutlet weak var lbl_UseMyLocation: UILabel!
    @IBOutlet weak var txt_Pincode: UITextField!
    @IBOutlet weak var btnSubmit: UIControl!
    @IBOutlet weak var btn_TitleSubmit: UILabel!
    @IBOutlet weak var view_Collection_BG: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Collection_BG_Height: NSLayoutConstraint!
    
    
    //MARK: - Veriable
    var selectedAddress = -1
    var addressData: MPAddressModel?
    var delegate: delegateSelectPincode?
    let locationManager = CLLocationManager()

    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Register Collection Cell
        self.collection_view.register(nibWithCellClass: MPSaveAddressCollectionCell.self)
        
        if kSharedAppDelegate.userId != "" {
            self.callAPIfor_GetAddressList()
        }
        else {
            self.constraint_view_Collection_BG_Height.constant = 0
        }
        
        self.view_Main.layer.cornerRadius = 12
        self.btn_Close.setTitle("", for: .normal)
        self.btn_CurrentLocation.setTitle("", for: .normal)
        self.constraint_view_Bottom.constant = -UIScreen.main.bounds.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        txt_Pincode.delegate = self
        //--
        initCurrentLocation()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.constraint_view_Bottom.constant = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        } completion: { success in
        }
    }
    
    @objc func close_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.constraint_view_Bottom.constant = -UIScreen.main.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { success in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    func initCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Submit_Action(_ sender: UIControl) {
        if self.txt_Pincode.text != "" {
            self.delegate?.Clk_After_selectPinCode(true, pincode: self.txt_Pincode.text ?? "", address_id: "")
            self.close_animation()
        }
    }
    
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        self.close_animation()
    }
    @IBAction func btnCurrentLocation(_ sender: Any) {
        if isLocationPermissionGranted() {
            guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else {
                initCurrentLocation()
                return
            }

            MPLocation.getAddressFromLatLon(pdblLatitude: "\(locValue.latitude)", withLongitude: "\(locValue.longitude)") { (pinCode, address) in
                self.delegate?.Clk_After_selectPinCode(true, pincode: pinCode, address_id: "")
                self.close_animation()
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
}


//MARK: - API Call

extension SelectPincodeDialouge {

    func callAPIfor_GetAddressList() {
        let nameAPI: endPoint = .mp_user_mycart_getUserAddress

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                let mPaddressData = MPAddressModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.addressData = mPaddressData

                let data = MPAddressLocalDB.getAddress()
                for i in 0..<(self.addressData?.data.count ?? 0){
                    if self.addressData?.data[i].id == data.id {
                        MPAddressLocalDB.saveAddress(strData: self.addressData?.data[safe: self.selectedAddress]?.toJSONString() ?? "")
                    }
                }
                
                if self.addressData?.data.count == 0 {
                    self.constraint_view_Collection_BG_Height.constant = 0
                }
                else {
                    self.constraint_view_Collection_BG_Height.constant = 135
                }


                if let strAddressID = UserDefaults.standard.object(forKey: kDeliveryAddressID) as? String {
                    if let indxx = self.addressData?.data.firstIndex(where: { dic_address in
                        let addressid = "\(dic_address.id)"
                        return addressid == strAddressID
                    }) {
                        self.selectedAddress = indxx
                    }
                }

                self.collection_view.reloadData()
                self.view.layoutIfNeeded()
            }else if status.lowercased() == "Token is Expired".lowercased() || status.lowercased() == "Authorization Token not found".lowercased(){
                callAPIfor_LOGIN()
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Something went wrong! Please try again.".localized(), okTitle: "Ok".localized(), controller: findtopViewController()!) {}
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}

extension SelectPincodeDialouge: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = textField.text!.count + string.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        return (strValid && (newLength <= MAX_LENGTH_PINCODE))
    }
}

extension SelectPincodeDialouge: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}


//MARK: - UITableView Delegate Datasource
extension SelectPincodeDialouge: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addressData?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: MPSaveAddressCollectionCell.self, for: indexPath)
        cell.view_Base.layer.borderWidth = 1
        cell.view_Base.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        let data = addressData?.data[indexPath.row]

        cell.lbl_Title.text = data?.full_name ?? "N/A"
        cell.lbl_Type.text = data?.address_type ?? ""
        cell.lbl_SubTitle.text = MPAddressLocalDB.showWholeAddressForEnterPincodeScreen(addressModel: data!)
        cell.img_selection.image = self.selectedAddress == indexPath.row ? MP_appImage.img_radio_selected : MP_appImage.img_radio_unselected
        cell.view_Base.layer.borderColor = selectedAddress == indexPath.row ? kAppBlueColor.cgColor : UIColor.lightGray.cgColor

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let getWidth = (UIScreen.main.bounds.width/2) + 15
        return CGSize.init(width: getWidth, height: 122)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = addressData?.data[indexPath.row]
        self.selectedAddress = indexPath.row
        var strUsername = data?.full_name ?? ""
        if strUsername != "" {
            strUsername = "\(strUsername) - "
        }
        let selectedPincode = "\(strUsername) \(data?.pincode ?? "")"
        self.delegate?.Clk_After_selectPinCode(true, pincode: selectedPincode, address_id: "\(data?.id ?? 0)")
        self.collection_view.reloadData()
        self.collection_view.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.close_animation()
    }
}
