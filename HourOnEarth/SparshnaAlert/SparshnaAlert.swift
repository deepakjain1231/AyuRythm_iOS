//
//  SparshnaAlert.swift
//  HourOnEarth
//
//  Created by Pradeep on 11/28/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class SparshnaAlert: UIViewController {

    var is_facenaadi = false
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewBoundry: UIView!
    @IBOutlet weak var viewBlackBoundry: UIView!
    @IBOutlet weak var txtView: UITextView!

    var completionHandler: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgView.image = UIImage.gifImageWithName("sparshna")
        viewBoundry.layer.cornerRadius = 10.0
        viewBoundry.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SparshnaAlert.dismissClicked))
        tapGesture.numberOfTapsRequired = 1
        self.viewBlackBoundry.addGestureRecognizer(tapGesture)
        
        if self.is_facenaadi {
            txtView.text = "Start by taking selfie video for 30 seconds of your face\n\nEnsure you are in a brightly lit area.\n\nScreen brightness will increase during the test.".localized()
        }
        else {
            txtView.text = "We will be measuring your blood flow.\n\nPlace your finger/palm on the back camera of your phone, covering the flash,\nand then press continue.\n\nEnsure you are in a brightly lit area\nbefore starting the test\n\nThe screen will turn red when finger/palm is placed correctly".localized()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.txtView.flashScrollIndicators()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func alertOkClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionHandler?()
        }
    }
    
    @objc func dismissClicked() {
        self.dismiss(animated: true) {
        }
    }

    @IBAction func alertCancelClicled(_ sender: Any) {
     self.dismiss(animated: true)
    }
}
