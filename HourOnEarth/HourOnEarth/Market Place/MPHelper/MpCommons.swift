//
//  MpCommons.swift
//  HourOnEarth
//
//  Created by Sachin Patoliya on 02/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import UIKit

let MAX_LENGTH_PINCODE = 6
let MAX_LENGTH_PHONENUMBER = 10
let ACCEPTABLE_NUMBERS = "0123456789"


struct MPDateFormat{
    static let yyyy_MM_dd_HH_mm_ss = "yyyy-MM-dd HH:mm:ss"//2022-06-11 14:50:32
    static let yyyy_MM_dd = "yyyy-MM-dd"//2022-06-11
    static let EEEE = "EEEE"//Friday
    static let EEE = "EEE"//Fri
    static let DD_MMM_yyyy = "dd-MMM-yyyy"//2022-06-11
    
    static let yyyy_MM_dd_HH_mm_ss_AM_PM = "yyyy-MM-dd hh:mm:ssa"//2022-06-11 14:50:32
    static let dd_MM_yyyy_hh_mm_ss_AM_PM = "dd-MM-yyyy hh:mm:ssa"
    
    static let dd_MMM_yyyy_hh_mm_AM_PM = "dd MMM yyyy - hh:mm a"
    
    static let EEEE_ddMMMYYYY = "EEEE, dd MMM yyyy"//Fri
    
    static let ddMMMYYYYhhmma = "dd, MMM yyyy - hh:mm a"//Fri
    
    static let EEE_ddMMMYYYYhhmma = "EEE, dd MMM yyyy"//Fri
}

func convertStringToDate(strDate: String, fromFormat: String, toFormat: String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = fromFormat
    let yourDate = formatter.date(from: strDate) ?? Date()
    formatter.dateFormat = toFormat
    return formatter.string(from: yourDate)
}

func convertDateToString(date: Date, toFormat: String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = toFormat
    return formatter.string(from: date)
}

func getDate(date: String, toFormat: String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = toFormat
    return formatter.date(from: date) ?? Date()
}

func getTodayWeekDay(date: String, toFormat: String)-> String{
    let date = getDate(date: date, toFormat: toFormat)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = MPDateFormat.EEE
    let weekDay = dateFormatter.string(from: date)
    return weekDay
 }

extension UIView{
    func setGradientBackground() {
        self.removeOutOfStockGradient()
        let colorBottom =  UIColor.black.withAlphaComponent(0.9).cgColor
        let colorTop = UIColor.white.withAlphaComponent(0.6).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientLayer"
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = self.cornerRadiuss
        gradientLayer.frame = self.bounds
                
        self.layer.insertSublayer(gradientLayer, at:0)
    }

    func removeOutOfStockGradient()  {
        for item in self.layer.sublayers ?? []{
            if item.name == "gradientLayer"{
                item.removeFromSuperlayer()
            }
        }
    }
}

func setCorner(view: UIView, cornerRadius: CGFloat){
    view.clipsToBounds = true
    view.layer.cornerRadius = cornerRadius
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
}


func findtopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return findtopViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return findtopViewController(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return findtopViewController(controller: presented)
    }
    return controller
}


func random(digits:Int) -> String {
    var number = String()
    for _ in 1...digits {
       number += "\(Int.random(in: 1...9))"
    }
    return number
}


extension UIImage {
    func tint(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()

        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


func getRandomNumber() -> String{
    return "\(Int(Date()?.timeIntervalSince1970 ?? 0))"
}


extension UIViewController {
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)) {
        
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.font = font
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        self.view.addSubview(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])

        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75)
        self.view.addConstraints([c1, c2, c3])
        toastContainer.alpha = 1.0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}


struct MPCartString{
    static let added_successfully = "Product added successfully."
    static let qty_added_successfully = "Quantity added successfully."
    static let removed_successfully = "Product removed from your cart."
    static let please_login = "Please login to access the cart products."
    static let something_went_wrong = "Something went wrong please try again later."
    static let quantity_not_availabel = "Quantity not available."
}


struct MPWishListString{
    static let added_successfully = "Product added successfully."
    static let removed_successfully = "Product removed from your wishlist."
    static let please_login = "Please login to access the wishlist products."
    static let something_went_wrong = "Something went wrong please try again later."
}
