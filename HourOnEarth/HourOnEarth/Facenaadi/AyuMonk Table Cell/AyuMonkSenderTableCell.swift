//
//  AyuMonkSenderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class AyuMonkSenderTableCell: UITableViewCell {

    @IBOutlet weak var view_Receiver_BG: UIView!
    @IBOutlet weak var lbl_Receiver_Name: UILabel!
    @IBOutlet weak var lbl_Receiver_Msg: UILabel!
    @IBOutlet weak var lbl_Receiver_MsgDate: UILabel!
    
    @IBOutlet weak var view_Sender_BG: UIView!
    @IBOutlet weak var lbl_Sender_Msg: UILabel!
    @IBOutlet weak var lbl_Sender_MsgDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.view_Receiver_BG.roundCornerss([.topLeft, .topRight, .bottomRight], radius: 12)
        //self.view_Sender_BG.roundCornerss([.topLeft, .topRight, .bottomLeft], radius: 12)
        
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longpressGesture(gesture:)))
        self.view_Receiver_BG.addGestureRecognizer(longPressGesture)
        
        let longPressGesture1 = UILongPressGestureRecognizer.init(target: self, action: #selector(longpressGesture1(gesture:)))
        self.view_Sender_BG.addGestureRecognizer(longPressGesture1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @objc func longpressGesture(gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let gestureView = gesture.view else {
                return
            }
            let actionsheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let actCopy = UIAlertAction.init(title: "Copy", style: .default, handler: { (actCopy) in
                let strCopy = self.lbl_Receiver_Msg.text ?? ""// gestureView.accessibilityHint ?? ""
                UIPasteboard.general.string = strCopy
            })
            let actCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            actionsheet.addAction(actCopy)
            actionsheet.addAction(actCancel)
            appDelegate.window?.rootViewController?.present(actionsheet, animated: true, completion: nil)
        }
    }
    
    @objc func longpressGesture1(gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let gestureView = gesture.view else {
                return
            }
            let actionsheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let actCopy = UIAlertAction.init(title: "Copy", style: .default, handler: { (actCopy) in
                let strCopy = self.lbl_Sender_Msg.text ?? ""// gestureView.accessibilityHint ?? ""
                UIPasteboard.general.string = strCopy
            })
            let actCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            actionsheet.addAction(actCopy)
            actionsheet.addAction(actCancel)
            appDelegate.window?.rootViewController?.present(actionsheet, animated: true, completion: nil)
        }
    }
    
}
