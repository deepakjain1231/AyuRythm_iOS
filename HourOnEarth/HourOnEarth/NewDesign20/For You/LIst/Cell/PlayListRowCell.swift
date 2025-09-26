//
//  PlayListCell.swift
//  HourOnEarth
//
//  Created by Apple on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import AlamofireImage

protocol PlayListDelegate: class {
    func lockMyListClicked(index : Int)
    func lockBenfitsClikced(indexPath: IndexPath)
}

class PlayListRowCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
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
        self.lblTitle.text = title ?? ""
        self.lblSubTitle.text = subTitle ?? ""
        guard let url = URL(string: urlString ?? "") else {
            return
        }
        imgView.af.setImage(withURL: url)
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

extension PlayListRowCell {
    func toggleLockView(isLock: Bool) {
        lockView.isHidden = !isLock
        imgView.isHidden = isLock
    }
}
