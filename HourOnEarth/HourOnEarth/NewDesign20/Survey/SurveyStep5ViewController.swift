//
//  SurveyStep5ViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class SurveyStep5ViewController: UIViewController {
    
//    enum TimeSlots: Int {
//        case slot1 = 1
//        case slot2
//        case slot3
//        case slot4
//        case slot5
//        
//        var stringValue: String {
//            switch self {
//            case .slot1:
//                return "20-30 MIN"
//            case .slot2:
//                return "30-45 MIN"
//            case .slot3:
//                return "45-60 MIN"
//            case .slot4:
//                return "60-90 MIN"
//            case .slot5:
//                return "More then 90 MIN"
//            }
//        }
//        
//        static func timeSlotValue(from string: String) -> TimeSlots {
//            switch string {
//            case "30-45 MIN":
//                return .slot2
//            case "45-60 MIN":
//                return .slot3
//            case "60-90 MIN":
//                return .slot4
//            case "More then 90 MIN":
//                return .slot5
//            default:
//                return .slot1
//            }
//        }
//    }

//    @IBOutlet var levelTypeViews: [TextImageClickableView]!
//    @IBOutlet weak var txtSessionTimeSlot: UITextField!
//    @IBOutlet weak var txtSessionTime: UITextField!
    
    var selectedTextField: UITextField?
    
    var int_selected: Int?
    var arr_Section = [[String: Any]]()
    var delegate: delegate_nextPressed?
    @IBOutlet weak var tbl_View: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: TodaysGoalHeaderTableCell.self)
        
//        levelTypeViews.forEach{
//            $0.delegate = self
//            $0.borderColor = UIColor().hexStringToUIColor(hex: "#faf2db")
//        }
        
//        txtSessionTimeSlot.rightImage(#imageLiteral(resourceName: "arrowCircularDown"), imageWidth: 18, padding: 12)
//        txtSessionTimeSlot.leftImage(nil, imageWidth: 0, padding: 8)
//        txtSessionTimeSlot.layer.cornerRadius = 18
//        txtSessionTimeSlot.layer.borderWidth = 3
//        txtSessionTimeSlot.layer.borderColor = #colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1)
//        txtSessionTimeSlot.delegate = self
//        txtSessionTimeSlot.addDoneOnKeyboardWithTarget(self, action: #selector(textFieldDoneBtnClicked))
//
//        txtSessionTimeSlot.loadDropdownData(data: [TimeSlots.slot1.stringValue, TimeSlots.slot2.stringValue, TimeSlots.slot3.stringValue, TimeSlots.slot4.stringValue, TimeSlots.slot5.stringValue]) { selectedSlot in
//            print("selected Slot : ", selectedSlot)
//        }
//
//        txtSessionTime.rightImage(#imageLiteral(resourceName: "arrowCircularDown"), imageWidth: 18, padding: 12)
//        txtSessionTime.leftImage(nil, imageWidth: 0, padding: 8)
//        txtSessionTime.layer.cornerRadius = 18
//        txtSessionTime.layer.borderWidth = 3
//        txtSessionTime.layer.borderColor = #colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1)
//        txtSessionTime.delegate = self
//        txtSessionTime.addDoneOnKeyboardWithTarget(self, action: #selector(textFieldDoneBtnClicked))
//
//        let picker = UIDatePicker()
//        picker.datePickerMode = .time
//        picker.timeZone = TimeZone.current
//        //picker.minimumDate = Date()
//        picker.addTarget(self, action: #selector(updateStartDate(_:)), for: .valueChanged)
//        if #available(iOS 13.4, *) {
//            picker.preferredDatePickerStyle = .wheels
//        }
//        txtSessionTime.inputView = picker
        self.manageSection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showSavedData()
    }
    
    func showSavedData() {
//        levelTypeViews.forEach{ cView in
//            if cView.tag == SurveyData.shared.levelID {
//                //textImageClickableViewv(view: cView, didSelectAt: cView.tag)
//            }
//        }
//        if let timeSlot = TimeSlots(rawValue: SurveyData.shared.timeSlot) {
//            txtSessionTimeSlot.text = timeSlot.stringValue
//        }
//        if !SurveyData.shared.reminderTime.isEmpty {
//            txtSessionTime.text = SurveyData.shared.reminderTime
//        }
        self.int_selected = SurveyData.shared.levelID
    }
    
    @objc func updateStartDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //"yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en")

//        txtSessionTime.text = dateFormatter.string(from: sender.date)
        SurveyData.shared.reminderTime = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func clearReminderBtnPressed(sender: UIButton) {
        SurveyMainViewController.clearScheduledLocalNotification()
        SurveyData.shared.reminderTime = ""
//        txtSessionTime.text = ""
    }
}

