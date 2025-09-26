//
//  TimeZoneTableswift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 26/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TimeZoneTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_startDate_Title: UILabel!
    @IBOutlet weak var txt_startDate: UITextField!
    @IBOutlet weak var btn_startDate: UIButton!
    @IBOutlet weak var lbl_TimeSlot_Title: UILabel!
    @IBOutlet weak var timeZoneView: TextTagCollectionView!

    var didTappedDate: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let textConfig = TextTagConfig()
        textConfig.textColor = UIColor.fromHex(hexString: "#6B6B6B")
        textConfig.selectedTextColor = AppColor.app_DarkGreenColor
        textConfig.backgroundColor = .clear
        textConfig.selectedBackgroundColor = .clear
        textConfig.borderColor = UIColor.fromHex(hexString: "#878787")
        textConfig.borderWidth = 1.0
        textConfig.selectedBorderWidth = 1.0
        textConfig.selectedBorderColor = AppColor.app_DarkGreenColor
        textConfig.cornerRadius = 5
        textConfig.selectedCornerRadius = 5
        textConfig.shadowColor = .white
        textConfig.minWidth = (kDeviceWidth / 2) - 30
        textConfig.textFont = UIFont.AppFontRegular(14)
        
        if timeZoneView != nil {
            timeZoneView.defaultConfig = textConfig
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellData(arr_timeSlot: [PackageTimeSlot], session_Date: Date?) {
        
        timeZoneView.removeAllTags()
        for timeslot in arr_timeSlot {
            let start = timeslot.start_time?.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat) ?? ""
            let end = timeslot.end_time?.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat) ?? ""
            let config = timeZoneView.defaultConfig
            if let weekDays = timeslot.week_days, !weekDays.isEmpty {
                if let sessionStartDate = session_Date, Calendar.current.isDateInToday(sessionStartDate), var slotStartTimeStr = timeslot.start_time {
                    let currentDate = Date()
                    let todayDateStr = Date().toString(.custom("yyyy-MM-dd"))
                    let slotStartTime = (todayDateStr + " " + slotStartTimeStr).UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss")
                    //print("Date :: ", todayDateStr, " - ", (todayDateStr + " " + slotStartTimeStr))
                    if slotStartTime! > currentDate {
                        config?.backgroundColor = .clear
                    } else {
                        //disable slot, 2020-10-06
                        config?.backgroundColor = .lightGray
                    }
                } else {
                    config?.backgroundColor = .clear
                }
            } else {
                //disable slot
                config?.backgroundColor = .lightGray
            }
            timeZoneView.addTag(start + "-" + (end), with: config)
        }
    }

    
    // MARK: - UIButton Action
    @IBAction func btn_Start_Date_Action(_ sender: UIButton) {
        self.didTappedDate?(sender)
    }
}
