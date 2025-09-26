//
//  Extensions.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 12/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// MARK: -
extension UIDevice {
    static var isiPadDevice: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}


extension UIFont {
    
    public class func AppFontOpenSansRegular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans", size: fontSize)!
    }
    
    public class func AppFontOpenSansSemiBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: fontSize)!
    }
    
    public class func AppFontOpenSansBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: fontSize)!
    }
    
    
    public class func AppFontRegular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Regular", size: fontSize)!
    }
    public class func AppFontBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Bold", size: fontSize)!
    }
    public class func AppFontSemiBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-SemiBold", size: fontSize)!
    }
    
    public class func AppFontLight(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Light", size: fontSize)!
    }
    
    public class func AppFontExtraBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-ExtraBold", size: fontSize)!
    }
    
    public class func AppFontMedium(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-Medium", size: fontSize)!
    }
    
    public class func AppFontExtraLight(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Inter-ExtraLight", size: fontSize)!
    }
    
}

// MARK: -
extension UICollectionView {
    func setupUISpace(allSide space: CGFloat = 0, itemSpacing:  CGFloat = 0, lineSpacing: CGFloat = 0) {
        setupUISpace(top: space, left: space, bottom: space, right: space, itemSpacing: itemSpacing, lineSpacing: lineSpacing)
    }
    
    func setupUISpace(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing:  CGFloat = 0, lineSpacing: CGFloat = 0) {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func widthOfItemCellFor(noOfCellsInRow: Int, view: UIView? = nil, isForce: Bool = false) -> CGFloat {
        let noOfCellsInRow = isForce ? noOfCellsInRow : (UIDevice.isiPadDevice ? noOfCellsInRow * 2 : noOfCellsInRow)  //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let width = view != nil ? UIScreen.main.bounds.size.width : frame.width
        return floor((width - totalSpace) / CGFloat(noOfCellsInRow))
    }
}


// MARK: -
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: -

extension UIViewController {
    func setBackButtonTitle() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
}

extension UILabel{
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}

extension Int {
    var stringValue: String {
        return String(self)
    }
}

extension Bool {
    var intValue: Int {
        return self == true ? 1 : 0
    }
    var stringValue: String {
        return self == true ? "1" : "0"
    }
}

extension Float {
    var stringValue: String {
        return String(self)
    }
}

@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

extension UIBarButtonItem {
    convenience init(image :UIImage, title :String, target: Any?, action: Selector?) {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.frame = CGRect(x: 0, y: 0, width: image.size.width + 46, height: image.size.height)
        //button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        self.init(customView: button)
    }
}

extension String {
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var floatValue: Float {
        return Float(self) ?? 0
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func getHtmlToAttributedString(fontSize: Int = 17) -> NSAttributedString? {
        let newString = "<div style=\"font-family: -apple-system, BlinkMacSystemFont, sans-serif;font-size: \(fontSize)px\">\(self)</div>"
        return newString.htmlToAttributedString
    }
    
    var isHtmlString: Bool {
        let validateTest = NSPredicate(format:"SELF MATCHES %@", "<[a-z][\\s\\S]*>")
        return validateTest.evaluate(with: self)
    }
}

extension UILabel {
    func setHtmlText(text: String, fontSize: Int? = nil) {
        let fSize = fontSize ?? Int(self.font.pointSize)
        self.attributedText = text.getHtmlToAttributedString(fontSize: fSize)
    }
}

extension UIView {
    func makeItRounded() {
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
        //layer.borderWidth = 3.0
        //layer.borderColor = UIColor.white.cgColor
    }
}

extension Int {
    var twoDigitStringValue: String {
        return String(format: "%02d", self)
    }
    
    var dayStrValue: String {
        return self > 1 ? "days".localized() : "day".localized()
    }
}

extension String {
    var dayStrValue: String {
        return Int(self)?.dayStrValue ?? "day".localized()
    }
}

extension Double {
    var nonDecimalStringValue: String {
        return String(format: "%.0f", self)
    }
    
    var twoDigitStringValue: String {
        return String(format: "%.2f", self)
    }
}

extension UIViewController {
    func popToViewController<T : UIViewController>(_ vcClass: T.Type, animated: Bool = true) {
        if let navVC = self.navigationController, let popToVC = navVC.viewControllers.first(where: { $0.isKind(of: vcClass) }) {
            navVC.popToViewController(popToVC, animated: animated)
        }
    }
}

extension UIViewController {
    func fixAutoHeightTableHeader(of tableView: UITableView, verticalFittingPriority: UILayoutPriority = .fittingSizeLevel) {
        guard let headerView = tableView.tableHeaderView else { return }
        let size = headerView.systemLayoutSizeFitting(headerView.frame.size, withHorizontalFittingPriority: UILayoutPriority.defaultHigh, verticalFittingPriority: verticalFittingPriority)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
}

// MARK: -
// https://gist.github.com/tijme/14ec04ef6a175a70dd5a759e7ff0b938
extension UITextView: UITextViewDelegate {
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    public var placeholderColor: UIColor? {
        get {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                return placeholderLabel.textColor
            }
            return nil
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.textColor = newValue
            }
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    public func resizePlaceholder(topPadding: CGFloat = 0, leftPadding: CGFloat = 0) {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding + self.textContainerInset.left + leftPadding
            let labelY = self.textContainerInset.top - 2 + topPadding
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}

// MARK: -
class AutoExpandingTextView: UITextView {
    
