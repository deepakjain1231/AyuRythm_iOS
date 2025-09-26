//
//  RemediesFavouritesCell.swift
//  HourOnEarth
//
//  Created by Apple on 20/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class RemediesFavouritesCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var lblSubCategory: UILabel!

    @IBOutlet weak var view_Header_bg: UIView!
    @IBOutlet weak var img_design_1: UIImageView!
    @IBOutlet weak var img_design_2: UIImageView!
    
    

    var indexPath: IndexPath?
    weak var delegate: FavouriteSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
