//
//  ARContentLibraryFeedPostVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 08/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARContentLibraryFeedPostVC: UIViewController {
    
    @IBOutlet weak var image1IV: UIImageView!
    @IBOutlet weak var image2IV: UIImageView!
    @IBOutlet weak var listNameTF: UITextField!
    @IBOutlet weak var descTV: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "Creare a post".localized()
        setBackButtonTitle()
        
        listNameTF.setLeftPaddingPoints(16)
        descTV.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        descTV.placeholder = "What's on your mind? Write here...".localized()
        
        let contents = ARContentLibraryManager.shared.selectedContents
        if let firstContent = contents.first {
            image1IV.af_setImage(withURLString: firstContent.image)
        }
        if let secondContent = contents[safe: 1] {
            image2IV.af_setImage(withURLString: secondContent.image)
        } else {
            image2IV.isHidden = true
        }
    }
    
    @IBAction func postBtnPressed(sender: UIButton) {
    }
}

extension ARContentLibraryFeedPostVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = ARContentLibraryFeedPostVC.instantiate(fromAppStoryboard: .Ayuverse)
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
