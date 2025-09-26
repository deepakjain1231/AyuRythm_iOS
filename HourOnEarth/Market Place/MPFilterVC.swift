//
//  MPFilterVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 07/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit


class MPFilterOptions {
    var title: String?
    var type: MPFilterType?
    var subData: [Any]
    
    internal init(title: String? = nil, type: MPFilterType? = nil, subData: [Any]) {
        self.title = title
        self.type = type
        self.subData = subData
    }
    
}
var mpFilter_Selected_PriceRange = ""
var mpFilter_Selected_DeliveryTime = ""
var mpFilter_Selected_Discounts = ""
var MPApplyFilter = false

class MPFilterVC: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView_Type: UITableView!
    @IBOutlet weak var tableView_Data: UITableView!
    @IBOutlet weak var btnApply: UIButton!
    
    //MARK: - Veriable
    var str_ScreenID = ""
    var str_Screen_Name = ""
    
    var didTappedApplyFilter: ((UIControl, [String: Any])->Void)? = nil
    var selectedIndx = 0
    var arr_FiltterOption = [MPFilterModel]()
    
    var dic_FilterSelection = [String: Any]()
    
//    var arr_Category = [MPCategoryModel]()
//    var arr_PopularBrand = [MPCategoryModel]()
//    var arr_PriceRange:[String] = ["10-500", "501-1000", "1001-1500", "1501-2000", "2001-5000"]
    
    //var arrSelected_PriceRange:[String] = []
//    var arr_DeliveryTime:[String] = ["5-7 days", "24", "1-3 days"]
    
    //var arrSelected_DeliveryTime:[String] = []
//    var arr_Discounts:[String] = ["up to 2%", "up to 5%", "up to 10%", "up to 20%", "up to 30%"]
    
    //var arrSelected_Discounts:[String] = []
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Filters"
        navigationItem.backButtonTitle = ""
        //tableView_Type.register(nibWithCellClass: filterTypeTableCell.self)
        self.callapiforgetFilterOption()
        
        
