//
//  BookNowViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 16/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

let MyBookingTimeFormat = "hh:mm a"

class BookNowViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TextTagCollectionViewDelegate, UITextViewDelegate {
    
    var str_StartDate = ""
    var str_trainer_info = ""
    var arr_section = [[String: Any]]()
    @IBOutlet weak var tableView: UITableView!
    
    let picker = UIDatePicker()
    
    var timeZoneSelectedIndex = -1
    var locationSelectedIndex = -1
    
    var trainer: Trainer?
    var package: TrainerPackage?
    var sessionDetails = [String : Any]()
    let locations = ["Karnataka", "Others"]
    var selectedDate = Set<Int>()
    var bookedDays = [String]()
    var isSessionTypeIsAlternateDay = false
    var selectedTimeSlot: PackageTimeSlot?
    var timeSlots = [PackageTimeSlot]()
    var sessionStartDate : Date?
    let defaultMinDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reiater Table Cell
        self.tableView.register(nibWithCellClass: TimeZoneTableCell.self)
        self.tableView.register(nibWithCellClass: BookNowDateTableCell.self)
        self.tableView.register(nibWithCellClass: BookNow_HeaderTableCell.self)
        self.tableView.register(nibWithCellClass: BookNowLocationTableCell.self)
        self.tableView.register(nibWithCellClass: SideMenuButtonTableCell.self)
        self.tableView.register(nibWithCellClass: BookNowTrainerInfoTableCell.self)
        
