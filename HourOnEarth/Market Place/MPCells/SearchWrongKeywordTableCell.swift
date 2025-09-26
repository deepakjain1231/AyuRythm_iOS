//
//  SearchWrongKeywordTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 13/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class SearchWrongKeywordTableCell: UITableViewCell {
    
    var typee = MPDataType.none
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var view_BG: UIView!
    @IBOutlet weak var view_TopLayer_Borderline: UIView!
    @IBOutlet weak var img_arrow: UIImageView!
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var lbl_bottokUnderLine: UILabel!
    @IBOutlet weak var constraint_view_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_tblView_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_Title_leading: NSLayoutConstraint!
    
    var subData = [Any]()
    var completionhanlder: ((String)->Void)? = nil
    
    var data: [Any]? {
        didSet {
            guard let data = data else { return }
            subData = data
            tbl_View.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tbl_View.register(nibWithCellClass: SearchWrongKeywordTableCell.self)
        
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tbl_View.reloadData()
    }
    
}


extension SearchWrongKeywordTableCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.subData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SearchWrongKeywordTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.img_arrow.isHidden = false
        cell.constraint_view_Top.constant = 0
        cell.titleL.font = UIFont.systemFont(ofSize: 14)
        cell.titleL.text = self.subData[indexPath.row] as? String ?? ""
        cell.constraint_lbl_Title_leading.constant = 30
        cell.titleL.textColor = UIColor.fromHex(hexString: "#8C8989")
        
        if (indexPath.row + 1) == self.subData.count {
            cell.lbl_bottokUnderLine.isHidden = true
        }
        else {
            cell.lbl_bottokUnderLine.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.completionhanlder?(data?.subData[indexPath.row] ?? "")
    }
    
}
