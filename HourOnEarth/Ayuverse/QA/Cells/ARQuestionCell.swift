//
//  ARPopularQuestionCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import ActiveLabel

protocol ARQuestionAnswerCellDelegate {
    func questionAnswerCell(cell: Any, didSelect data: Any)
}

class ARQuestionCell: UITableViewCell {
    
    @IBOutlet weak var userNameL: UILabel!
    @IBOutlet weak var questionL: ActiveLabel!
    @IBOutlet weak var countL: UILabel!

    
    var delegate: ARQuestionAnswerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        question = nil
        answer = nil
    }
    
    var question: QuestionData? {
        didSet {
            guard let question = question else { return }
            
            userNameL.text = "Asked by ".localized() + (question.userName ?? "")
            userNameL.isHidden = question.userID == kSharedAppDelegate.userId

            countL.attributedText = NSAttributedString(string: "Answers received - ".localized()) +
            NSAttributedString(string: String(question.answerCount ?? "0"),
                               attributes: [.foregroundColor: UIColor.fromHex(hexString: "#555555"), .font : UIFont.systemFont(ofSize: countL.font.pointSize, weight: .medium)])
        }
    }
    
    var answer: AnswerData? {
        didSet {
            guard let answer = answer else { return }
            
            userNameL.text = "Asked by ".localized() + (answer.userName ?? "")
            userNameL.isHidden = answer.userID == kSharedAppDelegate.userId
            
            countL.attributedText =
            NSAttributedString(string: "Upvotes - ".localized()) +
            NSAttributedString(string: String(answer.upvotes ?? "0"),
                               attributes: [.foregroundColor: UIColor.fromHex(hexString: "#555555"), .font : UIFont.systemFont(ofSize: countL.font.pointSize, weight: .medium)])
        }
    }
    
    @IBAction func moreActionBtnPressed(sender: UIButton) {
        if let question = question {
            delegate?.questionAnswerCell(cell: self, didSelect: question)
        } else if let answer = answer {
            delegate?.questionAnswerCell(cell: self, didSelect: answer)
        }
    }
    
}
