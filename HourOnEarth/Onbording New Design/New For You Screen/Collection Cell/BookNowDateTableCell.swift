//
//  BookNowDateTableswift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 26/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class BookNowDateTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    
    var didTappedButton: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupDefaultButton() {
        mondayButton.isEnabled = false
        mondayButton.backgroundColor = kAppMidGreyColor
        tuesdayButton.isEnabled = false
        tuesdayButton.backgroundColor = kAppMidGreyColor
        wednesdayButton.isEnabled = false
        wednesdayButton.backgroundColor = kAppMidGreyColor
        thursdayButton.isEnabled = false
        thursdayButton.backgroundColor = kAppMidGreyColor
        fridayButton.isEnabled = false
        fridayButton.backgroundColor = kAppMidGreyColor
        saturdayButton.isEnabled = false
        saturdayButton.backgroundColor = kAppMidGreyColor
        sundayButton.isEnabled = false
        sundayButton.backgroundColor = kAppMidGreyColor
    }
    
    func setupcell(package: TrainerPackage?, isSession: Bool, timeslot: PackageTimeSlot?, selectedDate: Set<Int>, bookedDays: [String]) {
        let days = package?.max_session_week ?? 0
        lbl_subTitle.text = String(format: "Please choose any %d %@ %@ of the week for your sessions".localized(), days, (isSession ? "non-consecutive".localized() : ""/*"consecutive"*/), (days > 1 ? "days".localized() : "day".localized()))
        
        if let timeSlot = timeslot, let days = timeSlot.week_days?.components(separatedBy: ",") {
            var updatedDays = days
            for bookedDay in bookedDays {
                if let index = updatedDays.firstIndex(of: bookedDay) {
                    updatedDays.remove(at: index)
                }
            }
            
            for day in updatedDays {
                if let mondayButton = mondayButton, day.lowercased() == "monday" {
                    mondayButton.isEnabled = true
                    mondayButton.backgroundColor = selectedDate.contains(mondayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    mondayButton.setTitleColor(selectedDate.contains(mondayButton.tag) ? .white : .black, for: .normal)
                }
                
                if let tuesdayButton = tuesdayButton, day.lowercased() == "tuesday" {
                    tuesdayButton.isEnabled = true
                    tuesdayButton.backgroundColor = selectedDate.contains(tuesdayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    tuesdayButton.setTitleColor(selectedDate.contains(tuesdayButton.tag) ? .white : .black, for: .normal)
                }
                
                if let wednesdayButton = wednesdayButton, day.lowercased() == "wednesday" {
                    wednesdayButton.isEnabled = true
                    wednesdayButton.backgroundColor = selectedDate.contains(wednesdayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    wednesdayButton.setTitleColor(selectedDate.contains(wednesdayButton.tag) ? .white : .black, for: .normal)
                }
                
                if let thursdayButton = thursdayButton, day.lowercased() == "thursday" {
                    thursdayButton.isEnabled = true
                    thursdayButton.backgroundColor = selectedDate.contains(thursdayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    thursdayButton.setTitleColor(selectedDate.contains(thursdayButton.tag) ? .white : .black, for: .normal)
                }
                
                if let fridayButton = fridayButton, day.lowercased() == "friday" {
                    fridayButton.isEnabled = true
                    fridayButton.backgroundColor = selectedDate.contains(fridayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    fridayButton.setTitleColor(selectedDate.contains(fridayButton.tag) ? .white : .black, for: .normal)
                }
                
                if let saturdayButton = saturdayButton, day.lowercased() == "saturday" {
                    saturdayButton.isEnabled = true
                    saturdayButton.backgroundColor = selectedDate.contains(saturdayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    saturdayButton.setTitleColor(selectedDate.contains(saturdayButton.tag) ? .white : .black, for: .normal)
                }
                
                if let sundayButton = sundayButton, day.lowercased() == "sunday" {
                    sundayButton.isEnabled = true
                    sundayButton.backgroundColor = selectedDate.contains(sundayButton.tag) ? AppColor.app_DarkGreenColor : .clear
                    sundayButton.setTitleColor(selectedDate.contains(sundayButton.tag) ? .white : .black, for: .normal)
                }
            }
        }
    }
    
    
    // MARK: - UIButton Action
    @IBAction func btn_Action(_ sender: UIButton) {
        self.didTappedButton?(sender)
    }
}
