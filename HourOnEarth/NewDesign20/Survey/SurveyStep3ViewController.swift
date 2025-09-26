//
//  SurveyStep3ViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

//protocol TextImageClickableViewDelegate: class {
//    func textImageClickableViewv(view: TextImageClickableView, didSelectAt index: Int)
//}

//class TextImageClickableView: DesignableView {
//    @IBOutlet weak var titleL: UILabel!
//    var isSelected = false
//
//    weak var delegate: TextImageClickableViewDelegate?
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.addGestureRecognizer(tap)
//    }
//
//    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        //print("view clicked")
//        delegate?.textImageClickableViewv(view: self, didSelectAt: tag)
//    }
//}

class SurveyStep3ViewController: UIViewController, delegateCompleteNow {
    
//    enum ContentType: Int {
//        case Yogasana
//        case Pranayama
//        case Meditation
//        case Mudras
//        case Kriyas
//
//        var stringValue: String {
//            switch self {
//            case .Yogasana:
//                return "Yogasana"
//            case .Pranayama:
//                return "Pranayama"
//            case .Meditation:
//                return "Meditation"
//            case .Mudras:
//                return "Mudras"
//            case .Kriyas:
//                return "Kriyas"
//            }
//        }
//
//        static func contentTypeValue(from string: String) -> ContentType {
//            switch string {
//            case "Pranayama":
//                return .Pranayama
//            case "Meditation":
//                return .Meditation
//            case "Mudras":
//                return .Mudras
//            case "Kriyas":
//                return .Kriyas
//            default:
//                return .Yogasana
//            }
//        }
//    }
    
//    @IBOutlet var contentTypeViews: [TextImageClickableView]!
    
    var super_view: UIViewController?
    var arr_Section = [[String: Any]]()
    var data = [SurveyCuretedList]()
    var delegate: delegate_nextPressed?
    @IBOutlet weak var tbl_View: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbl_View.register(nibWithCellClass: TodaysGoalHeaderTableCell.self)
        //        contentTypeViews.forEach{ $0.delegate = self }
        
        data = [SurveyCuretedList(id: 1, title: "Personalized foods", image: "icon_personilized", color: "#EDE3FE"),
                SurveyCuretedList(id: 2, title: "Curated ayurvedic products", image: "icon_ayurvedik", color: "#FFDCE5"),
                SurveyCuretedList(id: 3, title: "Personalized exercises", image: "icon_personilized_excerise", color: "#CFF1E6"),
                SurveyCuretedList(id: 4, title: "Daily Planner ( Dincharya)", image: "icon_dailyplanner", color: "#FFEAB6")]
                //SurveyCuretedList(id: 5, title: "what am I doing wrong?", image: "icon_wrong", color: "#CFDFFF")]
        
        showSavedData()
        self.manageSection()
    }
    
    func showSavedData() {
        print("saved -->> ", SurveyData.shared.contentTypeIDs)
        data.forEach{ item in
            SurveyData.shared.contentTypeIDs.forEach{
                if $0 == item.id {
                    item.isSelected = true
                }
            }
        }
    }
}

extension SurveyStep3ViewController {//}: TextImageClickableViewDelegate {
//    func textImageClickableViewv(view: TextImageClickableView, didSelectAt index: Int) {
//        view.isSelected.toggle()
//
//        guard let type = ContentType(rawValue: index) else { return }
//        var colorCode = ""
//        switch type {
//        case .Yogasana:
//            colorCode = view.isSelected ? "#bdd630" : "#f4f8dd"
//        case .Pranayama:
//            colorCode = view.isSelected ? "#ffe66d" : "#fffbe7"
//        case .Meditation:
//            colorCode = view.isSelected ? "#3c91e6" : "#dfedfb"
//        case .Mudras:
//            colorCode = view.isSelected ? "#c781cb" : "#f4e6f5"
//        case .Kriyas:
//            colorCode = view.isSelected ? "#eb711f" : "#fadbc7"
//        }
//        view.backgroundColor = UIColor().hexStringToUIColor(hex: colorCode)
//        view.titleL.textColor = (view.isSelected && !(type == .Yogasana || type == .Pranayama)) ? .white : .black
//    }
}

extension SurveyStep3ViewController: DataValidateable {
    func validateData() -> (Bool, String) {
        SurveyData.shared.contentTypeIDs = data.filter{ $0.isSelected }.map{ $0.id }
        print("saving-->> ", SurveyData.shared.contentTypeIDs)
        guard !SurveyData.shared.contentTypeIDs.isEmpty else {
            return (false, "Please select atleast one option to proceed".localized())
        }
        return (true, "")
    }
}


extension SurveyStep3ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.append(["identifier": "header", "title": "How would you like to achieve?".localized(),
                                 "subtitle": "To reach your goals, choose what you want\nto see in your feed.".localized()])
        
        self.arr_Section.append(["identifier": "achieve"])
        
        self.arr_Section.append(["identifier": "button", "title": "No worries! You can always edit this later.".localized(),
                                 "button_title": "Next".localized()])
        
        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let idetifier = self.arr_Section[indexPath.row]["identifier"] as? String ?? ""
        if idetifier == "header" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodaysGoalHeaderTableCell") as? TodaysGoalHeaderTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.lbl_Title.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            cell.lbl_subTitle.text = self.arr_Section[indexPath.row]["subtitle"] as? String ?? ""
            
            return cell
        }
        else if idetifier == "achieve" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Today_Goal_1TableCell") as? Today_Goal_1TableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            let int_count = (self.data.count * 75) + 50
            cell.constraint_collection_view_Height.constant = CGFloat(int_count)
            cell.arr_selectedID = SurveyData.shared.contentTypeIDs
            cell.arr_goal = self.data
            
            cell.completation = {(selectedid, selection) in
                if selectedid == 5 {
                    return
                }
                self.data.forEach{ item in
                    if selectedid == item.id {
                        item.isSelected = selection
                    }
                }
            }
            
            return cell
        }
        else if idetifier == "button" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalButtonTableCell") as? TodayGoalButtonTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.lbl_title.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            cell.btn_Next.setTitle((self.arr_Section[indexPath.row]["button_title"] as? String ?? ""), for: .normal)
            
            cell.didTappedonNext = { (sender) in
                self.delegate?.nextpressed(true)
//                self.showDialouge()
            }
            
            return cell
        }
        

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func clickonGenericContent(_ success: Bool, clickComplteNow: Bool, clickLater: Bool) {
        if success {
            self.delegate?.nextpressed(true)
        }
    }
    
    func showDialouge() {
        let objDialouge = GenericContentDialouge(nibName:"GenericContentDialouge", bundle:nil)
        objDialouge.delegate = self
        objDialouge.screenFrom = ScreenType.for_Reminder
        self.super_view?.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.super_view?.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self.super_view)
    }
}
