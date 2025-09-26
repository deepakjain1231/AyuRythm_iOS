//
//  ARAyuVerseWelcomeVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 05/08/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

protocol delegateTeremSelection {
    func terms_condition_selection(_ success: Bool)
}

class ARAyuVerseWelcomeVC: UIViewController, delegateRulesAccepted {

    var str_Rules = ""
    var rulesSelection = false
    var delegate: delegateTeremSelection?
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_Close: UIButton!
    @IBOutlet weak var btn_letsGo: UIControl!
    @IBOutlet weak var img_chceck: UIImageView!
    @IBOutlet weak var lbl_agreeRules: UILabel!
    
    @IBOutlet weak var lbl_title1: UILabel!
    @IBOutlet weak var lbl_title2: UILabel!
    @IBOutlet weak var lbl_title3: UILabel!
    
    @IBOutlet weak var lbl_subTitle1: UILabel!
    @IBOutlet weak var lbl_subTitle2: UILabel!
    @IBOutlet weak var lbl_subTitle3: UILabel!
    
    @IBOutlet weak var lbl_buttonText: UILabel!
    @IBOutlet weak var lbl_bottomText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.callAPIforGetRules()
        self.setTitleText()
        self.setRulesText()
        self.setupLabel1Text()
        self.setupLabel2Text()
        self.setupLabel3Text()
        self.btn_letsGo.backgroundColor = .lightGray
        self.img_chceck.setImageColor(color: UIColor.init(named: "Ayuverse_PurpleColor") ?? .purple)
    }
    
    func setTitleText() {
        let strtext = "Welcome to\nAyuVerse".localized()
        let newText = NSMutableAttributedString.init(string: strtext)

        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: strtext)
        let highlight_range = textRange.range(of: "AyuVerse")

        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 30), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(named: "Ayuverse_PurpleColor") ?? .purple, range: highlight_range)

        self.lbl_Title.attributedText = newText
        
        
        self.lbl_title1.text = "Create".localized()
        self.lbl_title2.text = "Connect".localized()
        self.lbl_title3.text = "Discover".localized()
        self.lbl_bottomText.text = "So what are you waiting for? Come join us in our Ayurveda community!".localized()
        self.lbl_buttonText.text = "Let’s Go!".localized()
      
    }
    
    func setRulesText() {
        let strtext = "I agree to the rules stated".localized()
        let newText = NSMutableAttributedString.init(string: strtext)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center
        
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: strtext)
        let highlight_range = textRange.range(of: "rules".localized())

        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.blue, range: highlight_range)

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        self.lbl_agreeRules.attributedText = newText
    }
    
    func setupLabel1Text() {
        let strtext = "Share your wellness\nexperiences with like\nminded people.".localized()
        let newText = NSMutableAttributedString.init(string: strtext)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        paragraphStyle.alignment = .left

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        self.lbl_subTitle1.attributedText = newText
    }
    
    func setupLabel2Text() {
        let strtext = "Engage with people\ninterested in ayurvedic\nwellness".localized()
        let newText = NSMutableAttributedString.init(string: strtext)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        paragraphStyle.alignment = .left

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        self.lbl_subTitle2.attributedText = newText
    }
    
    func setupLabel3Text() {
        let strtext = "Explore ayurvedic wellness\ncontent by experts and\nwellness enthusiasts.".localized()
        let newText = NSMutableAttributedString.init(string: strtext)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        paragraphStyle.alignment = .left

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        self.lbl_subTitle3.attributedText = newText
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - UIButton Action
    @IBAction func btnRules_Action(_ sender: UIControl) {
        let objDialouge = ARAyuVerseRulesVC.instantiate(fromAppStoryboard: .Ayuverse)
        objDialouge.delegate = self
        objDialouge.str_Rules = self.str_Rules
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    @IBAction func btnRulesTick_Action(_ sender: UIControl) {
        if self.rulesSelection {
            self.rulesSelection = false
            self.btn_letsGo.backgroundColor = .lightGray
            self.img_chceck.image = UIImage.init(named: "check_box_unselected")
            self.img_chceck.setImageColor(color: UIColor.init(named: "Ayuverse_PurpleColor") ?? .purple)
        }
        else {
            self.rulesSelection = true
            self.img_chceck.image = UIImage.init(named: "icon_rules_selected")
            self.btn_letsGo.backgroundColor = UIColor.init(named: "Ayuverse_PurpleColor") ?? .purple
        }
    }
    
    @IBAction func btnLetsGo_Action(_ sender: UIControl) {
        if self.rulesSelection {
            UserDefaults.standard.set(true, forKey: "Welcome_AyuVerse")
            UserDefaults.standard.synchronize()
            self.dismiss(animated: true) {
                self.delegate?.terms_condition_selection(true)
            }
        }
    }
    
    @IBAction func btnClose_Action(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
    
    
    
    //MARK: - Rules Accepted and Continue
    func rulesAcceptedAndContinue(_ success: Bool) {
        if success {
            self.rulesSelection = true
            self.img_chceck.image = UIImage.init(named: "icon_rules_selected")
            self.btn_letsGo.backgroundColor = UIColor.init(named: "Ayuverse_PurpleColor") ?? .purple
            

            UserDefaults.standard.set(true, forKey: "Welcome_AyuVerse")
            UserDefaults.standard.synchronize()
            self.dismiss(animated: true) {
                self.delegate?.terms_condition_selection(true)
            }
        }
    }
}


//MARK: - API Call
extension ARAyuVerseWelcomeVC {
    
    func callAPIforGetRules(){
        let params = ["language_id" : Utils.getLanguageId()]
                      
        Utils.doAyuVerseAPICall(endPoint: .fetchGroupRules, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let groupRules = try? JSONDecoder().decode(GroupRules.self, from: responseJSON.rawData())
                if groupRules?.status == "success"{
                    var rules = ""
                    for rule in groupRules!.data!{
                        rules = rules + String(rule.number ?? 0) + ". " + (rule.rule ?? "") + "\n\n"
                    }
                    self?.str_Rules = rules
                }
            }
        }
    }
}
