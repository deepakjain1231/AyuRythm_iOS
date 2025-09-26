//
//  ReportPostDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 23/09/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

protocol delegate_repot {
    func report_message_selected(_ success: Bool, reportmsg: String, currentType: String, selectedFeed: Feed?)
}

class ReportPostDialouge: UIViewController {

    var strSelection = ""
    var is_ForPost_User = ""
    var delegate: delegate_repot?
    var currentFeedSelection: Feed?
    var arr_ReportData = [ReportData]()
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btn_Report: UIButton!
    @IBOutlet weak var btn_Cancel: UIButton!
    @IBOutlet weak var constraint_tblView_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_viewMain_Bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tblView.register(nibWithCellClass: ReportPostTableCell.self)
        self.setupData()
        self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.2)
    }
    
    func setupData() {
        self.tblView.reloadData()
        self.btn_Report.setTitle("Report".localized().uppercased(), for: .normal)
        self.btn_Cancel.setTitle("Cancel".localized().uppercased(), for: .normal)
        
        
        self.lbl_Title.text = self.is_ForPost_User == "post" ? "Report Post".localized() : "Report User".localized()
        let bottomSafeArea = (kSharedAppDelegate.window?.safeAreaInsets.bottom ?? 0) + 20
        self.constraint_viewMain_Bottom.constant = bottomSafeArea
        self.view_Main.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
        let safeArearHeight = kSharedAppDelegate.window?.safeAreaInsets.top ?? 0 + (kSharedAppDelegate.window?.safeAreaInsets.bottom ?? 0)
        let getScreenHeight = UIScreen.main.bounds.height - safeArearHeight - 175
        let TotalHeight: CGFloat = CGFloat(self.arr_ReportData.count * 36)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if getScreenHeight < TotalHeight {
                self.constraint_tblView_Height.constant = getScreenHeight
            }
            else {
                self.constraint_tblView_Height.constant = self.tblView.contentSize.height
            }
        }
        self.view.layoutIfNeeded()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_Bottom.constant = 0
            self.view_Main.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.view_Main.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
        }
    }
    
    
    func clkToClose(_ is_Action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if is_Action {
                self.delegate?.report_message_selected(true, reportmsg: self.strSelection, currentType: self.is_ForPost_User, selectedFeed: self.currentFeedSelection)
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
    @IBAction func btn_Report_Action(_ sender: UIButton) {
        if self.strSelection != "" {
            self.clkToClose(true)
        }
    }
    
    @IBAction func btn_Cancel_Action(_ sender: UIButton) {
        self.clkToClose(false)
    }
}


//MARK: - UITableview Delegate DataSource Method
extension ReportPostDialouge: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_ReportData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ReportPostTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lbl_Title.text = self.arr_ReportData[indexPath.row].message ?? ""
        
        if self.strSelection == self.arr_ReportData[indexPath.row].message ?? "" {
            cell.lbl_Title.textColor = .black
            cell.img_Selection.image = UIImage.init(named: "icon_radio_button_checked")
        }
        else {
            cell.img_Selection.image = UIImage.init(named: "icon_radio_button_unchecked")
            cell.lbl_Title.textColor = UIColor.init(named: "mp-text-light-gray") ?? .darkGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.strSelection = self.arr_ReportData[indexPath.row].message ?? ""
        self.btn_Report.isUserInteractionEnabled = true
        self.btn_Report.setTitleColor(kAppBlueColor, for: .normal)
        self.tblView.reloadData()
    }
}



//MARK: - API Call
extension ReportPostDialouge {
    
    func callAPIforGetReportMessage(){
        
        //"msg_type" 1 for Post, 2 for User
        let str_msg_type = self.is_ForPost_User == "post" ? "1" : "2"
        
        let param = ["language_id": Utils.getLanguageId(),
                     "msg_type": str_msg_type] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .getreportMessage, parameters: param,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let reportData = try? JSONDecoder().decode(ReportMessage.self, from: responseJSON.rawData())
                if (reportData?.status ?? "") == "success"{
                    if let arrTemp = reportData?.data {
                        self?.arr_ReportData = arrTemp
                    }
                    self?.setupData()
                }
            }
        }
    }
}
