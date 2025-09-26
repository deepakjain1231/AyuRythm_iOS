//
//  HomeScreenFirstCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenFirstCell: UITableViewCell {

    @IBOutlet weak var lbl_mainTitle: UILabel!
    @IBOutlet weak var img_progress1: UIImageView!
    @IBOutlet weak var img_progress2: UIImageView!
    @IBOutlet weak var img_progress3: UIImageView!
    @IBOutlet weak var lbl_progressText1: UILabel!
    @IBOutlet weak var lbl_progressText2: UILabel!
    @IBOutlet weak var lbl_progressText3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_progressText1.text = "Measure current balance".localized()
        self.lbl_progressText2.text = "Find your ideal balance".localized()
        self.lbl_progressText3.text = "Unlock wellness schedule".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupmainLabel(title_text: String, is_sparshna: Bool, is_prashna: Bool) {
        var str_HighlightText = ""
        let strTitleText = title_text
        
        if !is_sparshna && !is_prashna {
            str_HighlightText = "2 easy steps!".localized()
            self.img_progress1.image = UIImage.init(named: "icon_top1")
            self.img_progress2.image = UIImage.init(named: "icon_top2")
        }
        else if is_sparshna && !is_prashna {
            str_HighlightText = "1 step away".localized()
            self.img_progress1.image = UIImage.init(named: "icon_top1_sparshnaDone")
            self.img_progress2.image = UIImage.init(named: "icon_top2_sparshnaDone")
        }
        else if !is_sparshna && is_prashna {
            str_HighlightText = "1 step away".localized()
            self.img_progress1.image = UIImage.init(named: "icon_top1")
            self.img_progress2.image = UIImage.init(named: "icon_top2_withfullProgress")
        }

        let newText = NSMutableAttributedString.init(string: strTitleText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(16), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#333333"), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: strTitleText)
        let highlight_range = textRange.range(of: str_HighlightText)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(16), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#6B1CB0"), range: highlight_range)
        self.lbl_mainTitle.attributedText = newText
    }
    
    func setupmainLabel_forDialouge(title_text: String, is_sparshna: Bool, is_prashna: Bool) {
        var str_HighlightText = ""
        let strTitleText = title_text
        
        if !is_sparshna && !is_prashna {
            str_HighlightText = "2 easy steps!".localized()
            self.img_progress1.image = UIImage.init(named: "icon_top1")
            self.img_progress2.image = UIImage.init(named: "icon_top2")
            
        }
        else if is_sparshna && !is_prashna {
            str_HighlightText = "1 step away".localized()
            self.img_progress1.image = UIImage.init(named: "icon_top1_sparshnaDone")
            self.img_progress2.image = UIImage.init(named: "icon_top2_sparshnaDone")
        }
        else if !is_sparshna && is_prashna {
            str_HighlightText = "1 step away".localized()
            self.img_progress1.image = UIImage.init(named: "icon_top1")
            self.img_progress2.image = UIImage.init(named: "icon_top2_withfullProgress")
        }

        let newText = NSMutableAttributedString.init(string: strTitleText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(16), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: strTitleText)
        let highlight_range = textRange.range(of: str_HighlightText)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(16), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#E08D00"), range: highlight_range)
        self.lbl_mainTitle.attributedText = newText
    }
}
