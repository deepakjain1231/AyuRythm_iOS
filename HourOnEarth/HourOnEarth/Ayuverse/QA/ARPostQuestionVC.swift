//
//  ARPostQuestionVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARPostQuestionVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textTV: UITextView!
    @IBOutlet weak var textCountL: UILabel!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var lbl_CategoryTitle: UILabel!
    @IBOutlet weak var lbl_recommendedCat: UILabel!

    var categories = ARAyuverseCategory.getAllCategories()
    var selectedCategeory = "Others"
    var question:QuestionData?
    var isEditingQuestion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Q&A".localized()
        self.postBtn.setTitle("Post".localized(), for: .normal)
        self.lbl_CategoryTitle.text = "Choose category".localized()
        self.lbl_recommendedCat.text = "Recommended categories".localized()
        
        setupUI()
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: ARCategoryTableViewCell.self)
        searchTF.setLeftPaddingPoints(16)
        textTV.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textTV.placeholder = "Type your question here...".localized()
        textTV.delegate = self
        if isEditingQuestion{
            textTV.placeholder = ""
            var strQuestionTitle = question?.questionTitle?.trimed().base64Decoded()
            if strQuestionTitle == nil {
                strQuestionTitle = question?.questionTitle
            }
            textTV.text = strQuestionTitle
            searchTF.text = question?.category
            selectedCategeory = question?.category ?? "Others"
            textCountL.text = "\(strQuestionTitle?.count ?? 0)" + "/250"
            for category in categories {
                if category.name == selectedCategeory{
                    category.isSelected = true
                }else{
                    category.isSelected = false
                }
            }
            self.postBtn.setTitle("Update", for: .normal)
            self.postBtn.backgroundColor = kAppBlueColor
        }else{
            searchTF.text = "Others"
            self.postBtn.backgroundColor = .lightGray
        }
        tableView.reloadData()
        tableView.scrollToRow(at: NSIndexPath.init(row:categories.count - 1,
                                                   section: 0) as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
    }
    func postAQuestion(_ ques: String) {
        
        var strURL: endPoint = .postQuestions
        var params = ["question_title": ques.base64Encoded() ?? "",
                      "decoded_question": ques,
                      "question_category": selectedCategeory] as [String : Any]
        
        if self.isEditingQuestion {
            strURL = .editQuestions
            params["question_id"] = question?.questionID
        }

        Utils.doAyuVerseAPICall(endPoint: strURL, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let postQuestion = try? JSONDecoder().decode(PostQuestionModel.self, from: responseJSON.rawData())
                if postQuestion?.status == "success"{
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARQuestionListVC.self }) {
                            let catName = (activeSubVC as? ARQuestionListVC)?.selectedCategeory ?? ""
                            (activeSubVC as? ARQuestionListVC)?.getQuestions(categeory: catName)
                        }
                    }

                    self?.navigationController?.popViewController(animated: true)
                    self?.textTV.text = ""
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: postQuestion?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    @IBAction func postBtnPressed(sender: UIButton) {
        let strQuestion = textTV.text.trimed()
        if strQuestion != ""{
            postAQuestion(strQuestion)
        }else{
            //let alert = UIAlertController(title: "Error".localized(), message: "Please Enter Your Question", preferredStyle: .alert)
            //alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
            //self.present(alert, animated: true)
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        self.postBtn.backgroundColor = textView.text == "" ? .lightGray : kAppBlueColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.count > 0{
            textTV.placeholder = ""
            self.postBtn.backgroundColor = .lightGray
        }else{
            self.postBtn.backgroundColor = kAppBlueColor
            textTV.placeholder = "Type your question here...".localized()
        }
        textCountL.text = String(newText.count) + "/250"
      return newText.count <= 249
    }
}

extension ARPostQuestionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARCategoryTableViewCell.self, for: indexPath)
        cell.category = categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categories.forEach{ $0.isSelected = false }
        let category = categories[indexPath.row]
        category.isSelected = true
        ARLog(" select category : ", category)
        searchTF.text = category.name
        selectedCategeory = category.name
        tableView.reloadData()
    }
}
