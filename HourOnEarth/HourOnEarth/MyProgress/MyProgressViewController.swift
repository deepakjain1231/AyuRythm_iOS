////
////  MyProgressViewController.swift
////  HourOnEarth
////
////  Created by Pradeep on 1/18/19.
////  Copyright © 2019 Pradeep. All rights reserved.
////
//
//import UIKit
//import FSCalendar
//import Alamofire
//
//class MyProgressViewController: UIViewController, FSCalendarDelegate, UITableViewDataSource, UITableViewDelegate {
//    
//    @IBOutlet weak var imgProfile: UIImageView!
//    @IBOutlet weak var calender: FSCalendar!
//    @IBOutlet weak var tblViewResult: UITableView!
//    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var lblPlaceHolder: UILabel!
//    
//    var arrData: [MyProgress] = [MyProgress]()
//    
//    var resultDic: [String: Any] = [String: Any]()
//    var arrKeys: [String] = [String]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        calender.scope = .week
//        self.lblPlaceHolder.isHidden = true
//        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
//            return
//        }
//        lblName.text = empData["name"] as? String ?? ""
//        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
//        imgProfile.clipsToBounds = true
//        
//        arrKeys = ["Vega","Akruti(Volume)","Akruti(Tension)","Tala","Bala","Kathinya","Gati","Spo2","Respiratory Rate","BMI","BMR"];
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        getResultFromServer()
//        
//        if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
//            let urlRequest = URLRequest(url: url)
//            let imageDownloader = UIImageView.af_sharedImageDownloader
//            _ = imageDownloader.imageCache?.removeImage(for: urlRequest, withIdentifier: nil)
//            imageDownloader.session.session.configuration.urlCache!.removeCachedResponse(for: urlRequest)
//            self.imgProfile.af_setImage(withURL: url)
//        }
//        
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.resultDic.keys.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80.0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProgressCell") as? MyProgressCell else {
//            return UITableViewCell()
//        }
//        
//        let key = arrKeys[indexPath.row]
//        cell.lblTitle.text = key
//        let valueStr = self.resultDic[key] as? String ?? ""
//        cell.lblValue.text = valueStr
//       
//        let value = Int(valueStr) ?? 0
//        cell.lblSubTitle.text = ""
//
//        if key == "Vega" {
//            if (value <= 70) {
//                cell.lblSubTitle.text = "Kapha"
//            } else if (value > 70 && value < 80) {
//                cell.lblSubTitle.text = "Pitta"
//            } else {
//                cell.lblSubTitle.text = "Vatta"
//            }
//        } else if key == "Akruti(Volume)" {
//            if (value <= 90) {
//                cell.lblSubTitle.text = "Vatta"
//            } else if (value>90 && value<=140) {
//                cell.lblSubTitle.text = "Pitta"
//            }
//            else if (value > 140) {
//                cell.lblSubTitle.text = "Kapha"
//            }
//        } else if key ==  "Akruti(Tension)" {
//            if (value<=60) {
//                cell.lblSubTitle.text = "Vatta"
//            } else if (value>60 && value<=90) {
//                cell.lblSubTitle.text = "Pitta"
//            }
//            else if (value>90) {
//                cell.lblSubTitle.text = "Kapha"
//            }
//        } else if key ==  "Bala" {
//            if (value<=30) {
//                cell.lblSubTitle.text = "Vatta"
//            } else if (value>40) {
//                cell.lblSubTitle.text = "Pitta"
//            } else if (value>30 && value<=40) {
//                cell.lblSubTitle.text = "Kapha"
//            }
//        } else if key ==  "Kathinya" {
//            if (value>=310) {
//                cell.lblSubTitle.text = "Vatta"
//            } else if (value<210) {
//                cell.lblSubTitle.text = "Pitta"
//            } else if (value>=210 && value<310) {
//                cell.lblSubTitle.text = "Kapha"
//            }
//        }
//       
//        cell.selectionStyle = .none
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let key = arrKeys[indexPath.row]
//        guard key != "Tala" && key != "Gati" else {
//            return
//        }
//        let storyBoard = UIStoryboard(name: "MyProgress", bundle: nil)
//        let objGraph = storyBoard.instantiateViewController(withIdentifier: "MyProgressGraphViewController") as! MyProgressGraphViewController
//        objGraph.arrData = arrData
//        objGraph.graphValueType = GraphValueType(rawValue: key) ?? .vega
//        self.navigationController?.pushViewController(objGraph, animated: true)
//    }
//    
//    @IBAction func settingsClicked(_ sender: Any) {
//        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
//        let objGraph = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
//        self.navigationController?.pushViewController(objGraph, animated: true)
//    }
//    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        self.resultDic = self.getSparshnaResult(selectedDate: date)
//        if self.resultDic.isEmpty {
//            self.lblPlaceHolder.isHidden = false
//        } else {
//            self.lblPlaceHolder.isHidden = true
//        }
//        self.tblViewResult.reloadData()
//    }
//    
//    func getSparshnaResult(selectedDate: Date) -> [String: Any] {
//        
//        let dateFormatter = DateFormatter()
//        let filteredData = arrData.filter { (dic) -> Bool in
//            dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss a"
//            guard let dateString = dic.date, !dateString.isEmpty else {
//                return false
//            }
//            guard let date = dateFormatter.date(from: dateString) else {
//                return false
//            }
//            
//            dateFormatter.dateFormat = "dd-MM-yyyy"
//            let selectedDateStr = dateFormatter.string(from: selectedDate)
//            
//            let strDate = dateFormatter.string(from: date)
//            guard let dateWithoutTime = dateFormatter.date(from: strDate) else {
//                return false
//            }
//            guard let selectedDateWithoutTime = dateFormatter.date(from: selectedDateStr) else {
//                return false
//            }
//            if selectedDateWithoutTime.compare(dateWithoutTime) == ComparisonResult.orderedSame {
//                return true
//            }
//            return false
//        }
//        
//        
//        let sortedData = filteredData.sorted { (progress1, progress2) -> Bool in
//            
//            dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss a"
//            guard let dateString = progress1.date, !dateString.isEmpty else {
//                return false
//            }
//            f
//            
//            guard let dateString2 = progress2.date, !dateString2.isEmpty else {
//                return false
//            }
//            guard let date2 = dateFormatter.date(from: dateString2) else {
//                return false
//            }
//            
//            if date1.compare(date2) == ComparisonResult.orderedDescending {
//                return true
//            }
//            return false
//            
//        }
//        
//        guard let currentData = sortedData.first, let resultString = currentData.result, let dataStr = resultString.data(using: .utf8) else {
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
//        }
//        return [:]
//    }
//}
//
//extension MyProgressViewController {
//    func getResultFromServer () {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseURL + "user_data_collection/docpatientjson.php"
//            let params = ["user_id": kSharedAppDelegate.userId]
//            
//            
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//                switch response.result {
//                    
//                    // Dhiren change
//                case .success(let value):
//                    print(response)
//                    guard let arrResults = (value as? [[String: Any]]) else {
//                        return
//                    }
//                    
////                    guard let arrResults = (response.result as? [[String: Any]]) else {
////                        return
////                    }
//                    for dic in arrResults {
//                        MyProgress.createMyProgressData(dicData: dic)
//                    }
//                    self.getMyProgresssDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//            }
//        } else {
//            self.getMyProgresssDataFromDB()
//            //Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
//    
//    func getMyProgresssDataFromDB() {
//        guard let arrProgressData = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyProgress", withPredicate: nil, sortKey: nil, isAscending: false) as? [MyProgress] else {
//            return
//        }
//        self.arrData = arrProgressData
//        let selectedDate = self.calender.selectedDate ?? Date()
//        self.resultDic = self.getSparshnaResult(selectedDate: selectedDate)
//        if self.resultDic.isEmpty {
//            self.lblPlaceHolder.isHidden = false
//        } else {
//            self.lblPlaceHolder.isHidden = true
//        }
//        self.tblViewResult.reloadData()
//    }
//}
