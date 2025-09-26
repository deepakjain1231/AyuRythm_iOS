//
//  AyuSeedIntroViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 05/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class AyuSeedIntroViewController: UIViewController {
    
    @IBOutlet weak var lblWelcomeTitle1: UILabel!
    @IBOutlet weak var lblWelcomeTitle2: UILabel!
    @IBOutlet weak var lblDoNotShow: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utils.isAppInHindiLanguage {
            let title1Font = lblWelcomeTitle1.font
            let title1Text = lblWelcomeTitle1.text
            lblWelcomeTitle1.font = lblWelcomeTitle2.font
            lblWelcomeTitle1.text = lblWelcomeTitle2.text
            lblWelcomeTitle2.font = title1Font
            lblWelcomeTitle2.text = title1Text
            lblDoNotShow.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        }
    }
    
    //MARK: Button Click Methods
    
    @IBAction func btnDontShowClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        kUserDefaults.set(sender.isSelected, forKey: kDoNotShowAyuSeeds)
    }
    
    @IBAction func btnletsGoClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func btnCloseClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    //MARK: Helper Methods
    
    static func showScreen(from vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "AyuSeeds", bundle: nil)
        guard let introScreen = storyBoard.instantiateViewController(withIdentifier: "AyuSeedIntroViewController") as? AyuSeedIntroViewController else {
            return
        }
        introScreen.modalPresentationStyle = .fullScreen
        
        vc.present(introScreen, animated: true, completion: nil)
    }
}
