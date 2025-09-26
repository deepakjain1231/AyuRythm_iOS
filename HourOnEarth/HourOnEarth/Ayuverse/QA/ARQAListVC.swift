//
//  ARQAListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import ActiveLabel

class ARQAListVC: UIViewController {
    
    @IBOutlet weak var view_HeaderView: UIView!
    @IBOutlet weak var categoryPickerView: ARCategoryPickerView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myQuestionsBtnView: ARUnderlineButtonView!
    @IBOutlet weak var myAnswersBtnView: ARUnderlineButtonView!
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var constraint_view_SearchBG_Height: NSLayoutConstraint!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    @IBOutlet weak var constraint_collectionView_Height: NSLayoutConstraint!
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var popularQuestionStackView: UIStackView!
    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var lbl_askQuestion: UILabel!
    @IBOutlet weak var lbl_popularQuestion: UILabel!
    @IBOutlet weak var lbl_popularQuestion_title: UILabel!
    @IBOutlet weak var btn_popularQuestion: UIButton!
    
    var popularQuestions: [QuestionData] = []
    var myQuestions: [QuestionData] = []
    var myAllQuestion: [QuestionData] = []
    var myAnswers: [AnswerData] = []
    var myAllAnswers: [AnswerData] = []
    var selectedCategeory = "all"
    var isSearching = false
    var is_Popular_Question = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_Nodata.isHidden = true
        self.constraint_view_SearchBG_Height.constant = 0
        self.lbl_askQuestion.text = "Ask your question".localized()
        self.lbl_popularQuestion.text = "Popular questions".localized()
        self.lbl_popularQuestion_title.text = "Popular questions".localized()
        self.viewAllBtn.setTitle("View All".localized().uppercased(), for: .normal)
        self.myQuestionsBtnView.titleL.text = "My questions".localized()
        self.myAnswersBtnView.titleL.text = "My answers".localized()
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryPickerView.collectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isSearching {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            if myAnswersBtnView.isSelected{
                searchQuestionFromServer(text: "") { (success) in
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }else{
                searchAnswerFromServer(text: "") { (success) in
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
           
        } else {
            getPopularQuestion()
        }
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: ARQuestionCell.self)
        collectionView.register(nibWithCellClass: ARPopularQuestionCell.self)
        categoryPickerView.delegate = self
        ARAyuverseManager.shared.fetchCommonData { [weak self] in
            self?.categoryPickerView.reloadData()
        }
        myQuestionsBtnView.isSelected = true
        myQuestionsBtnView.delegate = self
        myAnswersBtnView.delegate = self
        self.txt_Search.clearButtonMode = .whileEditing
        self.txt_Search.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
        
    }
    func getPopularQuestion() {
        var params = ["question_category": selectedCategeory,"limit": "10", "offset" : "", "search_term": "", "filter": "1", "myflag": "0" ] as [String : Any]
        
        if self.is_Popular_Question == false {
            params["filter"] = "2"
        }
        
        Utils.doAyuVerseAPICall(endPoint: .fetchQuestionList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let question = try? JSONDecoder().decode(FetchQuestionListModel.self, from: responseJSON.rawData())
                self?.popularQuestions = question?.data ?? []
                if self?.popularQuestions.count == 0{
                    //self?.constraint_collectionView_Height.constant = 64
                    //self?.view_HeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 278)
                }else{
                    //self?.constraint_collectionView_Height.constant = 132
                    //self?.view_HeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 346)
                }
                if (self?.popularQuestions.count ?? 0) > 3 {
                    self?.viewAllBtn.isHidden = false
                }else{
                    self?.viewAllBtn.isHidden = true
                }
                self?.view.layoutIfNeeded()
                self?.collectionView.reloadData()
                self?.getQuestions()
                self?.hideActivityIndicator()
            } else  if message == "No Data Found"{
                self?.popularQuestions = []
                if self?.popularQuestions.count == 0{
                    //self?.constraint_collectionView_Height.constant = 64
                    //self?.view_HeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 278)
                }else{
                    //self?.constraint_collectionView_Height.constant = 132
                    //self?.view_HeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 346)
                }
                if (self?.popularQuestions.count ?? 0) > 3{
                    self?.viewAllBtn.isHidden = false
                }else{
                    self?.viewAllBtn.isHidden = true
                }
                //self?.view.layoutIfNeeded()
                self?.collectionView.reloadData()
                self?.getQuestions()
                self?.hideActivityIndicator()
            }else{
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func getQuestions(){
        let params = ["question_category": selectedCategeory,"limit": "20", "offset" : "", "search_term": "", "filter": "", "myflag": "1" ] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .fetchQuestionList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let question = try? JSONDecoder().decode(FetchQuestionListModel.self, from: responseJSON.rawData())
                self?.myQuestions = question?.data ?? []
                self?.myAllQuestion = question?.data ?? []
                self?.myQuestionsBtnView.countL.text = "(" + String(self?.myQuestions.count ?? 0) + ")"
                self?.manageQATableView()
                self?.getAnswer()
                
                self?.hideActivityIndicator()
            } else  if message == "No Data Found"{
                self?.myQuestions = []
                self?.myQuestionsBtnView.countL.text = "(" + String(0) + ")"
                self?.manageQATableView()
                self?.getAnswer()
                
                self?.hideActivityIndicator()
            }else{
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func getAnswer(){
        let params = ["answer_category": selectedCategeory, "question_id": "","limit": "20", "offset" : "", "search_term": "","myanswers": "1"] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .fetchAnswerList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let answer = try? JSONDecoder().decode(FetchAnswerListModel.self, from: responseJSON.rawData())
                self?.myAnswers = answer?.data ?? []
                self?.myAllAnswers = answer?.data ?? []
                self?.manageQATableView()
                self?.myAnswersBtnView.countL.text = "(" + String(self?.myAnswers.count ?? 0) + ")"
                self?.hideActivityIndicator()
            } else  if message == "No Data Found"{
                self?.myAnswers =  []
                self?.manageQATableView()
                self?.myAnswersBtnView.countL.text = "(" + String(0) + ")"
                self?.hideActivityIndicator()
            }else{
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    @IBAction func askQuestionBtnPressed(sender: UIButton) {
        let vc = ARPostQuestionVC.instantiate(fromAppStoryboard: .Ayuverse)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewAllBtnPressed(sender: UIButton) {
        let vc = ARQuestionListVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.selectedCategeory = self.selectedCategeory
        vc.is_PopularQuestion = self.is_Popular_Question
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Popular_Action(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        
        if self.is_Popular_Question {
            actionSheet.addAction(UIAlertAction(title: "Latest questions".localized(), style: .default, handler: { _ in
                self.is_Popular_Question = false
                self.lbl_popularQuestion.text = "Latest questions".localized()
                self.lbl_popularQuestion_title.text = "Latest questions".localized()
                self.getPopularQuestion()
            }))
        }
        else {
            actionSheet.addAction(UIAlertAction(title: "Popular questions".localized(), style: .default, handler: { _ in
                self.is_Popular_Question = true
                self.lbl_popularQuestion.text = "Popular questions".localized()
                self.lbl_popularQuestion_title.text = "Popular questions".localized()
                self.getPopularQuestion()
            }))
        }

        self.present(actionSheet, animated: true, completion: nil)
        
    }
}

extension ARQAListVC: ARCategoryPickerViewDelegate {
    func categoryPickerView(view: ARCategoryPickerView, didSelect category: ARAyuverseCategoryModel) {
        print(">> selected category : ", category.name)
        if category.name == "All"{
            selectedCategeory = "all"
        }else{
            selectedCategeory = category.name
        }
        getPopularQuestion()
    }
}

extension ARQAListVC: ARUnderlineButtonViewDelegate {
    func underlineButtonViewDidSelected(view: ARUnderlineButtonView) {
        [myQuestionsBtnView, myAnswersBtnView].forEach{ $0?.isSelected = false }
        view.isSelected = true
        manageQATableView()
    }
}

extension ARQAListVC: ARQuestionAnswerCellDelegate {
    func questionAnswerCell(cell: Any, didSelect data: Any) {
        if let _ = cell as? ARPopularQuestionCell, let data = data as? QuestionData {
            ARLog(" more action of popular question : \(data.questionTitle ?? "")")
            self.doMoreActionOn(question: data)
        } else if let _ = cell as? ARQuestionCell {
            if let data = data as? QuestionData {
                ARLog(" more action of question : \(data.questionTitle ?? "")")
                self.doMoreActionOn(question: data)
            } else if let data = data as? AnswerData {
                ARLog(" more action of answer : \(data.answer)")
                self.doMoreActionOn(answer: data)
            }
        }
    }
    
    func doMoreActionOn(question: QuestionData) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if question.userID == kSharedAppDelegate.userId {
            actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
                ARLog("edit question")
                let vc = ARPostQuestionVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.question = question
                vc.isEditingQuestion = true
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: "Delete Question".localized(), message: "Are you sure you want to delete this question?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                    self.deleteQuestion(question: question)
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
                
                ARLog("delete question")
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Question".localized(), style: .default, handler: { _ in
                self.reportQuestionUser(reportType: "5", reportUserId: "", questionId: question.questionID ?? "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                ARLog("report question")
                self.reportQuestionUser(reportType: "7", reportUserId: question.userID ?? "", questionId: question.questionID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func doMoreActionOn(answer: AnswerData) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if answer.userID == kSharedAppDelegate.userId {
            actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
                ARLog("edit answer")
                let vc = ARQuestionDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.questionId = answer.questionID ?? ""
                vc.isFromAnswer = true
                vc.isEditAnswer = true
                vc.answerData = answer
                self.navigationController?.pushViewController(vc, animated: true)
              
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: "Delete Answer".localized(), message: "Are you sure you want to delete this answer?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                    self.deleteAnswer(answer: answer)
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
                ARLog("delete question")
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Answer".localized(), style: .default, handler: { _ in
                self.reportAnswerUser(reportType: "6", feed: answer, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                ARLog("report question")
                self.reportAnswerUser(reportType: "7", feed: answer, reportUserId: answer.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}

extension ARQAListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if popularQuestions.count == 0 {
            self.collectionView.setEmptyMessage("No Questions Found!".localized())
        }else{
            self.collectionView.restore()
        }
        if popularQuestions.count > 3{
            return 3
        }else{
            return popularQuestions.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 210, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ARPopularQuestionCell.self, for: indexPath)
        let dic_popularQuestion = popularQuestions[indexPath.row]
        cell.question = dic_popularQuestion
        cell.delegate = self
        
        var strQuestionTittle = dic_popularQuestion.questionTitle?.trimed().base64Decoded()
        if strQuestionTittle == nil {
            strQuestionTittle = dic_popularQuestion.questionTitle
        }
        let arr_GetURL = Utils.getLinkfromString(str_msggggg: strQuestionTittle ?? "")
        if arr_GetURL.count != 0 {
            for strGetURL in arr_GetURL {
                if strGetURL.contains("http") {
                }
                else {
                    strQuestionTittle = strQuestionTittle?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                }
            }
        }

        cell.questionL.customize { label in
            label.text = strQuestionTittle ?? ""
            label.textColor = UIColor.black
            label.hashtagColor = kAppBlueColor
            label.URLColor = kAppBlueColor

            label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: indexPath) }
            label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let question = popularQuestions[indexPath.row]
        ARQuestionDetailVC.showScreen(question: question, fromVC: self)
    }
}

extension ARQAListVC: UITableViewDelegate, UITableViewDataSource {
    func manageQATableView(_ search: Bool = false) {
        
        if search && ((myQuestionsBtnView.isSelected && myQuestions.count == 0) || (myAnswersBtnView.isSelected && myAnswers.count == 0)){
            self.view_Nodata.isHidden = false
            self.lbl_Nodata_Title.text = "No results found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noSearch")
            self.lbl_Nodata_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
            self.lbl_Nodata_subTitle.isHidden = false
        }else if myQuestionsBtnView.isSelected && myQuestions.count == 0{
            self.view_Nodata.isHidden = false
            self.lbl_Nodata_Title.text = "No Questions found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "no_question")
            self.lbl_Nodata_subTitle.text = "start asking your questions.".localized()
            self.lbl_Nodata_subTitle.isHidden = false
        }else if myAnswersBtnView.isSelected && myAnswers.count == 0{
            self.view_Nodata.isHidden = false
            self.lbl_Nodata_Title.text = "No answer found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "no_answer")
            self.lbl_Nodata_subTitle.isHidden = true
        }else{
            self.view_Nodata.isHidden = true
        }
       
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myQuestionsBtnView.isSelected {
            return myQuestions.count
        } else {
            return myAnswers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARQuestionCell.self, for: indexPath)
        if myQuestionsBtnView.isSelected {
            let dic_Question = myQuestions[indexPath.row]
            cell.question = dic_Question
            

            var strQuestionTittle = dic_Question.questionTitle?.trimed().base64Decoded()
            if strQuestionTittle == nil {
                strQuestionTittle = dic_Question.questionTitle
            }

            let arr_GetURL = Utils.getLinkfromString(str_msggggg: strQuestionTittle ?? "")
            if arr_GetURL.count != 0 {
                for strGetURL in arr_GetURL {
                    if strGetURL.contains("http") {
                    }
                    else {
                        strQuestionTittle = strQuestionTittle?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                    }
                }
            }
                    
            cell.questionL.customize { label in
                label.text = strQuestionTittle ?? ""
                label.textColor = UIColor.black
                label.hashtagColor = kAppBlueColor
                label.URLColor = kAppBlueColor

                label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: indexPath) }
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }
            }
            
            
        } else {
            let dic_Answer = myAnswers[indexPath.row]
            cell.answer = dic_Answer
            
            var strAnswer = dic_Answer.answer?.trimed().base64Decoded()
            if strAnswer == nil {
                strAnswer = dic_Answer.answer
            }
            
            let arr_GetURL = Utils.getLinkfromString(str_msggggg: strAnswer ?? "")
            if arr_GetURL.count != 0 {
                for strGetURL in arr_GetURL {
                    if strGetURL.contains("http") {
                    }
                    else {
                        strAnswer = strAnswer?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                    }
                }
            }
                    
            cell.questionL.customize { label in
                label.text = strAnswer ?? ""
                label.textColor = UIColor.black
                label.hashtagColor = UIColor.black
                label.URLColor = kAppBlueColor
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }
            }
        }
        cell.delegate = self
        
        let noOfLines = cell.questionL.calculateMaxLines()
        if noOfLines > 3 {
            cell.questionL.numberOfLines = 3
        } else {
            cell.questionL.numberOfLines = 0
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if myQuestionsBtnView.isSelected{
            let question = myQuestions[indexPath.row]
            ARQuestionDetailVC.showScreen(question: question, fromVC: self)
        }else{
            let vc = ARQuestionDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
            vc.questionId = myAnswers[indexPath.row].questionID ?? ""
            vc.isFromAnswer = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    //MARK:- tappedOnLabel
    
    func tappedonLabel(_ title: String, message: String, indx: IndexPath) {
        
        if title == "Hashtag" {
            debugPrint("user tapped on hashtag text")

            self.show_SearchBar()
            self.txt_Search.text = "#\(message)"

            //Search in question answer
            isSearching = true
            if myQuestionsBtnView.isSelected {
                searchQuestionFromServer(text: "#\(message)"){ (success) in
                    Utils.stopActivityIndicatorinView(self.view)
                    self.manageQATableView(true)
                }
            }else{
                searchAnswerFromServer(text: "#\(message)"){ (success) in
                    Utils.stopActivityIndicatorinView(self.view)
                    self.manageQATableView(true)
                }
            }
            
            
            
        }
        else if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
    }
        
}
extension ARQAListVC{
    func deleteQuestion(question: QuestionData?){
        let params = ["question_id": question?.questionID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deletQuestion, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    self?.getQuestions()
                   // self?.navigationController?.popViewController(animated: true)
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
    func searchQuestionFromServer (text: String, completion: @escaping (Bool)->Void) {
        
        if Utils.isConnectedToNetwork() {
            
            let urlString = kBaseNewURL + endPoint.fetchQuestionList.rawValue
            
            let params = ["filter": "",
                          "myflag": "1",
                          "limit": "20",
                          "offset" : "",
                          "search_term": text,
                          "question_category": selectedCategeory] as [String : Any]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    let question = try? JSONDecoder().decode(FetchQuestionListModel.self, from: response.data!)
                    self.myQuestions = question?.data ?? []
                    self.myQuestionsBtnView.countL.text = "(" + String(self.myQuestions.count ) + ")"
                    
                    if self.txt_Search.text == "" {
                        self.myQuestions = self.myAllQuestion
                        self.myQuestionsBtnView.countL.text = "(" + String(self.myQuestions.count ) + ")"
                    }

                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }else {
            completion(false)
        }
    }
    
    func searchAnswerFromServer (text: String, completion: @escaping (Bool)->Void) {
        
        if Utils.isConnectedToNetwork() {
            
            let urlString = kBaseNewURL + endPoint.fetchAnswerList.rawValue
            
            let params = ["offset" : "",
                          "limit": "20",
                          "myanswers": "1",
                          "question_id": "",
                          "search_term": text,
                          "answer_category": selectedCategeory] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    let answer = try? JSONDecoder().decode(FetchAnswerListModel.self, from: response.data!)
                    self.myAnswers = answer?.data ?? []
                    self.myAnswersBtnView.countL.text = "(" + String(self.myAnswers.count ) + ")"
                    
                    if self.txt_Search.text == "" {
                        self.myAnswers = self.myAllAnswers
                        self.myAnswersBtnView.countL.text = "(" + String(self.myAnswers.count ) + ")"
                    }
                    
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }else {
            completion(false)
        }
    }
    
    func deleteAnswer(answer: AnswerData){
        let params = ["answer_id": answer.answerID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deleteAnswer, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
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
        let params = ["report_type": reportType, "group_id": "","feed_id": "","comment_id": "","question_id": "","answer_id": feed.answerID ?? "","report_message": "reported","report_user_id":reportUserId] as [String : Any]
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
    func reportQuestionUser(reportType: String,reportUserId: String, questionId: String){
        let params = ["report_type": reportType, "group_id": "","feed_id": "","comment_id": "","question_id": questionId,"answer_id": "","report_message": "reported","report_user_id":reportUserId] as [String : Any]
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
}
extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        messageLabel.textColor = UIColor.fromHex(hexString: "#777777")
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
extension ARQAListVC: UITextFieldDelegate {

    func show_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.txt_Search.becomeFirstResponder()
            self.constraint_view_SearchBG_Height.constant = 60
            self.txt_Search.placeholder = "Search".localized()
            self.view.layoutIfNeeded()
        }
    }
    
    func hide_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.constraint_view_SearchBG_Height.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func textFieldEditing(_ textField: UITextField) {
        if let str_SearchText = textField.text {
            if str_SearchText == "" {
                if myQuestionsBtnView.isSelected{
                    self.myQuestions = self.myAllQuestion
                    isSearching = false
                }else{
                    self.myAnswers = self.myAllAnswers
                    isSearching = false
                }
                self.manageQATableView(true)
            }
            else {
                //Search in feeds
                isSearching = true
                if myQuestionsBtnView.isSelected{
                    searchQuestionFromServer(text: str_SearchText){ (success) in
                        Utils.stopActivityIndicatorinView(self.view)
                        self.manageQATableView(true)
                    }
                }else{
                    searchAnswerFromServer(text: str_SearchText){ (success) in
                        Utils.stopActivityIndicatorinView(self.view)
                        self.manageQATableView(true)
                    }
                }
               
                
            }
        }
        
        
    }
    
    
    
}


