//
//  StreakLevelCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 26/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class StreakLevelCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var levelIV: UIImageView!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var progressBarHeightCons: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView! {
        didSet {
            progressBar.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        //progressBar.widthAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressBarHeightCons.constant = contentView.frame.height
        progressBar.widthAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
    
    var level: ARStreakLevelModel? {
        didSet {
            guard let data = level else { return }
            
            nameL.text = data.rank
            levelIV.af_setImage(withURLString: data.titleIcon)
            subtitleL.setHtmlText(text: data.label)
            bgView.backgroundColor = UIColor.fromHex(hexString: data.backgroundColor)
            arrowBtn.isHidden = !data.isMoreRewards
            detailView.isHidden = true
            
            if data.progress > 0 || !data.lock {
                statusBtn.setTitle("", for: .normal)
                statusBtn.setImage(#imageLiteral(resourceName: "checkmark-white"), for: .normal)
                statusBtn.backgroundColor = UIColor.fromHex(hexString: "#3E8B3A")
                progressBar.progress = data.progress
                blurView.isHidden = true
                detailView.isHidden = false
            } else {
                statusBtn.backgroundColor = UIColor.fromHex(hexString: "#E9CDEA")
                progressBar.progress = 0
                if data.isNext {
                    //statusBtn.setTitle("Day".localized() + " " + data.days.stringValue, for: .normal)
                    statusBtn.setImage(#imageLiteral(resourceName: "timer"), for: .normal)
                    statusBtn.setTitle(nil, for: .normal)
                    blurView.isHidden = true
                    detailView.isHidden = false
                    arrowBtn.isHidden = true
                } else {
                    statusBtn.setTitle(nil, for: .normal)
                    statusBtn.setImage(#imageLiteral(resourceName: "lock-gray-small"), for: .normal)
                    blurView.isHidden = false
                    detailView.isHidden = true
                }
            }
        }
    }
}

// MARK: -

//@IBDesignable
class DashedLineView : UIView {
    @IBInspectable var perDashLength: CGFloat = 2.0
    @IBInspectable var spaceBetweenDash: CGFloat = 2.0
    @IBInspectable var dashColor: UIColor = UIColor.lightGray


    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let  path = UIBezierPath()
        if height > width {
            let  p0 = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            path.move(to: p0)

            let  p1 = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
            path.addLine(to: p1)
            path.lineWidth = width

        } else {
            let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
            path.move(to: p0)

            let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
            path.addLine(to: p1)
            path.lineWidth = height
        }

        let  dashes: [ CGFloat ] = [ perDashLength, spaceBetweenDash ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

        path.lineCapStyle = .butt
        dashColor.set()
        path.stroke()
    }

    private var width : CGFloat {
        return self.bounds.width
    }

    private var height : CGFloat {
        return self.bounds.height
    }
}
