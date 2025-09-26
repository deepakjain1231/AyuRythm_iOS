//
//  CurrentBalanceTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class CurrentBalanceTableCell: UITableViewCell {

    @IBOutlet weak var lbl_mainTopText: UILabel!
    @IBOutlet weak var lbl_detail_result: UILabel!
    
    @IBOutlet weak var lbl_Body: UILabel!
    @IBOutlet weak var lbl_Metabolism: UILabel!
    @IBOutlet weak var lbl_Mind: UILabel!
    
    @IBOutlet weak var view_Body: UIView!
    @IBOutlet weak var view_Metabolism: UIView!
    @IBOutlet weak var view_Mind: UIView!
    
    @IBOutlet weak var lbl_Body_Presentage: UILabel!
    @IBOutlet weak var lbl_Metabolism_Presentage: UILabel!
    @IBOutlet weak var lbl_Mind_Presentage: UILabel!
    @IBOutlet weak var lbl_dosaType: UILabel!
    @IBOutlet weak var lbl_balTitle: UILabel!
    @IBOutlet weak var btn_DetailResult: UIView!
    @IBOutlet weak var constraint_view_KPV_BG_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_dosaType_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_dosaType_Bottom: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_btn_detail_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_detail_Bottom: NSLayoutConstraint!
    
    
    var didTappedonDetailedResult: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_Body.text = "Body".localized()
        self.lbl_Metabolism.text = "Metabolism".localized()
        self.lbl_Mind.text = "Mind".localized()
        self.lbl_detail_result.text = "View detailed result".localized()
        
        self.view_Body.layer.borderWidth = 1
        self.view_Metabolism.layer.borderWidth = 1
        self.view_Mind.layer.borderWidth = 1
        
        let kapha_colors = [#colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1), #colorLiteral(red: 0.7411764706, green: 0.8392156863, blue: 0.1882352941, alpha: 1), #colorLiteral(red: 1, green: 0.862745098, blue: 0.1882352941, alpha: 1)]  //6CC068, //BDD630, //FFDC30
        if let kapha_gradientColor = CAGradientLayer.init(frame: self.view_Body.frame, colors: kapha_colors, direction: GradientDirection.Top).creatGradientImage() {
            self.view_Body.layer.borderColor = UIColor.init(patternImage: kapha_gradientColor).cgColor
        }
        
        let pitta_colors = [#colorLiteral(red: 0.9882352941, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7960784314, blue: 0.1647058824, alpha: 1)]  //FC0000, //FFCB2A
        if let pitta_gradientColor = CAGradientLayer.init(frame: self.view_Metabolism.frame, colors: pitta_colors, direction: GradientDirection.Top).creatGradientImage() {
            self.view_Metabolism.layer.borderColor = UIColor.init(patternImage: pitta_gradientColor).cgColor
        }
        
        let vata_colors = [#colorLiteral(red: 0.2352941176, green: 0.568627451, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.737254902, green: 0.4078431373, blue: 0.7529411765, alpha: 1), #colorLiteral(red: 0.2352941176, green: 0.568627451, blue: 0.9019607843, alpha: 1)]  //3C91E6, //BC68C0, //3C91E6
        if let vata_gradientColor = CAGradientLayer.init(frame: self.view_Metabolism.frame, colors: vata_colors, direction: GradientDirection.Right).creatGradientImage() {
            self.view_Mind.layer.borderColor = UIColor.init(patternImage: vata_gradientColor).cgColor
        }
    }
    
    func setupforBodyText(prensentage: String) {
        let newText = NSMutableAttributedString.init(string: prensentage)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontBold(28), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: prensentage)
        let highlight_range = textRange.range(of: "%")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(15), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1), range: highlight_range)
        self.lbl_Body_Presentage.attributedText = newText
    }
    
    func setupforMetabolismText(prensentage: String) {
        let newText = NSMutableAttributedString.init(string: prensentage)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontBold(28), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: prensentage)
        let highlight_range = textRange.range(of: "%")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(15), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1), range: highlight_range)
        self.lbl_Metabolism_Presentage.attributedText = newText
    }
    
    func setupforMindText(prensentage: String) {
        let newText = NSMutableAttributedString.init(string: prensentage)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontBold(28), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: prensentage)
        let highlight_range = textRange.range(of: "%")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(15), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1), range: highlight_range)
        self.lbl_Mind_Presentage.attributedText = newText
    }
    
    func setupforDoshaTypeText(idelText: String, dosha_type: String) {
        let perodieemintText = idelText
        let newText = NSMutableAttributedString.init(string: perodieemintText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(15), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: idelText)
        let highlight_range = textRange.range(of: dosha_type)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(15), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#007AFF"), range: highlight_range)
        self.lbl_dosaType.attributedText = newText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_detailedResult_Action(_ sender: UIControl) {
        if self.didTappedonDetailedResult != nil {
            self.didTappedonDetailedResult!(sender)
        }
    }
    
}