extension SurveyStep5ViewController {//}: TextImageClickableViewDelegate {
//    func textImageClickableViewv(view: TextImageClickableView, didSelectAt index: Int) {
//
//        levelTypeViews.forEach{
//            $0.isSelected = false
//            $0.borderColor = UIColor().hexStringToUIColor(hex: "#faf2db")
//        }
//        view.isSelected.toggle()
//
//        guard let type = LevelType(rawValue: index) else { return }
//        var colorCode = ""
//        switch type {
//        case .Beginner:
//            colorCode = "#bdd630"
//        case .Intermediate:
//            colorCode = "#bf901a"
//        case .Advanced:
//            colorCode = "#843c0c"
//        }
//        view.borderColor = UIColor().hexStringToUIColor(hex: view.isSelected ? colorCode : "#faf2db")
//        SurveyData.shared.levelID = view.tag
//    }
}

extension SurveyStep5ViewController: UITextFieldDelegate {
//    @objc func textFieldDoneBtnClicked() {
//        guard let selectedTextField = selectedTextField else { return }
//
//        if selectedTextField == txtSessionTime {
//            if let datePicker = txtSessionTime.inputView as? UIDatePicker {
//                updateStartDate(datePicker)
//            }
//            SurveyData.shared.reminderTime = txtSessionTime.text ?? ""
//        } else {
//            SurveyData.shared.timeSlot = TimeSlots.timeSlotValue(from: txtSessionTimeSlot.text ?? "").rawValue
//        }
//        view.endEditing(true)
//    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        selectedTextField = textField
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//    }
}

extension UITextField {
    func leftImage(_ image: UIImage?, imageWidth: CGFloat, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: padding, y: 0, width: imageWidth, height: frame.height)
        imageView.contentMode = .center
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth + 2 * padding, height: frame.height))
        containerView.addSubview(imageView)
        leftView = containerView
        leftViewMode = .always
    }
    
    func rightImage(_ image: UIImage?, imageWidth: CGFloat, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: padding, y: 0, width: imageWidth, height: frame.height)
        imageView.contentMode = .center
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth + 2 * padding, height: frame.height))
        containerView.addSubview(imageView)
        rightView = containerView
        rightViewMode = .always
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension SurveyStep5ViewController: DataValidateable {
    func validateData() -> (Bool, String) {
        return (true, "")
    }
}


