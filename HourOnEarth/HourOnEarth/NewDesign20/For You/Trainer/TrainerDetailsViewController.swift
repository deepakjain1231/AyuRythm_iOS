//
//  TrainerDetailsViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 15/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import CoreData

class TrainerDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arr_section = [[String: Any]]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    var trainer: Trainer?
    var selectedIndex = -1
    var packages = [TrainerPackage]()
    var isReadMore = false
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Action Methods
    
    @IBAction func expandCollapseButtonPressed(_ sender: UIButton) {
        if selectedIndex == sender.tag {
            selectedIndex = -1
        } else {
            selectedIndex = sender.tag
        }
        tableView.reloadData()
    }
    
    @IBAction func bookNowButtonPressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
        guard let bookNowViewController = storyBoard.instantiateViewController(withIdentifier: "BookNowViewController") as? BookNowViewController else {
            return
        }
        bookNowViewController.trainer = trainer
        bookNowViewController.package = packages[sender.tag]
        self.navigationController?.pushViewController(bookNowViewController, animated: true)
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showConfirmOrderScreen(package: TrainerPackage?) {
        let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
        guard let confirmOrderViewController = storyBoard.instantiateViewController(withIdentifier: "ConfirmOrderViewController") as? ConfirmOrderViewController else {
            return
        }
        
        let dates = [["date":"2020-10-15", "end_time":"17:45:00", "start_time":"17:00:00", "week_day":"Sunday"],
                     ["date":"2020-10-22", "end_time":"17:45:00", "start_time":"17:00:00", "week_day":"Sunday"]]
        confirmOrderViewController.paymentDetails = ["order_dates": dates]
        confirmOrderViewController.selectedDate = [1,2]
        confirmOrderViewController.package = package
        confirmOrderViewController.modalPresentationStyle = .overCurrentContext
        confirmOrderViewController.modalTransitionStyle = .crossDissolve
        present(confirmOrderViewController, animated: true, completion: nil)
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        title = trainer?.name
        self.lbl_Title.text = self.trainer?.name ?? ""
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        self.tableView.register(nibWithCellClass: TrainerHeaderTableCell.self)
        self.tableView.register(nibWithCellClass: TrainerPackageTableCell.self)
        
        guard let trainer = trainer else {
            return
        }
        if let packs = trainer.package?.allObjects as? [TrainerPackage] {
            packages =  packs.sorted{ $0.favorite_id > $1.favorite_id  }
        }
        self.manageSection()
    }
    
    func manageSection() {
        self.arr_section.removeAll()
        self.arr_section.append(["identifier": "header"])
        self.arr_section.append(["title": "About".localized(), "identifier": "about"])
        self.arr_section.append(["title": "Programs Offered".localized(), "identifier": "header_title"])
        
        if self.packages.count != 0 {
            for dic_package in self.packages {
                self.arr_section.append(["identifier": "package", "value": dic_package])
            }
        }

        self.arr_section.append(["title": "Need custom package".localized(), "identifier": "custom_pack"])

        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic_detail = self.arr_section[indexPath.row]
        let str_Title = dic_detail["title"] as? String ?? ""
        let identifier = dic_detail["identifier"] as? String ?? ""
        if identifier == "header" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerHeaderTableCell") as! TrainerHeaderTableCell
            cell.selectionStyle = .none
            cell.lbl_Third.text = ""
            cell.lbl_fourth.text = ""
            
            cell.lbl_Title.text = self.trainer?.name ?? ""
            cell.lbl_subTitle.text = (self.trainer?.type ?? "").capitalized

            if let url = URL(string: self.trainer?.image ?? "") {
                cell.img_Thumb.af.setImage(withURL: url)
            }
            
            return cell
        }
        else if identifier == "header_title" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! TrainerDetailsTableViewCell
            cell.selectionStyle = .none
            cell.headerLabel.text = str_Title
            
            return cell
        }
        else if identifier == "about" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell") as! TrainerDetailsTableViewCell
            cell.selectionStyle = .none
            cell.headerLabel.text = str_Title
            cell.aboutLabel.text = trainer?.about
            cell.delegate = self
            if let readMoreBtn = cell.readMoreButton {
                let noOfLines = cell.aboutLabel.calculateMaxLines()
                if noOfLines > 3 {
                    readMoreBtn.isHidden = false
                    readMoreBtn.isSelected = isReadMore
                    cell.aboutLabel.numberOfLines = isReadMore ? 0 : 3
                } else {
                    readMoreBtn.isHidden = true
                    cell.aboutLabel.numberOfLines = 3
                }
            }
            return cell
        }
        else if identifier == "custom_pack" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomPackageCell") as! TrainerDetailsTableViewCell
            cell.selectionStyle = .none
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerPackageTableCell") as! TrainerPackageTableCell
            cell.selectionStyle = .none

            if let package_detail = dic_detail["value"] as? TrainerPackage {
                cell.lbl_Title.text = package_detail.name
                cell.lbl_sessionCost.text = package_detail.final_dis_price_per_session.priceValueString + "/" + "session".localized()
                
                let discount = package_detail.final_discount_per_session
                cell.view_discount.isHidden = discount > 0 ? false : true
                cell.lbl_discount.text = discount > 0 ? "\(discount.nonDecimalStringValue)% Off" : ""
                
                cell.lbl_Instruction.text = package_detail.descriptions
                let str_TotalSession = package_detail.total_session_string
                let str_SessionDuration = package_detail.time_per_session ?? ""
                cell.lbl_sessionDuration.text = str_TotalSession + " | " + str_SessionDuration + " " + "min each".localized()
                
                //Did Tapped Book Now
                cell.didTappedBookNow = { (sender) in
                    let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
                    guard let objBook = storyBoard.instantiateViewController(withIdentifier: "BookNowViewController") as? BookNowViewController else {
                        return
                    }
                    objBook.trainer = self.trainer
                    objBook.package = package_detail
                    self.navigationController?.pushViewController(objBook, animated: true)
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic_detail = self.arr_section[indexPath.row]
        let identifier = dic_detail["identifier"] as? String ?? ""
        tableView.deselectRow(at: indexPath, animated: true)
        if identifier == "custom_pack" {
        //if indexPath.section == 2 {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let objSettings:ContactUsViewController = storyBoard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(objSettings, animated: true)
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as? TrainerDetailsTableViewCell else {
//            return UIView()
//        }
//
//        if section == 0 {
//            cell.headerLabel.text = "About".localized()
//        } else if section == 1 {
//            cell.headerLabel.text = "Programs Offered".localized()
//        } else {
//            return UIView()
//        }
//
//        return cell.contentView
//    }
}

extension TrainerDetailsViewController: TrainerDetailsTableViewCellDelegate {
    func readMoreClicked() {
        isReadMore.toggle()
        tableView.reloadData()
    }
}
