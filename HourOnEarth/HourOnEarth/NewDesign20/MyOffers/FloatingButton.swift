//
//  FloatingButton.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 14/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

open class FloatingButton: UIButton {
    static let buttonTag = 2020
    
    var originPoint = CGPoint.zero
    var screen = UIScreen.main.bounds
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            fatalError("touch can not be nil")
        }
        originPoint = touch.location(in: self)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            fatalError("touch can not be nil")
        }
        let nowPoint = touch.location(in: self)
        let offsetX = nowPoint.x - originPoint.x
        let offsetY = nowPoint.y - originPoint.y
        self.center = CGPoint(x: self.center.x + offsetX, y: self.center.y + offsetY)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactBounds(touches: touches)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactBounds(touches: touches)
    }
    
    func reactBounds(touches: Set<UITouch>) {
        guard let touch = touches.first else {
            fatalError("touch can not be nil")
        }
        let endPoint = touch.location(in: self)
        print("Point :: ", endPoint)
        let offsetX = endPoint.x - originPoint.x
        let offsetY = endPoint.y - originPoint.y
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        if center.x + offsetX >= screen.width / 2 {
            self.center = CGPoint(x: screen.width - bounds.size.width / 2, y: center.y + offsetY)
        } else {
            self.center = CGPoint(x: bounds.size.width / 2, y: center.y + offsetY)
        }
        if center.y + offsetY >= (screen.height + screen.origin.y) - bounds.size.height / 2 {
            self.center = CGPoint(x: center.x, y: (screen.height + screen.origin.y) - bounds.size.height / 2)
        } else if center.y + offsetY < screen.origin.y + bounds.size.height / 2 {
            self.center = CGPoint(x: center.x, y: screen.origin.y + bounds.size.height / 2)
        }
        UIView.commitAnimations()
    }
    
    override open func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    @objc func offersBtnClicked(_ sender: Any) {
        let vc = MyOffersViewController.instantiateFromStoryboard("Offers")
        vc.modalPresentationStyle = .fullScreen
        if let topVC = UIApplication.topViewController() {
            topVC.present(vc, animated: true, completion: nil)
        }
    }
}

extension FloatingButton {
    static func addButton(in view: UIView) {
        if view.viewWithTag(FloatingButton.buttonTag) == nil {
            //add butotn
            let viewBounds = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.size.width, height: view.bounds.size.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom))
            let buttonWidth: CGFloat = 64
            let floatingButton = FloatingButton(frame: CGRect(x: (viewBounds.maxX - 16) - buttonWidth, y: (viewBounds.maxY - 16) - buttonWidth, width: buttonWidth, height: buttonWidth))
            floatingButton.addTarget(floatingButton, action: #selector(FloatingButton.offersBtnClicked(_:)), for: .touchUpInside)
            floatingButton.setImage(UIImage(named: "offer-button"), for: .normal)
            floatingButton.screen = viewBounds
            floatingButton.tag = FloatingButton.buttonTag
            
            view.addSubview(floatingButton)
        }
    }
    
    static func addButton(in view: UIView, target: Any?, action: Selector) -> FloatingButton {
        let viewBounds = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.size.width, height: view.bounds.size.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom))
        let buttonWidth: CGFloat = 64
        let floatingButton = FloatingButton(frame: CGRect(x: (viewBounds.maxX - 16) - buttonWidth, y: (viewBounds.maxY - 16) - buttonWidth, width: buttonWidth, height: buttonWidth))
        floatingButton.addTarget(target, action: action, for: .touchUpInside)
        floatingButton.setImage(UIImage(named: "offer-button"), for: .normal)
        
        floatingButton.screen = viewBounds
        view.addSubview(floatingButton)
        return floatingButton
    }
    
    static func showOfferScreen(from view: UIView) {
        if let floatingButton = view.viewWithTag(FloatingButton.buttonTag) as? FloatingButton {
            floatingButton.offersBtnClicked(floatingButton)
        }
    }
}

/*
 Usage ::

        let floatingButton = FloatingButton(frame: CGRect(x: 10, y: 100, width: 56, height: 56))
        floatingButton.addTarget(self, action: #selector(tap(sender:)), for: .touchUpInside)
        floatingButton.setImage(UIImage(named: "AsstisTouch"), for: .normal)
        view.addSubview(floatingButton)
 */
