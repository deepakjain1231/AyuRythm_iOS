//
//  MpHelpVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 20/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON
//import ObjectMapper

class MpHelpVC: UIViewController {

    var arr_OpenIDs = [String]()
    var arr_HelpData = [MPHelpFaqModel]()
    @IBOutlet weak var tbl_View: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Help"
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        self.tbl_View.register(nibWithCellClass: MPHelpTableCell.self)
        self.callAPIforGetFaq()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
}

//MARK: - UITABLEVIEW DELEGATE DATASOURCE METHOD

extension MpHelpVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_HelpData.first?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: MPHelpTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lbl_subtitle.text = ""
        cell.constraint_subtitle_Top.constant = 0
        let dic_detail = self.arr_HelpData.first?.data[indexPath.row]
        cell.lbl_title.text = dic_detail?.title
        
        let id = dic_detail?.id ?? 0
        if self.arr_OpenIDs.contains("\(id)") {
            cell.constraint_subtitle_Top.constant = 12
            cell.img_arrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            let str_DetailText = dic_detail?.details ?? ""
            cell.lbl_subtitle.text = str_DetailText.htmlToAttributedString?.string ?? ""
        }
        else {
            cell.lbl_subtitle.text = ""
            cell.img_arrow.transform = .identity
            cell.constraint_subtitle_Top.constant = 0

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic_detail = self.arr_HelpData.first?.data[indexPath.row]
        let id = dic_detail?.id ?? 0
        if self.arr_OpenIDs.contains("\(id)") {
            if let indx = self.arr_OpenIDs.firstIndex(of: "\(id)") {
                self.arr_OpenIDs.remove(at: indx)
            }
        }
        else {
            self.arr_OpenIDs.append("\(id)")
        }
        self.tbl_View.reloadData()
    }
}

