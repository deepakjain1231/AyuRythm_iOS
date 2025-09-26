//
//  MPMyOrderReviewVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 20/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Cosmos
import Alamofire

protocol delegateScreenRefresh {
    func screenRefresh(_ is_success: Bool)
}

class MPMyOrderReviewVC: UIViewController, UITextViewDelegate {

    var product_id = ""
    var product_rating_id = ""
    var placeholderText = "Please write your review here"
    var dic_ProductDetail: MPMyOrderProductDetail?
    var dic_ProductDetail_fromDetail: MPProductData?
    
    var is_fromProductDetail = false
    var delegate: delegateScreenRefresh?
    
    @IBOutlet weak var rating_product: CosmosView!
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var lbl_product_Title: UILabel!
    @IBOutlet weak var lbl_product_subTitle: UILabel!
    @IBOutlet weak var txt_View: UITextView!
    @IBOutlet weak var view_addPhotos: UIView!
    @IBOutlet weak var lbl_addPhoto_Title: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraint_collection_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_addPhoto_View_Height: NSLayoutConstraint!
    
    var mediaPicker: PDImagePicker?
    var mediaFileLimit: Int = 5
    var medias = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        self.updateUI()
        self.setupValue()
        self.txt_View.delegate = self
        self.txt_View.textColor = .lightGray
        self.txt_View.layer.cornerRadius = 12
        self.txt_View.layer.borderWidth = 1
        self.collectionView.isHidden = true
        self.constraint_collection_Height.constant = 0
        self.txt_View.layer.borderColor = UIColor.fromHex(hexString: "#E5E5E5").cgColor
        self.txt_View.textContainerInset = UIEdgeInsets(top: 22, left: 22, bottom: 12, right: 12)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
    }
    
    func setupUI() {
        collectionView.setupUISpace(allSide: 0, itemSpacing: 12, lineSpacing: 12)
        collectionView.register(nibWithCellClass: ARFeedPostMediaCell.self)
    }
    
    
    func setupValue() {
        if self.is_fromProductDetail {
            self.product_id = "\(self.dic_ProductDetail_fromDetail?.id ?? 0)"
            self.product_rating_id = "\(self.dic_ProductDetail_fromDetail?.rating_conditions?.rating_review_id ?? 0)"
            let strImgPrroduct = self.dic_ProductDetail_fromDetail?.thumbnail ?? ""
            if strImgPrroduct != "" {
                if let url = URL(string: strImgPrroduct) {
                    self.img_product.af_setImage(withURL: url, placeholderImage: UIImage.init(named: "default_image"))
                }
                else {
                    self.img_product.image = UIImage.init(named: "default_image")
                }
            }
            else {
                self.img_product.image = UIImage.init(named: "default_image")
            }
            self.lbl_product_Title.text = self.dic_ProductDetail_fromDetail?.title ?? ""
            self.lbl_product_subTitle.text = self.dic_ProductDetail_fromDetail?.sizes.first ?? ""
            self.rating_product.rating = Double(self.dic_ProductDetail_fromDetail?.rating_conditions?.rating_given ?? 0)
        }
        else {
            self.product_id = "\(self.dic_ProductDetail?.id ?? 0)"
            self.product_rating_id = "\(self.dic_ProductDetail?.rating_review_id ?? 0)"
            let strImgPrroduct = self.dic_ProductDetail?.feature_image ?? ""
            if strImgPrroduct != "" {
                if let url = URL(string: strImgPrroduct) {
                    self.img_product.af_setImage(withURL: url, placeholderImage: UIImage.init(named: "default_image"))
                }
                else {
                    self.img_product.image = UIImage.init(named: "default_image")
                }
            }
            else {
                self.img_product.image = UIImage.init(named: "default_image")
            }
            self.lbl_product_Title.text = self.dic_ProductDetail?.name ?? ""
            self.lbl_product_subTitle.text = self.dic_ProductDetail?.size ?? ""
            self.rating_product.rating = Double(self.dic_ProductDetail?.rating ?? 0)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let str_Text = textView.text {
            if str_Text == placeholderText {
                textView.text = ""
                textView.textColor = .black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let str_Text = textView.text {
            if str_Text == placeholderText || str_Text == ""  {
                textView.text = placeholderText
                textView.textColor = .lightGray
            }
        }
    }
    
    func showMediaPicker() {
        guard medias.count < 6 else {
            showAlert(message: "Maximum \(mediaFileLimit) media files allowed in post")
            return
        }
        
        if mediaPicker == nil {
            mediaPicker = PDImagePicker(presentingVC: self, delegate: self, mediaTypes: [.image], allowsEditing: true)
        }
        mediaPicker?.present()
    }
    
    

    // MARK: - UIButton method
    @IBAction func btn_AddPhotos_Action(_ sender: UIControl) {
        //show media picker
        showMediaPicker()
    }
    
    @IBAction func btn_OrderReview_Action(_ sender: UIControl) {
        let ratinggg = self.rating_product.rating
        if ratinggg == 0 {
            kSharedAppDelegate.window?.rootViewController?.showToast(message: "Please add rating")
            return
        }
        else {
            var strReviewText = self.txt_View.text ?? ""
            if strReviewText == placeholderText {
                strReviewText = ""
            }
            self.callAPIforUploadRatingAndReviewImages(reviewText: strReviewText)
        }
        
    }
    
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MPMyOrderReviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ARFeedPostMediaCell.self, for: indexPath)
        cell.deleteBtn.tag = indexPath.row
        cell.particular_media = medias[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //show media picker
            showMediaPicker()
        } else {
            let media = medias[indexPath.row]
            print(">> select media : ", media)
        }
    }
}


