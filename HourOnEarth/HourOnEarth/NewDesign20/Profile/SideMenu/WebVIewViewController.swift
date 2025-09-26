//
//  WebVIewViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 3/15/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit

enum WebViewType: String {
    case privacyPolicy
    case termsOfUse
    case aboutUs
}

class WebVIewViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var webViewType: WebViewType = .privacyPolicy
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        var urlString = ""
        switch webViewType {
        case .privacyPolicy:
            navigationItem.title = "Privacy Policy".localized()
            urlString = "https://www.ayurythm.com/privacypolicy.html"
        case .termsOfUse:
            navigationItem.title = "Terms & Conditions".localized()
            urlString = "https://www.ayurythm.com/termsandconditions.html"
        case .aboutUs:
            navigationItem.title = "About Us".localized()
            urlString = "https://www.ayurythm.com/"
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        webView.delegate = self
        Utils.startActivityIndicatorInView(self.view, userInteraction: true)
        let request = URLRequest(url: url)
        self.webView.loadRequest(request)
    }

    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        Utils.stopActivityIndicatorinView(self.view)
    }
}

