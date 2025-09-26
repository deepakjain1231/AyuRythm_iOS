//
//  HomeVCNoTestDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 02/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

enum Dialouge_RecommendationCellType {
    case noTestDone(title: String, isSparshna: Bool, isPrashna: Bool)
    case noSparshnaTest(isSparshna: Bool, isPrashna: Bool)
    case noQuestionnaires(isSparshna: Bool, isPrashna: Bool)
    case blankCell

    var sortOrder: Int {
        switch self {
        case .noTestDone:
            return 0
        case .noSparshnaTest:
            return 1
        case .noQuestionnaires:
            return 2
        case .blankCell:
            return 3
        }
    }
    
    static func < (lhs: Dialouge_RecommendationCellType, rhs: Dialouge_RecommendationCellType) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

protocol delegateTappedTryNow {
    func didTappedOnClickTryNowEvent(_ isSuccess: Bool, is_assessment: Bool)
}

import UIKit

class HomeVCNoTestDialouge: UIViewController {

    var delegate: delegateTappedTryNow?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraint_viewHeader_Top: NSLayoutConstraint!
    var dataArray: [Dialouge_RecommendationCellType] = [Dialouge_RecommendationCellType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.registerCells()
        self.manageSection()
        self.constraint_viewHeader_Top.constant = kSharedAppDelegate.window?.safeAreaInsets.top ?? 20
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ isAction: Bool = false, assessment: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if isAction {
                self.delegate?.didTappedOnClickTryNowEvent(true, is_assessment: assessment)
            }
            
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

//MARK: - UITableView Delegate DataSource Method
extension HomeVCNoTestDialouge: UITableViewDelegate, UITableViewDataSource {
    
    func registerCells() {
        self.tblView.register(nibWithCellClass: HomeScreenFirstCell.self)
        self.tblView.register(nibWithCellClass: HomeScreenNoSparshnaTableCell.self)
        self.tblView.register(nibWithCellClass: HomeScreenBlankExtraTableCell.self)
    }
    
    func manageSection() {
        self.dataArray.removeAll()
        
        var isPrakritiPrashna = false
        if let prashnaResult = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String, !prashnaResult.isEmpty {
            isPrakritiPrashna = true
        }
        
        let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
        
        if !isPrakritiPrashna && !isSparshnaTestGiven  {
            self.dataArray.append(.noTestDone(title: "Begin your Ayurvedic journey today in just\n2 easy steps! 🔥".localized(), isSparshna: false, isPrashna: false))
            
            self.dataArray.append(.noSparshnaTest(isSparshna: isSparshnaTestGiven, isPrashna: isPrakritiPrashna))
        }
        else if isSparshnaTestGiven && !isPrakritiPrashna  {
            self.dataArray.append(.noTestDone(title: "You are 1 step away from unlocking\npersonalized results 🔥".localized(), isSparshna: true, isPrashna: false))
            
            self.dataArray.append(.noQuestionnaires(isSparshna: isSparshnaTestGiven, isPrashna: isPrakritiPrashna))
        }
        else if isPrakritiPrashna && !isSparshnaTestGiven  {
            self.dataArray.append(.noTestDone(title: "You are 1 step away from unlocking\npersonalized results 🔥".localized(), isSparshna: false, isPrashna: true))
            
            self.dataArray.append(.noSparshnaTest(isSparshna: isSparshnaTestGiven, isPrashna: isPrakritiPrashna))
        }

        self.dataArray.append(.blankCell)
        self.tblView.reloadData()
    }
    
    
    //MARK: UITableViewCell
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .noTestDone, .noSparshnaTest, .noQuestionnaires, .blankCell:
            return UITableView.automaticDimension
        }
    }
    
    //MARK: TableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {

        case .noTestDone(let title, let isSparshna, let isParshna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenFirstCell") as? HomeScreenFirstCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupmainLabel_forDialouge(title_text: title, is_sparshna: isSparshna, is_prashna: isParshna)
            return cell
            
        case .noSparshnaTest(let isSparshna, let isParshna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenNoSparshnaTableCell") as? HomeScreenNoSparshnaTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupForPluseAssessment(is_sparshna: isSparshna, is_parshna: isParshna)
            
            //Try Now Tapped
            cell.didTappedonTryNow = {(sender) in
                self.clkToClose(true, assessment: true)
            }
            
            return cell
          
        case .noQuestionnaires(let isSparshna, let isParshna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenNoSparshnaTableCell") as? HomeScreenNoSparshnaTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupForQuestionnaires(is_sparshna: isSparshna, is_parshna: isParshna)
            
            //Try Now Tapped
            cell.didTappedonTryNow = {(sender) in
                self.clkToClose(true, assessment: false)
            }
            
            return cell
            
        case .blankCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenBlankExtraTableCell") as? HomeScreenBlankExtraTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.clkToClose()
    }
}
