//
//  MP_ProductReminderVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 13/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON

class MP_ProductReminderVC: UIViewController {

    var strTitle = ""
    var strCatID = ""
    var str_CurrentDay = ""
    var arr_Days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var arr_week_Days = ["Blank", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @IBOutlet weak var collection_days: UICollectionView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_goodMorrnig: UILabel!
    @IBOutlet weak var img_Illutation: UIImageView!
    
    
    var arr_Section = [[String: Any]]()
    var arr_TimeSlot = [WeeklyPlanner_TimeSlot]()
    var dic_ProductDetail = WeeklyPlannerProductData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = self.strTitle
        self.lbl_goodMorrnig.text = "\(get_Day_Status())"
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            if (empData["gender"] as? String ?? "").lowercased() == "male" {
                self.img_Illutation.image = UIImage.init(named: "icon_navHeader_male")
            }
            else {
                self.img_Illutation.image = UIImage.init(named: "icon_navHeader")
            }
        }
        
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            self.lbl_userName.text = "\(empData["name"] as? String ?? "")"
        }
        
        
        self.getCurrentDay()
        self.startWeeklyTimer()
        
        //Register Colllection cell
        self.tblView.register(nibWithCellClass: ProductHeaderTableCell.self)
        self.collection_days.register(nibWithCellClass: WeekCollectionCell.self)
        self.tblView.register(nibWithCellClass: Category_ProductsTableCell.self)

        
        
        self.collection_days.reloadData()
        self.callAPIfor_GetproductListDayWise()
        self.callAPIfor_GETTimeSlot()
    }
    
    func getCurrentDay() {
        let cuurent_Day = Date().dayNumberOfWeek() ?? 0
        self.str_CurrentDay = arr_week_Days[cuurent_Day]
    }
    
    func startWeeklyTimer() {
        if self.dic_ProductDetail.started_using == false {
            let alertController = UIAlertController(title: nil, message: "Do you want to start the weekly planner?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Later".localized(), style: UIAlertAction.Style.default, handler: nil))
            alertController.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { actionnn in
                self.callAPIfor_StartWeeklyTimer()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btn_EditReminder(_ sender: UIControl) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = EditReminderDialouge(nibName:"EditReminderDialouge", bundle:nil)
            objDialouge.superVC = self
            objDialouge.screenFrom = .MP_EditReminder
            objDialouge.arr_TimeSlot = self.arr_TimeSlot
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }

}

//MARK: - UICollectionView Delegate DataSource Method
extension MP_ProductReminderVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_Days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCollectionCell", for: indexPath) as! WeekCollectionCell

        cell.view_BG.borderWidth1 = 0.8
        cell.view_BG.layer.cornerRadius = 22
        let str_WeekName = self.arr_Days[indexPath.item]
        cell.lbl_weekName.text = str_WeekName
        
        if str_WeekName == self.str_CurrentDay {
            cell.view_BG.borderColor1 = .clear
            cell.lbl_weekName.textColor = .white
            cell.view_BG.backgroundColor = UIColor.fromHex(hexString: "3E8B3A")
        }
        else {
            cell.view_BG.backgroundColor = .white
            cell.view_BG.borderColor1 = .lightGray
            cell.lbl_weekName.textColor = .darkGray
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (UIScreen.main.bounds.width - 40)/CGFloat(self.arr_Days.count) - 8, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let str_WeekName = self.arr_Days[indexPath.item]
        self.str_CurrentDay = str_WeekName
        self.collection_days.reloadData()
    }
}

