//
//  ARDietPrecautionVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARDietPrecautionVC: UIViewController {
    
    @IBOutlet weak var precautionTV: UITextView!
    
    var precautions = [ARDietItemModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Suggestions".localized()
        setBackButtonTitle()
        let cancelBarBtn = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelBtnPressed(_:)))
        self.navigationItem.rightBarButtonItem = cancelBarBtn
        setupUI()
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        precautionTV.superview?.layoutIfNeeded()
    }*/
    
    func setupUI() {
        let precautionStrs = precautions.compactMap{ $0.name }
        precautionTV.attributedText = NSAttributedString.bulletListedAttributedString(stringList: precautionStrs, font: precautionTV.font!, bullet: "•", indentation: 16, lineSpacing: 6, paragraphSpacing: 12, textColor: .black, bulletColor: .black)
    }
    
    @objc func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ARDietPrecautionVC {
    static func showScreen(precautions: [ARDietItemModel], fromVC: UIViewController) {
        let vc = ARDietPrecautionVC.instantiate(fromAppStoryboard: .WellnessPlan)
        vc.precautions = precautions
        let nvc = UINavigationController(rootViewController: vc)
        fromVC.present(nvc, animated: true, completion: nil)
        
        /*let vc = ARDietPrecautionVC.instantiate(fromAppStoryboard: .WellnessPlan)
        vc.precautions = precautions
        let options = SheetOptions(useInlineMode: true)
        let bottomSheet = SheetViewController(controller: vc, options: options)
        fromVC.present(bottomSheet, animated: true, completion: nil)*/
    }
}
