//
//  HowToUseProductVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 21/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper
//import HCVimeoVideoExtractor
import AVKit
import CoreData

class HowToUseProductVC: UIViewController {

    var is_ReadMore = false
    var is_MyProduct = false
    var dic_Datail = JSON()
    var dic_ProducDatail: MPMyOrderProductDetail?
    
    var str_ProductID = ""
    var str_readMoeText = ""
    var arr_HowToUse = [String]()
    var arr_afterCare = [String]()
    var arr_Image_Video = [[String: Any]]()
    var arr_WhetherGuide = [[String: Any]]()
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var lbl_ProductName: UILabel!
    @IBOutlet weak var lbl_Productsub_name: UILabel!
    @IBOutlet weak var view_Base_BG: UIView!
    @IBOutlet weak var lbl_about: UILabel!
    @IBOutlet weak var btn_seeMoreLess: UIButton!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var tbl_HowtoUse: UITableView!
    @IBOutlet weak var tbl_afterCare: UITableView!
    @IBOutlet weak var collection_view_Images: UICollectionView!
    @IBOutlet weak var constraint_tbl_HowtoUse_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_tbl_afterCare_Height: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_Base_BG.isHidden = true
        self.img_Product.layer.cornerRadius = 12
        
        //Register Collection Cell
        self.tbl_HowtoUse.register(nibWithCellClass: HowtoUseTableCell.self)
        self.tbl_afterCare.register(nibWithCellClass: HowtoUseTableCell.self)
        self.collection_view.register(nibWithCellClass: WeatherGuideCollectionCell.self)
        self.collection_view_Images.register(nibWithCellClass: ImageVideoCollectionCell.self)
        
        self.callAPIfor_ProductDetail()
    }
    
    func setupData(detail: [String: Any]) {
        var urlString = ""
        
        if self.is_MyProduct {
            urlString = detail["first_image"] as? String ?? ""
            self.lbl_ProductName.text = detail["title"] as? String ?? ""
            self.lbl_Productsub_name.text = detail["ayurvedic_name"] as? String ?? ""
        }
        else {
            urlString = self.dic_Datail["thumbnail"].stringValue
            self.lbl_ProductName.text = self.dic_Datail["name"].stringValue
            self.lbl_Productsub_name.text = self.dic_Datail["product_sub_name"].string
        }
        
        if let url = URL(string: urlString) {
            self.img_Product.af.setImage(withURL: url)
        }

        self.lbl_about.numberOfLines = 4
        self.str_readMoeText = detail["details"] as? String ?? ""
        self.lbl_about.text = self.str_readMoeText
        let noOfLines = self.lbl_about.calculateMaxLines()
        let readmoreFont = UIFont.systemFont(ofSize: 13)
        let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#1283DA")

        if noOfLines > 4 {
            let strWith_Text = "... "
            let addTrellingText = "Read more   "
            DispatchQueue.main.async {
                self.lbl_about.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
            }
        } else {
            self.lbl_about.numberOfLines = 0
            self.btn_seeMoreLess.isHidden = true
        }
        
        let str_HowtoApply = detail["how_to_apply"] as? String ?? ""
        let strText = str_HowtoApply.trimHTMLTags() ?? ""
        var trimmed = strText.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmed = trimmed.replacingOccurrences(of: "\t", with: "")
        trimmed = trimmed.replacingOccurrences(of: "\n", with: "")
        let arr_use = trimmed.components(separatedBy: "•")
        var int_howtouse_Height: CGFloat = 0
        for str_howtoUse in arr_use {
            if str_howtoUse != "" {
                let getHeight = str_howtoUse.height(withConstrainedWidth: (UIScreen.main.bounds.width - 82), font: UIFont.systemFont(ofSize: 13))
                int_howtouse_Height = int_howtouse_Height + getHeight + 30
                self.arr_HowToUse.append(str_howtoUse)
            }
        }
        self.constraint_tbl_HowtoUse_Height.constant = int_howtouse_Height
        
        
        let str_aftercare_guide = detail["aftercare_guide"] as? String ?? ""
        let strText1 = str_aftercare_guide.trimHTMLTags() ?? ""
        var trimmed1 = strText1.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmed1 = trimmed1.replacingOccurrences(of: "\t", with: "")
        trimmed1 = trimmed1.replacingOccurrences(of: "\n", with: "")
        let arr_aftercare = trimmed1.components(separatedBy: "•")
        var int_after_caree_Height: CGFloat = 0
        for str_after_care in arr_aftercare {
            if str_after_care != "" {
                let getHeight = str_after_care.height(withConstrainedWidth: (UIScreen.main.bounds.width - 82), font: UIFont.systemFont(ofSize: 13))
                int_after_caree_Height = int_after_caree_Height + getHeight + 30
                self.arr_afterCare.append(str_after_care)
            }
        }
        self.constraint_tbl_afterCare_Height.constant = int_after_caree_Height
        self.arr_WhetherGuide = detail["weather_guide"] as? [[String: Any]] ?? [[:]]

        let arr_Images = detail["images"] as? [[String: Any]] ?? [[:]]
        let arr_Videos = detail["videos"] as? [[String: Any]] ?? [[:]]
        if arr_Images.count != 0 {
            self.arr_Image_Video = arr_Images
        }
        else {
            self.arr_Image_Video.append(["id" : "1", "image": urlString])
        }
        if arr_Videos.count != 0 {
            for dic_video in arr_Videos {
                self.arr_Image_Video.append(dic_video)
            }
        }
        
        self.collection_view_Images.reloadData()
        self.tbl_HowtoUse.reloadData()
        self.tbl_afterCare.reloadData()
        self.collection_view.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btn_readMore_Action(_ sender: UIButton) {
        let readmoreFont = UIFont.systemFont(ofSize: 13)
        let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#1283DA")
        
        if self.is_ReadMore {
            self.is_ReadMore = false
            let strWith_Text = "... "
            self.lbl_about.numberOfLines = 4
            self.lbl_about.text = self.str_readMoeText
            let addTrellingText = "Read more   "
            self.view.layoutIfNeeded()
            DispatchQueue.main.async {
                self.lbl_about.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
            }
        }
        else {
            self.is_ReadMore = true
            let strWith_Text = "   "
            self.lbl_about.numberOfLines = 0
            self.lbl_about.text = self.str_readMoeText
            let addTrellingText = "Read less   "
            self.view.layoutIfNeeded()
            DispatchQueue.main.async {
                self.lbl_about.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
            }
        }
    }

}

