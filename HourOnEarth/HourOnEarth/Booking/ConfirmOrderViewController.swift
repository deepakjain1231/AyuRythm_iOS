//
//  ConfirmOrderViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 16/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import EventKit
import SafariServices

class ConfirmOrderViewController: UIViewController {
    
    @IBOutlet weak var appleCalendarButton: UIButton!
    
    var package: TrainerPackage?
    var sessionDetails : [String : Any]?
    var selectedDate = [Int]()
    var paymentDetails : [String : Any]?

    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(true)
    }
    
    // MARK: - Action Methods
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        if let nvc = self.presentingViewController as? UINavigationController {
            dismiss(animated: true, completion: { [weak self] in
                //nvc.popToRootViewController(animated: true)
                let myBookingVC = MyBookingViewController.instantiateFromStoryboard("Booking")
                if let viewControllers = nvc.viewControllers.first {
                    nvc.viewControllers = [viewControllers]
                }
                nvc.pushViewController(myBookingVC, animated: true)
                //self?.navigationController?.setNavigationBarHidden(false, animated: true)
            })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func appleCalendarButtonPressed(_ sender: UIButton) {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            saveEvents(store: eventStore)
            
        case .denied:
            showCalendarAccessDeniedAlert()
            print("Access denied")
            
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:{[weak self] (granted: Bool, error: Error?) -> Void in
                DispatchQueue.main.async {
                    if granted {
                        self?.saveEvents(store: eventStore)
                    } else {
                        print("Access denied")
                        self?.showCalendarAccessDeniedAlert()
                    }
                }
            })
        default:
            print("Case default")
        }
    }
    
    @IBAction func viewInvoiceButtonPressed(_ sender: UIButton) {
        if let invoiceLink = paymentDetails?["invoice_link"] as? String, let invoiceUrl = URL(string: invoiceLink)  {
            let vc = SFSafariViewController(url: invoiceUrl)
            present(vc, animated: true)
        }
    }
    
    // MARK: - Custom Methods
    
    func openSettings(alert: UIAlertAction!) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func showCalendarAccessDeniedAlert() {
        let alert = UIAlertController(title: "",
                                      message: "Calendar access was denied. Please enable it in app settings.".localized(),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Open Settings".localized(),
                                      style: UIAlertAction.Style.default,
                                      handler: openSettings))
        alert.addAction(UIAlertAction(title: "Cancel".localized(),
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func setupUI() {
        appleCalendarButton.layer.borderWidth = 2.0
    }
    
    func saveRecurrenceEvent(store: EKEventStore) {
        showActivityIndicator()
        guard let orderDates = paymentDetails?["order_dates"] as? [[String : Any]],
              let firstOrderDate = orderDates.first,
              let lastOrderDate = orderDates.last,
              let startDateStr = firstOrderDate["date"] as? String,
              let startTimeStr = firstOrderDate["start_time"] as? String,
              let startDate = (startDateStr + " " + startTimeStr).UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss"),
              let endDateStr = lastOrderDate["date"] as? String,
              let endTimeStr = lastOrderDate["end_time"] as? String,
              let endDate = (endDateStr + " " + endTimeStr).UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss"),
              let evenTimeIntervalStr = package?.time_per_session,
              let evenTimeInterval = Double(evenTimeIntervalStr) else {
            hideActivityIndicator()
            showAlert(title: "Error".localized(), message: "Failed to sync events with calendar".localized())
            return
        }
        
        let event = EKEvent(eventStore: store)
        event.calendar = store.defaultCalendarForNewEvents
        
        event.title = package?.name ?? "Yoga Class".localized()
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(evenTimeInterval * 60)
        
        var daysOfWeek = [EKRecurrenceDayOfWeek]()

        for day in selectedDate {
            if day == 1 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.monday))
            }
            
            if day == 2 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.tuesday))
            }
            
            if day == 3 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.wednesday))
            }
            
            if day == 4 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.thursday))
            }
            
            if day == 5 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.friday))
            }
            
            if day == 6 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.saturday))
            }
            
            if day == 7 {
                daysOfWeek.append(EKRecurrenceDayOfWeek(.sunday))
            }
        }
        
        let recurrenceEnd = EKRecurrenceEnd(end: endDate)
        let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: daysOfWeek, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: recurrenceEnd)
        
        event.recurrenceRules = [rule]
        
        do {
            try store.save(event, span: .thisEvent)
            hideActivityIndicator()
            showAlert(title: "Success".localized(), message: "Successfully sync events with calendar".localized())
        } catch {
            print("Error saving event in calendar")
            hideActivityIndicator()
            showAlert(title: "Error".localized(), message: "Failed to sync events with calendar".localized())
        }
    }
    
    func saveEvents(store: EKEventStore) {
        showActivityIndicator()
        guard let orderDates = paymentDetails?["order_dates"] as? [[String : Any]],
              let eventName = package?.name else {
            hideActivityIndicator()
            showAlert(title: "Error".localized(), message: "Failed to sync events with calendar".localized())
            return
        }
        
        let orderDateModels = orderDates.compactMap{ OrderDateModel(fromDictionary: $0) }
        orderDateModels.forEach { orderDate in
            guard let startDate = orderDate.startFullDate, let endDate = orderDate.endFullDate else {
                print("Can't save event, problem in event date")
                return
            }
            let event = EKEvent(eventStore: store)
            event.calendar = store.defaultCalendarForNewEvents
            event.title = eventName
            event.startDate = startDate
            event.endDate = endDate
            
            do {
                try store.save(event, span: .thisEvent)
            } catch {
                print("Error saving event in calendar")
                //hideActivityIndicator()
                //showAlert(title: "Error", message: "Failed to sync events with calendar".localized())
            }
        }
        hideActivityIndicator()
        showAlert(title: "Success".localized(), message: "Successfully sync events with calendar".localized())
    }
}

class OrderDateModel : NSObject{

    var date : String!
    var endTime : String!
    var startTime : String!
    var weekDay : String?
    
    var startFullDate: Date? {
        return (date + " " + startTime).UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    var endFullDate: Date? {
        return (date + " " + endTime).UTCToLocalDate(incomingFormat: "yyyy-MM-dd HH:mm:ss")
    }

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init?(fromDictionary dictionary: [String:Any]){
        
        guard let date = dictionary["date"] as? String,
           let endTime = dictionary["end_time"] as? String,
           let startTime = dictionary["start_time"] as? String else {
            return nil
        }
        
        self.date = date
        self.endTime = endTime
        self.startTime = startTime
        self.weekDay = dictionary["week_day"] as? String
    }
}
