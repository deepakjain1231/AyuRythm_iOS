//
//  RemediesDetailsCell.swift
//  HourOnEarth
//
//  Created by hardik mulani on 19/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol FavouriteSelectedDelegate: class {
    func favSelectedAtIndex(index: IndexPath)
    func shareSelectedAtIndex(index: IndexPath)
}

class RemediesDetailsCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var view_Header_bg: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var starSareBtnView: UIView!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var img_design_1: UIImageView!
    @IBOutlet weak var img_design_2: UIImageView!
    
    var indexPath: IndexPath?
    weak var delegate: FavouriteSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func starClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        self.delegate?.favSelectedAtIndex(index: indexPath)
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        self.delegate?.shareSelectedAtIndex(index: indexPath)
    }
}
