//
//  View_RecipeBottomSheet.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 15/01/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

class View_RecipeBottomSheet: UIViewController {

    var str_FoodDay = ""
    var str_FoodSubstaction = ""
    var str_infoText = ""
    var is_openMethod = false
    var dic_DietItem: ARDietItemModel?
    var arr_Nutrition = [[String: Any]]()
    var arr_alternativeData: [ARDietItemModel]?
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_TopHeader: UIView!
    @IBOutlet weak var view_scroll: UIScrollView!
    @IBOutlet weak var view_Inner_Base: UIView!
    @IBOutlet weak var img_food: UIImageView!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var lbl_Alternatives: UILabel!
    @IBOutlet weak var collection_nutricision: UICollectionView!
    @IBOutlet weak var collection_alternative: UICollectionView!
    @IBOutlet weak var lbl_infoText: UILabel!
    @IBOutlet weak var constraint_viewMain_bottom: NSLayoutConstraint!
    @IBOutlet weak var lbl_foodName: UILabel!
    @IBOutlet weak var lbl_foodType: UILabel!
    @IBOutlet weak var lbl_foodKcal: UILabel!
    @IBOutlet weak var img_vegNonVeg: UIImageView!
    @IBOutlet weak var Constraint_lbl_infoText_TOP: NSLayoutConstraint!
    @IBOutlet weak var Constraint_lbl_infoText_BOTTOM: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register Collection Cell============================================//
        self.collection_nutricision.register(nibWithCellClass: NutrisicionCollectionCell.self)
        self.collection_alternative.register(nibWithCellClass: AlternativeFoodCollectionCell.self)
        //********************************************************************//
        
        self.setupText()
        self.constraint_viewMain_bottom.constant = -screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view_TopHeader.addGestureRecognizer(swipeDown)
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .up || swipeGesture.direction == .down {
                self.clkToClose()
            }
        }
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_bottom.constant = 0
            self.view_Base.roundCorners(corners: [.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
            let BGColors = [UIColor.fromHex(hexString: "#DEF8DE"), UIColor.fromHex(hexString: "#FFFFFF")]
            if let gradientColor = CAGradientLayer.init(frame: self.view_Inner_Base.frame, colors: BGColors, direction: GradientDirection.Bottom).creatGradientImage() {
                self.view_Inner_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
            }
        }
    }
    
    func clkToClose(_ isAction: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func setupText() {
        self.is_openMethod = false
        var str_foodName = self.dic_DietItem?.name ?? ""
        self.str_infoText = self.dic_DietItem?.recipes ?? ""
        str_foodName = str_foodName == "" ? (self.dic_DietItem?.food_name ?? "") : str_foodName
        self.lbl_foodName.text = str_foodName
        
        self.img_food.af_setImage(withURLString: self.dic_DietItem?.image)
        self.img_food.layer.cornerRadius = 10
        self.img_food.clipsToBounds = true
        self.img_food.layer.masksToBounds = true
        
        if self.dic_DietItem?.food_type != "Vegetarian" {
            self.img_vegNonVeg.image = UIImage.init(named: "icon_nonveg")
        }
        else {
            self.img_vegNonVeg.image = UIImage.init(named: "icon_veg")
        }

        var str_kcal = self.dic_DietItem?.calary
        if self.dic_DietItem?.calary == "" {
            str_kcal = "0 Kcal"
        }
        else {
            str_kcal = "\(self.dic_DietItem?.calary ?? "0") Kcal"
        }
        self.lbl_foodKcal.text = str_kcal
        self.lbl_foodType.text = (self.dic_DietItem?.info ?? "")
        self.lbl_foodType.isHidden = (self.dic_DietItem?.info ?? "") == "" ? true : false
        
        let str_qauntity = self.dic_DietItem?.qauntity ?? ""
        if str_qauntity != "" {
            self.lbl_foodName.text = "\(str_foodName) - (\(str_qauntity.trimed()))"
        }
        
        let newText = NSMutableAttributedString.init(string: "")
        self.lbl_infoText.attributedText = newText
        self.Constraint_lbl_infoText_TOP.constant = 12
        self.Constraint_lbl_infoText_BOTTOM.constant = 0
        

        //Setup Nutrition
        self.arr_Nutrition.removeAll()
        self.arr_Nutrition.append(["txt1": self.dic_DietItem?.carbs ?? "", "txt2": "Carbs", "img": "icon_carbs"])
        self.arr_Nutrition.append(["txt1": self.dic_DietItem?.protein ?? "", "txt2": "Protein", "img": "icon_protein"])
        self.arr_Nutrition.append(["txt1": self.dic_DietItem?.fiber ?? "", "txt2": "Fiber", "img": "icon_fiber"])
        self.arr_Nutrition.append(["txt1": self.dic_DietItem?.fats ?? "", "txt2": "Fats", "img": "icon_fats"])
        self.collection_nutricision.reloadData()
        
        
        self.collection_alternative.reloadData()
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btn_close_Action(_ sender: UIButton) {
        self.clkToClose()
    }
    
    @IBAction func btn_open_closeReceipe_Action(_ sender: UIButton) {
        if self.is_openMethod {
            UIView.animate(withDuration: 0.3) {
                let newText = NSMutableAttributedString.init(string: "")
                self.lbl_infoText.attributedText = newText
                self.Constraint_lbl_infoText_TOP.constant = 12
                self.Constraint_lbl_infoText_BOTTOM.constant = 0
            } completion: { success in
                self.is_openMethod = false
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.Constraint_lbl_infoText_TOP.constant = 20
                self.Constraint_lbl_infoText_BOTTOM.constant = 20
                let str_ingredients = "Ingredients".localized() + ":"
                let str_instructions = "Instructions".localized() + ":"
                let str_tips = "Tips".localized() + ":"
                 
                var str_Text = self.str_infoText.replacingOccurrences(of: "**", with: "")
                str_Text = str_Text.replacingOccurrences(of: ":", with: "")
                
                if Utils.getLanguageId() == 1 {
                    str_Text = str_Text.replacingOccurrences(of: "Ingredients", with: str_ingredients)
                    str_Text = str_Text.replacingOccurrences(of: "Instructions", with: str_instructions)
                    str_Text = str_Text.replacingOccurrences(of: "Tips", with: str_tips)
                }
                else {
                    str_Text = str_Text.replacingOccurrences(of: "सामग्री", with: str_ingredients)
                    str_Text = str_Text.replacingOccurrences(of: "निर्देश", with: str_instructions)
                    str_Text = str_Text.replacingOccurrences(of: "सुझाव", with: str_tips)
                }

                let newText = NSMutableAttributedString.init(string: str_Text)

                newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(14), range: NSRange.init(location: 0, length: newText.length))
                newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange.init(location: 0, length: newText.length))

                let textRange = NSString(string: str_Text)
                let highlight_range1 = textRange.range(of: str_ingredients)
                let highlight_range2 = textRange.range(of: str_instructions)
                let highlight_range3 = textRange.range(of: str_tips)
                
                newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(15), range: highlight_range1)
                newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(15), range: highlight_range2)
                newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(15), range: highlight_range3)

                self.lbl_infoText.attributedText = newText
            } completion: { success in
                self.is_openMethod = true
            }
        }
    }
    
    
}


