//
//  ARQuestionDetailVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import DropDown
import ActiveLabel

class ARQuestionDetailVC: UIViewController, UITextViewDelegate {
    
    var pageNO = 0
    var data_limit = 15
    var isLoading = false
    
    @IBOutlet weak var userNameL: UILabel!
    @IBOutlet weak var questionL: ActiveLabel!
    @IBOutlet weak var countL: UILabel!
    @IBOutlet weak var answerTV: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var btn_Post: UIButton!
    @IBOutlet weak var lbl_AnswerTitle: UILabel!
    
    
    @IBOutlet weak var libraryView: UIView!
    var answers: [AnswerData] = []
    var question: QuestionData?
    var answerData: AnswerData?
    var isEditAnswer = false
    var isFromAnswer = false
    var questionId = ""
    var answerId = ""
    var isReadMore = false
    var is_SearchKeyboard = false
    var answerCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.answerTV.delegate = self
        self.view_Nodata.isHidden = true
        self.btn_Post.setTitle("Post".localized(), for: .normal)
        self.lbl_AnswerTitle.text = "Answers".localized()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fixAutoHeightTableHeader(of: tableView)
    }
    
    func setupUI() {
        self.title = "Q&A".localized()
        tableView.register(nibWithCellClass: ARQAAnswerCell.self)
        tableView.register(nibWithCellClass: ARNoAnswerCell.self)
        tableView.register(nibWithCellClass: ARNoCommentTableCell.self)
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        userNameL.text = "Asked by ".localized() + (question?.userName ?? "")

        var strQuestionTitle = question?.questionTitle?.trimed().base64Decoded()
        if strQuestionTitle == nil {
            strQuestionTitle = question?.questionTitle
        }

        let arr_GetURL = Utils.getLinkfromString(str_msggggg: strQuestionTitle ?? "")
        if arr_GetURL.count != 0 {
            for strGetURL in arr_GetURL {
                if strGetURL.contains("http") {
                }
                else {
                    strQuestionTitle = strQuestionTitle?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                }
            }
        }
                
        self.questionL.customize { label in
            label.text = strQuestionTitle ?? ""
            label.textColor = UIColor.black
            label.hashtagColor = kAppBlueColor
            label.URLColor = kAppBlueColor

            label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: IndexPath.init(item: 0, section: 0)) }
            label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: IndexPath.init(item: 0, section: 0)) }
            self.questionL.numberOfLines = 0
        }

        self.answerCount = Int(question?.answerCount ?? "0") ?? 0
        countL.text = "Answer Received:- \(self.answerCount)"
        answerTV.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        answerTV.placeholder = "Type your answer here...".localized()
        libraryView.isHidden = true
        answerTV.delegate = self
        if isFromAnswer{
            getQuestions()
        }else{
            getAnswer()
        }
        if isEditAnswer {
            var strAnswer = answerData?.answer?.trimed().base64Decoded()
            if strAnswer == nil {
                strAnswer = answerData?.answer
            }
            
            answerTV.text = strAnswer
            answerTV.placeholder = ""
            answerId = answerData?.answerID ?? ""
            self.btn_Post.backgroundColor = kAppBlueColor
        }
        else {
            self.btn_Post.backgroundColor = .lightGray
        }
        
    }
    
    @objc func Pullto_refreshScreen() {
        self.pageNO = 0
        self.getAnswer()
    }
    
    func getQuestions() {
        
        let params = ["question_id": questionId,
                      "question_category": "",
                      "limit": "15",
                      "offset" : "",
                      "search_term": "",
                      "filter": "",
                      "myflag": "1" ] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .fetchQuestionList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let question = try? JSONDecoder().decode(FetchQuestionListModel.self, from: responseJSON.rawData())
                let myQuestions = question?.data ?? []
                if myQuestions.count > 0{
                    self?.question = myQuestions[0]
                    self?.userNameL.text = "Asked by ".localized() + (self?.question?.userName ?? "")

                    var strQuestionTitle = self?.question?.questionTitle?.trimed().base64Decoded()
                    if strQuestionTitle == nil {
                        strQuestionTitle = self?.question?.questionTitle
                    }
                    self?.questionL.text = strQuestionTitle

                    self?.countL.text = "Answer Received:- " + (self?.question?.answerCount ?? "0")
                    self?.getAnswer()
                }
                self?.hideActivityIndicator()
            } else  if message == "No Data Found"{
                self?.hideActivityIndicator()
            }else{
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func manageTableView(_ search: Bool = false) {
        
        self.is_SearchKeyboard = search
       // self.feedTableView.closeEndPullRefresh()
        
        if search {
            self.lbl_Nodata_Title.text = "No results found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noSearch")
            self.lbl_Nodata_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
        }
        else {
            self.lbl_Nodata_Title.text = "No answer found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "no_answer")
            self.lbl_Nodata_subTitle.isHidden = true
        }
        //self.view_Nodata.isHidden = self.answers.count == 0 ? false : true
        self.tableView.reloadData()
    }
    
    @IBAction func postAnswerBtnPressed(sender: UIButton) {
        let str_Answer = (answerTV.text ?? "").trimed()
        if str_Answer != "" {
            if isEditAnswer {
                editAnAnswer(str_Answer)
            }else{
                postAnAnswer(str_Answer)
            }
        }else{
            let alert = UIAlertController(title: "Error".localized(), message: "Please Enter Your Answer", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
            self.present(alert, animated: true)
        }
    }
    func getAnswer() {
        
        let params = ["limit": self.data_limit,
                      "offset" : self.pageNO,
                      "search_term": "",
                      "question_id": question?.questionID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .fetchAnswerList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.tableView.closeEndPullRefresh()
            if isSuccess, let responseJSON = responseJSON {
                let answer = try? JSONDecoder().decode(FetchAnswerListModel.self, from: responseJSON.rawData())
                let arr_Data = answer?.data ?? []
                
                if self?.pageNO == 0 {
                    self?.answers.removeAll()
                }
                
                if arr_Data.count != 0 {
                    if self?.pageNO == 0 {
                        self?.answers = answer?.data ?? []
                    }
                    else {
                        for dic in arr_Data {
                            self?.answers.append(dic)
                        }
                    }
                    self?.isLoading = false
                }
                else {
                    self?.isLoading = true
                }
                self?.manageTableView()
                self?.hideActivityIndicator()
            } else {
                self?.answers.removeAll()
                self?.manageTableView()
                self?.hideActivityIndicator()
               // self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func postAnAnswer(_ ansswes: String) {
        
        let params = ["answer": ansswes.base64Encoded() ?? "",
                      "decoded_answer": ansswes,
                      "question_id": question?.questionID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .postAnAnswer, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let answer = try? JSONDecoder().decode(PostAnswerModel.self, from: responseJSON.rawData())
                if answer?.status == "success"{
                    self?.answers.insert((answer?.data)!, at: 0)
                    self?.answerCount = (self?.answerCount ?? 0) + 1
                    self?.countL.text = "Answer Received:- \(self?.answerCount ?? 0)"
                    self?.manageTableView()
                    self?.answerTV.text = ""
                    self?.btn_Post.backgroundColor = .lightGray
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARQuestionListVC.self }) {
                            (activeSubVC as? ARQuestionListVC)?.pageNO = 0
                            (activeSubVC as? ARQuestionListVC)?.getQuestions(categeory: (activeSubVC as? ARQuestionListVC)?.selectedCategeory ?? "all")
                        }
                    }
                        
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: answer?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func editAnAnswer(_ ansswes: String) {
        
        let params = ["answer_id": answerId,
                      "decoded_answer": ansswes,
                      "answer": ansswes.base64Encoded() ?? "",
                      "question_id": question?.questionID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .editAnswer, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let answer = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if answer?.status == "success"{
                    self?.getAnswer()
                    self?.answerTV.text = ""
                    self?.isEditAnswer = false
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: answer?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func deleteQuestion(){
        
        let params = ["question_id": question?.questionID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deletQuestion, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    self?.navigationController?.popViewController(animated: true)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func deleteAnswer(answer: AnswerData) {
        
        let params = ["answer_id": answer.answerID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .deleteAnswer, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    self?.answerCount = (self?.answerCount ?? 0) - 1
                    self?.countL.text = "Answer Received:- \(self?.answerCount ?? 0)"
                    self?.getAnswer()
                    let alert = UIAlertController(title: "Success".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func reportAnswerUser(reportType: String, feed: AnswerData,reportUserId: String){
        
        let params = ["report_type": reportType,
                      "group_id": "",
                      "feed_id": ""
                      ,"comment_id": "",
                      "question_id": "",
                      "answer_id": feed.answerID ?? "",
                      "report_message": "reported",
                      "report_user_id":reportUserId] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .reportFeedOrComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    let alert = UIAlertController(title: "Success".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func reportQuestionUser(reportType: String,reportUserId: String){
        
        let params = ["report_type": reportType,
                      "group_id": "",
                      "feed_id": "",
                      "comment_id": "",
                      "question_id": question?.questionID ?? "",
                      "answer_id": "",
                      "report_message": "reported",
                      "report_user_id":reportUserId] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .reportFeedOrComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    let alert = UIAlertController(title: "Success".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func likeAnswer(answerId: String, data:AnswerData?){
        
        let params = ["answer_id": answerId,
                      "question_id": question?.questionID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .likeUnlikeQA, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let likeQA = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if likeQA?.status == "success"{
                    if data?.mylike == "0"{
                        data?.mylike = "1"
                        data?.upvotes =  String((Int(data?.upvotes ?? "0") ?? 0) + 1)
                    }else{
                        data?.mylike = "0"
                        data?.upvotes =  String((Int(data?.upvotes ?? "0") ?? 0) - 1)
                    }
                    self?.manageTableView()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: likeQA?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    @IBAction func openContentLibraryBtnPressed(sender: UIButton) {
        ARContentLibraryHomeVC.showScreen(fromVC: self)
    }
    
    @IBAction func questionMoreBtnPressed(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if question?.userID == kSharedAppDelegate.userId {
            actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
                ARLog("edit question")
                let vc = ARPostQuestionVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.question = self.question
                vc.isEditingQuestion = true
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: "Delete Question".localized(), message: "Are you sure you want to delete this question?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                    self.deleteQuestion()
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
                ARLog("delete question")
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Question".localized(), style: .default, handler: { _ in
                self.reportQuestionUser(reportType: "5", reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                ARLog("report question")
                self.reportQuestionUser(reportType: "7", reportUserId: self.question?.userProfile?.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
       
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
        self.btn_Post.backgroundColor = textView.text == "" ? .lightGray : kAppBlueColor
    }
}

extension ARQuestionDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    self.pageNO = self.answers.count
                    self.getAnswer()
                }
            }
        }
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if answers.count == 0 {
           return 1
       }
       return answers.count
   }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.answers.count == 0 {
            let cell = tableView.dequeueReusableCell(withClass: ARNoCommentTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            if self.is_SearchKeyboard {
                cell.lbl_Nodata_Title.text = "No results found!".localized()
                cell.img_view_Nodata.image = UIImage.init(named: "icon_noSearch")
                cell.lbl_Nodata_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
            }
            else {
                cell.lbl_Nodata_subTitle.text = ""
                cell.lbl_Nodata_Title.text = "No answer found!".localized()
                cell.img_view_Nodata.image = UIImage.init(named: "no_answer")
                cell.lbl_Nodata_subTitle.isHidden = true
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withClass: ARQAAnswerCell.self, for: indexPath)
            let dic_answer = answers[indexPath.row]
            cell.answer = dic_answer
            cell.delegate = self
            
            var strAns = dic_answer.answer?.trimed().base64Decoded()
            if strAns == nil {
                strAns = dic_answer.answer
            }
            
            let customType1 = ActiveType.custom(pattern: "\\sSee More\\b".localized()) //Looks for "are"
            let customType2 = ActiveType.custom(pattern: "\\sSee Less\\b".localized()) //Looks for "are"
            cell.answerL.enabledTypes.append(customType1)
            cell.answerL.enabledTypes.append(customType2)

            let arr_GetURL = Utils.getLinkfromString(str_msggggg: strAns ?? "")
            if arr_GetURL.count != 0 {
                for strGetURL in arr_GetURL {
                    if strGetURL.contains("http") {
                    }
                    else {
                        strAns = strAns?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                    }
                }
            }
                    
            cell.answerL.customize { label in
                label.text = strAns ?? ""
                label.textColor = UIColor.black
                label.hashtagColor = UIColor.black
                label.URLColor = kAppBlueColor
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }

                let noOfLines = cell.answerL.calculateMaxLines()
                let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                if noOfLines > 3 {
                    cell.answerL.numberOfLines = dic_answer.is_ReadMore ? 0 : 3
                    let strWith_Text = dic_answer.is_ReadMore ? "   " :"... "
                    let addTrellingText = dic_answer.is_ReadMore ? kSeeMoreLessText.See_Less.rawValue.localized() : kSeeMoreLessText.See_More.rawValue.localized()
                    DispatchQueue.main.async {
                        cell.answerL.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                    }
                    
                } else {
                    cell.answerL.numberOfLines = 0
                }

                //Custom types
                label.customColor[customType1] = UIColor().hexStringToUIColor(hex: "#3E8B3A")
                label.customColor[customType2] = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                label.handleCustomTap(for: customType1) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
                label.handleCustomTap(for: customType2) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
            }
            
            // Check if the last row number is the same as the last current data element
            if self.isLoading == false {
                if indexPath.row == self.answers.count - 4 {
                    self.loadMoreData()
                }
            }
            
            return cell
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.answers.count != 0 {
            let answer = answers[indexPath.row]
            ARLog(" select answer : ", answer.answer)
        }
    }
    
    //MARK:- tappedOnLabel
    func tappedonLabel(_ title: String, message: String, indx: IndexPath) {
        
        if title == "Hashtag" {
            debugPrint("user tapped on hashtag text")
            let vc = ARQuestionListVC.instantiate(fromAppStoryboard: .Ayuverse)
            vc.selectedCategeory = "all"
            vc.strSearchText = "#\(message)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
        else {
            if message == kSeeMoreLessText.See_More.rawValue.localized().trimed() {
                answers[indx.row].is_ReadMore = true
                self.tableView.reloadData()
                debugPrint("user tapped on see more text")
            }
            else if message == kSeeMoreLessText.See_Less.rawValue.localized().trimed() {
                answers[indx.row].is_ReadMore = false
                self.tableView.reloadData()
                debugPrint("user tapped on see less text")
            }
        }
    }
}

extension ARQuestionDetailVC: ARQAAnswerCellDelegate {
    func answerCell(cell: ARQAAnswerCell, didPressUpvoteBtn data: AnswerData?) {
        print(">>  didPressUpvoteBtn")
        likeAnswer(answerId: data?.answerID ?? "", data: data!)
    }
    
    func answerCell(cell: ARQAAnswerCell, didPressMoreActionBtn data: AnswerData?) {
        print(">>  didPressMoreActionBtn")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if data?.userID == kSharedAppDelegate.userId { // question?.userID == kSharedAppDelegate.userId
            actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
                //ARLog("edit question")
                self.isEditAnswer = true
                var str_Answer = data?.answer?.trimed().base64Decoded()
                if str_Answer == nil {
                    str_Answer = data?.answer
                }
                self.answerTV.placeholder = ""
                self.answerTV.text = str_Answer
                self.answerId = data?.answerID ?? ""
                self.btn_Post.backgroundColor = kAppBlueColor
                self.answerTV.becomeFirstResponder()
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: "Delete Answer".localized(), message: "Are you sure you want to delete this answer?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                    self.deleteAnswer(answer: data!)
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
                ARLog("delete question")
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Answer".localized(), style: .default, handler: { _ in
                self.reportAnswerUser(reportType: "6", feed: data!, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                
                self.reportAnswerUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func answerCell(cell: ARQAAnswerCell, didPressProfileBtn data: AnswerData?) {
        print(">>  didPressProfileBtn")
    }
}

extension ARQuestionDetailVC {
    static func showScreen(question: QuestionData, fromVC: UIViewController) {
        let vc = ARQuestionDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.question = question
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}


extension ARQuestionDetailVC {
    func readMoreClicked() {
        isReadMore.toggle()
        tableView.reloadData()
    }
}
