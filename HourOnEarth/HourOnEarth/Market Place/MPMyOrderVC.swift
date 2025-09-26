//
//  MPMyOrderVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
//import MoEngage
import AlamofireImage

class MPMyOrderVC: UIViewController, filter_delegate {

    var filter_Type = "All Orders"
//    var arr_All_OrderData = [MPOrderProductData]()
    var arr_OrderData = [MPMyOrderProductModel]()
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var btn_ShpNow: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "My Orders"
        self.btn_ShpNow.isHidden = true
        self.view_NoData.isHidden = true
        self.tbl_View.register(nibWithCellClass: MPMyOrderTableCell.self)
        self.callAPIforGetMyOrderList(true)
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

    // MARK: - UIButton Action
    @IBAction func btn_ShopNow_Action(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            UIApplication.topViewController?.tabBarController?.selectedIndex = 2
        }
    }
    
    @IBAction func btn_Filter_Action(_ sender: UIButton) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = SortDialougeVC(nibName: "SortDialougeVC", bundle: nil)
            objDialouge.selectedSortBy = filter_Type
            objDialouge.screen_From = .MP_MyOrderList
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)

            objDialouge.didTappedSelectSort = { [self] (title) in
                self.filter_Type = title
                self.callAPIforGetMyOrderList(true)
            }
        }
        
        
        
        
//        if let parent = kSharedAppDelegate.window?.rootViewController {
//            let objDialouge = MyOrderFilterDialouge(nibName: "MyOrderFilterDialouge", bundle: nil)
//            objDialouge.delegate = self
//            objDialouge.filter_Type = self.filter_Type
//            parent.addChild(objDialouge)
//            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            parent.view.addSubview((objDialouge.view)!)
//            parent.view.bringSubviewToFront(objDialouge.view)
//            objDialouge.didMove(toParent: parent)
//        }
    }
    
    func didTappedOnFilterSelectionType(_ success: Bool, type: String) {
        self.filter_Type = type
        self.callAPIforGetMyOrderList(true)
    }
}

//MARK: - UITABLEVIEW DELEGATE DATASOURCE METHOD

extension MPMyOrderVC: UITableViewDelegate, UITableViewDataSource, delegateScreenRefresh {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.arr_OrderData.count != 0 {
            return self.arr_OrderData.first?.data.count ?? 0
        }
        return self.arr_OrderData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_OrderData.first?.data[section].products.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view_Header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            view_Header.backgroundColor = .white
            
            let lbl_HeaderTitle = UILabel.init(frame: CGRect.init(x: 20, y: 18, width: UIScreen.main.bounds.width, height: 24))
            lbl_HeaderTitle.text = self.filter_Type
            view_Header.addSubview(lbl_HeaderTitle)
            let lbl_HeaderSeprater = UILabel.init(frame: CGRect.init(x: 0, y: 59, width: UIScreen.main.bounds.width, height: 1))
            lbl_HeaderSeprater.backgroundColor = UIColor.fromHex(hexString: "#E5E5E5")
            view_Header.addSubview(lbl_HeaderSeprater)
            
