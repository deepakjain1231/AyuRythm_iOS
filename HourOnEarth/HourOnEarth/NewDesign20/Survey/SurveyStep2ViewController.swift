//
//  SurveyStep2ViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

protocol delegate_nextPressed {
    func nextpressed(_ success: Bool)
    func clear_exitpressed(_ success: Bool)
}

class SurveyCuretedList {
    var id: Int
    var title: String
    var image: String
    var color: String
    var isSelected = false

    public init(id: Int, title: String, image: String, color: String) {
        self.id = id
        self.title = title
        self.image = image
        self.color = color
    }
}

class SurveyStep2ViewController: UIViewController {
    
    var data = [SurveyCuretedList]()
    var arr_Section = [[String: Any]]()
    var delegate: delegate_nextPressed?
    @IBOutlet weak var tbl_View: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbl_View.register(nibWithCellClass: TodaysGoalHeaderTableCell.self)

        data = [SurveyCuretedList(id: 7, title: "Immunity", image: "icon_immunity", color: "#DFCEFD"),
                SurveyCuretedList(id: 52, title: "Wellness", image: "icon_wellness", color: "#FFCCD9"),
                SurveyCuretedList(id: 3, title: "Weight Loss".localized(), image: "icon_weight_loss", color: "#CCDDFF"),
                SurveyCuretedList(id: 51, title: "Weight gain", image: "icon_weight_gain", color: "#FEDDCD"),
                SurveyCuretedList(id: 5, title: "Mindfulness", image: "icon_mindfulness", color: "#FFE9B3"),
                SurveyCuretedList(id: 2, title: "Digestion", image: "icon_digestion", color: "#E9D8D8"),
                SurveyCuretedList(id: 4, title: "Flexibility", image: "icon_flexbility", color: "#C4EEE0"),
                SurveyCuretedList(id: 1, title: "Stress Relief", image: "survey-list-4", color: "#dfedfb")]
        
        //SurveyCuretedList(id: 53, title: "Diet plan", image: "icon_diet_plan", color: "#FFCCF3"),
        

        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any], let gender = empData["gender"] as? String {
            if gender == "Female" {
                data.append(SurveyCuretedList(id: 6, title: "Women's Health", image: "survey-list-3", color: "#f4e6f5"))
            }
        }
        showSavedData()
        self.manageSection()
    }
    
    func showSavedData() {
        data.forEach{ item in
            SurveyData.shared.curetedListIDs.forEach{
                if $0 == item.id {
                    item.isSelected = true
                }
            }
        }
    }
}

extension SurveyStep2ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.append(["identifier": "header", "title": "What are your top goals?".localized(),
                                 "subtitle": "To further personalise your experience\nselect as many goal as you like".localized()])
        
        self.arr_Section.append(["identifier": "top_goal"])
        
        self.arr_Section.append(["identifier": "button", "title": "No worries! You can always edit this later.".localized()])
        
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
        else if idetifier == "top_goal" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TopGoalTableCell") as? TopGoalTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            let int_count = ((self.data.count/2) * 110) + 50
            cell.constraint_collection_view_Height.constant = CGFloat(int_count)
            cell.arr_selectedID = SurveyData.shared.curetedListIDs
            cell.arr_goal = self.data
            
            cell.completation = {(selectedid, selection) in
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
            
            cell.didTappedonNext = { (sender) in
                self.delegate?.nextpressed(true)
            }
            
            cell.didTappedonClearExit = { (sender) in
                self.delegate?.clear_exitpressed(true)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension SurveyStep2ViewController: DataValidateable {
    func validateData() -> (Bool, String) {
        SurveyData.shared.curetedListIDs = data.filter{ $0.isSelected }.map{ $0.id }
        print("-->> ", SurveyData.shared.curetedListIDs)
        guard !SurveyData.shared.curetedListIDs.isEmpty else {
            return (false, "Please select atleast one option to proceed".localized())
        }
        return (true, "")
    }
}

class SurveyStep2TableViewCell: UITableViewCell {
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
//    var listData: SurveyCuretedList? {
//        didSet {
//            guard let listData = listData else {
//                return
//            }
//            
//            titleL.text = listData.title.localized()
//            iconIV.image = UIImage(named: listData.image)
//            bgView.backgroundColor = listData.isSelected ? UIColor().hexStringToUIColor(hex: listData.selectedColor) : UIColor().hexStringToUIColor(hex: listData.color)
//            if listData.isSelected {
//                if listData.id == 7 || listData.id == 2 {
//                    titleL.textColor = .black
//                } else {
//                    titleL.textColor = .white
//                }
//            } else {
//                titleL.textColor = .black
//            }
//        }
//    }
}



