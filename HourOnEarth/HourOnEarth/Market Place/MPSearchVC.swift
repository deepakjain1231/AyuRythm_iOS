//
//  MPSearchVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 13/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Speech

class MPSearchVC: UIViewController {
    //MARK: - @IBOutlet
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionList: UICollectionView!
    @IBOutlet weak var collectionList_Height: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSearchResultList: UITableView!
    @IBOutlet weak var tblSearchResultList_height: NSLayoutConstraint!
    
    //--
    @IBOutlet weak var viewNoDataSearch: UIView!
    @IBOutlet weak var viewNoDataSearch_Height: NSLayoutConstraint!
    @IBOutlet weak var tblDoyouMean: UITableView!
    @IBOutlet weak var viewbgDoyouMean: UIView!
    @IBOutlet weak var viewbgDoyouMean_height: NSLayoutConstraint!
    
    
    @IBOutlet weak var btn_speakSearch: UIButton!
    @IBOutlet weak var view_Main_SpeakSearch: UIControl!
    @IBOutlet weak var txtView: UITextView!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var sppechTimer: Timer?
    var isSpeakSearchApiCall = false
    var is_VoiceDetection = false
    @IBOutlet weak var view_speak: UIControl!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var btn_tryagain: UIControl!
    @IBOutlet weak var icon_microphone: UIImageView!
    
    
    //MARK: - Veriable
    var str_Title = ""
    var dataSource = [MPData]()
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    var arr_Category = [MPCategoryModel]()
    var arr_PopularProducts = [MPProductModel]()
    var arr_ProductTranding = [MPProductModel]()
    var arr_RecentlyProducts = [MPProductModel]()
    
    var mpSearchResultModel = MPSearchResultModel()
    var mpDoyouMeanModel = MPSearchResultModel()
    
     
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.showSearchBar()
        navigationItem.backButtonTitle = ""
        self.view_Main_SpeakSearch.isHidden = true
        hideNoDataSearch()
        basicUISetup()
        //--
        registerCell()
        
        //--
        //manageSection()
        