// MARK: - CollectionView Delegate DataSource Method
extension View_RecipeBottomSheet: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collection_alternative {
            return self.arr_alternativeData?.count ?? 0
        }
        return self.arr_Nutrition.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collection_alternative {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlternativeFoodCollectionCell", for: indexPath) as! AlternativeFoodCollectionCell
            
            let dic = self.arr_alternativeData?[indexPath.row]
            cell.img_icon.layer.cornerRadius = 37.5
            cell.img_icon.clipsToBounds = true
            cell.img_icon.layer.masksToBounds = true
            
            cell.lbl_foodName.text = dic?.food_name as? String ?? ""
            let img_banner = dic?.image as? String ?? ""
            cell.img_icon.sd_setImage(with: URL.init(string: img_banner), placeholderImage: UIImage.init(named: "icon_diet_banner"), options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NutrisicionCollectionCell", for: indexPath) as! NutrisicionCollectionCell
            
            let dic = self.arr_Nutrition[indexPath.row]
            cell.lbl_1.text = dic["txt1"] as? String ?? ""
            cell.lbl_2.text = dic["txt2"] as? String ?? ""
            
            let str_img = dic["img"] as? String ?? ""
            cell.img_icon.image = UIImage.init(named: str_img)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collection_alternative {
            return CGSize.init(width: 90, height: 165)
        }
        return CGSize.init(width: (screenWidth - 46)/4, height: 97)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collection_alternative {
            let dic = self.arr_alternativeData?[indexPath.row]
            self.dic_DietItem = dic
            self.callAPIforGetAlternativesItem(foodID: dic?.id ?? "")
        }
    }
}

//MARK: - API Call
extension View_RecipeBottomSheet {
    
    func callAPIforGetAlternativesItem(foodID: String) {
        let params = ["language_id" : Utils.getLanguageId(),
                      "food_id": foodID,
                      "food_day": self.str_FoodDay,
                      "food_subsection": self.str_FoodSubstaction] as [String : Any]
        self.showActivityIndicator()
        Utils.doAPICall(endPoint: .getAlternativeFoodNames, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let dic_alternative = AlternaiveFoodModel(fromJson: responseJSON)
                self?.hideActivityIndicator()
                self?.arr_alternativeData = dic_alternative.data
                self?.setupText()
                self?.view_scroll.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
}