extension MPMyOrderReviewVC: ARFeedPostMediaCellDelegate {
    func feedPostMediaCell(cell: ARFeedPostMediaCell, didDeleteAt index: Int) {
        ARLog("Delete media at index : \(index)")
        medias.remove(at: index)
        if self.medias.count == 0 {
            self.collectionView.isHidden = true
            self.constraint_collection_Height.constant = 0
            self.lbl_addPhoto_Title.text = "Click here to more photos"
            self.view.layoutIfNeeded()
        }
        else {
            self.view_addPhotos.isHidden = false
            self.constraint_addPhoto_View_Height.constant = 100
            self.view.layoutIfNeeded()
        }
        updateUI()
    }
}

extension MPMyOrderReviewVC: PDImagePickerDelegate {
    func imagePicker(_ imagePicker: PDImagePicker, didSelectImage image: UIImage?) {
        if let image = image {
            medias.append(image)
            if medias.count == 1 {
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                self.constraint_collection_Height.constant = 120
                self.lbl_addPhoto_Title.text = "Click here to add more photos"
                self.view.layoutIfNeeded()
            }
            if medias.count == 5 {
                self.view_addPhotos.isHidden = true
                self.constraint_addPhoto_View_Height.constant = 0
            }
            updateUI()
        }
    }
    
    func updateUI() {
        self.collectionView.reloadData()
        self.collectionView.selectItem(at: IndexPath.init(row: (self.medias.count - 1), section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
}


//MARK: - API Call
extension MPMyOrderReviewVC {
    
    //MARK: - upload multiple photos

    func callAPIforUploadRatingAndReviewImages(reviewText: String) {
        
        self.showActivityIndicator()
        let nameAPI: endPoint = .mp_user_product_submitRating
        let urlString = kBaseUrl_MarketPlace + nameAPI.rawValue
        
        var parram = ["review": reviewText,
                      "product_id": product_id,
                      "rating": "\(Int(self.rating_product.rating))"] as [String : Any]
        
        if self.product_rating_id == "" && self.product_rating_id == "0" {
        }
        else {
            parram["rating_id"] = self.product_rating_id
        }

        ServiceCustom.shared.requestMultiPartWithUrlAndParameters(urlString, Method: "POST", headerssss: MPLoginLocalDB.getHeaderToken(true), parameters: parram, fileParameterName: "image", arr_ImgMedia: self.medias, mimeType: "image/jpeg") { requestttt, urlresponsess, dictionaryyyyy, dataaaa in
            debugPrint(dictionaryyyyy)
            let is_status = dictionaryyyyy
            self.delegate?.screenRefresh(true)
            self.navigationController?.popViewController(animated: true)
            self.hideActivityIndicator()
        } failure: { errorrr in
            debugPrint(errorrr)
            self.hideActivityIndicator()
        }
        
        
        
        
        
        
        
        
        /*
        guard let url = try? URLRequest(url: urlString, method: .post, headers: MPLoginLocalDB.getHeaderToken(true)) else {return}
        AF.upload(multipartFormData: { (multipartData) in
            
            for i in 0 ..< self.medias.count {
                if let imageData = self.medias[i].pngData(){
                    let mediaName = "image\(i + 1)"
                    multipartData.append(imageData, withName:mediaName, fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "image/jpeg")
                }
            }
            for (key, value) in parram {
                multipartData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: urlString, headers: MPLoginLocalDB.getHeaderToken(true)).responseJSON(queue: .main, options: .allowFragments) { (response) in
            self.hideActivityIndicator()
            switch response.result{
            case .success(let value):
                print("Json: \(value)")
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }.uploadProgress { (progress) in
            print("Progress: \(progress.fractionCompleted)")
        }*/
    }

}
