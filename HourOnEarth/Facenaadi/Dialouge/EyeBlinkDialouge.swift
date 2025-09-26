//
//  EyeBlinkDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 16/03/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

protocol didTappedBeginFaceNaadi {
    func didTappedStart_facenaadi(_ success: Bool)
}

import UIKit

class EyeBlinkDialouge: UIViewController {

    var delegate: didTappedBeginFaceNaadi?

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var view_Inner_Top: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
        
    func setup() {
        self.lbl_title.text = "Blink Eyes to Begin Test!".localized()
        self.lbl_subtitle.text = "To start the test, just blink your eyes. The assessment begins automatically upon detecting your blink.".localized()
        self.view_Inner_Top.roundCornerss([UIRectCorner.topLeft, .topRight], radius: 20)
    }
        
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
        
    func clkToClose() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.delegate?.didTappedStart_facenaadi(true)
        }
    }
        
        
        
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.clkToClose()
    }
}
