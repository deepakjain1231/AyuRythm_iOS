//
//  RoundedCell.swift
//  HOE
//
//  Created by Pradeep on 9/12/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class RoundedCell: UICollectionViewCell {

    var indexPath: IndexPath?

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let tableView = tableView(), let indexPath = indexPath {
            let lastRow = tableView.numberOfItems(inSection: indexPath.section) - 1
            roundCorners(isTop: indexPath.row == 0, isBottom: indexPath.row == lastRow)
        }
    }
    
    func roundCorners(isTop: Bool, isBottom: Bool) {
        var corners = UIRectCorner()
        if isTop {
            corners.insert([.topLeft, .topRight])
        }
        
        if isBottom {
            corners.insert([.bottomLeft, .bottomRight])
        }
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), byRoundingCorners: corners, cornerRadii: CGSize(width: 15, height: 15)).cgPath
        self.layer.mask = shape
        self.layer.masksToBounds = true
    }
    
    // MARK: - Convenience methods
    
    fileprivate func tableView() -> UICollectionView? {
        var view: UIView? = self
        while true {
            if view == nil {
                return nil
            }
            
            view = view?.superview
            if let view = view as? UICollectionView {
                return view
            }
        }
    }
}