//        dataSource = [MPFilterOptions(title: "Brand", type: .fBrand, subData: []),
//                      MPFilterOptions(title: "Category", type: .fCategory, subData: []),
//                      MPFilterOptions(title: "Price Range", type: .fPriceRange, subData: arr_PriceRange),
//                      MPFilterOptions(title: "Delivery Time", type: .fDeliveryTime, subData: arr_DeliveryTime),
//                      MPFilterOptions(title: "Discounts", type: .fDiscount, subData: arr_Discounts)]
//        self.tableView_Type.reloadData()
//        self.tableView_Data.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView_Type.reloadData()
        self.tableView_Data.reloadData()
    }
    
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_ClearAll_Action(_ sender: UIButton) {
        self.selectedIndx = 0
        self.dic_FilterSelection.removeAll()
//        arr_PopularBrand.first?.data.forEach({ mPCategoryData in
//            mPCategoryData.isSelect = false
//        })
//        arr_Category.first?.data.forEach({ mPCategoryData in
//            mPCategoryData.isSelect = false
//        })
//        mpFilter_Selected_PriceRange = ""
//        mpFilter_Selected_DeliveryTime = ""
//        mpFilter_Selected_Discounts = ""
        
        MPApplyFilter = false
        self.setupPreviousSelection()
        self.tableView_Type.reloadData()
        self.tableView_Data.reloadData()
    }
    
    @IBAction func btnApply(_ sender: UIControl) {
        var key_Name = ""
        MPApplyFilter = true
        
        if let arrMainData = self.arr_FiltterOption.first?.data {
            for main_data in arrMainData {
                let mainDataTitle = main_data.title
                let multiselection = main_data.filter_selection_type
                if multiselection == "multiple" {
                    if mainDataTitle.lowercased().contains("brand") {
                        key_Name = "brand_filter"
                    }
                    else if mainDataTitle.lowercased().contains("category") {
                        key_Name = "category_filter"
                    }
                    
                    if key_Name != "" {
                        
                        let selectIds = main_data.filter_value.filter { mPSelected_Data in
                            mPSelected_Data.isSelect == true
                        }.map { mPSelected_Data in
                            "\(mPSelected_Data.id)"
                        }.joined(separator: ",")

                        self.dic_FilterSelection[key_Name] = selectIds
                    }

                }
            }
        }
        
        if self.didTappedApplyFilter != nil {
            self.didTappedApplyFilter!(sender, self.dic_FilterSelection)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension MPFilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView_Type {
            return self.arr_FiltterOption.first?.data.count ?? 0
        }
        else {
            let sub_data = self.arr_FiltterOption.first?.data[self.selectedIndx]
            return sub_data?.filter_value.count ?? 0
//            switch sub_data.type {
//            case .fBrand:
//                return arr_PopularBrand.first?.data.count ?? 0
//            case .fCategory:
//                return arr_Category.first?.data.count ?? 0
////            case .fPriceRange:
////                let data_ = sub_data.subData as! [String]
////                return data_.count
////            case .fDeliveryTime:
////                let data_ = sub_data.subData as! [String]
////                return data_.count
////            case .fDiscount:
////                let data_ = sub_data.subData as! [String]
////                return data_.count
//            default:
//                let data_ = sub_data.subData as! [String]
//                return data_.count
//            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRow(at: indexPath, tableView: tableView)
    }
    func cellForRow(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        if tableView == self.tableView_Type {
            let data = self.arr_FiltterOption.first?.data[indexPath.row]

            let cell = tableView_Type.dequeueReusableCell(withClass: filterTypeTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = data?.title
            
            if indexPath.row == self.selectedIndx {
                cell.view_Base.backgroundColor = .white
                cell.lbl_Title.textColor = kAppBlueColor
            }
            else {
                cell.view_Base.backgroundColor = kFilter_GrayColor
                cell.lbl_Title.textColor = kFilter_GrayTextColor
            }
            
            return cell
        }
        else {
            let cell = tableView_Data.dequeueReusableCell(withClass: filterTypeTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            let main_data = self.arr_FiltterOption.first?.data[self.selectedIndx]
            let sub_data = main_data?.filter_value[indexPath.row]
            let str_Value = sub_data?.name ?? ""
            cell.lbl_Title.text = str_Value

            let multiselection = main_data?.filter_selection_type ?? ""
            if multiselection == "multiple" {
                let is_select = sub_data?.isSelect ?? false
                if is_select {
                    cell.img_selection?.image = MP_appImage.img_CheckBox_selected
                }else{
                    cell.img_selection?.image = MP_appImage.img_CheckBox_unselected
                }
            }
            else {
                var key_Name = ""
                let mainDataTitle = main_data?.title ?? ""
                let str_Value = sub_data?.name ?? ""
                if mainDataTitle.lowercased().contains("price") {
                    key_Name = "price_range"
                }
                else if mainDataTitle.lowercased().contains("delivery") {
                    key_Name = "delivery_time"
                }
                else if mainDataTitle.lowercased().contains("discount") {
                    key_Name = "discount"
                }
                let F_valueeee = self.dic_FilterSelection[key_Name] as? String ?? ""
                if F_valueeee == str_Value {
                    cell.img_selection?.image = MP_appImage.img_CheckBox_selected
                }else{
                    cell.img_selection?.image = MP_appImage.img_CheckBox_unselected
                }
            }
            
//            switch sub_data.type {
//            case .fBrand:
//                cell.lbl_Title.text = arr_PopularBrand.first?.data[indexPath.row].name
//                guard let data_ = arr_PopularBrand.first?.data[indexPath.row] else { break }
//                if data_.isSelect{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_selected")
//                }else{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_unselected")
//                }
//
//            case .fCategory:
//                cell.lbl_Title.text = arr_Category.first?.data[indexPath.row].name
//                guard let data_ = arr_Category.first?.data[indexPath.row] else { break }
//                if data_.isSelect{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_selected")
//                }else{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_unselected")
//                }
//
//            case .fPriceRange:
////                let title = sub_data.subData[indexPath.row] as? String ?? ""
//                cell.lbl_Title.text = title
//                if mpFilter_Selected_PriceRange == title{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_selected")
//                }else{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_unselected")
//                }
//            case .fDeliveryTime:
////                let title = sub_data.subData[indexPath.row] as? String ?? ""
//                cell.lbl_Title.text = title
//                if mpFilter_Selected_DeliveryTime == title{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_selected")
//                }else{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_unselected")
//                }
//            case .fDiscount:
////                let title = sub_data.subData[indexPath.row] as? String ?? ""
//                cell.lbl_Title.text = title
//                if mpFilter_Selected_Discounts == title{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_selected")
//                }else{
//                    cell.img_selection?.image = UIImage.init(named: "check_box_unselected")
//                }
//
//            default:
//                let cell = tableView_Data.dequeueReusableCell(withClass: filterTypeTableCell.self, for: indexPath)
//
//                return cell
//            }
        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView_Type {
            self.selectedIndx = indexPath.row
            self.tableView_Type.reloadData()
            self.tableView_Data.reloadData()
        }
        else {
            var key_Name = ""
            let main_data = self.arr_FiltterOption.first?.data[self.selectedIndx]
            let sub_data = main_data?.filter_value[indexPath.row]
            let multiselection = main_data?.filter_selection_type ?? ""
            if multiselection == "multiple" {
                let is_select = sub_data?.isSelect ?? false
                if is_select {
                    self.arr_FiltterOption.first?.data[self.selectedIndx].filter_value[indexPath.row].isSelect = false
                }else{
                    self.arr_FiltterOption.first?.data[self.selectedIndx].filter_value[indexPath.row].isSelect = true
                }
            }
            else {
                let mainDataTitle = main_data?.title ?? ""
                let str_Value = sub_data?.name ?? ""
                if mainDataTitle.lowercased().contains("price") {
                    key_Name = "price_range"
                }
                else if mainDataTitle.lowercased().contains("delivery") {
                    key_Name = "delivery_time"
                }
                else if mainDataTitle.lowercased().contains("discount") {
                    key_Name = "discount"
                }
                let F_valueeee = self.dic_FilterSelection[key_Name] as? String ?? ""
                if F_valueeee == str_Value {
                    self.dic_FilterSelection[key_Name] = ""
                }
                else {
                    self.dic_FilterSelection[key_Name] = str_Value
                }
            }
            
            
            
            /*switch sub_data.type {
            case .fBrand:
                guard let data_ = arr_PopularBrand.first?.data[indexPath.row] else { break }
                if data_.isSelect{
                    arr_PopularBrand.first?.data[indexPath.row].isSelect = false
                }else{
                    arr_PopularBrand.first?.data[indexPath.row].isSelect = true
                }
      
            case .fCategory:
                guard let data_ = arr_Category.first?.data[indexPath.row] else { break }
                if data_.isSelect{
                    arr_Category.first?.data[indexPath.row].isSelect = false
                }else{
                    arr_Category.first?.data[indexPath.row].isSelect = true
                }
                
            case .fPriceRange:
                let title = sub_data.subData[indexPath.row] as? String ?? ""
                mpFilter_Selected_PriceRange = title == mpFilter_Selected_PriceRange ? "" : title
               
                /*
                if arrSelected_PriceRange.contains(title){
                    var index = 0
                    arrSelected_PriceRange.forEach { title_ in
                        if title_ == title{
                            arrSelected_PriceRange.remove(at: index)
                        }
                        index = index + 1
                    }
                }else{
                    arrSelected_PriceRange.append(title)
                }*/
                
            case .fDeliveryTime:
                let title = sub_data.subData[indexPath.row] as? String ?? ""
                mpFilter_Selected_DeliveryTime = title == mpFilter_Selected_DeliveryTime ? "" : title
                
            case .fDiscount:
                let title = sub_data.subData[indexPath.row] as? String ?? ""
                mpFilter_Selected_Discounts = title == mpFilter_Selected_Discounts ? "" : title
                
            default:
                break
            }*/
            
            self.tableView_Data.reloadData()
        }
    }
    
    
}


// MARK: - UITableView Cell
class filterTypeTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_selection: UIImageView!
    
}