//MARK: - UITableView Delegate DataSource Method
extension MP_ProductReminderVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strID = self.arr_Section[indexPath.row]["id"] as? String ?? ""
        if strID == "header" || strID == "day_slot" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeaderTableCell", for: indexPath) as! ProductHeaderTableCell
            cell.selectionStyle = .none
            
            if strID == "header" {
                cell.lbl_TimeSlot.text = ""
                cell.view_weekName_BG.isHidden = false
                cell.lbl_weekName.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            }
            else {
                cell.lbl_weekName.text = ""
                cell.view_weekName_BG.isHidden = true
                cell.lbl_TimeSlot.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Category_ProductsTableCell", for: indexPath) as! Category_ProductsTableCell
            cell.selectionStyle = .none
            cell.view_NotStarted.isHidden = true
            
            if let dic_detail = self.arr_Section[indexPath.row]["value"] as? JSON {
                //let str_sizr = dic_detail["size_label_for_simple_product"].stringValue
                cell.lbl_title.text = "\(dic_detail["name"].stringValue)"//" \(str_sizr)"
                cell.lbl_subtitle.text = dic_detail["ayurvedic_name"].string

                let urlString = dic_detail["thumbnail"].stringValue
                if let url = URL(string: urlString) {
                    cell.img_Product.af.setImage(withURL: url)
                }
            }
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let strID = self.arr_Section[indexPath.row]["id"] as? String ?? ""
        if strID == "productt" {
            if let dic_detail = self.arr_Section[indexPath.row]["value"] as? JSON {
                let vc = HowToUseProductVC.instantiate(fromAppStoryboard: .WeeklyPlaner)
                vc.dic_Datail = dic_detail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


//MARK: - API CALLING
extension MP_ProductReminderVC {
    
    func callAPIfor_GetproductListDayWise() {
        
        showActivityIndicator()
        let nameAPI: endPoint = .mp_daywiseProductList
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["category_id": strCatID, "product_id": "\(self.dic_ProductDetail.product_id)"]
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            
            if isSuccess {
                
                self.arr_Section.removeAll()
                
                if let dic_Days = responseJSON?.dictionaryValue["data"]?.array?.first {
                    if let dic_Mon = dic_Days["Mon"].dictionary {
                        if dic_Mon.count != 0 {
                            self.manage_Section(day_name: "Monday", arr_weekDay: dic_Mon)
                        }
                    }
                    
                    if let dic_Tue = dic_Days["Tue"].dictionary {
                        if dic_Tue.count != 0 {
                            self.manage_Section(day_name: "Tuesday", arr_weekDay: dic_Tue)
                        }
                    }
                    
                    if let dic_Wed = dic_Days["Wed"].dictionary {
                        if dic_Wed.count != 0 {
                            self.manage_Section(day_name: "Wednesday", arr_weekDay: dic_Wed)
                        }
                    }
                    
                    if let dic_Thu = dic_Days["Thu"].dictionary {
                        if dic_Thu.count != 0 {
                            self.manage_Section(day_name: "Thursday", arr_weekDay: dic_Thu)
                        }
                    }
                    
                    if let dic_Fri = dic_Days["Fri"].dictionary {
                        if dic_Fri.count != 0 {
                            self.manage_Section(day_name: "Friday", arr_weekDay: dic_Fri)
                        }
                    }
                    
                    if let dic_Sat = dic_Days["Sat"].dictionary {
                        if dic_Sat.count != 0 {
                            self.manage_Section(day_name: "Saturday", arr_weekDay: dic_Sat)
                        }
                    }
                    
                    if let dic_Sun = dic_Days["Sun"].dictionary {
                        if dic_Sun.count != 0 {
                            self.manage_Section(day_name: "Sunday", arr_weekDay: dic_Sun)
                        }
                    }
                }
                
                self.tblView.reloadData()
            }else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func manage_Section(day_name: String, arr_weekDay: [String: JSON]?) {
        self.arr_Section.append(["id" : "header", "title": day_name])
        if let arrMor_Product = arr_weekDay?["Morning"]?.array {
            if arrMor_Product.count != 0 {
                self.arr_Section.append(["id" : "day_slot", "title": "☀ Morning"])
                
                for productt in arrMor_Product {
                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
                }
            }
        }
        
        if let arrAfternoon_Product = arr_weekDay?["Afternoon"]?.array {
            if arrAfternoon_Product.count != 0 {
                self.arr_Section.append(["id" : "day_slot", "title": "🌞 Afternoon"])
                
                for productt in arrAfternoon_Product {
                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
                }
            }
        }
        
        if let arrEve_Product = arr_weekDay?["Evening"]?.array {
            if arrEve_Product.count != 0 {
                self.arr_Section.append(["id" : "day_slot", "title": "🌕 Evening"])
                
                for productt in arrEve_Product {
                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
                }
            }
        }
        
        if let arrNight_Product = arr_weekDay?["Night"]?.array {
            if arrNight_Product.count != 0 {
                self.arr_Section.append(["id" : "day_slot", "title": "🌙 Night"])
                
                for productt in arrNight_Product {
                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
                }
            }
        }
    }
    
    
//    func manage_Section(day_name: String, arr_weekDay: [JSON]) {
//        self.arr_Section.append(["id" : "header", "title": day_name])
//        for daySlot in arr_weekDay {
//            let arrMor_Product = daySlot["Morning"].arrayValue
//            if arrMor_Product.count != 0 {
//                self.arr_Section.append(["id" : "day_slot", "title": "☀ Morning"])
//
//                for productt in arrMor_Product {
//                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
//                }
//            }
//
//            let arrAfternoon_Product = daySlot["Afternoon"].arrayValue
//            if arrAfternoon_Product.count != 0 {
//                self.arr_Section.append(["id" : "day_slot", "title": "🌞 Afternoon"])
//
//                for productt in arrAfternoon_Product {
//                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
//                }
//            }
//
//            let arrEve_Product = daySlot["Evening"].arrayValue
//            if arrEve_Product.count != 0 {
//                self.arr_Section.append(["id" : "day_slot", "title": "🌕 Evening"])
//
//                for productt in arrEve_Product {
//                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
//                }
//            }
//
//            let arrNight_Product = daySlot["Night"].arrayValue
//            if arrNight_Product.count != 0 {
//                self.arr_Section.append(["id" : "day_slot", "title": "🌙 Night"])
//
//                for productt in arrNight_Product {
//                    self.arr_Section.append(["id" : "productt", "title": "", "value": productt])
//                }
//            }
//        }
//    }
    
    func callAPIfor_GETTimeSlot() {
        
        //showActivityIndicator()
        let nameAPI: endPoint = .mp_reminderTime
        let getHeader = MPLoginLocalDB.getHeaderToken()
                
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_TimeSlot.removeAll()
                let mPCategoryModel = WeeklyPlanner_TimeSlot(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPCategoryModel.data.count != 0{
                    self.arr_TimeSlot.append(mPCategoryModel)
                }
            }else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_StartWeeklyTimer() {
        
        //showActivityIndicator()
        let nameAPI: endPoint = .mp_start_weeklyPlanner
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["row_id": "\(self.dic_ProductDetail.row_id)", "start_planner": true] as [String : Any]
                
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                if let arrViewControllers = self.navigationController?.viewControllers {
                    for aViewController in arrViewControllers {
                        if aViewController.isKind(of: MP_Product_CategoryVC.self) {
                            (aViewController as? MP_Product_CategoryVC)?.callAPIfor_GETProductList()
                        }
                        else if aViewController.isKind(of: MP_CategoryProductList.self) {
                            (aViewController as? MP_CategoryProductList)?.callAPIfor_GETProductList()
                        }
                    }
                }
            }else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
}


extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
