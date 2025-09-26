//
//  SparshnaTestInfoViewController.swift
//  HourOnEarth
//
//  Created by Apple on 13/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class SparshnaTestInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var tblTest: UITableView!
    @IBOutlet weak var btnStartNow: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var isBackBtnVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        btnStartNow.isUserInteractionEnabled = false
        self.navigationController?.isNavigationBarHidden = true
        tblTest.estimatedRowHeight = 300
        btnBack.isHidden = !isBackBtnVisible
     //   lblHeading.attributedText = getAttributedText()
        // Do any additional setup after loading the view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let modelName = UIDevice.modelName
        print("Using Device, running on: \(modelName)")
    }
    
    func getAttributedText() -> NSMutableAttributedString {
        let str_subTitleText = "sparshna_subTitle".localized()
        let str_step1_Text = "sparshna_step1".localized()
        let str_step2_Text = "sparshna_step2".localized()
        let str_step3_Text = "sparshna_step3".localized()
        let str_step4_Text = "sparshna_step4".localized()
        let str_disclimer_Text = "sparshna_disclimer".localized()
        let str_reference_Text = "sparshna_reference".localized()
        
        let strFullTEXT = str_subTitleText + "\n\n" + str_step1_Text + "\n\n" + str_step2_Text + "\n\n" + str_step3_Text + "\n\n" + str_step4_Text + "\n\n" + str_disclimer_Text + "\n\n" + str_reference_Text

        let newText = NSMutableAttributedString.init(string: strFullTEXT)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        paragraphStyle.alignment = .left

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(14), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange.init(location: 0, length: newText.length))
        
        
        let textRange = NSString(string: strFullTEXT)
        let highlight_range1 = textRange.range(of: str_subTitleText)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(14), range: highlight_range1)
        
        let highlight_step1 = textRange.range(of: str_step1_Text)
        let highlight_step2 = textRange.range(of: str_step2_Text)
        let highlight_step3 = textRange.range(of: str_step3_Text)
        let highlight_step4 = textRange.range(of: str_step4_Text)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(14), range: highlight_step1)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(14), range: highlight_step2)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(14), range: highlight_step3)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(14), range: highlight_step4)
        
        let highlight_disclimer = textRange.range(of: str_disclimer_Text)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(14), range: highlight_disclimer)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#FB5119"), range: highlight_disclimer)
        
        let highlight_reference = textRange.range(of: str_reference_Text)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(16), range: highlight_reference)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#EF3061"), range: highlight_reference)
        
        return newText
        
        
        
        
        /*
        let attributedString = NSMutableAttributedString(string: strFullTEXT, attributes: [.font: UIFont.AppFontRegular(14), .foregroundColor: UIColor.black, .kern: -0.08
        ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 522, length: 57) : NSRange(location: 477, length: 48))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 689, length: 3) : NSRange(location: 641, length: 4))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 716, length: 3) : NSRange(location: 674, length: 4))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 738, length: 12) : NSRange(location: 704, length: 12))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 780, length: 10) : NSRange(location: 746, length: 13))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 820, length: 2) : NSRange(location: 790, length: 4))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 849, length: 7) : NSRange(location: 827, length: 8))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 881, length: 3) : NSRange(location: 861, length: 4))
        
        attributedString.addAttribute(.foregroundColor, value: kAppPinkColor, range: Utils.isAppInHindiLanguage ? NSRange(location: attributedString.length - 174, length: 162) : NSRange(location: attributedString.length - 180, length: 170))
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: attributedString.length - 11, length: 10))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: NSRange(location: attributedString.length - 11, length: 10))
        return attributedString
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if let headerView = tblTest.tableHeaderView {
//
//            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//            var headerFrame = headerView.frame
//
//            //Comparison necessary to avoid infinite loop
//            if height != headerFrame.size.height {
//                headerFrame.size.height = height
//                headerView.frame = headerFrame
//                tblTest.tableHeaderView = headerView
//            }
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNative") else {
                return UITableViewCell()
            }
            cell.textLabel?.attributedText = self.getAttributedText()
            return cell
        } else {
            
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "testCell") else {
            return UITableViewCell()
        }
        let txtView = cell.viewWithTag(1000) as! UITextView
            txtView.isScrollEnabled = false
        let mutableAttributed = NSMutableAttributedString(string: "", attributes: [
          .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.08
        ])
            let attributedString = NSMutableAttributedString(string: "1. Determination of SpO2 and heart-rate using smartphone camera. READ MORE\n".localized(), attributes: [
          .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.08
        ])
        attributedString.addAttribute(.link, value: "https://ieeexplore.ieee.org/abstract/document/6959086", range: Utils.isAppInHindiLanguage ? NSRange(location: attributedString.length - 11, length: 10) : NSRange(location: attributedString.length - 10, length: 9))
        mutableAttributed.append(attributedString)
        
            let attributedString1 = NSMutableAttributedString(string: "2. A novel application for the detection of an irregular pulse using an iPhone 4S in patients with atrial fibrillation. READ MORE\n".localized(), attributes: [
          .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.08
        ])
        attributedString1.addAttribute(.link, value: "https://www.sciencedirect.com/science/article/abs/pii/S154752711201435X", range: Utils.isAppInHindiLanguage ? NSRange(location: attributedString1.length - 11, length: 10) : NSRange(location: attributedString1.length - 10, length: 9))
        mutableAttributed.append(attributedString1)

            let attributedString2 = NSMutableAttributedString(string: "3. Blood Pressure estimation using Photoplethysmography with telemedicine application. READ MORE\n".localized(), attributes: [
          .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.08
        ])
        attributedString2.addAttribute(.link, value: "https://search.proquest.com/openview/31c99056841c638798fa36dea8871310/1?pq-origsite=gscholar&cbl=18750&diss=y", range: Utils.isAppInHindiLanguage ? NSRange(location: attributedString2.length - 11, length: 10) : NSRange(location: attributedString2.length - 10, length: 9))
        mutableAttributed.append(attributedString2)

            let attributedString3 = NSMutableAttributedString(string: "4. An exploratory clinical study to determine the utility of Heart Rate variability analysis in the assessment of dosha imbalance. READ MORE\n".localized(), attributes: [
          .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.08
        ])
        attributedString3.addAttribute(.link, value: "https://www.sciencedirect.com/science/article/pii/S0975947617301158", range: Utils.isAppInHindiLanguage ? NSRange(location: attributedString3.length - 11, length: 10) : NSRange(location: attributedString3.length - 10, length: 9))
        mutableAttributed.append(attributedString3)

        txtView.delegate = self
        txtView.attributedText = mutableAttributed
        return cell
        }
    }
//
//    fileprivate func resize(textView: UITextView) {
//        let width = newFrame.size.width
//        let newSize = textView.sizeThatFits(CGSize(width: width,
//                                                   height: CGFloat.greatestFiniteMagnitude))
//        newFrame.size = CGSize(width: width, height: newSize.height)
//        textView.frame = newFrame
//    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    @IBAction func readAgreementClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        btnStartNow.isUserInteractionEnabled = sender.isSelected
    }
    
    @IBAction func doNotShowClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        kUserDefaults.set(sender.isSelected, forKey: kDoNotShowTestInfo)
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startClicked(_ sender: Any) {
        let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
        objSlideView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(objSlideView, animated: true)
        
        /*
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
        objAlert.hidesBottomBarWhenPushed = true
        objAlert.modalPresentationStyle = .overCurrentContext
        objAlert.completionHandler = {
            let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
            objSlideView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objSlideView, animated: true)
        }
        self.present(objAlert, animated: true)
        */
    }
}










