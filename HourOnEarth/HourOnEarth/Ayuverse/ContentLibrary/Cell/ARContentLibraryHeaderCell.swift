//
//  ARContentLibraryHeaderCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

protocol ARContentLibraryHeaderCellDelegate {
    func contentLibraryHeaderCell(cell: ARContentLibraryHeaderCell, didSelectSeeMoreBtn data: ARContentModel?)
}

class ARContentLibraryHeaderCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    var delegate: ARContentLibraryHeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var content: ARContentModel? {
        didSet {
            guard let content = content else { return }
            titleL.text = content.type.title
        }
    }
    
    @IBAction func seeMoreBtnPressed(sender: UIButton) {
        delegate?.contentLibraryHeaderCell(cell: self, didSelectSeeMoreBtn: content)
    }
    
}
