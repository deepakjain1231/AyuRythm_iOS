//
//  MyHomeDetailViewController.swift
//  HourOnEarth
//
//  Created by Apple on 18/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

enum DetailRowType {
    case detailRow(title: String, imageName: String, vikriti: Double?, prakriti: Double?, description: String)
    case completeRow(title: String, btnTitle: String, isPrashna: Bool)
}

class MyHomeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CompletePrashnaSparshna, HomeInfoDelegate {
    
    var str_Kpv = ""
    var str_Header = ""
    var str_KpvPrensentage = ""
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tblHomeDetail: UITableView!
    @IBOutlet weak var lblHeader: UILabel!

    var arrData: [DetailRowType] = [DetailRowType]()
    //var increasedValues = [KPVType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_title.text = "Your Wellness Index".localized()
        if kSharedAppDelegate.userId.isEmpty {
            self.navigationItem.rightBarButtonItem = nil
        }
        self.prepareData()
        self.tblHomeDetail.rowHeight = UITableView.automaticDimension
        self.tblHomeDetail.estimatedRowHeight = 190.0
        tblHomeDetail.register(nibWithCellClass: HomeDetailCell.self)
        tblHomeDetail.register(nibWithCellClass: CompletePrakritiVikritCell.self)
        
        if #available(iOS 15.0, *) {
            self.tblHomeDetail.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        self.populateHeader()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = arrData[indexPath.row]
        switch rowType {
        case .detailRow(let title, let imageName, let vikriti, let prakriti, let desc):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDetailCell") as? HomeDetailCell else {
                return UITableViewCell()
            }
            cell.configure(heading: title, image: imageName,  ideal: prakriti, current:vikriti , description: desc)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        case .completeRow(let title, let btnTitle, let isPrashna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompletePrakritiVikritCell") as? CompletePrakritiVikritCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configure(title: title, btnTitle: btnTitle, isPrashna: isPrashna)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func completePrakritiOrVikritClicked(isPrakriti: Bool) {
        if isPrakriti {
            let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
            let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiViewController") as! PrakritiViewController
            self.navigationController?.pushViewController(objDescription, animated: true)
        } else {
            let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
            let objDescription = storyBoard.instantiateViewController(withIdentifier: "KPVDescriptionViewController") as! KPVDescriptionViewController
            self.navigationController?.pushViewController(objDescription, animated: true)
        }
    }
    
    func prepareData() {
        
        let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
        let isPrashnaTestGiven = kUserDefaults.bool(forKey: kVikritiPrashnaCompleted)
        
        if !isPrashnaTestGiven {
            arrData.append(.completeRow(title: "Please complete Vikriti Prashna also to help us assess your current state better".localized(), btnTitle: "Complete Now".localized(), isPrashna: true))
        }
        
        if !isSparshnaTestGiven {
            arrData.append(.completeRow(title: "Please complete Vikriti Sparshna also to help us give you better recommendations".localized(), btnTitle: "Complete Now".localized(), isPrashna: false))
        }
        
        var kaphaP: Double? = nil
        var pittaP: Double? = nil
        var vataP: Double? = nil
        if let strPrakriti = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrakriti.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            setUIForComplete()
        }
        
        var kaphaV: Double? = nil
        var pittaV: Double? = nil
        var vataV: Double? = nil
        
        if let str_cloud_vikriti = UserDefaults.user.get_user_info_result_data["vikriti"] as? String {
            var str_v_presentage = str_cloud_vikriti.replacingOccurrences(of: "[", with: "")
            str_v_presentage = str_v_presentage.replacingOccurrences(of: "]", with: "")
            str_v_presentage = str_v_presentage.replacingOccurrences(of: ",", with: "")
            let arr_v = str_v_presentage.components(separatedBy: " ")
            if arr_v.count == 3 {
                kaphaV = Double(arr_v[0].trimed()) ?? 0
                pittaV = Double(arr_v[1].trimed()) ?? 0
                vataV = Double(arr_v[2].trimed()) ?? 0
            }
        }
        else {
            setUIForComplete()
        }
        
//        if let strVikriti = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
//            let arrVikritiScore = strVikriti.components(separatedBy: ",")
//            if arrVikritiScore.count == 3 {
//                kaphaV = Double(arrVikritiScore[0]) ?? 0
//                pittaV = Double(arrVikritiScore[1]) ?? 0
//                vataV = Double(arrVikritiScore[2]) ?? 0
//            }
//        } else {
//            setUIForComplete()
//        }
        