        //callAPIfor_popular_herbs()
        self.showActivityIndicator()
        self.callAPIfor_RecentlyProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tblSearchResultList.contentSize.height > 400{
            tblSearchResultList_height.constant = 400
        }else{
            tblSearchResultList_height.constant = tblSearchResultList.contentSize.height
        }
    }
    
    private func showSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func hideSearchBar() {
        navigationItem.searchController = nil
    }
    func basicUISetup(){
        viewbgDoyouMean.clipsToBounds = true
    }
    
    func registerCell(){
        collectionList.register(UINib(nibName: "MPViewAllCollectionReusableCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MPViewAllCollectionReusableCell")
        collectionList.register(nibWithCellClass: MPCategoryCell.self)
        collectionList.register(nibWithCellClass: MPMainTrendingProductCollectionCell.self)
        
        tblSearchResultList.register(nibWithCellClass: MPSearchResultTblCell.self)
        tblDoyouMean.register(nibWithCellClass: MPDoYouMeanTblCell.self)
    }
    
    func showNoDataSearch(hideDoYouMean: Bool) {
        viewNoDataSearch.isHidden = false
        
        if hideDoYouMean{
            viewNoDataSearch_Height.constant = 218
            
            viewbgDoyouMean_height.constant = 0
            viewbgDoyouMean.isHidden = true
        }else{
            viewNoDataSearch_Height.constant = 218 + 42 + tblDoyouMean.contentSize.height
            tblDoyouMean.isHidden = false
            
            viewbgDoyouMean_height.constant = 42 + tblDoyouMean.contentSize.height
            viewbgDoyouMean.isHidden = false
        }
    }
    
    func hideNoDataSearch() {
        viewNoDataSearch.isHidden = true
        viewNoDataSearch_Height.constant = 0
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MPSearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func manageSection() {
        //--
        self.dataSource.removeAll()
        
        self.dataSource.append(MPData(title: "CATEGORIES", type: .category, subData: self.arr_Category))
        
        self.dataSource.append(MPData(title: "RECENT VIEWED PRODUCTS", type: .recentViewdProducts, subData: self.arr_RecentlyProducts))
        
        self.dataSource.append(MPData(title: "TRENDING PRODUCTS", type: .trendingProducts, subData: self.arr_ProductTranding))
        
        self.dataSource.append(MPData(title: "ALL PRODUCTS", type: .popularProducts, subData: self.arr_PopularProducts))
        
        self.collectionList.reloadData()
        collectionList_Height.constant = collectionList.contentSize.height
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionList_Height.constant = self.collectionList.contentSize.height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width-30, height: 50.0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MPViewAllCollectionReusableCell", for: indexPath) as! MPViewAllCollectionReusableCell
            //--
            header.btnViewAll.tag = indexPath.section
            header.btnViewAll.addTarget(self, action: #selector(btnViewAllCollectionSection(sender:)), for: .touchUpInside)
            
            //--
            let data = dataSource[indexPath.section]
            header.lblTitle.text = data.title
            
            if data.subData.count == 0 { return header }
            switch data.type {
            case .category:
                header.btnViewAll.isHidden = true
                break
            case .recentViewdProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 ? false : true
                break
            case .popularProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 ? false : true
                break
            case .trendingProducts:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 ? false : true
                break
            case .topDealsForYou:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 ? false : true
                break
            case .newlyLaunched:
                let dic_product = data.subData.first as! MPProductModel
                header.btnViewAll.isHidden = dic_product.data.count >= 5 ? false : true
                break
            default:
                
                break
            }
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
    @objc func btnViewAllCollectionSection(sender: UIButton){
        let index = sender.tag
        let data = dataSource[index]
        
        let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
        switch data.type {
        case .category:
            vc.screenFrom = .MP_ViewALL_Categories
            vc.mpDataType = .category
            break
        case .recentViewdProducts:
            vc.screenFrom = .MP_ViewALL_RecentProduct
            vc.mpDataType = .recentViewdProducts
            break
        case .popularProducts:
            vc.screenFrom = .MP_ViewALL_PopularProducts
            vc.mpDataType = .popularProducts
            break
        case .trendingProducts:
            vc.screenFrom = .MP_ViewALL_TrendingProducts
            vc.mpDataType = .trendingProducts
            break
        case .topDealsForYou:
            vc.screenFrom = .MP_ViewALL_TopDealsForYou
            vc.mpDataType = .topDealsForYou
            break
        case .newlyLaunched:
            vc.screenFrom = .MP_ViewALL_NewlyLaunched
            vc.mpDataType = .newlyLaunched
            break
        default:
            break
        }
        vc.str_Title = data.title ?? ""
        vc.arr_Category = arr_Category
        vc.arr_RecentProducts = arr_RecentlyProducts
        vc.arr_PopularProducts = arr_PopularProducts
        vc.arr_ProductTranding = arr_ProductTranding
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = dataSource[section]
        if data.subData.count == 0 { return 0 }
        switch data.type {
        case .category:
            let dic_category = data.subData.first as! MPCategoryModel
            return dic_category.data.count > 0  ? 1 : 0

        case .recentViewdProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .popularProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)
            
        case .trendingProducts:
            return collectionViewNumberOfItemsInSection_Product(collectionView: collectionView, numberOfItemsInSection: section)

        default:
            return 0
        }
    }
    func collectionViewNumberOfItemsInSection_Product(collectionView: UICollectionView, numberOfItemsInSection section: Int)  -> Int {
        let data = dataSource[section]
        let dic_product = data.subData.first as! MPProductModel
        
        return dic_product.data.count > 0  ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        //let height = UIScreen.main.bounds.height
        
        let data = dataSource[indexPath.section]
        switch data.type {
        case .category:
            return CGSize(width: width, height: 150)

        case .recentViewdProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        case .popularProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        
        case .trendingProducts:
            return collectionViewSizeForItemAt_Product(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionViewSizeForItemAt_Product(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource[indexPath.section]
        switch data.type {
        case .category:
            return cellForRow_MPCategoryCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)

        case .recentViewdProducts:
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
            
        case .popularProducts:
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)
        
        case .trendingProducts:
            return cellForRow_MPMainTrendingProductCollectionCell(collectionView: collectionView, cellForItemAt: indexPath)

        default:
            let cell = collectionView.dequeueReusableCell(withClass: MPProductCell.self, for: indexPath)
            
            return cell
        }
    }
    
    func cellForRow_MPCategoryCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPMainTrendingProductCollectionCell.self, for: indexPath)
        
        cell.main_screenFrom = .MP_SearchScreen
        cell.data = dataSource[indexPath.section]
        cell.screenFrom = .MP_categories
        
        return cell
    }
    
    func cellForRow_MPMainTrendingProductCollectionCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPMainTrendingProductCollectionCell.self, for: indexPath)
        cell.current_vc = self
        cell.data = dataSource[indexPath.section]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataSource[indexPath.section]
        
        switch data.type {
        case .category:
            //--
            let dic_category = data.subData.first as! MPCategoryModel
            //--
            let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.str_Title = dic_category.data[indexPath.row].name
            vc.selectCategory = dic_category.data[indexPath.row]
            vc.screenFrom = .MP_categoryProductOnly
            vc.mpDataType = .categoryAllProduct
            self.navigationController?.pushViewController(vc, animated: true)
            break

        case .popularProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break
        case .trendingProducts:
            //--
            didSelectProduct(collectionView: collectionView, didSelectItemAt: indexPath)
            break

        default:
            
            break
        }
        
    }
    
    func didSelectProduct(collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let data = dataSource[indexPath.section]
        let dic_product = data.subData.first as! MPProductModel
        //--
        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.str_productID = "\(dic_product.data[indexPath.row].id)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension MPSearchVC: UITableViewDelegate, UITableViewDataSource {
    func manageSearchResult(){
        
        tblSearchResultList.reloadData()
        tblDoyouMean.reloadData()
        viewDidLayoutSubviews()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblDoyouMean{
            return mpDoyouMeanModel.data.count
        }else{
            return mpSearchResultModel.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblDoyouMean{
            let cell = tableView.dequeueReusableCell(withClass: MPDoYouMeanTblCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            cell.lblTitle.text = mpDoyouMeanModel.data[indexPath.row].title
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withClass: MPSearchResultTblCell.self, for: indexPath)
            
            cell.lblTitle.text = mpSearchResultModel.data[indexPath.row].title
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblDoyouMean{
            if mpDoyouMeanModel.data[indexPath.row].search_type == MPSearchResultType.SearchBrand.rawValue {
                //--
                let dicCategroy = MPCategoryData()
                dicCategroy.id = mpDoyouMeanModel.data[indexPath.row].id
                dicCategroy.name = mpDoyouMeanModel.data[indexPath.row].title
                
                //--
                let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_Title = mpDoyouMeanModel.data[indexPath.row].title
                vc.selectCategory = dicCategroy
                vc.screenFrom = .MP_brandProductOnly
                vc.mpDataType = .brandAllProduct
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if mpDoyouMeanModel.data[indexPath.row].search_type == MPSearchResultType.SearchCategory.rawValue {
                //--
                let dicCategroy = MPCategoryData()
                dicCategroy.id = mpDoyouMeanModel.data[indexPath.row].id
                dicCategroy.name = mpDoyouMeanModel.data[indexPath.row].title
                
                //--
                let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_Title = mpDoyouMeanModel.data[indexPath.row].title
                vc.selectCategory = dicCategroy
                vc.screenFrom = .MP_categoryProductOnly
                vc.mpDataType = .categoryAllProduct
                vc.selected_productID = "\(mpDoyouMeanModel.data[indexPath.row].id)"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                //--
                let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_productID = "\(mpDoyouMeanModel.data[indexPath.row].id)"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            if mpSearchResultModel.data[indexPath.row].search_type == MPSearchResultType.SearchBrand.rawValue{
                //--
                let dicCategroy = MPCategoryData()
                dicCategroy.id = mpSearchResultModel.data[indexPath.row].id
                dicCategroy.name = mpSearchResultModel.data[indexPath.row].title
                
                //--
                let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_Title = mpSearchResultModel.data[indexPath.row].title
                vc.selectCategory = dicCategroy
                vc.screenFrom = .MP_brandProductOnly
                vc.mpDataType = .brandAllProduct
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if mpSearchResultModel.data[indexPath.row].search_type == MPSearchResultType.SearchCategory.rawValue {
                //--
                let dicCategroy = MPCategoryData()
                dicCategroy.id = mpDoyouMeanModel.data[indexPath.row].id
                dicCategroy.name = mpDoyouMeanModel.data[indexPath.row].title
                
                //--
                let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_Title = mpSearchResultModel.data[indexPath.row].title
                vc.selectCategory = dicCategroy
                vc.screenFrom = .MP_categoryProductOnly
                vc.mpDataType = .categoryAllProduct
                vc.selected_productID = "\(mpSearchResultModel.data[indexPath.row].id)"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                //--
                let strproductid = "\(mpSearchResultModel.data[indexPath.row].id)"
                
                mpSearchResultModel = MPSearchResultModel()
                self.manageSearchResult()
                let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_productID = strproductid
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
  
    }
}

extension MPSearchVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            self.btn_speakSearch.isHidden = false
            mpSearchResultModel = MPSearchResultModel()
            manageSearchResult()
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            print(updatedText)
            
            if updatedText == "" {
                self.btn_speakSearch.isHidden = false
            }
            else {
                self.btn_speakSearch.isHidden = true
            }
            
            //--
            callAPIfor_search_item(term: updatedText)
            
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


//MRRK: - Speak to Search
extension MPSearchVC: SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
        
    @IBAction func btn_speakSeach_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        self.txtView.text = ""
        tblSearchResultList_height.constant = 0
        self.is_VoiceDetection = false
        self.isSpeakSearchApiCall = false
        self.speechRecognizer?.delegate = self
        self.btn_tryagain.isHidden = true
        self.btn_tryagain.layer.cornerRadius = 5
        self.btn_tryagain.layer.borderWidth = 2
        self.btn_tryagain.layer.borderColor = UIColor.lightGray.cgColor
        self.view_speak.layer.cornerRadius = self.view_speak.frame.size.height/2
        userAutorization()
    }
    
    @IBAction func btn_remove_speakSeach_Action(_ sender: UIControl) {
        self.remove_speakView()
    }
    
    func remove_speakView() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.UIchangeWhenStopSearch()
        self.view_Main_SpeakSearch.isHidden = true
    }

    func userAutorization(){
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.view_Main_SpeakSearch.isHidden = false
                    self.startSpeakSearch()
                }
                
            case .denied:
                print("User denied access to speech recognition")
            case .restricted:
                print("Speech recognition restricted on this device")
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
        }
    }
        
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            self.is_VoiceDetection = false
            
            if result != nil {
                self.sppechTimer = nil
                self.sppechTimer?.invalidate()
                self.startTimer()
                self.is_VoiceDetection = true
                self.txtView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                if (self.txtView.text ?? "") == "" {
                    self.UIchangeWhenStopSearch()
                }
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
        
    func startTimer() {
        sppechTimer = nil
        sppechTimer?.invalidate()
        sppechTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(methodWorkingforTimer), userInfo: nil, repeats: false)
    }
        
    @objc func methodWorkingforTimer() {
        if self.is_VoiceDetection {
            self.sppechTimer = nil
            self.sppechTimer?.invalidate()
            debugPrint("API Call Star Search=====>>\(self.txtView.text ?? "")")
            
            if self.isSpeakSearchApiCall == false {
                self.isSpeakSearchApiCall = true
                
                //--
                callAPIfor_search_item(term: self.txtView.text ?? "")
                self.remove_speakView()
            }

        }
    }
        
    @IBAction func btn_speakClick(_ sender: UIControl) {
        if audioEngine.isRunning {
            self.stopSearch()
        } else {
            self.startSpeakSearch()
        }
    }

    func startSpeakSearch() {
        startRecording()
        DispatchQueue.main.async {
            self.btn_tryagain.isHidden = true
            self.lbl_title.text = "Speak to search"
            self.view_speak.layer.borderWidth = 0
            self.view_speak.layer.borderColor = UIColor.clear.cgColor
            self.view_speak.backgroundColor = UIColor.init(red: 53/255, green: 120/255, blue: 247/255, alpha: 1)
            self.icon_microphone.image = UIImage.init(named: "icon_microphone_white")
        }
    }
        
    func stopSearch() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.UIchangeWhenStopSearch()
    }
        
    func UIchangeWhenStopSearch() {
        self.txtView.text = ""
        self.is_VoiceDetection = false
        self.btn_tryagain.isHidden = false
        self.view_speak.layer.borderWidth = 10
        self.view_speak.backgroundColor = .white
        self.view_speak.layer.borderColor = UIColor.red.cgColor
        self.lbl_title.text = "Didn't catch that. Try speaking again."
        self.icon_microphone.image = UIImage.init(named: "icon_microphone_blue")
    }

}
