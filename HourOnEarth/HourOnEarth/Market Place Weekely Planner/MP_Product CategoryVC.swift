//
//  MP_Product CategoryVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 12/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MP_Product_CategoryVC: UIViewController {

    var arr_Sections = [[String: Any]]()
    var arr_Category = [WeeklyPlanner_CategoryModel]()
    var arr_ProductList = [WeeklyPlanner_ProductModel]()
    
    @IBOutlet weak var lbl_NoData: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Your products"
        self.lbl_NoData.isHidden = true
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: YourProductHeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: YourProduct_KitCollectionCell.self)
        self.tbl_View.register(nibWithCellClass: ProductsTableCell.self)
        self.tbl_View.register(nibWithCellClass: Category_ProductsTableCell.self)
        self.tbl_View.register(nibWithCellClass: NoDataTableCell.self)
        
        self.callAPIfor_GETProductCategory()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UITableView Delegate DataSource Method
extension MP_Product_CategoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Sections.removeAll()

        if let arrData = self.arr_ProductList.first?.data {
            
            if (arr_Category.first?.data.count ?? 0) != 0 {
                self.arr_Sections.append(["id" : "header", "title1": "Personalised weekly plans for your products", "title2": "Kits"])
                
                self.arr_Sections.append(["id" : "kit_collection", "title1": "", "title2": "", "data": arr_Category])
            }

            self.arr_Sections.append(["id" : "header", "title1": "", "title2": "Products"])
            
            for dic_data in arrData {
                self.arr_Sections.append(["id" : "products", "title1": "", "title2": "Products", "data": dic_data])
            }
        }
        else {
            self.arr_Sections.append(["id" : "header", "title1": "Personalised weekly plans for your products", "title2": ""])
            
            self.arr_Sections.append(["id" : "no_single_product", "title1": "", "title2": "Products"])
        }
        
//        if (arr_Category.first?.data.count ?? 0) == 0 && (self.arr_ProductList.first?.data.count ?? 0) == 0 {
//            self.lbl_NoData.isHidden = false
//        }
//        else {
//            self.lbl_NoData.isHidden = true
//        }
            

        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_Identifier = self.arr_Sections[indexPath.row]["id"] as? String ?? ""
        
        if str_Identifier == "header" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourProductHeaderTableCell", for: indexPath) as! YourProductHeaderTableCell
            cell.selectionStyle = .none
            
            let str_title1 = self.arr_Sections[indexPath.row]["title1"] as? String ?? ""
            let str_title2 = self.arr_Sections[indexPath.row]["title2"] as? String ?? ""
            cell.lbl_title_1.isHidden = str_title1 == "" ? true : false
            cell.btn_EditReminder.isHidden = str_title1 == "" ? false : true
            cell.lbl_title_1.text = str_title1
            cell.lbl_title_2.text = str_title2
            
            
            cell.didTappedonEditReminder = { (sender) in
                if let parent = kSharedAppDelegate.window?.rootViewController {
                    let objDialouge = EditReminderDialouge(nibName:"EditReminderDialouge", bundle:nil)
                    objDialouge.superVC = self
                    objDialouge.arr_ProductList = self.arr_ProductList
                    parent.addChild(objDialouge)
                    objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    parent.view.addSubview((objDialouge.view)!)
                    objDialouge.didMove(toParent: parent)
                }
            }
            
            return cell
        }
        else if str_Identifier == "kit_collection" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourProduct_KitCollectionCell", for: indexPath) as! YourProduct_KitCollectionCell
            cell.selectionStyle = .none
            cell.categories = self.arr_Category
            cell.collection_viewkit.reloadData()
            
            let totalData = self.arr_Category.first?.data.count ?? 0
            let getValue = Double(totalData)/2
            let getV = getValue.rounded(.up)
            cell.constraint_collection_viewkit_HEIGHT.constant = getV * 135
            
            //did Tapped on Category Data
            cell.didSelectCategory = { (cat_data) in
                let vc = MP_CategoryProductList.instantiate(fromAppStoryboard: .WeeklyPlaner)
                vc.strTitle = "\(cat_data.name) kit"
                vc.str_CatID = "\(cat_data.id)"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
            return cell
        }
        else if str_Identifier == "no_single_product" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableCell", for: indexPath) as! NoDataTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = "Ouhh! You don't have any products yet."
            
            cell.did_TappedShopNow = { (sender) in
                self.navigationController?.popToRootViewController(animated: true)
                
                if let arrViewControllers = self.navigationController?.viewControllers {
                    for aViewController in arrViewControllers {
                        if aViewController.isKind(of: HOEForYouHomeVC.self) {
                            (aViewController as? HOEForYouHomeVC)?.tabBarController?.selectedIndex = 2
                        }
                    }
                }
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Category_ProductsTableCell", for: indexPath) as! Category_ProductsTableCell
            cell.selectionStyle = .none
            
            if let dic_detail = self.arr_Sections[indexPath.row]["data"] as? WeeklyPlannerProductData {
                cell.lbl_title.text = dic_detail.product_name
                cell.lbl_subtitle.text = dic_detail.ayurvedic_name
                
                let urlString = dic_detail.thumbnail
                if let url = URL(string: urlString) {
                    cell.img_Product.af.setImage(withURL: url)
                }
                
                cell.view_NotStarted.isHidden = dic_detail.started_using
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str_Identifier = self.arr_Sections[indexPath.row]["id"] as? String ?? ""
        if str_Identifier == "products" {
            if let dic_detail = self.arr_Sections[indexPath.row]["data"] as? WeeklyPlannerProductData {
                let vc = MP_ProductReminderVC.instantiate(fromAppStoryboard: .WeeklyPlaner)
                vc.strTitle = dic_detail.product_name
                vc.dic_ProductDetail = dic_detail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}





//MARK: - API CALLING
extension MP_Product_CategoryVC {
    func callAPIfor_GETProductCategory() {
        
        showActivityIndicator()
        let nameAPI: endPoint = .mp_rasayan_category_list
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["sort_by": "", "sort_by_id": "", "brand_filter": "", "category_filter": "", "price_range": "", "delivery_time": "", "discount": ""]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_Category.removeAll()
                let mPCategoryModel = WeeklyPlanner_CategoryModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPCategoryModel.data.count != 0{
                    self.arr_Category.append(mPCategoryModel)
                }
                self.callAPIfor_GETProductList()
            }else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_GETProductList() {
        
        let nameAPI: endPoint = .mp_rasayan_product_list
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_ProductList.removeAll()
                let mPProductModel = WeeklyPlanner_ProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_ProductList.append(mPProductModel)
                }
                self.manageSection()
            }else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}
