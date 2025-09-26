////
////  HOEHeaderCell.swift
////  HourOnEarth
////
////  Created by Dhiren Bharadava on 12/05/20.
////  Copyright © 2020 Pradeep. All rights reserved.
////
//
//import UIKit
//
//class HOEHeaderCell: UITableViewHeaderFooterView
//{
//    //===============================================================================================
//    // MARK: - UILabel IBOutlet
//    //===============================================================================================
//
//   @IBOutlet weak var lblTitle: UILabel!
//
//    //===============================================================================================
//    // MARK: - Closures For SeeMore ClickEvent Get
//    //===============================================================================================
//
//    var ClickActionSeeMore :((_ Section: Int?) -> Void)?
//    func registerForSeeMore(action:@escaping (_ Section: Int?) ->Void) -> Void{
//
//        ClickActionSeeMore = action
//    }
//
//
//    var Section: Int!
//    //===============================================================================================
//    // MARK: - UIButton Click Event for SeeMore
//    //===============================================================================================
//
//    @IBAction func BtnClickSeeMore(_ sender: UIButton)
//    {
//        ClickActionSeeMore?(Section)
//    }
//
//}
