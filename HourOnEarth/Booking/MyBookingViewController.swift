//
//  MyBookingViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 16/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class MyBookingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lbl_noData: UILabel!
    @IBOutlet weak var img_noData: UIImageView!
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var tableView: UITableView!

    var dataArray = [Any]()
    var bookingArray = [String : Any]()
        
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_NoData.isHidden = true
        self.lbl_noData.text = "No Bookings found".localized()
        setupUI()
        fetchBookingDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Action Methods
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.img_noData.image = UIImage.init(named: "empty_upcoming_icon")
            self.dataArray = self.bookingArray["upcoming_booking"] as! [Any]
        } else {
            self.img_noData.image = UIImage.init(named: "empty_past_icon")
            self.dataArray = self.bookingArray["past_booking"] as! [Any]
        }
        self.view_NoData.isHidden = self.dataArray.count == 0 ? false : true
        tableView.reloadData()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        tableView.tableFooterView = UIView()
    }
    
    func fetchBookingDetails() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.getTrainingBooking.rawValue
        
        AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                //debugPrint(response)
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "Success" {
                    guard let dataResponse = (dicResponse["response"] as? [String : Any]) else {
                        return
                    }
                    self.bookingArray = dataResponse
                    self.dataArray = self.bookingArray["upcoming_booking"] as! [Any]
                    self.view_NoData.isHidden = self.dataArray.count == 0 ? false : true
                    self.tableView.reloadData()
                } else {
                    Utils.showAlertWithTitleInController("", message: (dicResponse["message"] as? String ?? "Failed to get my bookings.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
            }
        }
    }
    
    // MARK: - UITableViewDelegate and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell") as? MyBookingTableViewCell else {
            return UITableViewCell()
        }
        let booking = dataArray[indexPath.row] as! [String : Any]
        
        cell.packageNameLabel?.text = booking["package_name"] as? String
        cell.trainerNameLabel?.text = booking["trainer_name"] as? String
        cell.sessionDaysLabel?.text = booking["selected_days"] as? String
        
        if let startTime = booking["start_time"] as? String, let endTime = booking["end_time"] as? String {
            let start = startTime.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat)
            let end = endTime.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat)
            cell.sessionTimeLabel?.text = (start + "-" + (end))
        } else {
            cell.sessionTimeLabel?.text = ""
        }
        
        if let startDate = booking["start_date"] as? String, let endDate = booking["end_date"] as? String {
            let start = startDate.toDate("yyyy-MM-dd")?.toString(.custom("dd/MM/yyyy")) ?? ""
            let end = endDate.toDate("yyyy-MM-dd")?.toString(.custom("dd/MM/yyyy")) ?? ""
            cell.sessionDateLabel?.text = (start + " - " + (end))
        } else {
            cell.sessionDateLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