//MARK: - UICollectionView Delegate DataSource Method
extension HowToUseProductVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collection_view_Images {
            return self.arr_Image_Video.count
        }
        return self.arr_WhetherGuide.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collection_view_Images {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageVideoCollectionCell", for: indexPath) as! ImageVideoCollectionCell
            cell.img_playPause.isHidden = true
            
            let dic = self.arr_Image_Video[indexPath.row]
            let strImage = dic["image"] as? String ?? ""
            if strImage != "" {
                cell.img_playPause.isHidden = true
                if let url = URL(string: strImage) {
                    cell.img_product.af.setImage(withURL: url)
                }
            }
            else {
                let strVideo = dic["video"] as? String ?? ""
                if strVideo != "" {
                    cell.img_playPause.isHidden = false
                    
                    //Temp comment
//                    if let url = URL(string: strVideo) {
//                        HCVimeoVideoExtractor.fetchVideoURLFrom(url: url, completion: { ( video:HCVimeoVideo?, error:Error?) -> Void in
//                            if let err = error {
//                                print("Error = \(err.localizedDescription)")
//                                DispatchQueue.main.async() {
//                                    cell.img_product.image = nil
//                                }
//                                return
//                            }
//
//                            guard let vid = video else {
//                                print("Invalid video object")
//                                return
//                            }
//
//                            print("Title = \(vid.title), url = \(vid.videoURL), thumbnail = \(vid.thumbnailURL)")
//
//                            DispatchQueue.main.async() {
//                                var url_video = vid.videoURL[.quality1080p]
//                                if url_video == nil {
//                                    url_video = vid.videoURL[.quality960p]
//                                }
//                                if url_video == nil {
//                                    url_video = vid.videoURL[.quality720p]
//                                }
//                                if url_video == nil {
//                                    url_video = vid.videoURL[.quality640p]
//                                }
//                                if url_video == nil {
//                                    url_video = vid.videoURL[.quality540p]
//                                }
//                                if url_video == nil {
//                                    url_video = vid.videoURL[.quality360p]
//                                }
//                                if url_video == nil {
//                                    url_video = vid.videoURL[.qualityUnknown]
//                                }
//                                cell.img_product.accessibilityLabel = url_video?.absoluteString ?? ""
//
//                                if let url = vid.thumbnailURL[.qualityBase] {
//                                    cell.img_product.af.setImage(withURL: url)
//                                }
//                            }
//                        })
//                    }
                    
                    
                }
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherGuideCollectionCell", for: indexPath) as! WeatherGuideCollectionCell
            
            let dic = self.arr_WhetherGuide[indexPath.row]
            cell.lbl_Title.text = dic["title"] as? String ?? ""
            cell.lbl_subTitle.text = dic["sub_title"] as? String ?? ""
            
            let iconURL = dic["icon"] as? String ?? ""
            if let url = URL(string: iconURL) {
                cell.img_icon.af.setImage(withURL: url)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collection_view_Images {
            return CGSize.init(width: UIScreen.main.bounds.width, height: collectionView.bounds.size.height)
        }
        else {
            return CGSize.init(width: (collectionView.bounds.size.width/3) - 8, height: collectionView.bounds.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collection_view_Images {
            let dic = self.arr_Image_Video[indexPath.row]
            let strVideo = dic["video"] as? String ?? ""
            if strVideo != "" {

                if let current_cell = self.collection_view_Images.cellForItem(at: indexPath) as? ImageVideoCollectionCell {
                    let str_videoURL = current_cell.img_product.accessibilityLabel ?? ""
                    if let url = URL.init(string: str_videoURL) {
                        let player = AVPlayer(url: url)
                        let playerController = AVPlayerViewController()
                        playerController.player = player
                        self.present(playerController, animated: true) {
                            player.play()
                        }
                    }
                }
                
            }
        }
    }
    
}

//MARK: - UITableView Delegate DataSource Method
extension HowToUseProductVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tbl_HowtoUse {
            return self.arr_HowToUse.count
        }
        return self.arr_afterCare.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tbl_HowtoUse {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HowtoUseTableCell", for: indexPath) as! HowtoUseTableCell
            cell.selectionStyle = .none
            cell.icon_aftercare.isHidden = true
            cell.view_counter_Bg.isHidden = false
            cell.lbl_title.text = self.arr_HowToUse[indexPath.row]
            cell.lbl_count.text = "\(indexPath.row + 1)"
            cell.lbl_top_line.isHidden = indexPath.row == 0 ? true : false
            cell.lbl_bottom_line.isHidden = (indexPath.row + 1) == self.arr_HowToUse.count ? true : false
            cell.lbl_title.textColor = UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HowtoUseTableCell", for: indexPath) as! HowtoUseTableCell
            cell.selectionStyle = .none
            cell.lbl_count.text = ""
            cell.lbl_top_line.isHidden = true
            cell.lbl_bottom_line.isHidden = true
            cell.icon_aftercare.isHidden = false
            cell.view_counter_Bg.isHidden = true
            cell.lbl_title.text = self.arr_afterCare[indexPath.row]
            cell.lbl_title.textColor = UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


//MARK: - API CALLING
extension HowToUseProductVC {
    
    func callAPIfor_ProductDetail() {
        
        showActivityIndicator()
        var finlName = ""
        let nameAPI: endPoint = .mp_howtouse_product
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        if self.is_MyProduct {
            finlName = String(format: nameAPI.rawValue, self.str_ProductID)
        }
        else {
            finlName = String(format: nameAPI.rawValue, self.dic_Datail["product_id"].stringValue)
        }

        Utils.doAPICallMartketPlace(endPoint: finlName, method: .get, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                if let dicdetails = responseJSON?.dictionaryValue["data"]?.dictionaryObject {
                    self.view_Base_BG.isHidden = false
                    self.setupData(detail: dicdetails)
                }
            }else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
}




//extension UILabel {
//
//    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
//        let readMoreText: String = trailingText + moreText
//        
//        let lengthForVisibleString: Int = self.vissibleTextLength
//        let mutableString: String = self.text!
//        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
//        let readMoreLength: Int = (readMoreText.count)
//        
//        
//        var trimmedForReadMore: String = ""
//        if moreText == "Read more" {
//            trimmedForReadMore = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
//        }
//        else {
//            trimmedForReadMore = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: (trimmedString?.count ?? 0), length: 0), with: "") + trailingText
//        }
//        
//        let answerAttributed = NSMutableAttributedString.init(string: trimmedForReadMore)
//        answerAttributed.addAttribute(NSAttributedString.Key.font, value: self.font!, range: NSRange.init(location: 0, length: answerAttributed.length))
//        
//        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
//
//        answerAttributed.append(readMoreAttributed)
//        self.attributedText = answerAttributed
//    }
//
//        var vissibleTextLength: Int {
//            let font: UIFont = self.font
//            let mode: NSLineBreakMode = self.lineBreakMode
//            let labelWidth: CGFloat = self.frame.size.width
//            let labelHeight: CGFloat = self.frame.size.height
//            let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
//
//            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
//            let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
//            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
//
//            if boundingRect.size.height > labelHeight {
//                var index: Int = 0
//                var prev: Int = 0
//                let characterSet = CharacterSet.whitespacesAndNewlines
//                repeat {
//                    prev = index
//                    if mode == NSLineBreakMode.byCharWrapping {
//                        index += 1
//                    } else {
//                        index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
//                    }
//                } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
//                return prev
//            }
//            return self.text!.count
//        }
//    }




extension String {
    public func trimHTMLTags() -> String? {
        guard let htmlStringData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
    
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
    
        let attributedString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        return attributedString?.string
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
