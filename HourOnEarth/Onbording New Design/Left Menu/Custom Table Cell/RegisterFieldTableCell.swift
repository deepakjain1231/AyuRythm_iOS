//
//  RegisterFieldTableCell.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit

class RegisterFieldTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextFieldBg: UIView!
    @IBOutlet weak var txt_Field: UITextField!
    @IBOutlet weak var txt_Field_Mobile: UITextField!
    @IBOutlet weak var lbl_countryCode: UILabel!
    @IBOutlet weak var view_countryBG: UIView!
    @IBOutlet weak var btn_Verify: UIButton!
    @IBOutlet weak var constraint_lbl_Title_TOP: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_TextFieldBg_Height: NSLayoutConstraint!
    
    var didTappedCountry: ((UIControl)->Void)? = nil
    var didTappedVerify: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_countryBG.isHidden = true
        self.txt_Field_Mobile.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_CountryCode_Action(_ sender: UIControl) {
        self.didTappedCountry?(sender)
    }
    
    @IBAction func btn_Verify_Action(_ sender: UIControl) {
        self.didTappedVerify?(sender)
    }
    
    
    
}
