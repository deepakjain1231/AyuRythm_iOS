//
//  StreakTaskCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class StreakTaskCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var progressL: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var grayScaleLayer: CALayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        progressL.isHidden = true
    }
    
    var task: ARDailyTaskModel? {
        didSet {
            guard let task = task else { return }
            
            nameL.text = task.taskLabel
            statusBtn.isSelected = task.isCompleted
            
            /*if !task.isCompleted && !task.isNext {
                grayScaleLayer = CALayer.getGrayScaleLayer(frame: bounds)
                mainView.layer.addSublayer(grayScaleLayer!)
                nameL.textColor = .gray
                arrowBtn.tintColor = .gray
            } else {
                grayScaleLayer?.removeFromSuperlayer()
                grayScaleLayer = nil
                nameL.textColor = .black
                arrowBtn.tintColor = .black
            }*/
        }
    }
}