//public extension UIDevice {
//    var identifier: String {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
//            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
//                ptr in String.init(validatingUTF8: ptr)
//            }
//        }
//        if modelCode == "x86_64" {
//            if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
//                if let simMap = String(validatingUTF8: simModelCode) {
//                    return simMap
//                }
//            }
//        }
//        return modelCode ?? "?unrecognized?"
//    }
//}
class WikiDevice {
    static func model(_ completion: @escaping ((String) -> ())){
        let unrecognized = "?unrecognized?"
        guard let wikiUrl=URL(string:"https://www.theiphonewiki.com//w/api.php?action=parse&format=json&page=Models") else { return completion(unrecognized) }
        var identifier: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let modelCode = withUnsafePointer(to: &systemInfo.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String.init(validatingUTF8: ptr)
                }
            }
            if modelCode == "x86_64" {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simMap = String(validatingUTF8: simModelCode) {
                        return simMap
                    }
                }
            }
            return modelCode ?? unrecognized
        }
        guard identifier != unrecognized else { return completion(unrecognized)}
        let request = URLRequest(url: wikiUrl)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data,
                    let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode,
                    error == nil else { return completion(unrecognized) }
                guard let convertedString = String(data: data, encoding: String.Encoding.utf8) else { return completion(unrecognized) }
                var wikiTables = convertedString.components(separatedBy: "wikitable")
                wikiTables.removeFirst()
                var tables = [[String]]()
                wikiTables.enumerated().forEach{ index,table in
                    let rawRows = table.components(separatedBy: #"<tr>\n<td"#)
                    var counter = 0
                    var rows = [String]()
                    while counter < rawRows.count {
                        let rawRow = rawRows[counter]
                        if let subRowsNum = rawRow.components(separatedBy: #"rowspan=\""#).dropFirst().compactMap({ sub in
                            (sub.range(of: #"\">"#)?.lowerBound).flatMap { endRange in
                                String(sub[sub.startIndex ..< endRange])
                            }
                        }).first {
                            if let subRowsTot = Int(subRowsNum) {
                                var otherRows = ""
                                for i in counter..<counter+subRowsTot {
                                    otherRows += rawRows[i]
                                }
                                let row = rawRow + otherRows
                                rows.append(row)
                                counter += subRowsTot-1
                            }
                        } else {
                            rows.append(rawRows[counter])
                        }
                        counter += 1
                    }
                    tables.append(rows)
                }
                for table in tables {
                    if let rowIndex = table.firstIndex(where: {$0.lowercased().contains(identifier.lowercased())}) {
                        let rows = table[rowIndex].components(separatedBy: "<td>")
                        if rows.count>0 {
                            if rows[0].contains("title") { //hyperlink
                                if let (cleanedGen) = rows[0].components(separatedBy: #">"#).dropFirst().compactMap({ sub in
                                    (sub.range(of: "</")?.lowerBound).flatMap { endRange in
                                        String(sub[sub.startIndex ..< endRange]).replacingOccurrences(of: #"\n"#, with: "")
                                    }
                                }).first {
                                    completion(cleanedGen)
                                }
                            } else {
                                let raw = rows[0].replacingOccurrences(of: "<td>", with: "")
                                let cleanedGen = raw.replacingOccurrences(of: #"\n"#, with: "")
                                completion(cleanedGen)
                            }
                            return
                        }
                    }
                }
                completion(unrecognized)
            }
        }.resume()
    }
}
