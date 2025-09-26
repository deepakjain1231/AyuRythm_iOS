//
//  PatientHistoryVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 22/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire



class PatientHistoryVC: BaseViewController {

    var arr_PatientHistoy: [PatientData] = []
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register Table Cell
        self.tblView.register(nibWithCellClass: PatientHistoryTableCell.self)
        
        self.callAPIforGetPatientHistory()
    }
    
    //MARK: - API Call
    func callAPIforGetPatientHistory() {

        if Utils.isConnectedToNetwork() {
            
            let strPatientID = UserDefaults.standard.object(forKey: kSanaayPatientID) as? String ?? ""

            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.patient_history.rawValue
            let params = ["patient_id": strPatientID, "language_id": Utils.getLanguageId()] as [String : Any]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    let status = dicResponse["status"] as? String
                    if status?.lowercased() == "success" {

                        let patienttt = try? JSONDecoder().decode(Patient_History.self, from: response.data!)
                        self.arr_PatientHistoy = patienttt?.data ?? []
                        
                        self.tblView.reloadData()
                        
                    } else {
                        Utils.showAlertWithTitleInController(status ?? APP_NAME, message: (dicResponse["message"] as? String ?? "Patient Id Not Match".localized()), controller: self)
                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
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

}

//MARK: - UITableView Delegate Datasource Method

extension PatientHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_PatientHistoy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientHistoryTableCell", for: indexPath) as! PatientHistoryTableCell
        cell.selectionStyle = .none
        
        cell.lbl_name.text = self.arr_PatientHistoy[indexPath.row].patient_name
        let str_vikriti = self.arr_PatientHistoy[indexPath.row].vikriti
        if str_vikriti.uppercased() == KPVType.KAPHA.rawValue {
            cell.lbl_TestnotDone.text = ""
            cell.view_aggrivationTypeBG.isHidden = false
            cell.lbl_aggrivationType.text = str_vikriti.capitalized
            cell.img_aggrivationType.image = UIImage.init(named: "Kaphaa")
            cell.view_aggrivationTypeBG.backgroundColor = UIColor.fromHex(hexString: "#E8FFB4")
        }
        else if str_vikriti.uppercased() == KPVType.PITTA.rawValue {
            cell.lbl_TestnotDone.text = ""
            cell.view_aggrivationTypeBG.isHidden = false
            cell.lbl_aggrivationType.text = str_vikriti.capitalized
            cell.img_aggrivationType.image = UIImage.init(named: "PittaN")
            cell.view_aggrivationTypeBG.backgroundColor = UIColor.fromHex(hexString: "#FFEEC3")
            
        }
        else if str_vikriti.uppercased() == KPVType.VATA.rawValue {
            cell.lbl_TestnotDone.text = ""
            cell.view_aggrivationTypeBG.isHidden = false
            cell.lbl_aggrivationType.text = str_vikriti.capitalized
            cell.img_aggrivationType.image = UIImage.init(named: "VataN")
            cell.view_aggrivationTypeBG.backgroundColor = UIColor.fromHex(hexString: "#D0DFFF")
        }
        else {
            cell.view_aggrivationTypeBG.isHidden = true
            cell.lbl_TestnotDone.text = "Test not done"
        }
        
        cell.lbl_LastVisited.text = "Visited at "
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
