//
//  EnhanceWellnessJourneyTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 04/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class EnhanceWellnessJourneyTableCell: UITableViewCell {

    var arr_section = [[String: Any]]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var Constraint_collection_view_Height: NSLayoutConstraint!
    
    var didTappedonCellIndex: ((Int)->Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.register(nibWithCellClass: WellnessJourneyCollectionCell.self)
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
        self.manageSection()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}


//MARK: - UICollection View Delegate Datasource Method
extension EnhanceWellnessJourneyTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func manageSection() {
        self.arr_section.removeAll()
        let BGColors1 = [UIColor.fromHex(hexString: "#C8203D"), UIColor.fromHex(hexString: "#FFFFFF")]
        let BGColors2 = [UIColor.fromHex(hexString: "#CED5EC"), UIColor.fromHex(hexString: "#738DEC")]
        let BGColors3 = [UIColor.fromHex(hexString: "#FFF6A1"), UIColor.fromHex(hexString: "#FFDD4D")]
        let BGColors4 = [UIColor.fromHex(hexString: "#D8ECCA"), UIColor.fromHex(hexString: "#91EF58")]
        
        
//        let BGColors1 = [UIColor.fromHex(hexString: "#FFF6A1"), UIColor.fromHex(hexString: "#FFDD4D")]
//        let BGColors2 = [UIColor.fromHex(hexString: "#CED5EC"), UIColor.fromHex(hexString: "#738DEC")]
//        let BGColors3 = [UIColor.fromHex(hexString: "#D8ECCA"), UIColor.fromHex(hexString: "#91EF58")]
//        
        self.arr_section.append(["gredient_color" : BGColors1, "title": "Explore ayurvedic\ndaily diet plans", "img": "icon_unlock_diet", "bg_img": "icon_frame_1", "tag": 111])
        self.arr_section.append(["gredient_color" : BGColors2, "title": "Book a session with\nhealth expert", "img": "icon_wellness_expert", "bg_img": "icon_frame_2", "tag": 112])
        
        if UserDefaults.user.is_main_subscription == false {
            self.arr_section.append(["gredient_color" : BGColors3, "title": "Unlock premium benefits", "img": "icon_unlock_benifiit", "bg_img": "icon_frame_3", "tag": 113])
        }
        //Remove Shop Section as per Sandeep
        //if Locale.current.isCurrencyCodeInINR {
            //self.arr_section.append(["gredient_color" : BGColors4, "title": "Shop personalized Ayurveda Products", "img": "icon_ayurveda_product", "bg_img": "icon_frame_4", "tag": 114])
        //}
        
        
//        self.arr_section.append(["gredient_color" : BGColors1, "title": "Unlock premium benefits", "img": "icon_unlock_benifiit"])
//        self.arr_section.append(["gredient_color" : BGColors2, "title": "Meet Our\nWellness Experts", "img": "icon_wellness_expert"])
//        self.arr_section.append(["gredient_color" : BGColors3, "title": "Shop personalized Ayurveda Products", "img": "icon_ayurveda_product"])
        let get_count: Double = (Double(self.arr_section.count)/2).rounded(.up)
        let collect_width = ((screenWidth - 36) / 2) - 8
        let getHeight = collect_width * get_count
        self.Constraint_collection_view_Height.constant = getHeight + 12
        self.collection_view.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WellnessJourneyCollectionCell", for: indexPath) as! WellnessJourneyCollectionCell
        
        //let arrcolors = self.arr_section[indexPath.row]["gredient_color"] as? [UIColor] ?? [UIColor.black]
        let str_Title = self.arr_section[indexPath.row]["title"] as? String ?? ""
        let str_ImgName = self.arr_section[indexPath.row]["img"] as? String ?? ""
        let str_BG_img = self.arr_section[indexPath.row]["bg_img"] as? String ?? ""

        cell.lbl_Title.text = str_Title
        cell.img_BG.image = UIImage.init(named: str_BG_img)
        cell.img_logo.image = UIImage.init(named: str_ImgName)

//        if let gradientColor = CAGradientLayer.init(frame: cell.view_Base.frame, colors: arrcolors, direction: GradientDirection.Bottom).creatGradientImage() {
//            cell.view_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//            if let gradientColor = CAGradientLayer.init(frame: cell.view_Base.frame, colors: arrcolors, direction: GradientDirection.Bottom).creatGradientImage() {
//                cell.view_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
//            }
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collect_width = ((screenWidth - 36) / 2) - 8
        return CGSize.init(width: collect_width, height: collect_width)
        //return CGSize.init(width: self.collection_view.frame.size.width/2, height: self.collection_view.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let int_tag = self.arr_section[indexPath.row]["tag"] as? Int ?? 0
#if !APPCLIP
        self.didTappedonCellIndex!(int_tag)
#endif
    }
}