            return view_Header
        }
        else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 60 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: MPMyOrderTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.img_Product.image = UIImage.init(named: "default_image")
        let mainSection = self.arr_OrderData.first?.data[indexPath.section]
        let dic_Detail = mainSection?.products[indexPath.row]
        
        if (mainSection?.products.count ?? 0) > 1 {
            cell.view_Base.layer.borderWidth = 1
            //cell.constraint_view_Base_Top.constant = indexPath.row item_price== 0 ? 8 : 0
            //cell.constraint_view_Base_Bottom.constant = indexPath.row == 0 ? 0 : 8
            cell.view_Base.layer.borderColor = UIColor.fromHex(hexString: "#E5E5E5").cgColor
            if indexPath.row == 0 {
                cell.constraint_view_Base_Top.constant = 8
                cell.constraint_view_Base_Bottom.constant = 0
                cell.view_UnderlineTop1_withBorder.isHidden = true
                cell.view_UnderlineTop1_withoutBorder.isHidden = true
                cell.view_UnderlineBottom1_withBorder.isHidden = false
                cell.view_UnderlineBottom1_withoutBorder.isHidden = false
            }
            else if (indexPath.row + 1) == (mainSection?.products.count ?? 0) {
                cell.constraint_view_Base_Top.constant = 0
                cell.constraint_view_Base_Bottom.constant = 8
                cell.view_UnderlineTop1_withBorder.isHidden = false
                cell.view_UnderlineTop1_withoutBorder.isHidden = false
                cell.view_UnderlineBottom1_withBorder.isHidden = true
                cell.view_UnderlineBottom1_withoutBorder.isHidden = true
            }
            else {
                cell.constraint_view_Base_Top.constant = 0
                cell.constraint_view_Base_Bottom.constant = 0
                cell.view_UnderlineTop1_withBorder.isHidden = false
                cell.view_UnderlineTop1_withoutBorder.isHidden = false
                cell.view_UnderlineBottom1_withBorder.isHidden = false
                cell.view_UnderlineBottom1_withoutBorder.isHidden = false
            }
        }
        else {
            cell.view_UnderlineTop1_withBorder.isHidden = true
            cell.view_UnderlineTop1_withoutBorder.isHidden = true
            cell.view_UnderlineBottom1_withBorder.isHidden = true
            cell.view_UnderlineBottom1_withoutBorder.isHidden = true
            
            cell.view_Base.layer.borderWidth = 1
            cell.constraint_view_Base_Top.constant = 8
            cell.constraint_view_Base_Bottom.constant = 8
            cell.view_Base.layer.borderColor = UIColor.fromHex(hexString: "#E5E5E5").cgColor
        }

        let productRating = dic_Detail?.rating
        let stt_productID = "\(dic_Detail?.id ?? 0)"
        let stt_ProductStatus = dic_Detail?.status
        let stt_ratingggg = dic_Detail?.rating_given_or_not
        let stt_reviewwww = dic_Detail?.review_given_or_not
        
        if stt_ProductStatus == "" || stt_ProductStatus?.lowercased() == "pending" || stt_ProductStatus?.lowercased() == "processing" || stt_ProductStatus?.lowercased() == "shipped" || stt_ProductStatus == "assigned" || stt_ProductStatus == "confirmed" {
            cell.view_rating.isHidden = true
            cell.lbl_deliveryStatus.text = "Pending"
            cell.constraint_view_Rating_Height.constant = 0
            cell.icon_deliveryStatus.image = UIImage.init(named: "icon_shipped")
        }
        else if stt_ProductStatus == "Delivered" || stt_ProductStatus == "On delivery" || stt_ProductStatus == "Return Requested"  {
            cell.view_rating.isHidden = false
            cell.lbl_deliveryStatus.text = stt_ProductStatus
            cell.constraint_view_Rating_Height.constant = 80
            cell.icon_deliveryStatus.image = UIImage.init(named: "icon_delivery")
            
            cell.product_rating.rating = Double(productRating ?? 0)
            if stt_ratingggg?.lowercased() == "no" {
                cell.lbl_writeReview.text = "Rate product"
                cell.product_rating.isUserInteractionEnabled = true
            }
            else {
                cell.product_rating.isUserInteractionEnabled = false
                if stt_reviewwww?.lowercased() == "no" {
                    cell.lbl_writeReview.text = "Write review"
                }
                else {
                    cell.lbl_writeReview.text = ""
                    cell.constraint_view_Rating_Height.constant = 60
                }
            }
            
            
            //Button Click Event Action
            //Did Tapped on Submit
            cell.product_rating.didFinishTouchingCosmos = { (sender) in
                debugPrint("ratingggg====\(cell.product_rating.rating)")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.callAPIforSubmitRating(rating: Int(cell.product_rating.rating), product_id: stt_productID)
                }
            }
        }
        else {
            cell.view_rating.isHidden = true
            cell.lbl_deliveryStatus.text = stt_ProductStatus
            cell.constraint_view_Rating_Height.constant = 0
            cell.icon_deliveryStatus.image = UIImage.init(named: "icon_cancelled")
        }
        
        if let dic_getCreatedDate = mainSection?.created_at as? [String: Any] {
            let strcreatedate = dic_getCreatedDate["date"] as? String ?? ""
            let strCreatedDate = convertStringToDate(strDate: strcreatedate, fromFormat: MPDateFormat.dd_MM_yyyy_hh_mm_ss_AM_PM, toFormat: MPDateFormat.EEEE_ddMMMYYYY)
            cell.lbl_deliveryDate.text = "On \(strCreatedDate)"
        }

        let strImgPrroduct = dic_Detail?.feature_image ?? ""
        if strImgPrroduct != "" {
            if let url = URL(string: strImgPrroduct) {
                cell.img_Product.af_setImage(withURL: url, placeholderImage: UIImage.init(named: "default_image"))
            }
            else {
                cell.img_Product.image = UIImage.init(named: "default_image")
            }
        }
        else {
            cell.img_Product.image = UIImage.init(named: "default_image")
        }
        cell.lbl_ProductName.text = dic_Detail?.name
        cell.lbl_ProductSubtitle.text = dic_Detail?.size

        
        //Did Tapped on Review
        cell.didTappedReview = { (sender) in
            if cell.lbl_writeReview.text == "Write review" {
                let vc = MPMyOrderReviewVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.delegate = self
                vc.dic_ProductDetail = dic_Detail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainSection = self.arr_OrderData.first?.data[indexPath.section]
        let dic_Detail = mainSection?.products[indexPath.row]
        let vc = MPMyOrderDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.dic_OrderDetail = mainSection
        vc.str_ClickedProductID = "\(dic_Detail?.id ?? 0)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func screenRefresh(_ is_success: Bool) {
        if is_success {
            self.callAPIforGetMyOrderList(true)
        }
    }
}


//MARK: - API Call

extension MPMyOrderVC {
    
    func callAPIforGetMyOrderList(_ animate: Bool) {
        if animate {
            showActivityIndicator()
        }
        let nameAPI: endPoint = .mp_UserMyOrder
        let param = ["filter_type": self.filter_Type] as [String : Any]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_OrderData.removeAll()
                let mPProductModel = MPMyOrderProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count > 0{
                    self.arr_OrderData.append(mPProductModel)
                }
                self.btn_ShpNow.isHidden = self.arr_OrderData.count == 0 ? false : true
                self.view_NoData.isHidden = self.arr_OrderData.count == 0 ? false : true
                self.tbl_View.reloadData()
            }else if status == "Token is Expired" {
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }

    }
    
    
    func callAPIforSubmitRating(rating: Int, product_id: String) {
        showActivityIndicator()
        let nameAPI: endPoint = .mp_user_product_submitRating
        let param = ["product_id": product_id,
                     "rating": rating,
                     "review": ""] as [String : Any]

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                
                //Temo Comment//let dic: NSMutableDictionary = ["product_id": product_id]
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.RateProduct.rawValue, properties: MOProperties.init(attributes: dic))
                
                self.callAPIforGetMyOrderList(false)
            }else if status == "Token is Expired" {
                callAPIfor_LOGIN()
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }

    }
}
