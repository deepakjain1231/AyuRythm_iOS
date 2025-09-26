//
//  PrakritiQuestionIntroVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 14/08/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class PrakritiQuestionIntroVC: BaseViewController {

    var isTryAsGuest = false
    var isFromOnBoarding = false
    var arrAllQuestions:[[String: Any]] = [[String: Any]]()
    
    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var img_Intro: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.img_Intro.image = UIImage.gifImageWithName("prakriti_question_loader")
        self.lbl_Text.text = "Please consider your childhood while answering these questions".localized()
        self.getQuestionsFromServer()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PrakritiQuestionIntroVC {
    func getQuestionsFromServer () {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.v2.getprakrutiquestionswithoptions.rawValue
            let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { [weak self] response in
                guard let `self` = self else {
                    return
                }
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrQuestions = (value as? [[String: Any]]) else {
                        return
                    }
                    let sortedQuestions = arrQuestions.sorted(by: { (dic1, dic2) -> Bool in
                        let questionID1 = Int((dic1["id"] as? String ?? "0")) ?? 0
                        let questionID2 = Int((dic2["id"] as? String ?? "0")) ?? 0
                        return questionID1 < questionID2
                    })
                    self.arrAllQuestions = sortedQuestions
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        self.goToQuestionnaireVC()
                    }
                    
//                    if !self.arrAllQuestions.isEmpty {
//                        self.updateData()
//                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: error.localizedDescription, okTitle: "Ok".localized(), controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: NO_NETWORK, okTitle: "Ok".localized(), controller: self) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension PrakritiQuestionIntroVC {
    
    func goToQuestionnaireVC() {
        let vc = Prakriti30QuestionnaireVC.instantiate(fromAppStoryboard: .Questionnaire)
        vc.isTryAsGuest = kSharedAppDelegate.userId.isEmpty
        vc.isFromOnBoarding = isFromOnBoarding
        vc.arrAllQuestions = self.arrAllQuestions
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func showScreen(isFromOnBoarding: Bool = false, fromVC: UIViewController) {
        //New design
        let vc = PrakritiQuestionIntroVC.instantiate(fromAppStoryboard: .Questionnaire)
        vc.isTryAsGuest = kSharedAppDelegate.userId.isEmpty
        vc.isFromOnBoarding = isFromOnBoarding
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
