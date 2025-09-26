//
//  MPAddAddressTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPAddAddressTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_Location: UIControl!
    @IBOutlet weak var view_Single: UIView!
    @IBOutlet weak var view_Dual: UIView!
    @IBOutlet weak var view_Dual1: UIView!
    @IBOutlet weak var view_Dual2: UIView!
    @IBOutlet weak var view_Home: UIView!
    @IBOutlet weak var view_Office: UIView!
    @IBOutlet weak var txt_single: UITextField!
    @IBOutlet weak var txt_dual1: UITextField!
    @IBOutlet weak var txt_dual2: UITextField!
    
    @IBOutlet weak var lbl_home: UILabel!
    @IBOutlet weak var lbl_office: UILabel!
    @IBOutlet weak var img_home: UIImageView!
    @IBOutlet weak var img_office: UIImageView!

    
    var completionAddressType: ((String) -> ())?
    var completionDataUpdate: ((String, Bool) -> ())?
    var completionAddCurrentLocation: (() -> ())?
    var addressData: MPData?
    var selectedAddressTYpe: String! {
        didSet{
            setSelectedType()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func homeButtonAction(_ sender: UIButton){
        selectedAddressTYpe = "Home"
        if completionAddressType != nil{
            completionAddressType?(selectedAddressTYpe)
        }
    }
    
    @IBAction func addCurrentLocationButtonAction(_ sender: UIButton){
        if completionAddCurrentLocation != nil{
            completionAddCurrentLocation?()
        }

    }
    
    @IBAction func officeButtonAction(_ sender: UIButton){
        selectedAddressTYpe = "Business"
        if completionAddressType != nil{
            completionAddressType?(selectedAddressTYpe)
        }
    }
    
    func setSelectedType() {
        if selectedAddressTYpe.lowercased() == "home"{
            self.view_Home.borderColor1 = UIColor.systemBlue
            self.lbl_home.textColor = UIColor.systemBlue
            self.img_home.image = UIImage(named: "icon_home_selected")?.tint(with: UIColor.systemBlue)

            self.view_Office.borderColor1 = self.view_Single.borderColor1
            self.lbl_office.textColor = UIColor.black
            self.img_office.image = UIImage(named: "icon_office-building")?.tint(with: UIColor.black)
        }else if selectedAddressTYpe.lowercased() == "business"{
            self.view_Office.borderColor1 = UIColor.systemBlue
            self.lbl_office.textColor = UIColor.systemBlue
            self.img_office.image = UIImage(named: "icon_office-building")?.tint(with: UIColor.systemBlue)

            self.view_Home.borderColor1 = self.view_Single.borderColor1
            self.lbl_home.textColor = UIColor.black
            self.img_home.image = UIImage(named: "icon_home_selected")?.tint(with: UIColor.black)
        }else {
            self.view_Office.borderColor1 = self.view_Single.borderColor1
            self.lbl_office.textColor = UIColor.black
            self.img_office.image = UIImage(named: "icon_office-building")?.tint(with: UIColor.black)

            self.view_Home.borderColor1 = self.view_Single.borderColor1
            self.lbl_home.textColor = UIColor.black
            self.img_home.image = UIImage(named: "icon_home_selected")?.tint(with: UIColor.black)
        }
    }
}

extension MPAddAddressTableCell: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if completionDataUpdate != nil{
            completionDataUpdate?(textField.text ?? "", textField == txt_dual2 ? true : false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if addressData?.type == .pincode{
            let newLength: Int = textField.text!.count + string.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            if !(strValid && (newLength <= MAX_LENGTH_PINCODE)){
                return (strValid && (newLength <= MAX_LENGTH_PINCODE))
            }else{
                if completionDataUpdate != nil{
                    completionDataUpdate?(textField.text! + string, textField == txt_dual2 ? true : false)
                }
                return true
            }
        }else if addressData?.type == .mobile{
            let newLength: Int = textField.text!.count + string.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            if !(strValid && (newLength <= MAX_LENGTH_PHONENUMBER)){
                return (strValid && (newLength <= MAX_LENGTH_PHONENUMBER))
            }else{
                if completionDataUpdate != nil{
                    completionDataUpdate?(textField.text! + string, textField == txt_dual2 ? true : false)
                }
                return true
            }
        }
        if completionDataUpdate != nil{
            completionDataUpdate?(textField.text! + string, textField == txt_dual2 ? true : false)
        }
        return true
    }
}
