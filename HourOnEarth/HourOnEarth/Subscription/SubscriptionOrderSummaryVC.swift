//
//  SubscriptionOrderSummaryVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class SubscriptionOrderSummaryVC: UIViewController {
    
    @IBOutlet weak var welcomeMsgTitleL: UILabel!
    
    @IBOutlet weak var orderDetailsL: UILabel!
    @IBOutlet weak var orderIDL: UILabel!
    @IBOutlet weak var packTypeL: UILabel!
    @IBOutlet weak var startDateL: UILabel!
    @IBOutlet weak var expiryDateL: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    
    @IBOutlet weak var paymentDetailsL: UILabel!
    @IBOutlet weak var paymentDateL: UILabel!
    @IBOutlet weak var subtotalL: UILabel!
    @IBOutlet weak var taxesL: UILabel!
    @IBOutlet weak var amountPaidL: UILabel!
    
    var screen_from = ScreenType.k_none
    var plan: ARSubscriptionPlanModel?
    var orderDetails: ARSubsOrderDetailModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeMsgTitleL.text = "Welcome aboard".localized() + " " + Utils.getLoginUserUsername().capitalized
        orderDetailsL.attributedText = NSAttributedString(string: "Order Details".localized()).underlined
        paymentDetailsL.attributedText = NSAttributedString(string: "Payment Details".localized()).underlined
        if self.screen_from == .fromFaceNaadi {
            self.lbl_subTitle.text = "Congratulations! Your subscription unlocks the empowering world of FaceNaadi assessment. Welcome to a healthier, happier you!".localized()
        }
        else if self.screen_from == .from_finger_assessment {
            self.lbl_subTitle.text = "Congratulations! Get ready to elevate your well-being journey with our Pulse Assessment feature. Thank you for choosing a healthier and happier you!".localized()
        }
        else if self.screen_from == .from_AyuMonk_Only {
            self.lbl_subTitle.text = "Congratulations! Welcome to a healthier and more balanced lifestyle with AyuMonk, your wellness companion.".localized()
        }
        else if self.screen_from == .from_home_remedies {
            self.lbl_subTitle.text = "Congratulations! Your subscription unlocks a world of personalized Home Remedies. Enjoy a healthier, happier lifestyle!".localized()
        }
        else if self.screen_from == .from_dietplan {
            self.lbl_subTitle.text = "Congratulations! Your subscription unlocks the curated diet plan. Welcome to a healthier, happier you!".localized()
        }
        setupUI()
    }
    
    func setupUI() {
        guard let orderDetails = orderDetails, let plan = plan else { return print("order details or plan not found") }
        orderIDL.text = orderDetails.orderDetails?.receiptId ?? ""
        packTypeL.text = plan.packName
        startDateL.text = orderDetails.orderDetails?.startDate.UTCToLocal(incomingFormat: App.dateFormat.serverSendDateTime, outGoingFormat: App.dateFormat.subscriptionSummeryDate)
        expiryDateL.text = orderDetails.orderDetails?.expiredDate.UTCToLocal(incomingFormat: App.dateFormat.serverSendDateTime, outGoingFormat: App.dateFormat.subscriptionSummeryDate)
        paymentDateL.text = orderDetails.paymentInfo?.paymentDate.UTCToLocal(incomingFormat: App.dateFormat.serverSendDateTime, outGoingFormat: App.dateFormat.subscriptionSummeryDate)
        subtotalL.text = orderDetails.paymentInfo?.amount.priceValueString
        taxesL.text = orderDetails.paymentInfo?.taxAmount.priceValueString
        amountPaidL.text = orderDetails.paymentInfo?.totalAmount.priceValueString
    }
    
    @IBAction func getStartedBtnPressed(sender: UIButton) {
        NotificationCenter.default.post(name: .refreshActiveSubscriptionData, object: ["isFromOrderSummeryScreen": true])
        if self.screen_from == .fromFaceNaadi ||
            self.screen_from == .from_AyuMonk_Only ||
            self.screen_from == .from_home_remedies ||
            self.screen_from == .from_finger_assessment {
            appDelegate.facenaadi_subscriptionDone = true
        }
        else if self.screen_from == .from_dietplan {
            appDelegate.is_start_dietPlan = true
            appDelegate.facenaadi_subscriptionDone = true
        }
        else {
            appDelegate.sparshanAssessmentDone = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadBtnPressed(sender: UIButton) {
        viewPurchaseReceipt()
    }
}

extension SubscriptionOrderSummaryVC: UIDocumentInteractionControllerDelegate {
    func viewPurchaseReceipt() {
        guard let urlStr = orderDetails?.invoiceLink else {
            print("??? no invoice link found")
            return
        }
        
        showActivityIndicator()
        Self.downloadFile(urlString: urlStr) { (isSuccess, message, fileURL) in
            self.hideActivityIndicator()
            if isSuccess {
                if let fileURL = fileURL {
                    print("fileURL link : ", fileURL)
                    //self.showWellnessReportShareAlert(reportURL: reportURL)
                    self.viewFile(fileURL: fileURL)
                } else {
                    self.showAlert(title: APP_NAME, message: "Fail to download receipt, please try after some time".localized())
                }
            } else {
                self.showAlert(message: message)
            }
        }
    }
    
    func viewFile(fileURL: URL) {
        print("View")
        let documentViewer = UIDocumentInteractionController.init(url: fileURL)
        documentViewer.delegate = self
        documentViewer.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    static func downloadFile(urlString: String, completion: @escaping (Bool, String, URL?)->Void) {
        if Utils.isConnectedToNetwork() {
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, options: [.removePreviousFile])

            AF.download(urlString, to: destination).downloadProgress(closure: { (progress) in
                    //progress closure
                }).response(completionHandler: { (response) in
                    //here you able to access the response
                    switch response.result {
                    case .success(_):
                        //print(response)
                        //print("Temporary URL: \(response.fileURL)")
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
