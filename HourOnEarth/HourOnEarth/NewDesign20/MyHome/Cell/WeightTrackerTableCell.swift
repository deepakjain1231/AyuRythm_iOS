//
//  WeightTrackerTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 03/03/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit

class WeightTrackerTableCell: UITableViewCell {

    @IBOutlet weak var lbl_weight_tracker: UILabel!
    @IBOutlet weak var lbl_current_weight: UILabel!
    @IBOutlet weak var lbl_current_weight_Title: UILabel!
    @IBOutlet weak var lbl_weight: UILabel!
    @IBOutlet weak var btn_weight_add: UIButton!
    @IBOutlet weak var btn_weight_minus: UIButton!
    
    var didTappedAdd_WeightButton: ((UIButton)->Void)? = nil
    var didTappedSubstack_WeightButton: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        self.lbl_current_weight_Title.text = "Current Weight".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell() {
        let str_weight = "\(Shared.sharedInstance.userWeight.nonDecimalStringValue)Kg"
        
        let newText = NSMutableAttributedString.init(string: str_weight)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontOpenSansSemiBold(16), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#000000").withAlphaComponent(0.8), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: str_weight)
        let highlight_range = textRange.range(of: "Kg")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontOpenSansRegular(13), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#404040").withAlphaComponent(0.8), range: highlight_range)
        self.lbl_weight.attributedText = newText
        self.lbl_current_weight.attributedText = newText
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_add_Weight_Pressed(_ sender: UIButton) {
        self.didTappedAdd_WeightButton?(sender)
    }
    
    @IBAction func btn_subtract_Weight_Pressed(_ sender: UIButton) {
        self.didTappedSubstack_WeightButton?(sender)
    }
   
}
