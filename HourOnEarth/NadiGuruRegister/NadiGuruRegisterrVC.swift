//
//  NadiGuruRegisterrVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 28/04/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class NadiGuruRegisterrVC: UIViewController {

    @IBOutlet weak var btn_fixDetail: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Register now"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btn_fillDetail_Action(_ sender: UIControl) {
        let vc = NadiGuruFillDetailsVC.instantiate(fromAppStoryboard: .NadiGuru)
        vc.title = "Fill details"
        self.navigationController?.pushViewController(vc, animated: true)
    }

}


extension NadiGuruRegisterrVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = NadiGuruRegisterrVC.instantiate(fromAppStoryboard: .NadiGuru)
        vc.title = "Register now"
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
