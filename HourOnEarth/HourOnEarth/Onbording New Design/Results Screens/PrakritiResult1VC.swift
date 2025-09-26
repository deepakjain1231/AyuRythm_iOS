//
//  PrakritiResult1VC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 22/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PrakritiResult1VC: UIViewController {

    var kpvDescription = ""
    var yourIdealState = ""
    var strAggrivation = ""
    var str_KaphaPercentage = ""
    var str_PittaPercentage = ""
    var str_VataPercentage = ""
    var is_FromHistory = false
    
    var arr_Section = [[String: Any]]()
    var isRegisteredUser = true
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tbl_view: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_title.text = "YOUR RESULTS".localized().capitalized
        self.tbl_view.register(nibWithCellClass: CurrentBalanceTableCell.self)
        self.tbl_view.register(nibWithCellClass: SideMenuButtonTableCell.self)
        self.tbl_view.register(nibWithCellClass: PrakritiResultTableCell.self)
        self.tbl_view.register(nibWithCellClass: HomeScreenNoSparshnaTableCell.self)
        self.manageSection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func backAction() {
        var is_screenRedirect = false
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                is_screenRedirect = true
                (activeSubVC as! MyHomeViewController).exceptFirstTime = true
                appDelegate.sparshanAssessmentDone = true
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
        
        if is_screenRedirect == false {
            kSharedAppDelegate.showHomeScreen()
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        if self.is_FromHistory {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.backAction()
        }
    }
    
    @IBAction func btn_Share_Action(_ sender: UIButton) {
        var details = "Your Ideal State".localized()
        details.append(":\n")
        details.append(yourIdealState)
        details.append("\n\n" + "What does this mean?".localized())
        details.append("\n" + kpvDescription)
        
        //print("--->>> \(details)")
        
        let text = "\(details) \n\n" + "I just did assessment to find my Prakriti (Ideal wellness state) on AyuRythm app.".localized() + Utils.shareDownloadString
        
        let shareAll = [ text ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func configureUIforVikratiOnly() {
        
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        if let strSprashna = kUserDefaults.value(forKey: VIKRITI_SPARSHNA) as? String {
            let arrSprashnaScore:[String] = strSprashna.components(separatedBy: ",")
            if  arrSprashnaScore.count == 3 {
                kaphaCount += Double(arrSprashnaScore[0]) ?? 0
                pittaCount += Double(arrSprashnaScore[1]) ?? 0
                vataCount += Double(arrSprashnaScore[2]) ?? 0
            } else {
                return
            }
        } else {
            return
        }
        
        let total = kaphaCount + pittaCount + vataCount
        
        let percentKapha = kaphaCount.rounded(.up)
        let percentPitta =  pittaCount.rounded(.up)
        let percentVata = (100 - (percentKapha + percentPitta))
        
        var getKPVIndx = 0
        let arr_StrKPV = ["kapha", "pitta", "vata"]
        let arr_KPV = [percentKapha, percentPitta, percentVata]
        if let kpvMax = arr_KPV.max() {
            getKPVIndx = arr_KPV.firstIndex(of: kpvMax) ?? 0
        }
        self.strAggrivation = arr_StrKPV[getKPVIndx]
        
        print("percentKapha=",percentKapha)
        print("percentPitta=",percentPitta)
        print("percentVata=",percentVata)

        self.str_KaphaPercentage = "\(Int(percentKapha))%"
        self.str_PittaPercentage = "\(Int(percentPitta))%"
        self.str_VataPercentage = "\(Int(percentVata))%"
    }

    
    func configureUI() {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0]) ?? 0
                pittaCount += Double(arrPrashnaScore[1]) ?? 0
                vataCount += Double(arrPrashnaScore[2]) ?? 0
            } else {
                return
            }
        } else {
            return
        }
        
        let total = kaphaCount + pittaCount + vataCount
        
        let percentKapha = round(kaphaCount*100.0/total)
        let percentPitta =  round(pittaCount*100.0/total)
        let percentVata =  round(vataCount*100.0/total)
        print("percentKapha=",percentKapha)
        print("percentPitta=",percentPitta)
        print("percentVata=",percentVata)

        self.str_KaphaPercentage = "\(Int(percentKapha))%"
        self.str_PittaPercentage = "\(Int(percentPitta))%"
        self.str_VataPercentage = "\(Int(percentVata))%"

        let currentPraktitiStatus = Utils.getYourCurrentPrakritiStatus()
        
        switch currentPraktitiStatus {
        case .TRIDOSHIC:
            self.strAggrivation = "tridoshic".localized()
            yourIdealState = String(format: "predominant_tridoshic".localized(), "tridoshic".localized())
            kpvDescription = "Although quite rare, some individuals have all 3 doshas in more or less equal strengths. They are categorized as tridoshic or Vata-Pitta-Kapha type individuals. With this naturally balanced Prakriti or dosha type, they are more likely to find a harmonious balance in life and can be meditative, fit, healthy, and emotionally stable.\n\nThis balance characterizes almost every aspect of life. Tridoshic individuals tend to be of a medium build and frame, with a pleasant disposition and sharp minds that can still find mental peace. The only scenario in which problems arise is when such individuals go against their basic nature throwing their doshas out of balance. Disorders that are associated with the aggravated dosha then begin to surface. For example, aggravation of Vata can give rise to problems like digestive and sleep disorders, while aggravation of Kapha could cause problems with excess body weight and depression.".localized()
        case .KAPHA_VATA:
            updateUIForKaphaVata()
        case .PITTA_KAPHA:
            updateUIForPittaKapha()
        case .VATA_PITTA:
            updateUIForVataPitta()
        case .VATA :
            updateUIForVata()
        case .PITTA:
            updateUIForPitta()
        case .KAPHA:
            updateUIForKapha()
        case .KAPHA_PITTA:
            updateUIForKaphaPitta()
        case .PITTA_VATA:
            updateUIForPittaVata()
        case .VATA_KAPHA:
            updateUIForVataKapha()
        }
    }
    
    func updateUIForKaphaPitta() {
        self.strAggrivation = "Kapha-Pitta".localized()
        yourIdealState = String(format: "predominant_dosha_Kapha-Pitta".localized(), "Kapha-Pitta".localized())
        kpvDescription = "Kapha-Pitta prescription_Text".localized()
    }
    
    func updateUIForPittaKapha() {
        self.strAggrivation = "Pitta-Kapha".localized()
        yourIdealState = String(format: "predominant_dosha_Pitta-Kapha".localized(), "Pitta-Kapha".localized())
        kpvDescription = "Pitta-Kapha type individuals have both Pitta and Kapha doshas in close to equal strength. These individuals have strong willpower and are more focused, with a clear goal-oriented nature. At the same time, they tend to be balanced with a somewhat relaxed nature.\nPhysically, Pitta-Kapha type individuals have a rather stocky or robust frame and they also enjoy relatively good health if they keep their doshas in balance. In balanced individuals, the fiery energy of pitta is kept grounded and balanced by Kapha. This means that individuals in this dosha type are less likely to experience digestive health problems early in life, as they have the perfect strength of Agni or digestive fire. Unfortunately, many tend to take this for granted and abuse their good fortune, leaning towards unhealthy lifestyles, overeating and under-exercising. As a result, problems with obesity and associated health risks may surface.\nPitta-Kapha types although generally healthy, may also be vulnerable to skin diseases and body odour problems that result from heavy perspiration.".localized()
    }
    
    func updateUIForPittaVata() {
        self.strAggrivation = "Pitta-Vata".localized()
        yourIdealState = String(format: "predominant_dosha_Pitta-Vata".localized(), "Pitta-Vata".localized())
        kpvDescription = "Pitta-Vata precription_Text".localized()
    }
    
    
    
    func updateUIForVataPitta() {
        self.strAggrivation = "Vata-Pitta".localized()
        yourIdealState = String(format: "predominant_dosha_Vata-Pitta".localized(), "Vata-Pitta".localized())
        kpvDescription = "Vata-Pitta combination type individuals have both Vata and Pitta dosha in a closely matching strength. Individuals of this dosha type require a combination approach to managing their health. They are generally creative, but can also be impulsive and conflicted within. As a result, they often put themselves under excessive pressure, which can lead to disappointment and burnout.\n\nPhysically, Vata-Pitta type individuals have a medium stature and are usually quite agile. Their dosha combination can create some specific health concerns as the quality of Vata for movement can exacerbate or accentuate the qualities of Pitta. This makes individuals more vulnerable to digestive disorders at varying ends of the spectrum, from constipation to diarrhoea, indigestion and heartburn to inflammatory disorders and peptic ulcers. They are also more likely to be afflicted with aches and pains, sleep disorders, emotional outbursts, skin irritation, and so on. A Vata-Pitta balancing routine is therefore vital to maintaining good health and wellbeing.".localized()
    }
    
    func updateUIForKaphaVata() {
        self.strAggrivation = "Kapha-Vata".localized()
        yourIdealState = String(format: "predominant_dosha_Kapha-Vata".localized(), "Kapha-Vata".localized())
        kpvDescription = "The Kapha-Vata combination type is perhaps the most interesting because of the opposing nature of the 2 doshas that are in predominance – Kapha and Vata. While Kapha dosha gives rise to a desire for stability, order, and routine, Vata triggers more creative pursuits and a more enthusiastic and chaotic approach to life. This strange combination can give rise to serious internal conflicts, leading to plenty of frustration at times.\n\nPhysically, individuals in the Kapha-Vata category can show significant variation being either small or delicately built, tall and slender, or more athletic and with a bigger frame. Kapha-Vata individuals also have greater vulnerability to a number of health conditions, including poor digestion with problems like bloating and constipation. Kapha-Vata individuals also have conflicting emotions, alternating between being laidback and anxious, as well as sleeping excessively or poorly. They also have a higher risk of stone formation, loss of focus, depression, and other disorders. This makes balancing dosha levels critical, as this is essential to mitigate the risk of poor health.".localized()
    }
    
    func updateUIForVataKapha() {
        self.strAggrivation = "Vata-Kapha".localized()
        yourIdealState = String(format: "predominant_dosha_Vata-Kapha".localized(), "Vata-Kapha".localized())
        kpvDescription = "Vata-Kapha Precription Text".localized()
    }
    
    func updateUIForKapha() {
        self.strAggrivation = "Kapha".localized()
        yourIdealState = String(format: "predominant_dosha_Kapha".localized(), "Kapha".localized())
        kpvDescription = "Kapha type individuals are usually calm and composed, with great potential for multi-tasking. They are usually more disciplined and often have higher levels of empathy and patience. They have a natural proclivity for routine and order.\n\nPhysically, individuals with a Kapha constitution are more likely to be well built, with large attractive eyes. They are more likely to be endowed with smooth skin, a clear complexion, and beautiful lips. Unfortunately, Kapha types are vulnerable to overeating and sedentary patterns, as well as oversleeping. This can make it quite a struggle to maintain a healthy body weight and stay in shape.\n\nFailing to balance Kapha levels can exacerbate unhealthy behaviours, increasing the risk for depression and metabolic syndrome disorders like obesity, heart disease, and diabetes.".localized()
    }
    
    func updateUIForPitta() {
        self.strAggrivation = "Pitta".localized()
        yourIdealState = String(format: "predominant_dosha_Pitta".localized(), "Pitta".localized())
        kpvDescription = "Pitta individuals tend to have greater mental clarity, focus, and retention. Pitta type individuals are highly competitive and enjoy outdoor activities. Physically, pitta type individuals tend to be of average stature, but of a more stocky or muscular build. They are also likely to have medium-sized eyes with a more penetrating gaze.\n\nBalancing pitta levels is vital for their wellbeing as pitta individuals are vulnerable to intense bouts of anger, especially when hungry, and they are also more likely to feel stressed and suffer from sleep disorders. Imbalances in dosha levels will make pitta type people more susceptible to inflammatory conditions like gastritis, peptic or intestinal ulcers, as well as inflammatory skin conditions like eczema.".localized()
    }
    
    func updateUIForVata() {
        self.strAggrivation = "Vata".localized()
        yourIdealState = String(format: "predominant_dosha_Vata".localized(), "Vata".localized())
        kpvDescription = "Vata individuals generally have a light and creative disposition, with high levels of enthusiasm. Such individuals are also likely to be more active but may be easily distracted or forgetful.\n\nVata individuals also tend to share certain physical traits, usually falling into ends of the spectrum, being either small statured or large. They are also likely to be of a more slender build, with small, but sharp eyes. Warmer and sunnier climates are more attractive to Vata individuals as they are more prone to circulatory disorders.\n\nDosha imbalances in someone with a Vata constitution will increase vulnerability to specific types of health conditions like anxiety, sleep disorders, arthritis, and joint disease.".localized()
    }
}


