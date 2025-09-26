//
//  ResultHistoryViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 14/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift

class ResultHistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {//, delegate_patienID {
    
    enum HistoryItems: Int {
        case variationHistory
        case spO2History
        case prakritiResult
        case suryathonHistory
        case wellnessReport
        case weight
//        case patientHistory

        var title: String {
            switch self {
            case .variationHistory:
                
                return "Variation History"
            case .spO2History:
                
                return "SpO2 or Oxygen Saturation History"
            case .prakritiResult:
                
                return "Prakriti History"
            case .suryathonHistory:
                
                return "Suryathon Tracker"
            case .wellnessReport:
                
                return "Wellness report"
            case .weight:
                
                return "Weight"
//            case .patientHistory:
//
//                return "Patient History"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var recommendationVikriti: RecommendationType = .kapha
    let historyItems: [HistoryItems] = [.variationHistory, .spO2History, .prakritiResult, .wellnessReport, .weight]//, .patientHistory]//.suryathonHistory
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UITableView Delegate and DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultHistoryCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = historyItems[indexPath.row].title.localized()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name:"ResultHistory", bundle:nil)
        
        switch historyItems[indexPath.row] {
        case .variationHistory:
            guard let resultHistoryViewController = storyBoard.instantiateViewController(withIdentifier: "ResultHistoryDeviationViewController") as? ResultHistoryDeviationViewController else {
                return
            }
            self.navigationController?.pushViewController(resultHistoryViewController, animated: true)
            
        case .spO2History:
            guard let resultHistoryViewController = storyBoard.instantiateViewController(withIdentifier: "ResultHistorySPO2ViewController") as? ResultHistorySPO2ViewController else {
                return
            }
            self.navigationController?.pushViewController(resultHistoryViewController, animated: true)
            
        case .prakritiResult:
            if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view prakriti history".localized(), controller: self)
                return
            }
            
            let vc = PrakritiResult1VC.instantiate(fromAppStoryboard: .Questionnaire)
            vc.is_FromHistory = true
            vc.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
            
            //let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
            //let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
            //objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
            //objDescription.isFromResultHistory = true
            //self.navigationController?.pushViewController(objDescription, animated: true)
            
        case .suryathonHistory:
            guard let resultHistoryViewController = storyBoard.instantiateViewController(withIdentifier: "ResultHistorySuryathonViewController") as? ResultHistorySuryathonViewController else {
                return
            }
            self.navigationController?.pushViewController(resultHistoryViewController, animated: true)
            
        case .weight:
            guard let resultHistoryViewController = storyBoard.instantiateViewController(withIdentifier: "ResultHistoryWeightViewController") as? ResultHistoryWeightViewController else {
                return
            }
            self.navigationController?.pushViewController(resultHistoryViewController, animated: true)
            
        case .wellnessReport:
            prepareWellnessReport()
            /*
        case .patientHistory:
            self.view.endEditing(true)
            
            if let strPatientID = UserDefaults.standard.object(forKey: kSanaayPatientID) as? String, strPatientID != "" {
                let storyBoard = UIStoryboard(name:"ResultHistory", bundle:nil)
                guard let obj_VC = storyBoard.instantiateViewController(withIdentifier: "PatientHistoryVC") as? PatientHistoryVC else {
                    return
                }
                self.navigationController?.pushViewController(obj_VC, animated: true)
            }
            else {
                if let parent = kSharedAppDelegate.window?.rootViewController {
                    let objDialouge = PatientID_DialogVC(nibName:"PatientID_DialogVC", bundle:nil)
                    objDialouge.delegate = self
                    objDialouge.super_viewVC = self
                    parent.addChild(objDialouge)
                    objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    parent.view.addSubview((objDialouge.view)!)
                    objDialouge.didMove(toParent: parent)
                }
            }
            */
            
        }
        
    }
    
//    func addPatientID_subscription(_ success: Bool, patientID: String) {
//        IQKeyboardManager.shared.enable = false
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
//        if success && patientID != "" {
//            let storyBoard = UIStoryboard(name:"ResultHistory", bundle:nil)
//            guard let obj_VC = storyBoard.instantiateViewController(withIdentifier: "PatientHistoryVC") as? PatientHistoryVC else {
//                return
//            }
//            self.navigationController?.pushViewController(obj_VC, animated: true)
//        }
//    }
}

