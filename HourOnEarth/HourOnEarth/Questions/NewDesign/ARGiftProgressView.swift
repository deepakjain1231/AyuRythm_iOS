//
//  ARGiftProgressView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/01/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import MKRingProgressView

class ARRingProgressView: RingProgressView {
    
    static let progressOrangeColor = UIColor.fromHex(hexString: "#F09457")
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var giftIcon: UIImageView!
    
    var isGiftClaimed: Bool = false {
        didSet {
            giftIcon.image = isGiftClaimed ? #imageLiteral(resourceName: "gift-gray") : #imageLiteral(resourceName: "gift-orange")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //progressAngleOffset = .pi
        startColor = Self.progressOrangeColor
        endColor = Self.progressOrangeColor
        bgView.makeItRounded()
        bgView.layer.applySketchShadow(color: .gray, alpha: 0.4, x: 1, y: 1, blur: 4, spread: 0)
    }
}

class ARGiftProgressView: UIView {
    @IBOutlet weak var progressView1: ARRingProgressView!
    @IBOutlet weak var progressView2: ARRingProgressView!
    @IBOutlet weak var progressView3: ARRingProgressView!
    @IBOutlet weak var progressViewLine1: UIView!
    @IBOutlet weak var progressViewLine2: UIView!
    @IBOutlet weak var progressView1HeightConst: NSLayoutConstraint!
    @IBOutlet weak var progressView2HeightConst: NSLayoutConstraint!
    @IBOutlet weak var progressView3HeightConst: NSLayoutConstraint!
    
    let nonActiveTransform = CGAffineTransform(scaleX: 0.66, y: 0.66)
    static let nonActiveProgressHeight: CGFloat = 36
    static let activeProgressHeight: CGFloat = 60
    
    func updateUIFor(section: Int, progress: Double, isAnsweredLastQuestion: Bool) {
        switch section {
        case 1:
            UIView.animate(withDuration: 0.3) {
                self.progressView1.progress = progress
                self.progressView2.progress = 0
                self.progressView3.progress = 0
                self.progressView1HeightConst.constant = Self.activeProgressHeight
                self.progressView2HeightConst.constant = Self.nonActiveProgressHeight
                self.progressView3HeightConst.constant = Self.nonActiveProgressHeight
                self.progressViewLine1.backgroundColor = .clear
                self.progressViewLine2.backgroundColor = .clear
                self.layoutIfNeeded()
            }
            
        case 2:
            UIView.animate(withDuration: 0.3) {
                self.progressView1.progress = 1
                self.progressView2.progress = progress
                self.progressView3.progress = 0
                self.progressView1HeightConst.constant = Self.nonActiveProgressHeight
                self.progressView2HeightConst.constant = Self.activeProgressHeight
                self.progressView3HeightConst.constant = Self.nonActiveProgressHeight
                self.progressViewLine1.backgroundColor = ARRingProgressView.progressOrangeColor
                self.progressViewLine2.backgroundColor = .clear
                self.progressView1.isGiftClaimed = true
                if isAnsweredLastQuestion {
                    self.progressView2.progress = 1
                    self.progressView2.isGiftClaimed = true
                    self.progressView2HeightConst.constant = Self.nonActiveProgressHeight
                    
                }
                self.layoutIfNeeded()
            }
            
            
        case 3:
            UIView.animate(withDuration: 0.3) {
                self.progressView1.progress = 1
                self.progressView2.progress = 1
                self.progressView3.progress = progress
                self.progressView1HeightConst.constant = Self.nonActiveProgressHeight
                self.progressView2HeightConst.constant = Self.nonActiveProgressHeight
                self.progressView3HeightConst.constant = Self.activeProgressHeight
                self.progressViewLine1.backgroundColor = ARRingProgressView.progressOrangeColor
                self.progressViewLine2.backgroundColor = ARRingProgressView.progressOrangeColor
                self.progressView1.isGiftClaimed = true
                self.progressView2.isGiftClaimed = true
                if isAnsweredLastQuestion {
                    self.progressView3.progress = 1
                    self.progressView3.isGiftClaimed = true
                    self.progressView3HeightConst.constant = Self.nonActiveProgressHeight
                    
                }
                self.layoutIfNeeded()
            }
            
        default:
            print("handle other sections")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.progressView1HeightConst.constant = Self.activeProgressHeight
        self.progressView2HeightConst.constant = Self.nonActiveProgressHeight
        self.progressView3HeightConst.constant = Self.nonActiveProgressHeight
    }
}
