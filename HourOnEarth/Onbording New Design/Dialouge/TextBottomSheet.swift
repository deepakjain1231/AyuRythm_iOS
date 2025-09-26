//
//  TextBottomSheet.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TextBottomSheet: UIViewController {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_understood: UILabel!
    
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var constraint_view_Main_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_viewHeader_Bottom: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupText()
        self.constraint_viewHeader_Bottom.constant = -screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    @objc func show_animation() {
        let topsafeArea: CGFloat = appDelegate.window?.safeAreaInsets.top ?? 0
        let screenHeight: CGFloat = screenHeight - topsafeArea - 100
        let scrollContentHeight: CGFloat = self.scrollview.contentSize.height
        if screenHeight < scrollContentHeight {
            self.constraint_view_Main_Height.constant = screenHeight
        }
        else {
            self.constraint_view_Main_Height.constant = scrollContentHeight
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewHeader_Bottom.constant = 0
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ isAction: Bool = false, clickCompleteNow: Bool = false, clickLater: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewHeader_Bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func setupText() {
        self.lbl_understood.text = "I Understood".localized()
        let currentPraktitiStatus = Utils.getYourCurrentPrakritiStatus()
        
        switch currentPraktitiStatus {
        case .TRIDOSHIC:
            self.lbl_Title.text = "You are tridoshic".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["tridoshic_paragraph1".localized(),
                 "tridoshic_paragraph2".localized()], paragraphSpacing: 12)
            
        case .KAPHA_VATA:
            self.lbl_Title.text = "Your predominant dosha is Kapha-Vata".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["kapha_vata_paragraph1".localized(),
                 "kapha_vata_paragraph2".localized()], paragraphSpacing: 12)

        case .PITTA_KAPHA:
            self.lbl_Title.text = "Your predominant dosha is Pitta-Kapha".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["pitta_kapha_paragraph1".localized(),
                 "pitta_kapha_paragraph2".localized(),
                 "pitta_kapha_paragraph3".localized()], paragraphSpacing: 12)

        case .VATA_PITTA:
            self.lbl_Title.text = "Your predominant dosha is Vata-Pitta".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["vata_pitta_paragraph1".localized(),
                 "vata_pitta_paragraph2".localized()], paragraphSpacing: 12)

        case .VATA :
            self.lbl_Title.text = "Your predominant dosha is Vata".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList:
                                   ["vata_paragraph1".localized(),
                                    "vata_paragraph2".localized(),
                                    "vata_paragraph3".localized()], paragraphSpacing: 12)

        case .PITTA:
            self.lbl_Title.text = "Your predominant dosha is Pitta".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList:
                                   ["pitta_paragraph1".localized(),
                                    "pitta_paragraph2".localized()], paragraphSpacing: 12)

        case .KAPHA:
            self.lbl_Title.text = "Your predominant dosha is Kapha".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList:
                                   ["kapha_paragraph1".localized(),
                                    "kapha_paragraph2".localized(),
                                    "kapha_paragraph3".localized()], paragraphSpacing: 12)
        case .KAPHA_PITTA:
            self.lbl_Title.text = "Your predominant dosha is Kapha-Pitta".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["kapha_pitta_paragraph1".localized(),
                 "kapha_pitta_paragraph2".localized(),
                 "kapha_pitta_paragraph3".localized()], paragraphSpacing: 12)
            
        case .PITTA_VATA:
            self.lbl_Title.text = "Your predominant dosha is Pitta-Vata".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["pitta_vata_paragraph1".localized(),
                 "pitta_vata_paragraph2".localized()], paragraphSpacing: 12)
            
        case .VATA_KAPHA:
            self.lbl_Title.text = "Your predominant dosha is Vata-Kapha".localized()
            self.lbl_subTitle.setBulletListedAttributedText(stringList: ["vata_kapha_paragraph1".localized(),
                 "vata_kapha_paragraph2".localized()], paragraphSpacing: 12)
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
    
    @IBAction func btn_close(_ sender: UIButton) {
        self.clkToClose()
    }
    

}
