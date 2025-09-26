//
//  MP_CategoryProductList.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 13/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MP_CategoryProductList: UIViewController {
    
    var strTitle = ""
    var str_CatID = ""
    var arr_ProductList = [WeeklyPlanner_ProductModel]()
    
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var lbl_NoDataTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = self.strTitle
        self.view_NoData.isHidden = true
        self.lbl_NoDataTitle.text = "Ouhh! You don't have any products yet."
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: Category_ProductsTableCell.self)
        
        self.callAPIfor_GETProductList()
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
    
    
    
    @IBAction func btn_ShopNowAction(_ sender: UIControl) {
        self.navigationController?.popToRootViewController(animated: true)
        
        if let arrViewControllers = self.navigationController?.viewControllers {
            for aViewController in arrViewControllers {
                if aViewController.isKind(of: HOEForYouHomeVC.self) {
                    (aViewController as? HOEForYouHomeVC)?.tabBarController?.selectedIndex = 2
                }
            }
        }
    }

}

//MARK: - UITableView Delegate DataSource Method
extension MP_CategoryProductList: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_ProductList.first?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category_ProductsTableCell", for: indexPath) as! Category_ProductsTableCell
        cell.selectionStyle = .none
        
        if let dic_detail = self.arr_ProductList.first?.data[indexPath.row] as? WeeklyPlannerProductData {
            cell.lbl_title.text = dic_detail.product_name
            cell.lbl_subtitle.text = dic_detail.product_sub_name
            
            let urlString = dic_detail.thumbnail
            if let url = URL(string: urlString) {
                cell.img_Product.af.setImage(withURL: url)
            }
            
            cell.view_NotStarted.isHidden = dic_detail.started_using
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dic_detail = self.arr_ProductList.first?.data[indexPath.row] as? WeeklyPlannerProductData {
            let vc = MP_ProductReminderVC.instantiate(fromAppStoryboard: .WeeklyPlaner)
            vc.strTitle = self.strTitle
            vc.strCatID = self.str_CatID
            vc.dic_ProductDetail = dic_detail
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}





//MARK: - API CALLING
extension MP_CategoryProductList {
    func callAPIfor_GETProductList() {

        self.showActivityIndicator()
        let nameAPI: endPoint = .mp_rasayan_product_list
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["category_id": self.str_CatID]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_ProductList.removeAll()
                let mPProductModel = WeeklyPlanner_ProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_ProductList.append(mPProductModel)
                }
                self.view_NoData.isHidden = (self.arr_ProductList.first?.data.count ?? 0) == 0 ? false : true
                self.tbl_View.reloadData()
            }else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}
