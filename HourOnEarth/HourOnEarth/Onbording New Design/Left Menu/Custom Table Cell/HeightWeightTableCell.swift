//
//  HeightWeightTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 17/06/23.
//

import UIKit

class HeightWeightTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    
    @IBOutlet weak var view_TextFieldBg: UIView!
    
    @IBOutlet weak var txt_Feet: UITextField!
    @IBOutlet weak var txt_Inch: UITextField!
    @IBOutlet weak var view_Height_TextFieldBg: UIView!
    
    @IBOutlet weak var txt_Field: UITextField!
    @IBOutlet weak var btn1: UIControl!
    @IBOutlet weak var btn2: UIControl!
    @IBOutlet weak var lbl_btnTitle1: UILabel!
    @IBOutlet weak var lbl_btnTitle2: UILabel!
    
    var didTappedButton: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Action(_ sender: UIControl) {
        self.didTappedButton?(sender)
    }
    
}
