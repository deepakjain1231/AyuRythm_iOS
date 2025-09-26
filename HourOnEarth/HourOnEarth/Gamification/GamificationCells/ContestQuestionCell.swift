//
//  ContestQuestionCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 29/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ContestQuestionCell: UITableViewCell {
    
    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var answerDetailL: UILabel!
    @IBOutlet weak var answerDetailView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var question: ARContestQuestionModel?
    var option: ARContestQuestionOptionModel? {
        didSet {
            guard let option = option else { return }
            questionL.text = option.value
            
            answerDetailView.isHidden = true
            let selectedOption = question?.selectedOption
            let currentOption = option.option
            if currentOption == selectedOption && currentOption == question?.correctOption {
                bgView.layer.borderWidth = 2
                bgView.layer.borderColor = #colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1)
                statusBtn.setImage(#imageLiteral(resourceName: "contest-checkmark-green"), for: .normal)
            } else if currentOption == selectedOption && currentOption != question?.correctOption {
                bgView.layer.borderWidth = 2
                bgView.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                statusBtn.setImage(#imageLiteral(resourceName: "contest-checkmark-red"), for: .normal)
            } else {
                bgView.layer.borderWidth = 1
                bgView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                statusBtn.setImage(#imageLiteral(resourceName: "contest-checkmark"), for: .normal)
            }
            
            //show correct answer hint when choose wrong answer every time
            if selectedOption != nil, currentOption == question?.correctOption {
                bgView.layer.borderWidth = 2
                bgView.layer.borderColor = #colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1)
                statusBtn.setImage(#imageLiteral(resourceName: "contest-checkmark-green"), for: .normal)
                let answerDetail = question?.correctDescription ?? ""
                answerDetailL.text = answerDetail
                answerDetailView.isHidden = answerDetail.isEmpty
            }
             //only show correct answer hint when choose wrong answer
            /*if let selectedOption = question?.selectedOption, selectedOption != question?.question {
                if answer == question?.correctOption {
                    bgView.layer.borderWidth = 2
                    bgView.layer.borderColor = #colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1)
                    statusBtn.setImage(#imageLiteral(resourceName: "contest-checkmark-green"), for: .normal)
                    answerDetailL.text = question?.answerDetails
                    answerDetailView.isHidden = question?.isCurrectAnswer ?? false
                }
            }*/
        }
    }
}
