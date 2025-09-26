//
//  ARQuestionListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import ActiveLabel

class ARQuestionListVC: UIViewController {
    
    var pageNO = 0
    var data_limit = 15
    var isLoading = false
    
    @IBOutlet weak var categoryPickerView: ARCategoryPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var constraint_view_SearchBG_Height: NSLayoutConstraint!

    @IBOutlet weak var lbl_popularQuestion_title: UILabel!
    @IBOutlet weak var btn_popularQuestion: UIButton!
    @IBOutlet weak var view_popularQuestion_titleBG: UIView!
    
    var questions: [QuestionData] = []
    var allQuestion: [QuestionData] = []
    var selectedCategeory = "all"
    var is_PopularQuestion = true
    var isSearching = false
    var strSearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_Nodata.isHidden = true
        self.title = "Q&A".localized()
        self.constraint_view_SearchBG_Height.constant = 0
        
        if self.is_PopularQuestion {
            self.lbl_popularQuestion_title.text = "Popular questions".localized()
        }
        else {
            self.lbl_popularQuestion_title.text = "Latest questions".localized()
        }

        let menu_button_ = UIBarButtonItem(image: UIImage(named: "ic_search"),
                                          style: UIBarButtonItem.Style.plain ,
                                          target: self, action: #selector(self.onSearchClicked))
        self.navigationItem.rightBarButtonItem = menu_button_
        setupUI()
    }
    
