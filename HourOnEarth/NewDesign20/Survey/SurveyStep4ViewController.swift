//
//  SurveyStep4ViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

enum LevelType: Int {
    case Beginner
    case Intermediate
    case Advanced
    
    var levelParamID: Int {
        switch self {
        case .Intermediate:
            return 102
        case .Advanced:
            return 103
        default:
            return 101
        }
    }
    
    static func levelType(from levelID: Int) -> LevelType {
        switch levelID {
        case 102:
            return .Intermediate
        case 103:
            return .Advanced
        default:
            return .Beginner
        }
    }
}

class SurveyStep4ViewController: UIViewController {
    
//    @IBOutlet var levelTypeViews: [TextImageClickableView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        levelTypeViews.forEach{
//            $0.delegate = self
//            $0.borderColor = UIColor().hexStringToUIColor(hex: "#faf2db")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showSavedData()
    }
    
    func showSavedData() {
//        levelTypeViews.forEach{ cView in
//            if cView.tag == SurveyData.shared.levelID {
//                textImageClickableViewv(view: cView, didSelectAt: cView.tag)
//            }
//        }
    }
}

extension SurveyStep4ViewController {//}: TextImageClickableViewDelegate {
//    func textImageClickableViewv(view: TextImageClickableView, didSelectAt index: Int) {
//        
//        levelTypeViews.forEach{
//            $0.isSelected = false
//            $0.borderColor = UIColor().hexStringToUIColor(hex: "#faf2db")
//        }
//        view.isSelected.toggle()
//        
//        guard let type = LevelType(rawValue: index) else { return }
//        var colorCode = ""
//        switch type {
//        case .Beginner:
//            colorCode = "#bdd630"
//        case .Intermediate:
//            colorCode = "#bf901a"
//        case .Advanced:
//            colorCode = "#843c0c"
//        }
//        view.borderColor = UIColor().hexStringToUIColor(hex: view.isSelected ? colorCode : "#faf2db")
//        SurveyData.shared.levelID = view.tag
//    }
}

extension SurveyStep4ViewController: DataValidateable {
    func validateData() -> (Bool, String) {
        return (true, "")
    }
}
