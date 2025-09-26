//
//  UIView.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 12/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import UIKit

public enum bordercolor {
    case yellow
    case gray
}
public enum backgroundcolor {
    case white
    case yellowL5
}
public enum shadowColor {
    case green
    case pink
    case blue
    case black
    case Black
}

extension UIView {
    
    
    func gradientView(_ rect : CGRect)
    {
        // Initialize gradient layer.
        let gradientLayer: CAGradientLayer = CAGradientLayer()

        // Set frame of gradient layer.
        gradientLayer.frame = rect

        // Color at the top of the gradient.
        let topColor: CGColor = UIColor(red: 181/255, green: 224/255, blue: 179/255, alpha: 1).cgColor

        // Color at the middle of the gradient.
        let middleColor: CGColor = UIColor(red: 255/255, green: 243/255, blue: 182/255, alpha: 1).cgColor

        // Color at the bottom of the gradient.
        let bottomColor: CGColor = UIColor(red: 255/255, green: 243/255, blue: 182/255, alpha: 1).cgColor
        
        // Color at the bottom1 of the gradient.

        let bottom1Color: CGColor = UIColor(red: 244/255, green: 169/255, blue: 183/255, alpha: 1).cgColor
        
        // Color at the bottom1 of the gradient.

        let bottom2Color: CGColor = UIColor(red: 222/255, green: 179/255, blue: 224/255, alpha: 1).cgColor
        
        // Color at the bottom1 of the gradient.

        let bottom3Color: CGColor = UIColor(red: 157/255, green: 200/255, blue: 243/255, alpha: 1).cgColor

        // Set colors.
        gradientLayer.colors = [topColor, middleColor, bottomColor,bottom1Color,bottom2Color,bottom3Color]

        // Set start point.
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)

        // Set end point.
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius  = 10

        // Insert gradient layer into view's layer heirarchy.
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func gradientOnView(_ arrcolor : [CGColor],_ rect : CGRect)
    {
        // Initialize gradient layer.
        let gradientLayer: CAGradientLayer = CAGradientLayer()

        // Set frame of gradient layer.
        gradientLayer.frame = rect

        // Set colors.
        gradientLayer.colors = arrcolor

        // Set start point.
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)

        // Set end point.
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius  = 10

        // Insert gradient layer into view's layer heirarchy.
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    

    func shadowOnVIew(_ shadowColor : shadowColor)
    {
        switch shadowColor {
        case .green:
            self.layer.shadowColor = UIColor(red: 108/255, green: 192/255, blue: 104/255, alpha: 0.4).cgColor
            self.layer.shadowOpacity = 1
            self.layer.cornerRadius  = 10
            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowRadius = 5

        case .pink:
            self.layer.shadowColor = UIColor(red: 234/255, green: 82/255, blue: 111/255, alpha: 0.4).cgColor
            self.layer.shadowOpacity = 1
            self.layer.cornerRadius  = 10
            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowRadius = 5

        case .blue:
            self.layer.shadowColor = UIColor(red: 60/255, green: 145/255, blue: 230/255, alpha: 0.4).cgColor
            self.layer.shadowOpacity = 1
            self.layer.cornerRadius  = 10
            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowRadius = 5

        case .black:
        self.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5).cgColor
            self.layer.shadowOpacity = 1
            self.layer.cornerRadius  = 10
            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowRadius = 5
            case .Black:
            self.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5).cgColor
                self.layer.shadowOpacity = 1
                self.layer.cornerRadius  = 10
                self.layer.shadowOffset = CGSize.zero
                self.layer.shadowRadius = 1

        }

    }
    
    
    
    func setViewColorAndBorder(_ bordercolor : bordercolor,_ backgroundcolor : backgroundcolor)
      {
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 0.5

        switch bordercolor {
        case .yellow:
            self.layer.borderColor = UIColor(red: 255/255, green: 230/255, blue: 109/255, alpha: 1).cgColor
        case .gray:
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
        switch backgroundcolor {
        case .yellowL5:
            self.backgroundColor = UIColor(red: 255/255, green: 242/255, blue: 202/255, alpha: 1)

        case .white:
            self.backgroundColor = UIColor.white
        }
    }
    
    func setViewColorAndBorder2(_ bordercolor : bordercolor,_ backgroundcolor : backgroundcolor)
      {
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 0.8

        switch bordercolor {
        case .yellow:
            self.layer.borderColor = UIColor(red: 255/255, green: 230/255, blue: 109/255, alpha: 1).cgColor
        case .gray:
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
        switch backgroundcolor {
        case .yellowL5:
            self.backgroundColor = UIColor(red: 255/255, green: 242/255, blue: 202/255, alpha: 1)

        case .white:
            self.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }
    }
        
func roundCornerss(_ corners:UIRectCorner, radius: CGFloat) {
   let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
   let mask = CAShapeLayer()
   mask.path = path.cgPath
   self.layer.mask = mask
 }
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadiuss: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = false
            }
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 0, height: 2),
                   shadowOpacity: Float = 0.18,
                   shadowRadius: CGFloat = 5) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

class DKCustomView: UIView {

    @IBInspectable var borderColors: UIColor = UIColor.clear {
        didSet {
            
            layer.borderColor = borderColors.cgColor
        }
    }

    @IBInspectable var borderWidths: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidths
        }
    }

    @IBInspectable var cornerRadiusss: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadiusss
            self.clipsToBounds = true
            self.layer.masksToBounds = true
        }
    }

    @IBInspectable var cornerRadiusByHeight: Bool = false {
        didSet {
            layer.cornerRadius = self.frame.size.height/2
        }
    }

    @IBInspectable var roundButton: Bool = false {
        didSet {
            layer.cornerRadius = self.frame.size.width / 2
            self.clipsToBounds = true
            self.layer.masksToBounds = true
        }
    }


    @IBInspectable var shadowColors: UIColor = UIColor.clear {

        didSet {

            layer.shadowColor = shadowColors.cgColor
            layer.masksToBounds = false
        }
    }


    @IBInspectable var shadowOpacitys: CGFloat = 0.0 {

        didSet {

            layer.shadowOpacity = Float(shadowOpacitys.hashValue)
            layer.masksToBounds = false
        }
    }

    @IBInspectable var shadowRadiuss: CGFloat = 0.0 {

        didSet {

            layer.shadowOpacity = Float(shadowRadiuss.hashValue)
            layer.masksToBounds = false
        }
    }

    override internal func awakeFromNib() {
        super.awakeFromNib()
    }

}
