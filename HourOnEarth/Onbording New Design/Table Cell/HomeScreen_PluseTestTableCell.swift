//
//  HomeScreen_PluseTestTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 04/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit


class HomeScreen_PluseTestTableCell: UITableViewCell {

    weak var delegate: PendingTestDelegate?
    @IBOutlet weak var lblLastAssesment: UILabel!
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_lstTestTitle: UILabel!
    
    @IBOutlet weak var img_kpv: UIImageView!
    @IBOutlet weak var lbl_kpvText: UILabel!
    @IBOutlet weak var view_img_kpv: UIView!
    @IBOutlet weak var img_kpv_full: UIImageView!
    @IBOutlet weak var img_kpv_arrow: UIImageView!
    @IBOutlet weak var lbl_retest: UILabel!
    @IBOutlet weak var lbl_pulsetest: UILabel!
    @IBOutlet weak var btn_info: UIButton!
    
    
    var did_TappedInfoClicked: ((UIButton)->Void)? = nil
    var did_TappedRetestClicked: ((UIControl)->Void)? = nil
    var did_TappedPulseTestClicked: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_title.text = "Wellness Index".localized()
        self.lbl_lstTestTitle.text = "Last test -".localized()
        self.lbl_retest.text = "Retest".localized()
        self.lbl_pulsetest.text = "Pulse Test".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUI(value: String) {
        lblLastAssesment.text = value
    }
    
    @IBAction func btn_PluseText_Actin(_ sender: UIControl) {
//        guard let delegate = self.delegate else {
//            return
//        }
//        delegate.completePendingTestDelegate(isSparshna: true)
        
        self.did_TappedPulseTestClicked!(sender)
    }
    
    @IBAction func btn_Retest_Actin(_ sender: UIControl) {
        self.did_TappedRetestClicked!(sender)
    }
    
    @IBAction func btn_Info_Actin(_ sender: UIButton) {
        self.did_TappedInfoClicked!(sender)
    }
    
}
