//
//  MyListCategoryTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 24/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//


import UIKit
import AlamofireImage

class MyListCategoryTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_sub_title: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var btnLock: UIButton!

    weak var delegate: PlayListDelegate?
    var indexPath: IndexPath?
    var isFromPlayListDetailScreen = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureUI(title: String?, subTitle: String?, urlString: String?) {
        self.lbl_title.text = title ?? ""
        self.lbl_sub_title.text = subTitle ?? ""
        guard let url = URL(string: urlString ?? "") else {
            return
        }
        self.imgThumb.af.setImage(withURL: url)
    }
    
    @IBAction func lockClicked(_ sender: UIButton) {
        if let indexPath = self.indexPath {
            if indexPath.section == 0 && !isFromPlayListDetailScreen {
                delegate?.lockMyListClicked(index: sender.tag)
            } else {
                delegate?.lockBenfitsClikced(indexPath: indexPath)
            }
        }
    }
    
}

extension MyListCategoryTableCell {
    func toggleLockView(isLock: Bool) {
        lockView.isHidden = !isLock
    }
}