// MARK: - Wellness report
extension ResultHistoryViewController {
    func prepareWellnessReport() {
        showActivityIndicator()
        getWellnessReportLinkFromServer { (isSuccess, title, message, reportLink) in
            self.hideActivityIndicator()
            if isSuccess {
                if let reportLink = reportLink {
                    print("report link : ", reportLink)
                    self.downloadAndShareWellnessReport(urlString: reportLink)
                } else {
                    self.showAlert(title: APP_NAME, message: "Fail to get wellness report, please try after some time".localized())
                }
            } else {
                self.showAlert(title: title, message: message)
            }
        }
    }
    
    func downloadAndShareWellnessReport(urlString: String) {
        showActivityIndicator()
        downloadWellnessReport(urlString: urlString) { (isSuccess, message, reportURL) in
            self.hideActivityIndicator()
            if isSuccess {
                if let reportURL = reportURL {
                    print("report link : ", reportURL)
                    //self.showWellnessReportShareAlert(reportURL: reportURL)
                    self.viewWellnessReport(reportURL: reportURL)
                } else {
                    self.showAlert(title: APP_NAME, message: "Fail to get wellness report, please try after some time".localized())
                }
            } else {
                self.showAlert(message: message)
            }
        }
    }
    
    func showWellnessReportShareAlert(reportURL: URL) {
        let alert = UIAlertController(title: APP_NAME, message: "Your wellness report is ready to view or share".localized(), preferredStyle: .alert)
        
        let viewBtn = UIAlertAction(title: "View".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.viewWellnessReport(reportURL: reportURL)
        })
        alert.addAction(viewBtn)
        let shareBtn = UIAlertAction(title: "Share".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.shareWellnessReport(reportURL: reportURL)
        })
        alert.addAction(shareBtn)
        let cancelBtn = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(cancelBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewWellnessReport(reportURL: URL) {
        print("View")
        let documentViewer = UIDocumentInteractionController.init(url: reportURL)
        documentViewer.delegate = self
        documentViewer.presentPreview(animated: true)
    }
    
    func shareWellnessReport(reportURL: URL) {
        print("share")
        let shareAll = [ reportURL ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func getWellnessReportLinkFromServer(completion: @escaping (Bool, String, String, String?)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.fetchResultsPDF.rawValue
            var params = ["type": recommendationVikriti.rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            params["type"] = appDelegate.cloud_vikriti_status

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, APP_NAME, "", nil)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let isSuccess = status == "success"
                    let title = status.isEmpty ? APP_NAME : status.capitalizingFirstLetter()
                    let message = dicResponse["message"] as? String ?? ""
                    let reportLink = dicResponse["pdf_url"] as? String
                    completion(isSuccess, title, message, reportLink)
                case .failure(let error):
                    print(error)
                    completion(false, APP_NAME, error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, APP_NAME, NO_NETWORK, nil)
        }
    }
    
    func downloadWellnessReport(urlString: String, completion: @escaping (Bool, String, URL?)->Void) {
        if Utils.isConnectedToNetwork() {
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, options: [.removePreviousFile])

            AF.download(urlString, to: destination).downloadProgress(closure: { (progress) in
                    //progress closure
                }).response(completionHandler: { (response) in
                    //here you able to access the response
                    switch response.result {
                    case .success(let value):
                        print(response)
                        print("Temporary URL: \(response.fileURL)")
                        completion(true, "", response.fileURL)
                    case .failure(let error):
                        print(error)
                        completion(false, error.localizedDescription, nil)
                    }
                })
        } else {
            completion(false, NO_NETWORK, nil)
        }
    }
}

extension ResultHistoryViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}



extension ResultHistoryViewController {
    static func showScreen(fromVC: UIViewController) {
        let vc = ResultHistoryViewController.instantiate(fromAppStoryboard: .ResultHistory)
        fromVC.navigationController?.isNavigationBarHidden = false
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