extension SurveyStep5ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.append(["identifier": "header", "title": "Your experience level with ayurveda".localized(),
                                 "subtitle": "If you're new to Ayurveda ,we recommend starting with beginner".localized()])
        
        self.arr_Section.append(["identifier": "exp_level"])
        
        self.arr_Section.append(["identifier": "header_1", "title": "Select a suitable time to exercise daily".localized(),
                                 "subtitle": "We'll send you a gentle reminder to exercise so you can start your day with energy.".localized()])
        
        self.arr_Section.append(["identifier": "choose_day_time"])
        
        self.arr_Section.append(["identifier": "button", "title": "", "button_title": "Let's Go".localized()])
        
        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
        //return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let idetifier = self.arr_Section[indexPath.row]["identifier"] as? String ?? ""
        if idetifier == "header" || idetifier == "header_1" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodaysGoalHeaderTableCell") as? TodaysGoalHeaderTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.lbl_Title.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            cell.lbl_subTitle.text = self.arr_Section[indexPath.row]["subtitle"] as? String ?? ""
            cell.lbl_Title.textAlignment = idetifier == "header_1" ? .left : .center
            cell.lbl_subTitle.textAlignment = idetifier == "header_1" ? .left : .center
            cell.comstraint_lbl_subTitle_Top.constant = idetifier == "header_1" ? 12 : 18
            
            return cell
        }
        else if idetifier == "exp_level" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalExperienceLevelTableCell") as? TodayGoalExperienceLevelTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.view_beginner_outer.layer.borderWidth = 1
            cell.view_intermideate_outer.layer.borderWidth = 1
            cell.view_advanced_outer.layer.borderWidth = 1
            
            if self.int_selected == cell.view_beginner_outer.tag {
                cell.view_beginner_outer.backgroundColor = .clear
                cell.view_beginner_outer.layer.borderColor = UIColor.black.cgColor
                cell.constraint_img_beginner_Ineer.constant = 5
                
                //Intermidiate
                cell.constraint_img_intermidiate_Ineer.constant = 0
                cell.view_intermideate_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_intermideate_outer.backgroundColor = UIColor.init(red: 204.0/255.0, green: 221.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                
                //Advanced
                cell.constraint_img_advances_Ineer.constant = 0
                cell.view_advanced_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_advanced_outer.backgroundColor = UIColor.init(red: 196.0/255.0, green: 238.0/255.0, blue: 224.0/255.0, alpha: 1.0)
            }
            else if self.int_selected == cell.view_intermideate_outer.tag {
                cell.view_intermideate_outer.backgroundColor = .clear
                cell.view_intermideate_outer.layer.borderColor = UIColor.black.cgColor
                cell.constraint_img_intermidiate_Ineer.constant = 5
                
                //Beginner
                cell.constraint_img_beginner_Ineer.constant = 0
                cell.view_beginner_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_beginner_outer.backgroundColor = UIColor.init(red: 255.0/255.0, green: 204.0/255.0, blue: 217.0/255.0, alpha: 1.0)
                
                //Advanced
                cell.constraint_img_advances_Ineer.constant = 0
                cell.view_advanced_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_advanced_outer.backgroundColor = UIColor.init(red: 196.0/255.0, green: 238.0/255.0, blue: 224.0/255.0, alpha: 1.0)
            }
            else if self.int_selected == cell.view_advanced_outer.tag {
                cell.view_advanced_outer.backgroundColor = .clear
                cell.view_advanced_outer.layer.borderColor = UIColor.black.cgColor
                cell.constraint_img_advances_Ineer.constant = 5
                
                //Beginner
                cell.constraint_img_beginner_Ineer.constant = 0
                cell.view_beginner_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_beginner_outer.backgroundColor = UIColor.init(red: 255.0/255.0, green: 204.0/255.0, blue: 217.0/255.0, alpha: 1.0)
                
                //Intermidiate
                cell.constraint_img_intermidiate_Ineer.constant = 0
                cell.view_intermideate_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_intermideate_outer.backgroundColor = UIColor.init(red: 204.0/255.0, green: 221.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
            else {
                //Beginner
                cell.constraint_img_beginner_Ineer.constant = 0
                cell.view_beginner_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_beginner_outer.backgroundColor = UIColor.init(red: 255.0/255.0, green: 204.0/255.0, blue: 217.0/255.0, alpha: 1.0)
                
                //Intermidiate
                cell.constraint_img_intermidiate_Ineer.constant = 0
                cell.view_intermideate_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_intermideate_outer.backgroundColor = UIColor.init(red: 204.0/255.0, green: 221.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                
                //Advanced
                cell.constraint_img_advances_Ineer.constant = 0
                cell.view_advanced_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_advanced_outer.backgroundColor = UIColor.init(red: 196.0/255.0, green: 238.0/255.0, blue: 224.0/255.0, alpha: 1.0)
            }
            
            cell.didTappedonLevel = { (sender) in
                self.int_selected = sender.tag
                SurveyData.shared.levelID = sender.tag
                self.tbl_View.reloadData()
            }
            
            return cell
        }
        else if idetifier == "choose_day_time" {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseDayTimeTableCell") as? ChooseDayTimeTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.date_picker.timeZone = TimeZone.current
            cell.date_picker.addTarget(self, action: #selector(updateStartDate(_:)), for: .valueChanged)
            if #available(iOS 13.4, *) {
                cell.date_picker.preferredDatePickerStyle = .wheels
            }
            
            for innerView in cell.view_StackDay.subviews {
                if SurveyData.shared.repetedDay.contains(innerView.tag) {
                    innerView.layer.borderColor = UIColor.clear.cgColor
                    (innerView.subviews.first as? UILabel)?.textColor = .white
                    innerView.backgroundColor = UIColor.init(red: 62.0/255.0, green: 139.0/255.0, blue: 58.0/255.0, alpha: 1.0)
                }
                else {
                    innerView.backgroundColor = UIColor.clear
                    (innerView.subviews.first as? UILabel)?.textColor = .black
                    innerView.layer.borderColor = UIColor.init(red: 187.0/255.0, green: 187.0/255.0, blue: 187.0/255.0, alpha: 1.0).cgColor
                }
            }
            
            cell.didTappedonDays = {(sender) in
                if let indx = SurveyData.shared.repetedDay.firstIndex(of: sender.tag) {
                    SurveyData.shared.repetedDay.remove(at: indx)
                }
                else {
                    SurveyData.shared.repetedDay.append(sender.tag)
                }
                self.tbl_View.reloadData()
            }
            
            
            return cell
        }
        else if idetifier == "button" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalButtonTableCell") as? TodayGoalButtonTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.lbl_title.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            cell.btn_Next.setTitle((self.arr_Section[indexPath.row]["button_title"] as? String ?? ""), for: .normal)
            
            cell.didTappedonNext = { (sender) in
                self.delegate?.nextpressed(true)
            }
            
            return cell
        }
        

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
