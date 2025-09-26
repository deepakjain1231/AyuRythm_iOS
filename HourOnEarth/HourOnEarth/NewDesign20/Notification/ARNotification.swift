//
//  ARNotification.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 01/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class ARNotification: BaseViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tblNotification: UITableView!
    var arrNotificationList = [[String: Any]]()
    var nitificationCount : String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.tblNotification.delegate = self
        self.tblNotification.dataSource = self
        
        self.tblNotification.tableFooterView = UIView()
        self.tblNotification.tableHeaderView = UIView()

        tblNotification.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        self.navigationItem.title = self.nitificationCount == "" || self.nitificationCount == "0" || self.nitificationCount.isEmpty ? "Notifications".localized() : ("Notifications".localized() + "\(self.nitificationCount)")
        self.getNotificationFromServer()
        self.tblNotification.register(UINib(nibName: "NotificationHeader", bundle: Bundle.main), forCellReuseIdentifier: "NotificationHeader")

        // Do any additional setup after loading the view.
    }
    
    //MARK: TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotificationList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = self.tblNotification.dequeueReusableCell(withIdentifier: "NotificationHeader") as! NotificationHeader
        cell.readAllButton.addTarget(self, action: #selector(ReadAllButtonClicked(_:)), for: .touchUpInside)
        return cell.contentView
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell else {
                return UITableViewCell()
            }
        
        let dict = self.arrNotificationList[indexPath.row]
        cell.lblTitle.text = dict["title"] as? String
        cell.lblDescription.text = dict["message"] as? String
        cell.backView.shadowOnVIew(.black)
        let stringdate = dict["timestamp"] as? String
    
        cell.lblTime.text = timeAgoSinceDate(stringToDate(stringdate!))
        let strStatus = dict["readstatus"] as? String
        cell.lblTime.textColor = strStatus == "0" ? colorTextTagGreen : colorTextTimestampblack

        cell.backView.backgroundColor = strStatus == "0" ? colorBgTagGreen : colorTextNotiCellbackgroundblack
        cell.selectionStyle = .none
            return cell
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.NotificationReadAllFromServer()

    }
    @IBAction func ReadAllButtonClicked(_ sender: UIButton)
    {
        self.NotificationReadAllFromServer()
    }
}

extension ARNotification {
    func getNotificationFromServer() {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.notificationList.rawValue
            
            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [[String : Any]]) else {
                        return
                    }
                    self.arrNotificationList = []
                    for dict in dicResponse
                    {
                        self.arrNotificationList.append(dict)
                    }
                    self.arrNotificationList.reverse()
                    self.tblNotification.reloadData()
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func NotificationReadAllFromServer() {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.changeNotificationStatus.rawValue
            
            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success( _):
                    print(response)
                    self.getNotificationFromServer()
                    self.navigationItem.title = "Notifications".localized()
                    UIApplication.shared.applicationIconBadgeNumber = 0
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    static func markAllNotificationAsRead() {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.changeNotificationStatus.rawValue
            
            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success( _):
                    print(response)
                    UIApplication.shared.applicationIconBadgeNumber = 0
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
