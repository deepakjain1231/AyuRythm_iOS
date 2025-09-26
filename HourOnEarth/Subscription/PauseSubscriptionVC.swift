//
//  PauseSubscriptionVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class PauseSubscriptionVC: UIViewController {

    @IBOutlet weak var pauseDateTF: UITextField!
    @IBOutlet weak var resumeDateTF: UITextField!
    
    var activeSubscription: ARActiveSubscription?
    var selectedTextField: UITextField?
    var pauseDate: Date?
    var resumeDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pause".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        let pauseLimits = activeSubscription?.planPauseDateLimits()
        setupDateFieldUI(for: pauseDateTF, seletedDate: pauseLimits?.start)
        setupDateFieldUI(for: resumeDateTF)
    }
    
    func setupDateFieldUI(for textField: UITextField, seletedDate: Date? = nil, minDate: Date? = nil, maxDate: Date? = nil) {
        textField.rightImage(#imageLiteral(resourceName: "Vector"), imageWidth: 18, padding: 12)
        textField.leftImage(nil, imageWidth: 0, padding: 8)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.black.cgColor //UIColor.fromHex(hexString: "#A949AE").cgColor
        textField.delegate = self
        textField.addDoneOnKeyboardWithTarget(self, action: #selector(textFieldDoneBtnClicked))
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.timeZone = TimeZone.current
        picker.minimumDate = minDate
        picker.maximumDate = maxDate
        picker.addTarget(self, action: #selector(updateStartDate(_:)), for: .valueChanged)
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        textField.inputView = picker
        
        if let seletedDate = seletedDate {
            picker.date = seletedDate
            selectedTextField = textField
            updateStartDate(picker)
        }
    }
    
    @objc func updateStartDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en")
        if selectedTextField == pauseDateTF {
            pauseDate = sender.date
            
            //reset resume date
            resumeDateTF.text = ""
            resumeDate = nil
        } else {
            resumeDate = sender.date
        }
        selectedTextField?.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func doneBtnPressed(sender: UIButton) {
        guard let pauseDate = pauseDate else {
            showAlert(message: "Please select pause date".localized())
            return
        }
        
        guard let resumeDate = resumeDate else {
            showAlert(message: "Please select resume date".localized())
            return
        }
    
        showPauseAlert(from: self, pauseDate: pauseDate, resumeDate: resumeDate)
    }
    
    func showPauseAlert(from vc: UIViewController, pauseDate: Date, resumeDate: Date) {
        let pauseTotalCount = activeSubscription?.pauseTotalCount ?? "1"
        let pauseMaxDays = activeSubscription?.pauseMaxDays ?? ""
        let message = String(format: "you can pause active subscription %@ %@, for a maximum of %@ %@ cumulatively.".localized(), pauseTotalCount, (Int(pauseTotalCount) ?? 0) > 1 ? "times".localized() : "time".localized(), pauseMaxDays, pauseMaxDays.dayStrValue)
        let alert = UIAlertController(title: "Your active subscription will be paused".localized(), message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive))
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { _ in
            let subID = self.activeSubscription?.id ?? ""
            self.callPauseSubscriptionApi(subID: subID, pauseDate: pauseDate, resumeDate: resumeDate)
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showPauseSccessSummeryScreen() {
        let vc = PauseSubscriptionResultVC.instantiate(fromAppStoryboard: .Subscription)
        vc.activeSubscription = activeSubscription
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PauseSubscriptionVC: UITextFieldDelegate {
    @objc func textFieldDoneBtnClicked() {
        guard let selectedTextField = selectedTextField else { return }
        
        if let datePicker = selectedTextField.inputView as? UIDatePicker {
            updateStartDate(datePicker)
        }
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        if let datePicker = textField.inputView as? UIDatePicker {
            if textField == pauseDateTF {
                datePicker.minimumDate = Date().tomorrow
                datePicker.maximumDate = activeSubscription?.planEndDateValue
            } else {
                let minDate = pauseDate?.adding(.day, value: 1)
                datePicker.minimumDate = minDate
                datePicker.maximumDate = minDate?.adding(.day, value: activeSubscription?.pauseMaxDays.intValue ?? 1)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

extension PauseSubscriptionVC {
    func callPauseSubscriptionApi(subID: String, pauseDate: Date, resumeDate: Date) {
        self.showActivityIndicator()
        let pauseDateStr = pauseDate.dateString(format: App.dateFormat.yyyyMMdd)
        let resumeDateStr = resumeDate.dateString(format: App.dateFormat.yyyyMMdd)
        let params = ["subscription_history_id": subID, "pause_date": pauseDateStr, "resume_date": resumeDateStr]
        Utils.doAPICall(endPoint: .pauseScription, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.activeSubscription?.pauseDate = pauseDateStr
                self?.activeSubscription?.resumeDate = resumeDateStr
                self?.hideActivityIndicator()
                self?.showPauseSccessSummeryScreen()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
}
