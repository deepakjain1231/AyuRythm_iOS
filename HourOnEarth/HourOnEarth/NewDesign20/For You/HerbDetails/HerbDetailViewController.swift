//
//  HerbDetailViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 20/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class HerbDetailViewController: BaseViewController {
    
    @IBOutlet weak var herbImageV: UIImageView!
    @IBOutlet weak var herbNameL: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var benefitsWebView: WKWebView!
    @IBOutlet weak var webviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var herbDetail: Herb?
    var favHerbDetail: FavouriteHerb?
    private var observation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let herbDetail = herbDetail {
            setupUI(name: herbDetail.herbs_name, image: herbDetail.vertical_image, star: herbDetail.star, details: herbDetail.benefits)
        } else if let herbDetail = favHerbDetail {
            setupUI(name: herbDetail.herbs_name, image: herbDetail.vertical_image, star: herbDetail.star, details: herbDetail.benefits)
        }
        
        activityIndicator.startAnimating()
        //benefitsWebView.scrollView.isScrollEnabled = false
        observation = benefitsWebView.observe(\WKWebView.estimatedProgress, options: .new) { [weak self] _, change in
            guard let strongSelf = self else { return }
            //print("Loaded: \(change)")
            if strongSelf.benefitsWebView.estimatedProgress == 1 {
                strongSelf.activityIndicator.stopAnimating()
                //let contentSize = strongSelf.benefitsWebView.scrollView.contentSize
                //print("benefitsWebView after loading : ", contentSize)
                
                //strongSelf.webviewHeightConstraint.constant = strongSelf.benefitsWebView.scrollView.contentSize.height
//                DispatchQueue.main.async {
//                    strongSelf.webviewHeightConstraint.constant = contentSize.height
//                }
            }
        }
    }
    
    func setupUI(name: String?, image: String?, star: String?, details: String?) {
        if let urlStr = image, let url = URL(string: urlStr) {
            herbImageV.af.setImage(withURL: url)
        }
        herbNameL.text = name
        favBtn.isSelected = !(star == "no")
        //let htmlStr = "<html><body>\(herbDetail.benefits ?? "")</body></html>"
        let fontSize = 34
        let htmlStr = """
                    <!DOCTYPE html>
                    <style>
                        body{
                            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                            font-size: \(fontSize)px
                        }
                    </style>
                    <html>
                        <body>
                            \(details ?? "")
                        </body>
                    </html>
                    """
        benefitsWebView.loadHTMLString(htmlStr, baseURL: nil)
    }
    
    @IBAction func closeBtnPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareBtnPressed(sender: UIButton) {
        
        let herbName = herbDetail?.herbs_name ?? (favHerbDetail?.herbs_name ?? "")
        let text = String(format: "I just found a useful herb - %@ on AyuRythm app.".localized(), herbName) + Utils.shareDownloadString
        
        let shareAll = [ text ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func favBtnPressed(sender: UIButton) {
        guard let herbDetail = herbDetail else { return }
        
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        if sender.isSelected {
            //Remove
            deleteFavOnServer(params: ["favourite_type_id": herbDetail.id, "favourite_type": "herbs" ]) {
                Utils.stopActivityIndicatorinView(self.view)
            }
        } else {
            //add
            updateFavOnServer(params: ["favourite_type_id": herbDetail.id, "favourite_type": "herbs" ]) {
                Utils.stopActivityIndicatorinView(self.view)
            }
        }
    }
    
    deinit {
        self.observation = nil
    }
}

extension HerbDetailViewController {
    func updateFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.saveFourite.rawValue
            
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Added".localized(), message: "Successfully added to your favourite list.".localized(), controller: self)
                    self.favBtn.isSelected = true
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            completion()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func deleteFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.deleteFourite.rawValue
            
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Removed".localized(), message: "Successfully removed from your favourite list.".localized(), controller: self)
                    self.favBtn.isSelected = false
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            completion()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}
