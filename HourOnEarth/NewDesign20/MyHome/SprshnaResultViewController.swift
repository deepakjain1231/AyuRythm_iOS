////
////  SprshnaResultViewController.swift
////  HourOnEarth
////
////  Created by hardik mulani on 18/03/20.
////  Copyright © 2020 Pradeep. All rights reserved.
////
//
//import UIKit
//import Alamofire
//import FSCalendar
//
//class SprshnaResultViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
//
//    @IBOutlet weak var tblHomeDetail: UITableView!
//
//
////    var arrData: [MyProgress] = [MyProgress]()
//
//     var resultDic: [String: Any] = [String: Any]()
//     var arrKeys: [String] = [String]()
//    var detailDict:[String:String] = [String:String]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tblHomeDetail.rowHeight = UITableView.automaticDimension
//        self.tblHomeDetail.estimatedRowHeight = UITableView.automaticDimension
//        tblHomeDetail.register(UINib(nibName: "SparshnaResultCell", bundle: nil), forCellReuseIdentifier: "SparshnaResultCell")
//        arrKeys = ["Vega","Tala","Akruti(Volume)","Akruti(Tension)","Bala","Kathinya","Gati"];
//
//        detailDict = [
//
//            "Vega" :"How fast pulse beats measured as high/medium/low. Correlates to heart rate",
//
//            "Tala": "Rhythm or stability of pulse. Correlates to HRV",
//
//            "Akruti(Volume)":"Subjective pressure felt on physician's fingers when blood vessel is full. Classified as high/medium/low. Correlates to Systolic BP ",
//
//            "Akruti(Tension)" :"Subjective pressure felt on physician's fingers when blood vessel is empty. Classified as high/medium/low. Correlates to Diastolic BP",
//
//            "Bala":"Subjective pressure felt on physician's finger. Classified as weak/moderate/strong. Correlates to Pulse Pressure",
//
//            "Kathinya":"Subjective hardness of radial artery felt by physician. Classified as soft/moderately hard/hard/brittle. Correlates to stiffness index",
//
//            "Gati" :"Subjective feeling of how the pulse is moving. Classified as slow and shallow/smooth and moderate/fast and strong. Correlates to pulse morphology"]
//        self.resultDic = self.getLastAssessmentData()
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        self.tabBarController?.tabBar.isHidden = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
//        super.viewWillDisappear(true)
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return arrKeys.count
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SparshnaResultCell") as? SparshnaResultCell else {
//            return UITableViewCell()
//        }
//        let key = arrKeys[indexPath.row]
//         cell.lblTitle.text = key
//         let valueStr = self.resultDic[key] as? String ?? ""
//        // cell.lblRange.text = "Range: \(valueStr)"
//
//         let value = Int(valueStr) ?? 0
//         cell.lblTitle.text = key
//        cell.lblDetail.text = detailDict[key]
//         if key == "Vega" {
//             if (value <= 70) {
//                 cell.lblRange.text = "Value Range: Less then 70"
//                cell.lblType.text = "Kapha"
//                cell.imgBodyType.setImage(UIImage(named: "Kaphaa"), for: .normal)
//             } else if (value > 70 && value < 80) {
//                 cell.lblRange.text = "Value Range: 70-80"
//                 cell.lblType.text = "Pitta"
//
//                cell.imgBodyType.setImage(UIImage(named: "PittaN"), for: .normal)
//
//             } else {
//                 cell.lblRange.text = "Value Range: More than 80"
//                 cell.lblType.text = "Vata"
//                cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//             }
//         } else if key == "Akruti(Volume)" {
//            cell.lblTitle.text = "Akruti (Matra)"
//             if (value <= 90) {
//                 cell.lblRange.text = "Value Range: Less than 90"
//                 cell.lblType.text = "Vata"
//                cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//
//             } else if (value>90 && value<=120) {
//                 cell.lblRange.text = "Value Range: 90-120"
//                 cell.lblType.text = "Pitta"
//                cell.imgBodyType.setImage(UIImage(named: "PittaN"), for: .normal)
//
//             }
//             else if (value>120) {
//                 cell.lblRange.text = "Value Range: More than 120"
//                 cell.lblType.text = "Kapha"
//                cell.imgBodyType.setImage(UIImage(named: "Kaphaa"), for: .normal)
//
//             }
//         } else if key ==  "Akruti(Tension)" {
//             cell.lblTitle.text = "Akruti (Tanaav)"
//             if (value<=60) {
//                 cell.lblRange.text = "Value Range: Less than 60"
//                 cell.lblType.text = "Vata"
//                cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//
//             } else if (value>60 && value<=80) {
//                 cell.lblRange.text = "Value Range: 60-80"
//                 cell.lblType.text = "Pitta"
//                cell.imgBodyType.setImage(UIImage(named: "PittaN"), for: .normal)
//
//             }
//             else if (value>80) {
//                 cell.lblRange.text = "Value Range: More than 80"
//                 cell.lblType.text = "Kapha"
//                cell.imgBodyType.setImage(UIImage(named: "Kaphaa"), for: .normal)
//
//             }
//         } else if key ==  "Bala" {
//             if (value<=30) {
//                 cell.lblRange.text = "Value Range: Less than 30"
//                 cell.lblType.text = "Vata"
//                cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//
//             } else if (value>40) {
//                 cell.lblRange.text = "Value Range: More than 40"
//                 cell.lblType.text = "Pitta"
//                cell.imgBodyType.setImage(UIImage(named: "PittaN"), for: .normal)
//
//             } else if (value>30 && value<=40) {
//                 cell.lblRange.text = "Value Range: 30-40"
//                 cell.lblType.text = "Kapha"
//                cell.imgBodyType.setImage(UIImage(named: "Kaphaa"), for: .normal)
//
//             }
//         } else if key ==  "Kathinya" {
//             if (value>=310) {
//                 cell.lblRange.text = "Value Range: More than 310"
//                 cell.lblType.text = "Vata"
//                cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//
//             } else if (value<210) {
//                 cell.lblRange.text = "Value Range: Less than 210"
//                 cell.lblType.text = "Pitta"
//                cell.imgBodyType.setImage(UIImage(named: "PittaN"), for: .normal)
//
//             } else if (value>=210 && value<=310) {
//                 cell.lblRange.text = "Value Range: 210-310"
//                 cell.lblType.text = "Kapha"
//                cell.imgBodyType.setImage(UIImage(named: "Kaphaa"), for: .normal)
//
//             }
//         }else if key == "Tala"{
//            if resultDic["Tala"] as? String == "(Vata)Irregular"{
//                 cell.lblRange.text = "Value Range: Irregular"
//                cell.lblType.text = "Vata"
//                cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//
//            }else{
//                cell.lblRange.text = "Value Range: \(resultDic["Tala"] as? String ?? "")"
//                cell.lblType.text = ""
//                cell.imgBodyType.setImage(nil, for: .normal)
//            }
//         }else if key == "Gati" {
//            if let value = resultDic["Gati"] as? String{
//                cell.lblRange.text = "Value Range: \(value)"
//               cell.lblType.text = value
//                if value == "Kapha" {
//                    cell.imgBodyType.setImage(UIImage(named: "Kaphaa"), for: .normal)
//                } else if value == "Pitta" {
//                    cell.imgBodyType.setImage(UIImage(named: "PittaN"), for: .normal)
//                } else {
//                    cell.imgBodyType.setImage(UIImage(named: "VataN"), for: .normal)
//                }
//            }
//        }
//         cell.selectionStyle = .none
//         return cell
//
//
//
//    }
//
//
//    @IBAction func btnNextClicked(_ sender: Any) {
//        kSharedAppDelegate.showHomeScreen()
//    }
//
//}
//extension SprshnaResultViewController {
////    func getResultFromServer () {
////        if Utils.isConnectedToNetwork() {
////            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
////            let urlString = kBaseURL + "user_data_collection/docpatientjson.php"
////            let params = ["user_id": kSharedAppDelegate.userId]
////            Alamofire.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
////                DispatchQueue.main.async(execute: {
////                    Utils.stopActivityIndicatorinView(self.view)
////                })
////                switch response.result {
////
////                case .success:
////                    print(response)
////                    guard let arrResults = (response.result.value as? [[String: Any]]) else {
////                        return
////                    }
////                    for dic in arrResults {
////                        MyProgress.createMyProgressData(dicData: dic)
////                    }
////                    self.getMyProgresssDataFromDB()
////                case .failure(let error):
////                    print(error)
////                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
////                }
////            }
////        } else {
////            self.getMyProgresssDataFromDB()
////            //Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
////        }
////
////    }
////
////    func getMyProgresssDataFromDB() {
////        guard let arrProgressData = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyProgress", withPredicate: nil, sortKey: nil, isAscending: false) as? [MyProgress] else {
////            return
////        }
////        self.arrData = arrProgressData
////        let date  = Date()
////        self.resultDic = self.getSparshnaResult(selectedDate: date)
////        if self.resultDic.isEmpty {
////        } else {
////        }
////        self.tblHomeDetail.reloadData()
////    }
////
////    func getSparshnaResult(selectedDate: Date) -> [String: Any] {
////
////        let dateFormatter = DateFormatter()
////        let filteredData = arrData.filter { (dic) -> Bool in
////            dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss a"
////            guard let dateString = dic.date, !dateString.isEmpty else {
////                return false
////            }
////            guard let date = dateFormatter.date(from: dateString) else {
////                return false
////            }
////
////            dateFormatter.dateFormat = "dd-MM-yyyy"
////            let selectedDateStr = dateFormatter.string(from: selectedDate)
////
////            let strDate = dateFormatter.string(from: date)
////            guard let dateWithoutTime = dateFormatter.date(from: strDate) else {
////                return false
////            }
////            guard let selectedDateWithoutTime = dateFormatter.date(from: selectedDateStr) else {
////                return false
////            }
////            if selectedDateWithoutTime.compare(dateWithoutTime) == ComparisonResult.orderedSame {
////                return true
////            }
////            return false
////        }
////
////
////        let sortedData = filteredData.sorted { (progress1, progress2) -> Bool in
////
////            dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss a"
////            guard let dateString = progress1.date, !dateString.isEmpty else {
////                return false
////            }
////            guard let date1 = dateFormatter.date(from: dateString) else {
////                return false
////            }
////
////            guard let dateString2 = progress2.date, !dateString2.isEmpty else {
////                return false
////            }
////            guard let date2 = dateFormatter.date(from: dateString2) else {
////                return false
////            }
////
////            if date1.compare(date2) == ComparisonResult.orderedDescending {
////                return true
////            }
////            return false
////
////        }
////
////        guard let currentData = sortedData.first, let resultString = currentData.result, let dataStr = resultString.data(using: .utf8) else {
////            return [:]
////        }
////
////        do {
////            let jsonData = try JSONSerialization.jsonObject(with: dataStr, options: .allowFragments)
////            let resultDic = jsonData as! [String: Any]
////            print(resultDic)
////            return resultDic
////        } catch let error {
////            print(error)
////        }
////        return [:]
////    }
//
//    func getLastAssessmentData()  -> [String: Any]  {
//        guard let lastAssData = kUserDefaults.value(forKey: LAST_ASSESSMENT_DATA) as? String, !lastAssData.isEmpty else {
//            return [:]
//        }
//        let resultString = lastAssData
//        guard let dataStr = resultString.data(using: .utf8) else {
//            return [:]
//        }
//
//        do {
//            let jsonData = try JSONSerialization.jsonObject(with: dataStr, options: .allowFragments)
//            let resultDic = jsonData as! [String: Any]
//            print(resultDic)
//            return resultDic
//        } catch let error {
//            print(error)
//            return [:]
//        }
//    }
//}
