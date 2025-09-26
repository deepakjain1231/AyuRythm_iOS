//
//  AROxygenWeightBannerCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 29/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

protocol AROxygenWeightBannerCellDelegate {
    func oxygenWeightBannerShowSpO2Info(_ cell: AROxygenWeightBannerCell)
    func oxygenWeightBannerAddSuryaNamaskar(_ cell: AROxygenWeightBannerCell)
    func oxygenWeightBanner(_ cell: AROxygenWeightBannerCell, updateWeightBy weight: Int)
    func oxygenWeightBannerCheckBPLWeight(_ cell: AROxygenWeightBannerCell)
}

class AROxygenWeightBannerCell: UITableViewCell {
    
    @IBOutlet weak var spo2L: UILabel!
    @IBOutlet weak var suryaNamaskarCountL: UILabel!
    @IBOutlet weak var weightL: UILabel!
    @IBOutlet weak var checkWeightBtn: UIButton!
    
    var delegate: AROxygenWeightBannerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setupCell() {
        if let spo2 = Utils.getLastAssessmentData()["o2r"] as? Int {
            spo2L.text = spo2.stringValue + "%"
        } else {
            spo2L.text = ""
        }
        //suryaNamaskarCountL.text = Shared.sharedInstance.suryaNamaskarCount.twoDigitStringValue
        weightL.attributedText = NSAttributedString(string: Shared.sharedInstance.userWeight.nonDecimalStringValue) + NSAttributedString(string: " kg", attributes: [.foregroundColor: UIColor.black, .font : UIFont.systemFont(ofSize: 18)])
        
        if ARBPLDeviceManager.shared.isAnyBluetoothEnableWeighingMachineRegistered() {
            checkWeightBtn.isUserInteractionEnabled = true
            checkWeightBtn.setTitleColor(UIColor.app.linkColor, for: .normal)
        } else {
            checkWeightBtn.isUserInteractionEnabled = false
            checkWeightBtn.setTitleColor(.black, for: .normal)
        }
    }
    
    @IBAction func spo2InfoBtnPressed(sender: UIButton) {
        delegate?.oxygenWeightBannerShowSpO2Info(self)
    }
    
    @IBAction func addSuryaNamaskarBtnPressed(sender: UIButton) {
        delegate?.oxygenWeightBannerAddSuryaNamaskar(self)
    }
    
    @IBAction func addWeightBtnPressed(sender: UIButton) {
        delegate?.oxygenWeightBanner(self, updateWeightBy: 1)
    }
    
    @IBAction func subtractWeightBtnPressed(sender: UIButton) {
        delegate?.oxygenWeightBanner(self, updateWeightBy: -1)
    }
    
    @IBAction func checkWeightBtnPressed(sender: UIButton) {
        delegate?.oxygenWeightBannerCheckBPLWeight(self)
    }
}
