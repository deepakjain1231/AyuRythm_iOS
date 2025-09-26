//
//  PDDesignableXibView.swift
//  SchoolTrackingSystem
//
//  Created by Paresh Dafda on 10/01/20.
//  Copyright © 2020 KCS. All rights reserved.
//

import UIKit

//@IBDesignable

class PDDesignableXibView: UIView {

    var contentView : UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Adding custom subview on top of our view
        addSubview(contentView)

        //pin contentView to view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        initialSetUp()
    }
    
    func initialSetUp() {
        // custom initial setup for view
        // over ride this method to do some initial setup
    }

    func loadViewFromNib() -> UIView! {

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