    @objc func onSearchClicked(){
        if self.isSearching == false {
            self.isSearching = true
            show_SearchBar()
        }
        else {
            if txt_Search.text == "" {
                self.view.endEditing(true)
                self.isSearching = false
                hide_SearchBar()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var scrollIndx = 0
        ARAyuverseManager.shared.fetchCommonData(isForceReload: true) { [weak self] in
            
            if let indxx = self?.categoryPickerView.categories.firstIndex(where: { dic_cat in
                return dic_cat.name == self?.selectedCategeory
            }) {
                scrollIndx = indxx
                self?.categoryPickerView.selectedCategory = self?.categoryPickerView.categories[indxx]
            }
            self?.categoryPickerView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.categoryPickerView.collectionView.scrollToItem(at: IndexPath.init(item: scrollIndx, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryPickerView.collectionView.reloadData()
    }
    
    //Puul refresh action
    @objc func Pullto_refreshScreen() {
        self.pageNO = 0
        self.hide_SearchBar()
        self.txt_Search.text = ""
        getQuestions(categeory: self.selectedCategeory)
    }
    
    
    func setupUI() {
        tableView.register(nibWithCellClass: ARQuestionCell.self)
        
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        
        categoryPickerView.delegate = self
        ARAyuverseManager.shared.fetchCommonData { [weak self] in
            self?.categoryPickerView.reloadData()
        }
        self.txt_Search.clearButtonMode = .whileEditing
        self.txt_Search.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
        
        if self.strSearchText == "" {
            getQuestions(categeory: self.selectedCategeory)
        }
        else {
            self.txt_Search.text = self.strSearchText
            self.show_SearchBar()
            isSearching = true
            searchQuestionFromServer(text: self.strSearchText){ (success) in
                Utils.stopActivityIndicatorinView(self.view)
                self.manageTableView(true)
            }
        }
        
    }
    func manageTableView(_ search: Bool = false) {
        
       // self.feedTableView.closeEndPullRefresh()
        
        if search {
            self.lbl_Nodata_Title.text = "No results found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noSearch")
            self.lbl_Nodata_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
        }
        else {
            self.lbl_Nodata_Title.text = "No Questions found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "no_question")
            self.lbl_Nodata_subTitle.text = "start asking your questions.".localized()
        }
        self.view_Nodata.isHidden = self.questions.count == 0 ? false : true
        self.tableView.reloadData()
    }
    
    func getQuestions(categeory: String) {
        
        var params = ["limit": self.data_limit,
                      "offset" : self.pageNO,
                      "filter": "1",
                      "myflag": "0",
                      "search_term": "",
                      "question_category": categeory] as [String : Any]
        
        if self.is_PopularQuestion == false {
            params["filter"] = "2"
        }
        
        Utils.doAyuVerseAPICall(endPoint: .fetchQuestionList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.tableView.closeEndPullRefresh()
            if isSuccess, let responseJSON = responseJSON {
                let question = try? JSONDecoder().decode(FetchQuestionListModel.self, from: responseJSON.rawData())
                let arr_Data = question?.data ?? []

                if self?.pageNO == 0 {
                    self?.questions.removeAll()
                }
                
                if arr_Data.count != 0 {
                    if self?.pageNO == 0 {
                        self?.questions = question?.data ?? []
                    }
                    else {
                        for dic in arr_Data {
                            self?.questions.append(dic)
                        }
                    }
                    self?.isLoading = false
                }
                else {
                    self?.isLoading = true
                }
                
                self?.allQuestion =  self?.questions ?? []
                self?.manageTableView()
                self?.hideActivityIndicator()
            } else if message == "No Data Found"{
               // self?.questions.removeAll()
               // self?.allQuestion.removeAll()
                self?.manageTableView()
                self?.hideActivityIndicator()
            }else{
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    
    @IBAction func btn_Popular_Action(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        
        if self.is_PopularQuestion {
            actionSheet.addAction(UIAlertAction(title: "Latest questions".localized(), style: .default, handler: { _ in
                self.is_PopularQuestion = false
                self.lbl_popularQuestion_title.text = "Latest questions".localized()
                self.getQuestions(categeory: self.selectedCategeory)
            }))
        }
        else {
            actionSheet.addAction(UIAlertAction(title: "Popular questions".localized(), style: .default, handler: { _ in
                self.is_PopularQuestion = true
                self.lbl_popularQuestion_title.text = "Popular questions".localized()
                self.getQuestions(categeory: self.selectedCategeory)
            }))
        }

        self.present(actionSheet, animated: true, completion: nil)
        
    }
}

extension ARQuestionListVC: ARCategoryPickerViewDelegate {
    
    func categoryPickerView(view: ARCategoryPickerView, didSelect category: ARAyuverseCategoryModel) {
        self.pageNO = 0
        print(">> selected category : ", category.name)
        selectedCategeory = category.name
        getQuestions(categeory: category.name)
    }
}

extension ARQuestionListVC: ARQuestionAnswerCellDelegate {
    func questionAnswerCell(cell: Any, didSelect data: Any) {
        if let _ = cell as? ARPopularQuestionCell, let data = data as? QuestionData {
            //ARLog(" more action of popular question : \(data.questionTitle)")
            self.doMoreActionOn(question: data)
        } else if let _ = cell as? ARQuestionCell, let data = data as? QuestionData {
            //ARLog(" more action of question : \(data.questionTitle)")
            self.doMoreActionOn(question: data)
        }
    }
    func deleteQuestion(question: QuestionData?){
        let params = ["question_id": question?.questionID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deletQuestion, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    self?.getQuestions(categeory: self?.selectedCategeory ?? "all")
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
    func searchQuestionFromServer (text: String, completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.fetchQuestionList.rawValue
            let params = ["question_category": selectedCategeory,"limit": "20", "offset" : "", "search_term": text, "filter": "", "myflag": "1" ] as [String : Any]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    let question = try? JSONDecoder().decode(FetchQuestionListModel.self, from: response.data!)
                    self.questions = question?.data ?? []
                    
                    if self.txt_Search.text == "" {
                        self.questions = self.allQuestion
                        self.isSearching = false
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
}

extension ARQuestionListVC: UITableViewDelegate, UITableViewDataSource {
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    self.pageNO = self.questions.count
                    self.getQuestions(categeory: self.selectedCategeory)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARQuestionCell.self, for: indexPath)
        let dic_question = questions[indexPath.row]
        cell.question = dic_question
        cell.delegate = self
        
        var strQuestionTittle = dic_question.questionTitle?.trimed().base64Decoded()
        if strQuestionTittle == nil {
            strQuestionTittle = dic_question.questionTitle
        }
        
        let customType1 = ActiveType.custom(pattern: "\\sSee More\\b".localized()) //Looks for "are"
        let customType2 = ActiveType.custom(pattern: "\\sSee Less\\b".localized()) //Looks for "are"
        cell.questionL.enabledTypes.append(customType1)
        cell.questionL.enabledTypes.append(customType2)

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

            let noOfLines = cell.questionL.calculateMaxLines()
            let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
            let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

            if noOfLines > 3 {
                cell.questionL.numberOfLines = dic_question.is_ReadMore ? 0 : 3
                let strWith_Text = dic_question.is_ReadMore ? "   " :"... "
                let addTrellingText = dic_question.is_ReadMore ? kSeeMoreLessText.See_Less.rawValue.localized() : kSeeMoreLessText.See_More.rawValue.localized()
                DispatchQueue.main.async {
                    cell.questionL.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                }
                
            } else {
                cell.questionL.numberOfLines = 0
            }
            

            //Custom types
            label.customColor[customType1] = UIColor().hexStringToUIColor(hex: "#3E8B3A")
            label.customColor[customType2] = UIColor().hexStringToUIColor(hex: "#3E8B3A")

            label.handleCustomTap(for: customType1) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
            label.handleCustomTap(for: customType2) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
        }

        
        // Check if the last row number is the same as the last current data element
        if self.isLoading == false {
            if indexPath.row == self.questions.count - 3 {
                self.loadMoreData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = questions[indexPath.row]
        
        ARQuestionDetailVC.showScreen(question: question, fromVC: self)
    }
    
    func tappedonLabel(_ title: String, message: String, indx: IndexPath) {
        
        if title == "Hashtag" {
            debugPrint("user tapped on hashtag text")
            
            self.show_SearchBar()
            self.txt_Search.text = "#\(message)"

            isSearching = true
            searchQuestionFromServer(text: "#\(message)") { (success) in
                Utils.stopActivityIndicatorinView(self.view)
                self.manageTableView(true)
            }

        }
        else if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
        else {
            if message == kSeeMoreLessText.See_More.rawValue.localized().trimed() {
                questions[indx.row].is_ReadMore = true
                self.tableView.reloadData()
                debugPrint("user tapped on see more text")
            }
            else if message == kSeeMoreLessText.See_Less.rawValue.localized().trimed() {
                questions[indx.row].is_ReadMore = false
                self.tableView.reloadData()
                debugPrint("user tapped on see less text")
            }
        }
    }
}

extension ARQuestionListVC: UITextFieldDelegate {

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
                self.questions = self.allQuestion
                isSearching = false
                manageTableView()
            }
            else {
                //Search in feeds
                isSearching = true
                searchQuestionFromServer(text: str_SearchText){ (success) in
                    Utils.stopActivityIndicatorinView(self.view)
                    self.manageTableView(true)
                }
            }
        }
    }
}

