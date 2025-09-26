//
//  ARWellnessPlanActivityCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPlanActivityCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var durationL: UILabel!
    
    @IBOutlet weak var activityImageIV: UIImageView!
    @IBOutlet weak var kaphaIV: UIImageView!
    @IBOutlet weak var pitaIV: UIImageView!
    @IBOutlet weak var vataIV: UIImageView!
    @IBOutlet weak var playBtnIV: UIImageView!
    @IBOutlet weak var checkmarkIV: UIImageView!
    @IBOutlet weak var lockIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var activity: ARWellnessPlanActivityModel? {
        didSet {
            guard let activity = activity else { return }
            
            nameL.text = activity.name
            
            let strDuration = activity.videoDuration
            if strDuration == "" {
                durationL.text = ""
            }
            else {
                durationL.text = "\(strDuration) min".lowercased()
            }
            activityImageIV.af_setImage(withURLString: activity.image)
            checkmarkIV.isHidden = !activity.isComplete
            //playBtnIV.isHidden = activity.isLocked
            //lockIV.isHidden = !activity.isLocked
            
            //kapha,pitta,vata
            kaphaIV.isHidden = true
            pitaIV.isHidden = true
            vataIV.isHidden = true
            if activity.doshaType.caseInsensitiveContains("kapha") {
                kaphaIV.isHidden = false
            }
            if activity.doshaType.caseInsensitiveContains("pitta") {
                pitaIV.isHidden = false
            }
            if activity.doshaType.caseInsensitiveContains("vata") {
                vataIV.isHidden = false
            }
        }
    }
}