    private var heightConstraint: NSLayoutConstraint!
    
    var maxHeight: CGFloat = 100 {
        didSet {
            heightConstraint?.constant = maxHeight
        }
    }
    
    private var observer: NSObjectProtocol?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        heightConstraint = heightAnchor.constraint(equalToConstant: maxHeight)
        
        observer = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.heightConstraint.isActive = self.contentSize.height > self.maxHeight
            self.isScrollEnabled = self.contentSize.height > self.maxHeight
            self.invalidateIntrinsicContentSize()
        }
    }
}

// MARK: -
class ResizableButton: UIButton {
    override var intrinsicContentSize: CGSize {
        let imageViewWidth = imageView?.frame.width ?? 0.0
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right + imageViewWidth, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        
        return desiredButtonSize
    }
}


//MARK:- Terms Lable Tap

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    func didTapAttributedTextInTextView(txtView: UITextView, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: txtView.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        let labelSize = txtView.bounds.size
        textContainer.size = labelSize
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: txtView)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
}


extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}




//MARK:- For PullTo Refresh TableView
extension UITableView {
    
    func pullTorefresh(_ target: Selector, tintcolor: UIColor,_ toView: UIViewController?){
        let refrshControll = UIRefreshControl()
        refrshControll.tintColor = tintcolor
        refrshControll.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
        refrshControll.addTarget(toView!, action: target, for: UIControl.Event.valueChanged)
        self.refreshControl = refrshControll
    }
    
    func closeEndPullRefresh(){
        self.refreshControl?.endRefreshing()
    }
}


extension String {
    
    func isValidMobile() -> Bool {
        let PHONE_REGEX = "^[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    func isValidPassword(digit: Int = 7) -> Bool {
        //Minimum six characters, at least one letter and one number
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d].{\(digit),}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    
    func isValidString(value:String?) -> Bool {
        return value == "" || value == nil
    }
    
    func checkAcceptableValidation(AcceptedCharacters:String) -> Bool {
        let cs = NSCharacterSet(charactersIn: AcceptedCharacters).inverted
        let filtered = self.components(separatedBy: cs).joined(separator: "")
        if self != filtered{
            return false
        }
        return true
    }
    
    func byaddingLineHeight(linespacing:CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = linespacing  // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func trimed() -> String{
        return  self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}


extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        //let str = self.replacingOccurrences(of: "\\n", with: "\n")
        //guard let data = Data(base64Encoded: str) else { return nil }
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}




extension UITextView{
    func addDoneToolbar(TintColor:UIColor = UIColor.blue)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.done))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.tintColor = TintColor
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func done() {
        self.endEditing(true)
    }
    
    
    
    func addDoneToolbarwithClearButton(TintColor:UIColor = UIColor.blue)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.done))
        let clear: UIBarButtonItem  = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.clearText))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        items.append(clear)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.tintColor = TintColor
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func clearText() {
        self.text = ""
    }
}



extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        
        
        var trimmedForReadMore: String = ""
        if moreText == kSeeMoreLessText.See_More.rawValue.localized() {
            trimmedForReadMore = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        }
        else {
            trimmedForReadMore = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: (trimmedString?.count ?? 0), length: 0), with: "") + trailingText
        }
        
        let answerAttributed = NSMutableAttributedString.init(string: trimmedForReadMore)
        answerAttributed.addAttribute(NSAttributedString.Key.font, value: self.font!, range: NSRange.init(location: 0, length: answerAttributed.length))
        
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor], direction: GradientDirection) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        //  locations = [0.0, 0.55]
        //        startPoint = CGPoint(x: 1.0, y: 0.5)
        //        endPoint = CGPoint(x: 0.0, y: 0.5)
        
        switch direction {
        case .Right:
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
        case .Left:
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
        case .Bottom:
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
        case .Top:
            startPoint = CGPoint(x: 0.5, y: 1.0)
            endPoint = CGPoint(x: 0.5, y: 0.0)
        case .TopLeftToBottomRight:
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
        case .TopRightToBottomLeft:
            startPoint = CGPoint(x: 1.0, y: 0.0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
        case .BottomLeftToTopRight:
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
        default:
            startPoint = CGPoint(x: 1.0, y: 1.0)
            endPoint = CGPoint(x: 0.0, y: 0.0)
        }
        
    }
    
    func creatGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}


extension UIColor {
    
    /// Returns color from its hex string
    ///
    /// - Parameter hexString: the color hex string
    /// - Returns: UIColor
    static func fromHex(hexString: String) -> UIColor {
        let hex = hexString.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clear
        }
        
        return UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255)
    }
}
