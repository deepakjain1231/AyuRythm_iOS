//
//  SideMenuButtonTableswift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class SideMenuButtonTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_logout: UILabel!
    @IBOutlet weak var btn_logout: UIControl!
    @IBOutlet weak var constraint_btn_logout_top: NSLayoutConstraint!
    
    var didTappedonLogout: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell() {
        btn_logout.layer.borderWidth = 0
        lbl_logout.textColor = UIColor.white
        lbl_logout.font = UIFont.AppFontMedium(18)
        lbl_logout.text = "Proceed for the payment".localized()
        btn_logout.backgroundColor = AppColor.app_DarkGreenColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_logout(_ sender: UIControl) {
        if self.didTappedonLogout != nil {
            self.didTappedonLogout!(sender)
        }
    }
    
}
