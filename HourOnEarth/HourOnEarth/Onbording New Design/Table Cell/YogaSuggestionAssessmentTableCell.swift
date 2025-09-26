//
//  YogaSuggestionAssessmentTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 05/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class YogaSuggestionAssessmentTableCell: UITableViewCell {
    
    var superVC = UIViewController()
    var arr_Suggestion_Data = [NSManagedObject]()
    var sectionType : TodayGoal_Type = .Food
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var view_InnerFirst: UIView!
    
    @IBOutlet weak var lbl_infoText: UILabel!
    
    @IBOutlet weak var view_suggestion_BG: UIView!
    @IBOutlet weak var collect_view: UICollectionView!
    @IBOutlet weak var constraint_collect_view_Height: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var img_range: UIImageView!
    @IBOutlet weak var lbl_range: UILabel!
    @IBOutlet weak var img_type: UIImageView!
    @IBOutlet weak var btn_arrow: UIButton!
    
    @IBOutlet weak var view_InnerSecond: UIView!
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
    var didSuccessAfterUnlock: ((Int, TodayGoal_Type)->Void)? = nil
    var didGoToDetail: ((TodayGoal_Type, NSManagedObject)->Void)? = nil
    
    var arr_Data: [NSManagedObject]? {
        didSet {
            guard let listData = arr_Data else {
                return
            }
            self.arr_Suggestion_Data = listData
            self.collect_view.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collect_view.delegate = self
        self.collect_view.dataSource = self
        
#if !APPCLIP
        //Register Collection Cell
        self.collect_view.register(nibWithCellClass: HOEYogaCell.self)
        self.collect_view.register(nibWithCellClass: HOEFoodCell.self)
        self.collect_view.register(nibWithCellClass: HOEHerbCell.self)
        self.collect_view.register(nibWithCellClass: YogasanaPranayamTableCell.self)
#endif
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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

    
    @IBAction func btn_Detailed_Action(_ sender: UIControl) {
        if self.didTappedonArrow != nil {
            self.didTappedonArrow!(sender)
        }
    }
    
}


//MARK: CollectionViewDataSource/Delegates
 
extension YogaSuggestionAssessmentTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_Suggestion_Data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
#if !APPCLIP
        if self.sectionType == .Food {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEFoodCell", for: indexPath as IndexPath) as? HOEFoodCell else {
                return UICollectionViewCell()
            }
            guard let food = self.arr_Suggestion_Data[indexPath.row] as? Food else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(food: food)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withClass: YogasanaPranayamTableCell.self, for: indexPath)
            cell.img_selection.isHidden = true
            cell.constraint_img_Base_Height.constant = 35
            cell.constraint_view_Base_leading.constant = 12
            cell.constraint_view_Base_trilling.constant = 12
            
            if self.sectionType == .Yogasana {
                guard let yoga = self.arr_Suggestion_Data[indexPath.row] as? Yoga else {
                    return UICollectionViewCell()
                }
                cell.configureUI(yoga: yoga)
                cell.btnLock.tag = indexPath.row
                debugPrint("yoga.access_point \(yoga.access_point)")
                if yoga.access_point == 0 {
                    cell.lockView.isHidden = true
                }
                else {
                    cell.lockView.isHidden = yoga.redeemed
                }
                
                cell.didTappedonLockView = { (sender) in
                    self.didSelectedSelectRowForRedeem(type: self.sectionType, index: indexPath.row)
                }
            }
            else if self.sectionType == .Pranayama {
                if let dic_pranayama = self.arr_Suggestion_Data[indexPath.row] as? Pranayama {
                    cell.configureUIPranayama(Pranayama: dic_pranayama)
                    cell.btnLock.tag = indexPath.row
                    debugPrint("pranayama.access_point \(dic_pranayama.access_point)")
                    if dic_pranayama.access_point == 0 {
                        cell.lockView.isHidden = true
                    }
                    else {
                        cell.lockView.isHidden = dic_pranayama.redeemed
                    }
                    
                    cell.didTappedonLockView = { (sender) in
                        self.didSelectedSelectRowForRedeem(type: self.sectionType, index: indexPath.row)
                    }
                }
            }
            else if self.sectionType == .Meditation {
                guard let Meditation = self.arr_Suggestion_Data[indexPath.row] as? Meditation else {
                    return UICollectionViewCell()
                }
                cell.configureUIMeditation(meditation: Meditation)
                cell.btnLock.tag = indexPath.row
                debugPrint("meditation.access_point \(Meditation.access_point)")
                if Meditation.access_point == 0 {
                    cell.lockView.isHidden = true
                }
                else {
                    cell.lockView.isHidden = Meditation.redeemed
                }
                
                cell.didTappedonLockView = { (sender) in
                    self.didSelectedSelectRowForRedeem(type: self.sectionType, index: indexPath.row)
                }
            }
            
            return cell
        }
#endif
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.sectionType == .Food {
            return CGSize(width: 110, height: 110)
        }
        else if self.sectionType == .Yogasana || self.sectionType == .Pranayama || self.sectionType == .Meditation {
            return CGSize(width: self.collect_view.frame.size.width, height: 70)
        }
        return CGSize(width: 0, height: 0)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dic_Data = self.arr_Suggestion_Data[indexPath.row]
        self.didGoToDetail!(self.sectionType, dic_Data)
    }
    
    func didSelectedSelectRowForRedeem(type: TodayGoal_Type, index: Int) {

        var accessPoint = Int()
        var name = String()
        var favID = Int()

        if type == .Meditation {
            guard let Meditation = self.arr_Suggestion_Data[index] as? Meditation else {
                return
            }
            name = type.rawValue.lowercased()
            favID = Meditation.id
            accessPoint = Int(Meditation.access_point)
        }
        else if type == .Yogasana {
            guard let yogasana = self.arr_Suggestion_Data[index] as? Yoga else {
                return
            }
            name = type.rawValue.lowercased()
            favID = Int(yogasana.id)
            accessPoint = Int(yogasana.access_point)
        }
        else if type == .Pranayama {
            guard let pranayama = self.arr_Suggestion_Data[index] as? Pranayama else {
                return
            }
            name = type.rawValue.lowercased()
            favID = pranayama.id
            accessPoint = Int(pranayama.access_point)
        }
#if !APPCLIP
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.superVC) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let strongSelf = self else { return }
            strongSelf.didSuccessAfterUnlock!(favID, type)
        }
 #endif
    }
    
}
