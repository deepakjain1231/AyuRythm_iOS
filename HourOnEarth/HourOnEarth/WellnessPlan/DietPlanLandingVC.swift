//
//  DietPlanLandingVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 23/02/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class DietPlanLandingVC: UIViewController {

    var arr_Info: [JSON]?
    var arr_Benefits: [JSON]?
    var arr_section = [[String: Any]]()
    @IBOutlet weak var img_Banner: UIImageView!
    @IBOutlet weak var view_BannerBottomBG: UIView!
    @IBOutlet weak var view_BottomPriceBG: UIView!
    @IBOutlet weak var view_BottomPrimeBG: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_banner_Title: UILabel!
    @IBOutlet weak var view_tblBG: UIView!
    @IBOutlet weak var lbl_bottomPrice: UILabel!
    @IBOutlet weak var img_tblBG: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_BannerBottomBG.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        //self.view_BottomPrimeBG.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        
//        let BGColors1 = [UIColor.fromHex(hexString: "#F3FFF9"), UIColor.fromHex(hexString: "#E0FFEF")]
//        if let gradientColor = CAGradientLayer.init(frame: self.view_tblBG.frame, colors: BGColors1, direction: GradientDirection.Bottom).creatGradientImage() {
//            self.view_tblBG.backgroundColor = UIColor.init(patternImage: gradientColor)
//        }
        self.img_tblBG.image = UIImage.init(named: "icon_tbl_BG")
        
        //Register Table Cell
        self.tblView.register(nibWithCellClass: DietInfoTableCell.self)
        self.tblView.register(nibWithCellClass: DietBenifitTableCell.self)
        //***********************************//
        
        self.callAPIforGetInfoPints()
    }
    

    func callAPIforGetInfoPints() {
        let params = ["device_id": "ios",
                      "language_id" : Utils.getLanguageId(),
                      "currency": Locale.current.paramCurrencyCode] as [String : Any]
        self.showActivityIndicator()
        Utils.doAPICall(endPoint: .getDietInfo, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if let response_JSON = responseJSON {
                let str_status = response_JSON["status"].stringValue.lowercased()
                if str_status == "sucess" || str_status == "success" {
                    
                    if let dic_Data = response_JSON["data"].dictionary {
                        if let dic_banner = dic_Data["banner"]?.dictionary {
                            self?.lbl_banner_Title.text = dic_banner["title"]?.string ?? ""
                            let img_banner = dic_banner["image"]?.string ?? ""
                            self?.img_Banner.sd_setImage(with: URL.init(string: img_banner), placeholderImage: UIImage.init(named: "icon_diet_banner"), options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
                            
                            self?.view_BannerBottomBG.roundCorners(corners: [.topLeft, .topRight], radius: 12)
                        }
                        
                        if let arrInfo = dic_Data["info"]?.array {
                            self?.arr_Info = arrInfo
                        }
                        
                        if let arrbenifit = dic_Data["benefits"]?.array {
                            self?.arr_Benefits = arrbenifit
                        }
                        
                        if let dic_planPack = dic_Data["plan_pack"]?.dictionary {
                            let int_plan_price = Double(dic_planPack["amount"]?.string ?? "") ?? 0.0
                            let int_plan_month = Double(dic_planPack["pack_months"]?.string ?? "") ?? 0.0
                            let int_total = int_plan_price / int_plan_month
                            self?.lbl_bottomPrice.text = String(format: "₹%.2f/month", int_total)
                        }
                        
                    }
                    
                    self?.hideActivityIndicator()
                    self?.manageSection()
                }
                else {
                    self?.hideActivityIndicator(withMessage: message)
                }
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
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
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btn_Prime_Action(_ sender: UIControl) {
        let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Plan_Action(_ sender: UIControl) {
        let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
        obj.str_screenFrom = .from_dietplan
        self.navigationController?.pushViewController(obj, animated: true)
    }
}

// MARK: - UITableView Delegate DataSource Method
extension DietPlanLandingVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_section.removeAll()
        
        if let arrinfo = self.arr_Info {
            for dic_info in arrinfo {
                self.arr_section.append(["identifier": "table_cell", "value": dic_info])
            }
        }
        
        if let arrbenifit = self.arr_Benefits {
            if arrbenifit.count != 0 {
                self.arr_section.append(["identifier": "collection_cell", "value": arrbenifit])
            }
        }
        
        self.tblView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 122
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let str_identifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        if str_identifier == "table_cell" {
            
            let cell = tableView.dequeueReusableCell(withClass: DietInfoTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            if let dic_detail = self.arr_section[indexPath.row]["value"] as? JSON {
                cell.lbl_Title.text = dic_detail["title"].string ?? ""
                cell.lbl_subTitle.text = dic_detail["description"].string ?? ""
                
                let img_banner = dic_detail["image"].string ?? ""
                cell.img_icon.sd_setImage(with: URL.init(string: img_banner), placeholderImage: nil, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withClass: DietBenifitTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.arrBenifits = self.arr_Benefits
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


extension DietPlanLandingVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = DietPlanLandingVC.instantiate(fromAppStoryboard: .WellnessPlan)
        vc.hidesBottomBarWhenPushed = true
        fromVC.navigationController?.isNavigationBarHidden = true
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}

