//
//  CurrentBalDetailTypeTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class CurrentBalDetailTypeTableCell: UITableViewCell {

    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var view_InnerFirst: UIView!
    @IBOutlet weak var view_InnerSecond: UIView!
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var img_range: UIImageView!
    @IBOutlet weak var lbl_range: UILabel!
    @IBOutlet weak var img_type: UIImageView!
    @IBOutlet weak var btn_arrow: UIButton!
    @IBOutlet weak var constraint_img_range_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_img_range_Leading: NSLayoutConstraint!
    
    //For Detaill
    @IBOutlet weak var lbl_shortDescriptionL: UILabel!
    @IBOutlet weak var whatDoesThisMeanL: UILabel!
    @IBOutlet weak var whatDoesThisMeanSV: UIStackView!
    
    @IBOutlet weak var paramValue1: ParamValueRangeView!
    @IBOutlet weak var paramValue2: ParamValueRangeView!
    @IBOutlet weak var paramValue3: ParamValueRangeView!
    @IBOutlet weak var paramValue4: ParamValueRangeView!
    @IBOutlet weak var paramValue5: ParamValueRangeView!
    @IBOutlet weak var paramValuesSV: UIStackView!
    @IBOutlet weak var paramBMIOther2ValuesSV: UIStackView!
    
    var didTappedonArrow: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_Main.layer.borderWidth = 0
    }
    
    func updateValueRangesAndSelectedValue(_ resultParam: SparshnaResultParamModel?) {
        guard let data = resultParam else { return }
        
        let paramValue = Int(data.paramStringValue) ?? 0
        paramValue1.isSelected = false
        paramValue2.isSelected = false
        paramValue3.isSelected = false
        paramValue4.isSelected = false
        paramValue5.isSelected = false
        
        switch data.paramType {
        case .bpm:
            paramValue1.titleL.text = "Below 70".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "Kaphaa")
            
            paramValue2.titleL.text = "70-80"
            paramValue2.image1.image = #imageLiteral(resourceName: "PittaN")
            
            paramValue3.titleL.text = "Above 80".localized()
            paramValue3.image1.image = #imageLiteral(resourceName: "VataN")
            
            if (paramValue < 70) {
                paramValue1.isSelected = true
            } else if (paramValue >= 70 && paramValue <= 80) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .sp:
            paramValue1.titleL.text = "Below 90".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "VataN")
            
            paramValue2.titleL.text = "90-120"
            paramValue2.image1.image = #imageLiteral(resourceName: "PittaN")
            
            paramValue3.titleL.text = "Above 120".localized()
            paramValue3.image1.image = #imageLiteral(resourceName: "Kaphaa")
            
            if (paramValue < 90) {
                paramValue1.isSelected = true
            } else if (paramValue >= 90 && paramValue <= 120) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .dp:
            paramValue1.titleL.text = "Below 60".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "VataN")
            
            paramValue2.titleL.text = "60-80"
            paramValue2.image1.image = #imageLiteral(resourceName: "PittaN")
            
            paramValue3.titleL.text = "Above 80".localized()
            paramValue3.image1.image = #imageLiteral(resourceName: "Kaphaa")
            
            if (paramValue < 60) {
                paramValue1.isSelected = true
            } else if (paramValue >= 60 && paramValue <= 80) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .bala:
            paramValue1.titleL.text = "Below 30".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "VataN")
            
            paramValue2.titleL.text = "30-40"
            paramValue2.image1.image = #imageLiteral(resourceName: "Kaphaa")
            
            paramValue3.titleL.text = "Above 40".localized()
            paramValue3.image1.image = #imageLiteral(resourceName: "PittaN")
            
            if (paramValue < 30) {
                paramValue1.isSelected = true
            } else if (paramValue >= 30 && paramValue <= 40) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .kath:
            paramValue1.titleL.text = "Below 210".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "PittaN")
            
            paramValue2.titleL.text = "210-310"
            paramValue2.image1.image = #imageLiteral(resourceName: "Kaphaa")
            
            paramValue3.titleL.text = "Above 310".localized()
            paramValue3.image1.image = #imageLiteral(resourceName: "VataN")
            
            if (paramValue < 210) {
                paramValue1.isSelected = true
            } else if (paramValue >= 210 && paramValue <= 310) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .gati:
            paramValue1.titleL.text = "Hamsa".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "Kaphaa")
            
            paramValue2.titleL.text = "Manduka".localized()
            paramValue2.image1.image = #imageLiteral(resourceName: "PittaN")
            
            paramValue3.titleL.text = "Sarpa".localized()
            paramValue3.image1.image = #imageLiteral(resourceName: "VataN")
            
            if data.paramStringValue == "Kapha" {
                paramValue1.isSelected = true
            } else if data.paramStringValue == "Pitta" {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .rythm:
            paramValue1.titleL.text = "Regular".localized()
            paramValue1.image1.image = #imageLiteral(resourceName: "Kaphaa")
            paramValue1.image2.isHidden = false
            
            paramValue2.titleL.text = "Irregular".localized()
            paramValue2.image1.image = #imageLiteral(resourceName: "VataN")
            
            paramValue3.isHidden = true
            
            if paramValue == 0 {
                paramValue2.isSelected = true
            } else {
                paramValue1.isSelected = true
            }
            
        case .o2r:
            paramValue1.titleL.text = "90-95".localized()
            paramValue1.stringValue = "Borderline".localized()
            paramValue2.titleL.text = "95-97"
            paramValue2.stringValue = "Normal".localized()
            paramValue3.titleL.text = "Above 97".localized()
            paramValue3.stringValue = "Good".localized()
            
            if (paramValue >= 90 && paramValue <= 95) {
                paramValue1.isSelected = true
            } else if (paramValue >= 95 && paramValue <= 97) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .bmi:
            paramValue1.titleL.text = "Below 18.5".localized()
            paramValue1.stringValue = "Underweight".localized()
            paramValue2.titleL.text = "18.5 - 24.9"
            paramValue2.stringValue = "Normal".localized()
            paramValue3.isHidden = true
            paramValue4.titleL.text = "25 - 30".localized()
            paramValue4.stringValue = "Overweight".localized()
            paramValue5.titleL.text = "Above 30".localized()
            paramValue5.stringValue = "Obese".localized()
            paramBMIOther2ValuesSV.isHidden = false
            
            let doubleValue = Double(data.paramStringValue) ?? 0
            if (doubleValue <= 18.5) {
                paramValue1.isSelected = true
            } else if (doubleValue > 18.5 && doubleValue <= 24.9) {
                paramValue2.isSelected = true
            } else if (doubleValue > 25 && doubleValue <= 30) {
                paramValue4.isSelected = true
            } else {
                paramValue5.isSelected = true
            }
            
        case .bmr:
            paramValuesSV.isHidden = true
                
        default:
            print("unhandled cases come here")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Detailed_Action(_ sender: UIControl) {
        if self.didTappedonArrow != nil {
            self.didTappedonArrow!(sender)
        }
    }
    
}