//MARK: UITableView Delegates and Datasource Method

extension PrakritiResult1VC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.removeAll()
        
        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
            self.configureUIforVikratiOnly()
            
            self.arr_Section.append(["id" : "current_balance", "text": "Your Mind, Body, and Metabolism ratios are as unique as you are!".localized(), "title": "Your current balance".localized()])
            
            self.arr_Section.append(["id" : "add_questionnaire", "text": "", "title": ""])
            self.arr_Section.append(["id" : "button", "text": "", "title": "SKIP".localized().capitalized])
        }
        else {
            self.configureUI()
            self.arr_Section.append(["id" : "current_balance", "text": "", "title": "Your ideal balance".localized()])
           
            self.arr_Section.append(["id" : "perdominant", "text": "", "title": ""])
            
            let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
            if !isSparshnaTestGiven {
                self.arr_Section.append(["id" : "add_questionnaire", "text": "", "title": ""])
                self.arr_Section.append(["id" : "button", "text": "", "title": "SKIP".localized().capitalized])
            }
            
        }

        self.tbl_view.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = self.arr_Section[indexPath.row]["id"] as? String ?? ""
        if identifier == "current_balance" {
            let cell = tableView.dequeueReusableCell(withClass: CurrentBalanceTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_balTitle.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            cell.lbl_mainTopText.text = self.arr_Section[indexPath.row]["text"] as? String ?? ""

            cell.setupforBodyText(prensentage: str_KaphaPercentage)
            cell.setupforMetabolismText(prensentage: str_PittaPercentage)
            cell.setupforMindText(prensentage: str_VataPercentage)
            
            if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
                cell.lbl_dosaType.text = ""
                cell.constraint_lbl_dosaType_Top.constant = 0
                cell.constraint_view_KPV_BG_Height.constant = 188
            }
            else {
                cell.btn_DetailResult.isHidden = true
                cell.setupforDoshaTypeText(idelText: self.yourIdealState, dosha_type: self.strAggrivation)
                cell.constraint_btn_detail_Top.constant = -8
                cell.constraint_btn_detail_Bottom.constant = 0
            }
            
            
            //Try Now Tapped
            cell.didTappedonDetailedResult = {(sender) in
                if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
                    let vc = SparshnaDetailResultVC.instantiate(fromAppStoryboard: .Questionnaire)
                    vc.aggrivation_type = self.strAggrivation
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
                    let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
                    objDescription.hidesBottomBarWhenPushed = true
                    objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
                    self.navigationController?.pushViewController(objDescription, animated: true)
                }
            }
            
            return cell
        }
        else if identifier == "perdominant" {
            let cell = tableView.dequeueReusableCell(withClass: PrakritiResultTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.setupDetail()
            
            if (kUserDefaults.value(forKey: RESULT_VIKRITI) == nil) {
                cell.btn_continue.isHidden = true
                cell.constraint_btn_Continue_TOP.constant = 0
                cell.constraint_btn_Continue_Height.constant = 0
            }
            
            //Detailed Tapped
            cell.didTappedKnowMoreButton = {(sender) in
                let objDialouge = TextBottomSheet(nibName:"TextBottomSheet", bundle:nil)
                self.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                self.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: self)
            }
            
            //Continue Tapped
            cell.didTappedContinue = {(sender) in
                self.backAction()
            }
            
            return cell
        }
        else if identifier == "add_questionnaire" {
            let cell = tableView.dequeueReusableCell(withClass: HomeScreenNoSparshnaTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
                cell.setupForQuestionnaires(is_sparshna: true, is_parshna: false, prakriti_result: true)
            }
            
            if (kUserDefaults.value(forKey: RESULT_VIKRITI) == nil) {
                cell.setupForPluseAssessment(is_sparshna: false, is_parshna: true, prakriti_result: true)
            }
            
            //Try Now Tapped
            cell.didTappedonTryNow = {(sender) in
                if (kUserDefaults.value(forKey: RESULT_VIKRITI) == nil) {
                    self.didTappedOnClickTryNowEvent(true, is_assessment: true)
                }
                
                if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
                    self.didTappedOnClickTryNowEvent(true, is_assessment: false)
                }
            }

            return cell
        }
        else if identifier == "button" {
            let cell = tableView.dequeueReusableCell(withClass: SideMenuButtonTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_logout.textColor = UIColor.fromHex(hexString: "#007AFF")
            cell.lbl_logout.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            cell.btn_logout.layer.borderWidth = 0
            cell.constraint_btn_logout_top.constant = 0
            
            cell.didTappedonLogout = { (sender) in
                self.backAction()
            }
            
            return cell
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension PrakritiResult1VC {
    static func showScreen(isFromOnBoarding: Bool = false, fromVC: UIViewController) {
        //New design
        let vc = PrakritiResult1VC.instantiate(fromAppStoryboard: .Questionnaire)
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - TRY NOW CLICK EVENT
    
    func didTappedOnClickTryNowEvent(_ isSuccess: Bool, is_assessment: Bool) {
        if isSuccess {
            if is_assessment {
                let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
                objBalVC.isBackButtonHide = false
                objBalVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objBalVC, animated: true)
            }
            else {
                let objBalVC = Story_Assessment.instantiateViewController(withIdentifier: "IdealBalanceQuestionnaireVC") as! IdealBalanceQuestionnaireVC
                objBalVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objBalVC, animated: true)
            }
        }
    }
    
}


