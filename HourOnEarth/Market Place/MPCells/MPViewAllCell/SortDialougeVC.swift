//
//  SortDialougeVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 06/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class SortDialougeVC: UIViewController {

    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnSelectionType1: UIButton!
    @IBOutlet weak var btnSelectionType2: UIButton!
    @IBOutlet weak var btnSelectionType3: UIButton!
    @IBOutlet weak var btnSelectionType4: UIButton!
    @IBOutlet weak var btnSelectionType5: UIButton!
    @IBOutlet weak var constant_tblView_Height: NSLayoutConstraint!
    
    var screen_From = ScreenType.k_none
    var dataSource = [MPProductSortModel]()
    var didTappedSelectSort: ((String)->Void)? = nil
    var selectedSortBy = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_Main.layer.cornerRadius = 12
        self.view_Main.clipsToBounds = true
        self.lbl_Title.text = self.screen_From == .MP_MyOrderList ? "Filters" : "Sort By"

        self.tblView.register(nibWithCellClass: SortingTableCell.self)

        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        
        setSelectedOption()
        callapiforgetSortingOption()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        } completion: { success in
        }
    }
    
    @objc func close_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { success in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    func setSelectedOption(){
        btnSelectionType1.setImage(UIImage(named: "radio_btn"), for: .normal)
        btnSelectionType2.setImage(UIImage(named: "radio_btn"), for: .normal)
        btnSelectionType3.setImage(UIImage(named: "radio_btn"), for: .normal)
        btnSelectionType4.setImage(UIImage(named: "radio_btn"), for: .normal)
        btnSelectionType5.setImage(UIImage(named: "radio_btn"), for: .normal)
        
        if selectedSortBy == "Discount"{
            btnSelectionType1.setImage(UIImage(named: "icon_radio_button_checked"), for: .normal)
        }
        if selectedSortBy == "Price Low to High"{
            btnSelectionType2.setImage(UIImage(named: "icon_radio_button_checked"), for: .normal)
        }
        if selectedSortBy == "Price High to Low"{
            btnSelectionType3.setImage(UIImage(named: "icon_radio_button_checked"), for: .normal)
        }
        if selectedSortBy == "Latest Product"{
            btnSelectionType4.setImage(UIImage(named: "icon_radio_button_checked"), for: .normal)
        }
        if selectedSortBy == "Oldest Product"{
            btnSelectionType5.setImage(UIImage(named: "icon_radio_button_checked"), for: .normal)
        }
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        self.close_animation()
    }
    
    @IBAction func btn1(_ sender: UIButton) {
        if self.didTappedSelectSort != nil {
            self.didTappedSelectSort!("Discount")
        }

        self.close_animation()
    }
    @IBAction func btn2(_ sender: UIButton) {
        if self.didTappedSelectSort != nil {
            self.didTappedSelectSort!("Price Low to High")
        }

        self.close_animation()
    }
    @IBAction func btn3(_ sender: UIButton) {
        if self.didTappedSelectSort != nil {
            self.didTappedSelectSort!("Price High to Low")
        }

        self.close_animation()
    }
    @IBAction func btn4(_ sender: UIButton) {
        if self.didTappedSelectSort != nil {
            self.didTappedSelectSort!("Latest Product")
        }

        self.close_animation()
    }
    @IBAction func btn5(_ sender: UIButton) {
        if self.didTappedSelectSort != nil {
            self.didTappedSelectSort!("Oldest Product")
        }

        self.close_animation()
    }


}

//MARK: - UITableview Delegate Datasource Method
extension SortDialougeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.first?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource.first?.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: SortingTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lbl_Title.text = data?.title
        cell.lbl_Underline.isHidden = indexPath.row + 1 == self.dataSource.first?.data.count ? true : false
        
        let sort_title = data?.title
        if selectedSortBy == sort_title {
            cell.btnSelectionType.setImage(UIImage(named: "icon_radio_button_checked"), for: .normal)
        }
        else {
            cell.btnSelectionType.setImage(UIImage(named: "radio_btn"), for: .normal)
        }
        
        cell.didTappedSelectionType = { (sender) in
            self.selectedSortBy = sort_title ?? ""
            self.tblView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                if self.didTappedSelectSort != nil {
                    self.didTappedSelectSort!(self.selectedSortBy)
                }
                self.close_animation()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource.first?.data[indexPath.row]
        self.selectedSortBy = data?.title ?? ""
        self.tblView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            if self.didTappedSelectSort != nil {
                self.didTappedSelectSort!(self.selectedSortBy)
            }
            self.close_animation()
        }
    }
}

//MARK: - API Call
extension SortDialougeVC {
    
    func callapiforgetSortingOption() {
        self.showActivityIndicator()
        var nameAPI: endPoint = .mp_product_sort
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_sort
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        var param = ["sorting_for": "Products"]
        if self.screen_From == .MP_MyOrderList {
            param = ["sorting_for": "Orders"]
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.dataSource.removeAll()
                let mPSortModel = MPProductSortModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPSortModel.data.count != 0{
                    self.dataSource.append(mPSortModel)
                }
                self.constant_tblView_Height.constant = CGFloat((self.dataSource.first?.data.count ?? 0) * 55)
                self.tblView.reloadData()
                self.view.layoutIfNeeded()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}