        setupUI()
        self.setupDatePicker()
    }
    
    func setupDatePicker() {
        //Setup for Date Picker
        self.picker.datePickerMode = .date
        self.picker.minimumDate = defaultMinDate
        self.picker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: defaultMinDate)  //max date is current + 1 month
        self.picker.addTarget(self, action: #selector(updateStartDate(_:)), for: .valueChanged)
        if #available(iOS 13.4, *) {
            self.picker.preferredDatePickerStyle = .wheels
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        tableView.reloadData()
    }
    
    // MARK: - Action Methods
    @IBAction func btn_back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dayButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if selectedDate.contains(sender.tag) {
            selectedDate.remove(sender.tag)
            tableView.reloadData()
        } else {
            if selectedDate.count >= Int(package?.max_session_week ?? 0) {
                Utils.showAlertWithTitleInController("", message: String(format: "Maximum number of session allowed per week is %@".localized(), "\(package?.max_session_week ?? 0)"), controller: self)
                return
            }
            
            if isSessionTypeIsAlternateDay {
                var isAlternateDay = true
                selectedDate.forEach { item in
                    let diff = item - sender.tag
                    if abs(diff) <= 1 {
                        isAlternateDay = false
                    }
                }
                if isAlternateDay {
                    selectedDate.insert(sender.tag)
                } else {
                    showAlert(title: "", message: "Please select non-consecutive day".localized())
                }
            } else {
                selectedDate.insert(sender.tag)
            }
            tableView.reloadData()
        }
        //print("Days : ", selectedDate)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        if isValidInput() {
            let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
            guard let obj_ReviewVC = storyBoard.instantiateViewController(withIdentifier: "ReviewOrderViewController") as? ReviewOrderViewController else {
                return
            }
            
            obj_ReviewVC.trainer = trainer
            obj_ReviewVC.package = package
            obj_ReviewVC.super_view = self
            obj_ReviewVC.sessionDetails = sessionDetails
            obj_ReviewVC.selectedDate = Array(selectedDate).sorted(by: <)
            //self.navigationController?.pushViewController(obj_ReviewVC, animated: true)

            
            self.addChild(obj_ReviewVC)
            obj_ReviewVC.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            self.view.addSubview((obj_ReviewVC.view)!)
            obj_ReviewVC.didMove(toParent: self)
        }
    }
    
    @IBAction func updateStartDate(_ sender: UIDatePicker) {
        sessionStartDate = sender.date
        self.str_StartDate = sender.date.toString(.custom("dd MMMM yyyy"))
        self.tableView.reloadData()
    }
    
    @IBAction func locationInfoBtnClicked(_ sender: UIButton) {
        showAlert(title: "Your Location Usage".localized(), message: "We use this information to calculate the GST applicable on your order.".localized())
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        if let package = package {
            isSessionTypeIsAlternateDay = (package.session_type?.lowercased() == "alternate")
            if let timeslotSets = package.timeslot?.allObjects as? [PackageTimeSlot] {
                let sortedTimeSolts = timeslotSets.sorted(by: { $0.start_time! < $1.start_time! })
                timeSlots = sortedTimeSolts
            }
        }

        
        fetchTrainerAvailableDate(isInitialCheck: true)
        
        self.manageSection()
    }
    
    func isValidInput() -> Bool {
        guard let package = package else { return false }
        
        if self.str_StartDate == "" {
            Utils.showAlertWithTitleInController("", message: "Please select your start date".localized(), controller: self)
            return false
        }
        
        if selectedDate.count == 0 {
            Utils.showAlertWithTitleInController("", message: "Please select days for session".localized(), controller: self)
            return false
        }
        
        if selectedDate.count > Int(package.max_session_week) {
            Utils.showAlertWithTitleInController("", message: String(format: "Maximum number of session allowed per week is %@".localized(), "\(package.max_session_week)"), controller: self)
            return false
        }
        
        let totalSessionDays = selectedDate.count * Int(package.max_week)
        if !((totalSessionDays == Int(package.total_session)) || (selectedDate.count == Int(package.max_session_week))) {
            Utils.showAlertWithTitleInController("", message: String(format: "Please choose %@ %@".localized(), "\(package.max_session_week)", (package.max_session_week > 1 ? "days".localized() : "day".localized())), controller: self)
            return false
        }
        
        if Locale.current.isCurrencyCodeInINR && sessionDetails["location"] == nil {
            Utils.showAlertWithTitleInController("", message: "Please select location".localized(), controller: self)
            return false
        }
        
        if self.str_trainer_info.trimed() == "" {
            Utils.showAlertWithTitleInController("", message: "Please enter information for the trainer".localized(), controller: self)
            return false
        }
        
        sessionDetails["startDate"] = self.str_StartDate.toDate("dd MMMM yyyy")?.toString(.custom("yyyy-MM-dd"))
        sessionDetails["information_for_trainer"] = self.str_trainer_info.trimed()
        return true
    }
    
    // MARK: - UITableViewDelegate and DataSource Methods
    func manageSection() {
        self.arr_section.removeAll()
        self.arr_section.append(["identifier": "package"])
        self.arr_section.append(["identifier": "time_zone"])
        
        if self.str_StartDate.count > 0 && sessionDetails["startTime"] != nil {
            self.arr_section.append(["identifier": "choose_day"])
        }
        
        if Locale.current.isCurrencyCodeInINR {
            self.arr_section.append(["identifier": "location"])
        }
        self.arr_section.append(["identifier": "trainer_info"])
        self.arr_section.append(["identifier": "button"])
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
//        if Locale.current.isCurrencyCodeInINR {
//            return 3
//        } else {
//            return 2
//        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 1 {
//            //if (sessionStartDateTextField.text?.count ?? 0) > 0 && sessionDetails["startTime"] != nil {
//                return 1
//            //}
//            return 0
//        }
//        return 1
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic_detail = self.arr_section[indexPath.row]
        let identifier = dic_detail["identifier"] as? String ?? ""
        if identifier == "package" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookNow_HeaderTableCell", for: indexPath) as! BookNow_HeaderTableCell
            cell.selectionStyle = .none

            if let detail_package = package {
                cell.setupCellData(package_detail: detail_package)
            }
            
            return cell
        }
        else if identifier == "time_zone" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeZoneTableCell") as! TimeZoneTableCell
            cell.selectionStyle = .none
            cell.timeZoneView.delegate = self
            cell.timeZoneView.tag = indexPath.row
            cell.setupCellData(arr_timeSlot: timeSlots, session_Date: sessionStartDate)
            
            if timeZoneSelectedIndex >= 0 {
                cell.timeZoneView.setTagAt(UInt(timeZoneSelectedIndex), selected: true)
            }
            
            cell.txt_startDate.text = self.str_StartDate
            cell.txt_startDate.inputView = picker
            
            
            //Did Tapped Start Date
            cell.didTappedDate = { (sender) in
                cell.txt_startDate.becomeFirstResponder()
            }
            
            return cell
        }
        else if identifier == "location" {

            let cell = tableView.dequeueReusableCell(withIdentifier: "BookNowLocationTableCell") as! BookNowLocationTableCell
            cell.selectionStyle = .none
            cell.timeZoneView.delegate = self
            cell.timeZoneView.tag = indexPath.row
            cell.setupCellData(locations: locations, selected_index: locationSelectedIndex)
            

            //Did Tapped Info Button
            cell.didTappedInfo = { (sender) in
                Utils.showAlertWithTitleInController("Your Location Usage".localized(), message: "We use this information to calculate the GST applicable on your order.".localized(), controller: self)
            }

            return cell
            
        }
        else if identifier == "button" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuButtonTableCell", for: indexPath) as! SideMenuButtonTableCell
            cell.selectionStyle = .none
            cell.setupCell()
            
            cell.didTappedonLogout = { (sender) in
                self.confirmButtonPressed(sender)
            }
            
            return cell
        }
        else if identifier == "choose_day" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookNowDateTableCell") as! BookNowDateTableCell
            cell.selectionStyle = .none
            cell.setupDefaultButton()
            cell.setupcell(package: package, isSession: isSessionTypeIsAlternateDay, timeslot: selectedTimeSlot, selectedDate: selectedDate, bookedDays: bookedDays)
            
            cell.didTappedButton = { (sender) in
                self.dayButtonPressed(sender)
            }

            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookNowTrainerInfoTableCell", for: indexPath) as! BookNowTrainerInfoTableCell
            cell.selectionStyle = .none
            cell.txt_info.delegate = self
            
            if (cell.txt_info.text ?? "") == "" {
                cell.txt_info.placeholder = "Please indicate if you have any medical or health condition.".localized()
            }
            else {
                cell.txt_info.placeholder = ""
            }
            
            
            return cell
        }
        /*
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeZoneCell") as? MyBookingTableViewCell else {
                return UITableViewCell()
            }
            
            cell.timeZoneView.tag = indexPath.section
            cell.timeZoneView.removeAllTags()
            for timeslot in timeSlots {
                let start = timeslot.start_time?.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat) ?? ""
                let end = timeslot.end_time?.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat) ?? ""
                let config = cell.timeZoneView.defaultConfig
                if let weekDays = timeslot.week_days, !weekDays.isEmpty {
                    if let sessionStartDate = sessionStartDate, Calendar.current.isDateInToday(sessionStartDate), var slotStartTimeStr = timeslot.start_time {
                        let currentDate = Date()
                        let todayDateStr = Date().toString(.custom("yyyy-MM-dd"))
                        let slotStartTime = (todayDateStr + " " + slotStartTimeStr).UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss")
                        //print("Date :: ", todayDateStr, " - ", (todayDateStr + " " + slotStartTimeStr))
                        if slotStartTime! > currentDate {
                            config?.backgroundColor = .white
                        } else {
                            //disable slot, 2020-10-06
                            config?.backgroundColor = .lightGray
                        }
                    } else {
                        config?.backgroundColor = .white
                    }
                } else {
                    //disable slot
                    config?.backgroundColor = .lightGray
                }
                cell.timeZoneView.addTag(start + "-" + (end), with: config)
            }
            cell.timeZoneView.delegate = self
            if timeZoneSelectedIndex >= 0 {
                cell.timeZoneView.setTagAt(UInt(timeZoneSelectedIndex), selected: true)
            }
            
            
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell") as? MyBookingTableViewCell else {
                return UITableViewCell()
            }
            
            cell.mondayButton?.isEnabled = false
            cell.mondayButton?.backgroundColor = kAppMidGreyColor
            cell.tuesdayButton?.isEnabled = false
            cell.tuesdayButton?.backgroundColor = kAppMidGreyColor
            cell.wednesdayButton?.isEnabled = false
            cell.wednesdayButton?.backgroundColor = kAppMidGreyColor
            cell.thursdayButton?.isEnabled = false
            cell.thursdayButton?.backgroundColor = kAppMidGreyColor
            cell.fridayButton?.isEnabled = false
            cell.fridayButton?.backgroundColor = kAppMidGreyColor
            cell.saturdayButton?.isEnabled = false
            cell.saturdayButton?.backgroundColor = kAppMidGreyColor
            cell.sundayButton?.isEnabled = false
            cell.sundayButton?.backgroundColor = kAppMidGreyColor
            
            let days = package?.max_session_week ?? 0
            cell.noOfSesseinPerWeekLabel?.text = String(format: "Please choose any %d %@ %@ of the week for your sessions".localized(), days, (isSessionTypeIsAlternateDay ? "non-consecutive".localized() : ""/*"consecutive"*/), (days > 1 ? "days".localized() : "day".localized()))
            
            //if let days = package?.available_week_days?.components(separatedBy: ",") {
            if let timeSlot = selectedTimeSlot, let days = timeSlot.week_days?.components(separatedBy: ",") {
                var updatedDays = days
                for bookedDay in bookedDays {
                    if let index = updatedDays.firstIndex(of: bookedDay) {
                        updatedDays.remove(at: index)
                    }
                }
                
                for day in updatedDays {
                    if let mondayButton = cell.mondayButton, day.lowercased() == "monday" {
                        mondayButton.isEnabled = true
                        mondayButton.backgroundColor = selectedDate.contains(mondayButton.tag) ? kGreenL3 : .white
                    }
                    
                    if let tuesdayButton = cell.tuesdayButton, day.lowercased() == "tuesday" {
                        tuesdayButton.isEnabled = true
                        tuesdayButton.backgroundColor = selectedDate.contains(tuesdayButton.tag) ? kGreenL3 : .white
                    }
                    
                    if let wednesdayButton = cell.wednesdayButton, day.lowercased() == "wednesday" {
                        wednesdayButton.isEnabled = true
                        wednesdayButton.backgroundColor = selectedDate.contains(wednesdayButton.tag) ? kGreenL3 : .white
                    }
                    
                    if let thursdayButton = cell.thursdayButton, day.lowercased() == "thursday" {
                        thursdayButton.isEnabled = true
                        thursdayButton.backgroundColor = selectedDate.contains(thursdayButton.tag) ? kGreenL3 : .white
                    }
                    
                    if let fridayButton = cell.fridayButton, day.lowercased() == "friday" {
                        fridayButton.isEnabled = true
                        fridayButton.backgroundColor = selectedDate.contains(fridayButton.tag) ? kGreenL3 : .white
                    }
                    
                    if let saturdayButton = cell.saturdayButton, day.lowercased() == "saturday" {
                        cell.saturdayButton?.isEnabled = true
                        saturdayButton.backgroundColor = selectedDate.contains(saturdayButton.tag) ? kGreenL3 : .white
                    }
                    
                    if let sundayButton = cell.sundayButton, day.lowercased() == "sunday" {
                        sundayButton.isEnabled = true
                        sundayButton.backgroundColor = selectedDate.contains(sundayButton.tag) ? kGreenL3 : .white
                    }
                }
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as? MyBookingTableViewCell else {
                return UITableViewCell()
            }
            
            cell.timeZoneView.tag = indexPath.section
            cell.timeZoneView.removeAllTags()
            let localizedTitle = locations.map{ $0.localized() }
            cell.timeZoneView.addTags(localizedTitle)
            cell.timeZoneView.delegate = self
            if locationSelectedIndex >= 0 {
                cell.timeZoneView.setTagAt(UInt(locationSelectedIndex), selected: true)
            }
            
            return cell
        }
        */
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TextTagCollectionView Delegate Methods
    
    func textTagCollectionView(_ textTagCollectionView: TextTagCollectionView!, canTapTag tagText: String!, at index: UInt, currentSelected: Bool, tagConfig config: TextTagConfig!) -> Bool {
        if textTagCollectionView.tag == 0 {
            if config.backgroundColor != .clear {
                return false
            }
            else if self.str_StartDate.count > 0 {
                self.selectedDate.removeAll()
                return true
            }
            else {
                Utils.showAlertWithTitleInController("", message: "Please select your start date".localized(), controller: self)
                return false
            }
        }
        return true
    }
    
    func textTagCollectionView(_ textTagCollectionView: TextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TextTagConfig!) {
        // update
        if textTagCollectionView.tag == 1 {
            timeZoneSelectedIndex = Int(index)
            selectedTimeSlot = timeSlots[Int(index)]
            sessionDetails["startTime"] = selectedTimeSlot?.start_time
            sessionDetails["endTime"] = selectedTimeSlot?.end_time
            self.fetchPackageWeeks()
        } else {
            locationSelectedIndex = Int(index)
            sessionDetails["location"] = locations[locationSelectedIndex]
            //print("Location : ", sessionDetails["location"], " ", tagText)
        }
        
        self.manageSection()
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            let startDate = (textField.inputView as? UIDatePicker)?.minimumDate ?? Date()
            sessionStartDate = startDate
            textField.text = startDate.toString(.custom("dd MMMM yyyy"))
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        timeZoneSelectedIndex = -1
        selectedTimeSlot = nil
        sessionDetails.removeValue(forKey: "startTime")
        sessionDetails.removeValue(forKey: "endTime")
        selectedDate.removeAll()
        //tableView.reloadData()
        fetchTrainerAvailableDate()
    }
    
    //MARK: - UITextView Delegate
    func textViewDidChange(_ textView: UITextView) {
        if let str_Text = textView.text {
            if str_Text == "" {
                textView.placeholder = "Please indicate if you have any medical or health condition.".localized()

            }else {
                textView.placeholder = ""
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if let str_Text = textView.text {
            self.str_trainer_info = str_Text
        }
    }
}

// MARK: - API calls
extension BookNowViewController {
    
    func fetchPackageWeeks() {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getPackageWeeks.rawValue
            
            let params = [
                "trainer_id" : trainer?.id ?? 0,
                "package_id" : package?.favorite_id ?? 0,
                "start_date" : self.str_StartDate.toDate("dd MMMM yyyy")?.toString(.custom("yyyy-MM-dd")) ?? "0",
                "start_time" : sessionDetails["startTime"] ?? "0",
                "end_time" : sessionDetails["endTime"] ?? "0",
            ] as [String : Any]
            //print("Params : ", params)
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    guard let dataResponse = (dicResponse["response"] as? [String : Any]) else {
                        return
                    }
                    
                    self.bookedDays = dataResponse["booked_days"] as! [String]
                    self.selectedDate.removeAll()
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
                }
            }
        }
    }
    
    func fetchTrainerAvailableDate(isInitialCheck: Bool = false) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getTrainerFreeSlots.rawValue
            
            let startDate = (self.str_StartDate.toDate("dd MMMM yyyy")?.date ?? Date()).toString(.custom("yyyy-MM-dd"))
            let params = [
                "trainer_id" : trainer?.id ?? 0,
                "package_id" : package?.favorite_id ?? 0,
                "start_date" : startDate
            ] as [String : Any]
            //print("Params : ", params)
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    guard let dataResponse = (dicResponse["response"] as? [String : Any]) else {
                        return
                    }
                    
                    if let detailsData = dataResponse["time_slotes"] as? [String: Any] {
                        //if isInitialCheck,
                         //  let availableDateStr = detailsData["date"] as? String,
                           //let availableDate = availableDateStr.toDate("yyyy-MM-dd")?.date,
//                           let datePicker = self.sessionStartDateTextField.inputView as? UIDatePicker {
//                            //print("date : ", availableDate)
//                            if !Calendar.current.isDateInToday(availableDate) {
//                                datePicker.minimumDate = availableDate
//                            }
//                        }
                        if let timeSlotData = detailsData["slots"] as? [[String: Any]] {
                            var arrData = [PackageTimeSlot]()
                            for details in timeSlotData {
                                if let entity = PackageTimeSlot.createPackageTimeSlotData(dicData: details) {
                                    arrData.append(entity)
                                }
                            }
                            self.timeSlots = arrData
                        }
                    }
                    //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.view_trainers.rawValue)
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
                }
            }
        }
    }
}
