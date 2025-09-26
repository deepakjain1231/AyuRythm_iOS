//
//  MPOrderConfirmedVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPOrderConfirmedVC: UIViewController {

    var highlightText = "Order tracking"
    var strSubTitleText = "Thank you for your order. You will receive email confirmation shortly."//\n\n\nCheck the status of your order\non the Order tracking page."
    @IBOutlet weak var btn_NO: UIControl!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var view_RateExperience: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Order Confirmed"
        let newBackButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.done, target: self, action: nil)// #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton

        self.btn_NO.layer.borderWidth = 1
        self.view_RateExperience.layer.borderWidth = 1
        self.btn_NO.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
        self.view_RateExperience.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
        
        self.lbl_subTitle.text = strSubTitleText
        
        self.setupText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MPCartManager.removeCartData()
        NotificationCenter.default.post(name: .refreshProductData, object: nil)
        NotificationCenter.default.post(name: Notification.Name("productAddedToCart"), object: nil)
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.back(sender:)))
    }
    
    @objc func back(sender: UIBarButtonItem) {
        redirectToViewController()
    }
    
    @IBAction func btn_Continue_Shopping_Action(_ sender: UIControl) {
        redirectToViewController()
    }
    
    func redirectToViewController() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MPHomeVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

//MARK: - Set Up label

extension MPOrderConfirmedVC {
    func setupText() {
        
        let newText = NSMutableAttributedString.init(string: strSubTitleText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange.init(location: 0, length: newText.length))
        
        let textRange = NSString(string: strSubTitleText)
        let highlightTextrange = textRange.range(of: highlightText)
        
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: highlightTextrange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#007AFF"), range: highlightTextrange)
        
        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))

        self.lbl_subTitle.attributedText = newText

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(TapResponce(_:)))
        self.lbl_subTitle.isUserInteractionEnabled = true
        self.lbl_subTitle.addGestureRecognizer(tapGesture)
    }
    
           
    @objc func TapResponce(_ sender: UITapGestureRecognizer) {
        let highlightTextrange = (strSubTitleText as NSString).range(of: highlightText)
        
        if (sender.didTapAttributedTextInLabel(label: self.lbl_subTitle, inRange: highlightTextrange)) {
            let vc = MPMyOrderVC.instantiate(fromAppStoryboard: .MarketPlace)
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    @IBAction func btn_OrderTracking_Action(_ sender: UIControl) {
        let vc = MPMyOrderVC.instantiate(fromAppStoryboard: .MarketPlace)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
