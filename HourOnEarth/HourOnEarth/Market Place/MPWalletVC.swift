//
//  MPWalletVC.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 27/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPWalletVC: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var btnReceived: UIButton!
    @IBOutlet weak var btnPaid: UIButton!
    @IBOutlet weak var btnSeeAll: UIButton!
    @IBOutlet var headerView: UIView!
    
    
    @IBOutlet var lbl_walletBal: UILabel!
    @IBOutlet var lbl_cashBackText: UILabel!
    @IBOutlet var lbl_referText: UILabel!
    @IBOutlet var btnReferNow: UIButton!
    @IBOutlet var lbl_walletBal_Title: UILabel!
    
    
    
    
    //MARK: - Veriable
    var selectTabIndex = 2
    var walletList: MPWalletModel?
    var arrWalletHistoryData: [MPAll_WalletData] = []
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        manageTab()
        self.title = "My Wallet"
        tblList.tableHeaderView = headerView
        self.callAPIforWallet()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem?.title = ""
    }
    func registerCell(){
        tblList.register(UINib(nibName: "MPMyWalletCell", bundle: nil), forCellReuseIdentifier: "MPMyWalletCell")
    }
    
    func setupData() {
        self.lbl_referText.text = self.walletList?.singleData?.referal
        self.lbl_cashBackText.text = self.walletList?.singleData?.cashback_guarantee
        self.lbl_walletBal.text = self.settwo_desimalValue(self.walletList?.singleData?.wallet_balance)
        self.arrWalletHistoryData = self.walletList?.singleData?.All ?? []
        self.tblList.reloadData()
    }
    
    func settwo_desimalValue(_ value: NSNumber?) -> String {
        return String(format: "₹ %.2f", value?.doubleValue ?? 0.0)
    }
    
    func manageTab(){
        btnReceived.backgroundColor = .white
        btnReceived.setTitleColor(.gray, for: .normal)
        btnPaid.backgroundColor = .white
        btnPaid.setTitleColor(.gray, for: .normal)
        btnSeeAll.backgroundColor = .white
        btnSeeAll.setTitleColor(.gray, for: .normal)
        
        if selectTabIndex == 0{
            //--Received
            btnReceived.backgroundColor = .black
            btnReceived.setTitleColor(.white, for: .normal)
        }else if selectTabIndex == 1{
            //--Paid
            btnPaid.backgroundColor = .black
            btnPaid.setTitleColor(.white, for: .normal)
        }else if selectTabIndex == 2{
            //--See All
            btnSeeAll.backgroundColor = .black
            btnSeeAll.setTitleColor(.white, for: .normal)
        }
        tblList.reloadData()
    }
    
    //MARK: - @IBAction
    @IBAction func btnReceived(_ sender: UIButton) {
        selectTabIndex = 0
        manageTab()
        self.arrWalletHistoryData = self.walletList?.singleData?.Received ?? []
        self.tblList.reloadData()
    }
    @IBAction func btnPaid(_ sender: Any) {
        selectTabIndex = 1
        manageTab()
        self.arrWalletHistoryData = self.walletList?.singleData?.Paid ?? []
        self.tblList.reloadData()
    }
    @IBAction func btnSeeAll(_ sender: Any) {
        selectTabIndex = 2
        manageTab()
        self.arrWalletHistoryData = self.walletList?.singleData?.All ?? []
        self.tblList.reloadData()
    }
    
    
    @IBAction func btn_ReferNow_Action(_ sender: UIButton) {
        let strShareText = self.walletList?.singleData?.referal
        let shareAll = [ strShareText ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension MPWalletVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrWalletHistoryData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MPMyWalletCell", for: indexPath) as! MPMyWalletCell
        cell.selectionStyle = .none
        
        let strNarration = self.arrWalletHistoryData[indexPath.row].narration
        if strNarration.lowercased() == "paid" {
            cell.lblAmount.textColor = .red
            cell.lblAmount.text = "-₹ \(self.arrWalletHistoryData[indexPath.row].amount)"
        }
        else {
            cell.lblAmount.textColor = kAppColorWalletGreen
            cell.lblAmount.text = "+₹ \(self.arrWalletHistoryData[indexPath.row].amount)"
        }
        cell.lbl_Title.text = "Amount \(strNarration)"
        
        cell.lblSubTitle.text = self.arrWalletHistoryData[indexPath.row].transaction_title
        
        let str_date_exp = self.arrWalletHistoryData[indexPath.row].expiring_on
        let dateformatt = DateFormatter()
        dateformatt.dateFormat = "yyyy-MM-dd"
        if let dateee = dateformatt.date(from: str_date_exp) {
            let getDateSuffix = self.daySuffix(from: dateee)
            dateformatt.dateFormat = "dd"
            var str_expDate = dateformatt.string(from: dateee)
            str_expDate = str_expDate + getDateSuffix
            dateformatt.dateFormat = "MMM yyyy"
            str_expDate = "\(str_expDate) \(dateformatt.string(from: dateee))"
            cell.lblExpDate.text = "Expiring on \(str_expDate)"
        }
        else {
            cell.lblExpDate.text = "Expiring on \(str_date_exp)"
        }
        
        let str_crt_date = self.arrWalletHistoryData[indexPath.row].created_at
        dateformatt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let dateee = dateformatt.date(from: str_crt_date) {
            let getDateSuffix = self.daySuffix(from: dateee)
            dateformatt.dateFormat = "dd"
            var str_expDate = dateformatt.string(from: dateee)
            str_expDate = str_expDate + getDateSuffix
            dateformatt.dateFormat = "MMM, yyyy"
            str_expDate = "\(str_expDate) \(dateformatt.string(from: dateee))"
            cell.lbl_TitleDate.text = "\(str_expDate)".uppercased()
        }
        else {
            cell.lbl_TitleDate.text = "\(str_crt_date)".uppercased()
        }
        
        
        
        /*
        let dicData = arrList.object(at: indexPath.row) as! NSDictionary
        cell.lblName.text = dicData.object(forKey: "name") as? String ?? ""
        
        let imgURL = "\(kImageBaseURL)\(dicData.object(forKey: "avata") as? String ?? "")"
        ImageLoader().imageLoad(imgView: cell.imgUser, url: imgURL)
        
        if selectTabIndex == 1{
            cell.lblExpDate.text = ""
        }else{
            cell.lblExpDate.text = "Expiring on 20TH, Oct, 2021"
        }*/
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

    }
    
    
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}


//MARK: - Websrvice Call
extension MPWalletVC {
    
    func callAPIforWallet() {

        showActivityIndicator()
        let nameAPI: endPoint = .mp_my_wallet
        let param = ["filter_type": "All Orders"]
            
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
                if isSuccess {
                    self.walletList = MPWalletModel(JSON: responseJSON?.rawValue as! [String : Any])!
                    print("response")
                    self.setupData()
                }else if status == "Token is Expired"{
                    callAPIfor_LOGIN()
                } else {
                    self.showAlert(title: status, message: message)
                }
            }
        
    }
}