        arrData.append(.detailRow(title: KPVStringType.KAPHA.rawValue, imageName: "KaphaDetail", vikriti: kaphaV, prakriti: kaphaP, description: "Balanced Kapha means good energy, strength and stamina.".localized()))
        arrData.append(.detailRow(title: KPVStringType.PITTA.rawValue, imageName: "PittaDetail", vikriti: pittaV, prakriti: pittaP, description: "Balanced Pitta means good appetite, digestion and absorption.".localized()))
        arrData.append(.detailRow(title: KPVStringType.VATA.rawValue, imageName: "VataDetail", vikriti: vataV, prakriti: vataP, description: "Balanced Vata means enthusiastic, calm, happy and imaginative.".localized()))
    }
    
    func populateHeader() {
        
        setupAttributedText(str_FullText: self.str_Header,
                            fullTextFont: UIFont.AppFontSemiBold(16),
                            fullTextColor: UIColor.fromHex(hexString: "#777777"),
                            highlightText1: self.str_Kpv,
                            highlightText1Font: UIFont.AppFontSemiBold(16),
                            highlightText1Color: UIColor.fromHex(hexString: "#2F2E2E"),
                            highlightText2: self.str_KpvPrensentage,
                            highlightText2Font: UIFont.AppFontSemiBold(16),
                            highlightText2Color: UIColor.fromHex(hexString: "#2F2E2E"),
                            lbl_attribute: self.lblHeader)
    }
    
    func setUIForComplete() {
        self.tblHomeDetail.tableHeaderView = UIView()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func retestClicked(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "MyHome", bundle: nil)
        let retestController = storyboard.instantiateViewController(withIdentifier:"RetestViewController" ) as! RetestViewController
        self.navigationController?.pushViewController(retestController, animated: true)
    }
    
    func infoClickedFor(type: KPVType) {
        let storyboard = UIStoryboard(name: "MoreKpv", bundle: nil)
        let moreController = storyboard.instantiateViewController(withIdentifier:"MoreKpvViewController" ) as! MoreKpvViewController
        moreController.kpvType = type
        self.navigationController?.pushViewController(moreController, animated: true)
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyHomeDetailViewController {
    
    func completePrashnaOrSparshnaClicked(isPrashna: Bool) {
        if isPrashna {
            showPrashna()
        } else {
            showSparshna()
        }
    }
    
    func showSparshna() {
        if kUserDefaults.bool(forKey: kDoNotShowTestInfo) {
            let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
            self.navigationController?.pushViewController(objSlideView, animated: true)
            
            /*
            let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
            let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
            objAlert.modalPresentationStyle = .overCurrentContext
            objAlert.completionHandler = {
                let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
                self.navigationController?.pushViewController(objSlideView, animated: true)
            }
            self.present(objAlert, animated: true)
            */
        } else {
            let storyBoard = UIStoryboard(name: "SparshnaTestInfo", bundle: nil)
            let objSlideView: SparshnaTestInfoViewController = storyBoard.instantiateViewController(withIdentifier: "SparshnaTestInfoViewController") as! SparshnaTestInfoViewController
            self.navigationController?.pushViewController(objSlideView, animated: true)

        }
    }
    
    func showPrashna() {
        Vikrati30QuestionnaireVC.showScreen(fromVC: self)
        //VikritiQuestionsVC.showScreen(fromVC: self)
    }
}
