//
//  Enums.swift
//  HourOnEarth
//
//  Created by Apple on 16/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation

enum KPVType: String {
    case KAPHA
    case PITTA
    case VATA
}

enum CurrentKPVStatus: String {
    case Kapha
    case Pitta
    case Vata
    case Kapha_Pitta
    case Pitta_Vata
    case Vata_Kapha
    case Kapha_Pitta_Vata
    case Balanced
    
    var stringValue: String {
        switch self {
        case .Kapha:
            return "KAPHA"
        case .Pitta:
            return "PITTA"
        case .Vata:
            return "VATA"
        case .Balanced:
            return "BALANCED"
        case .Kapha_Pitta:
            return "KAPHA-PITTA"
        case .Pitta_Vata:
            return "PITTA-VATA"
        case .Vata_Kapha:
            return "VATA-KAPHA"
        case .Kapha_Pitta_Vata:
            return "KAPHA-PITTA-VATA"
        }
    }
}

enum CurrentPrakritiStatus: String {
    
    case TRIDOSHIC
    case KAPHA_PITTA
    case KAPHA_VATA
    case PITTA_KAPHA
    case PITTA_VATA
    case VATA_KAPHA
    case VATA_PITTA
    case VATA
    case PITTA
    case KAPHA
    
    var stringValue: String {
        switch self {
        case .TRIDOSHIC:
            return "Tridoshic"
        case .KAPHA_PITTA:
            return "Kapha-Pitta"
        case .KAPHA_VATA:
            return "Kapha-Vata"
        case .PITTA_KAPHA:
            return "Pitta-Kapha"
        case .PITTA_VATA:
            return "Pitta-Vata"
        case .VATA_KAPHA:
            return "Vata-Kapha"
        case .VATA_PITTA:
            return "Vata-Pitta"
        case .VATA :
            return"Vata"
        case .PITTA:
            return "Pitta"
        case .KAPHA:
            return "Kapha"
        }
    }
}

enum GradientDirection {
    case Right
    case Left
    case Bottom
    case Top
    case TopLeftToBottomRight
    case TopRightToBottomLeft
    case BottomLeftToTopRight
    case BottomRightToTopLeft
}



struct appImage {
    static let group_default_pic = UIImage.init(named: "default_group_icon")
    static let default_avatar_pic = UIImage.init(named: "default-avatar")
    static let default_male_avatar_pic = UIImage.init(named: "default_male_avtar")
    static let default_female_avatar_pic = UIImage.init(named: "default_female_avtar")
    static let default_Rsaience_logo = UIImage.init(named: "icon_Rsaience_logo_placeholder")
    static let default_image_placeholder = UIImage.init(named: "default_image")
    
    
    static let default_selected_star = UIImage.init(named: "icon_selected_star")
    static let default_unselected_star = UIImage.init(named: "icon_unselected_star")
}

enum RecommendationType: String {
    case kapha
    case pitta
    case vata
}


enum RecommendationTagType: String {
    case vikriti = "Vikriti"
    case prakriti = "Prakriti"
}

enum KPVStringType: String {
    case KAPHA
    case PITTA
    case VATA
}

enum SelectionsHeightType: String
{
    case cm = "cm"
    case ftin = "ft in"
    case balnk = ""
}
enum SelectionsageType: String
{
    case month = "month"
    case year = "year"
}
enum SelectionWeightType: String
{
    case lbs = "lbs"
    case Kgs = "Kgs"
    case balnk = ""
}

enum SelectionType {
    case weightSelection
    case heightSelection
    case heightFtIn
    case age
}



enum ScreenType {
    case k_none
    case MP_ViewALL_Categories
    case MP_ViewALL_RecommendedProducts
    case MP_ViewALL_PopularProducts
    case MP_ViewALL_Popular_brands
    case MP_ViewALL_TrendingProducts
    case MP_ViewALL_TopDealsForYou
    case MP_ViewALL_NewlyLaunched
    case MP_brandProductOnly
    case MP_categoryProductOnly
    case MP_ViewALL_HerdsProduct
    case MP_ViewALL_SimilarProduct
    case MP_ViewALL_RecentProduct
    
    case MP_HomeScreen
    case MP_SearchScreen
    case MP_ViewAllScreen
    case MP_PaymentFailed
    case MP_PaymentSuccess
    case MP_categories
    case MP_Produce_Categorywise
    case MP_Product_Wishlist
    case MP_MyOrderList
    case MP_EditReminder
    
    case MP_Product
    case MP_popularBrand
    case MP_View_ALLcategories
    case MP_RecommendedProduct
    
    case for_Reminder
    case today_screen
    case from_herbListVC
    case fromFaceNaadi
    case from_AyuMonk_Only
    case from_PrimeMember
    case from_home_remedies
    case from_finger_assessment
    case from_facenaadi_free_trial
    case from_dietplan
    case from_subscription
    case from_ediProfile
}



enum kSeeMoreLessText: String
{
    case See_More = "See More   "
    case See_Less = "See Less   "
}




enum MPFilterType: String
{
    case fBrand = "brand"
    case fCategory = "category"
    case fPriceRange = "priceRange"
    case fDeliveryTime = "deliveryTime"
    case fDiscount = "discount"
}

enum MPSearchResultType: String {
    case SearchBrand = "brands"
    case SearchProduct = "product"
    case SearchCategory = "categories"
}

struct MP_appImage {
    static let img_CheckBox_selected = UIImage.init(named: "check_box_selected")
    static let img_CheckBox_unselected = UIImage.init(named: "check_box_unselected")
    
    static let img_RadioBox_selected = UIImage.init(named: "radio_btn_selected")
    static let img_RadioBox_unselected = UIImage.init(named: "radio_btn")
    
    static let img_Order_Status_selected = UIImage.init(named: "icon_order_status_selected")
    
    static let img_radio_selected = UIImage.init(named: "icon_radio_button_checked")
    static let img_radio_unselected = UIImage.init(named: "icon_radio_button_unchecked")
}
    
enum FacenaadiSelectionOption: String {
    case knone = ""
    case fingerSparshna = "Finger Sparshna"
    case facenaadiSparshna = "Facenaadi Sparshna"
}

struct AppColor {
    static let app_TextGrayColor = #colorLiteral(red: 0.2705882353, green: 0.2705882353, blue: 0.2705882353, alpha: 1) //454545
    static let app_BorderGrayColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1) //AAAAAA
    static let app_TextBlueColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) //#007AFF
    static let app_DarkGreenColor = #colorLiteral(red: 0.003921568627, green: 0.5764705882, blue: 0.2705882353, alpha: 1) //#019345
    
    
    static let app_SelectedGreenColor = #colorLiteral(red: 0.3176470588, green: 0.5921568627, blue: 0.3058823529, alpha: 1) //51974E
    static let app_DotGrayColor = #colorLiteral(red: 0.8470588235, green: 0.9098039216, blue: 0.8470588235, alpha: 0.7) //AAAAAA
    static let app_GreenColor = #colorLiteral(red: 0.003921568627, green: 0.5764705882, blue: 0.2705882353, alpha: 1) //#019345
}



enum TodayGoal_Type: String {
    case knone = ""
    case Food = "Food"
    case Herbs = "Herbs"
    case Yogasana = "Yogasana"
    case Pranayama = "Pranayama"
    case Meditation = "Meditation"
    case Mudras = "Mudras"
    case Kriyas = "Kriyas"
}

public enum Detector: String {
  case onDeviceFace = "Face Detection"
}

enum Constant {
    static let alertControllerTitle = "Vision Detectors"
    static let alertControllerMessage = "Select a detector"
    static let cancelActionTitleText = "Cancel"
    static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
    static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
    static let noResultsMessage = "No Results"
    static let localModelFile = (name: "bird", type: "tflite")
    static let labelConfidenceThreshold = 0.75
    static let smallDotRadius: CGFloat = 4.0
    static let lineWidth: CGFloat = 3.0
    static let originalScale: CGFloat = 1.0
    static let padding: CGFloat = 10.0
    static let resultsLabelHeight: CGFloat = 200.0
    static let resultsLabelLines = 5
    static let imageLabelResultFrameX = 0.4
    static let imageLabelResultFrameY = 0.1
    static let imageLabelResultFrameWidth = 0.5
    static let imageLabelResultFrameHeight = 0.8
    static let segmentationMaskAlpha: CGFloat = 0.5
    static let circleViewAlpha: CGFloat = 0.7
    static let rectangleViewAlpha: CGFloat = 0.3
    static let shapeViewAlpha: CGFloat = 0.3
    static let rectangleViewCornerRadius: CGFloat = 10.0
    static let maxColorComponentValue: CGFloat = 255.0
    static let bgraBytesPerPixel = 4
    static let circleViewIdentifier = "MLKit Circle View"
    static let lineViewIdentifier = "MLKit Line View"
    static let rectangleViewIdentifier = "MLKit Rectangle View"
    
    
    static let detectionNoResultsMessage = "No results returned."
    static let failedToDetectObjectsMessage = "Failed to detect objects in image."
    static let largeDotRadius: CGFloat = 30.0
    static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.clear.cgColor
}


enum SideMenuOptionsKey: String {
    case knone = ""
    case kheader = "header"
    case kResult_His = "result_history"
    case kMyBooking = "my_booking"
    case kMyList = "my_list"
    case kMyAcPlan = "my_active_plan"
    case kAppleHealth = "apple_health"
    case kMyAddress = "my_address"
    case kMyOrder = "my_order"
    case kMyCart = "my_cart"
    case kWishlist = "my_wishlist"
    case kMyReward = "my_reward"
    case kMyWallet = "my_wallet"
    case kReferEarn = "refer_earn"
    case kContactUs = "contact_us"
    case kAccSetting = "account_setting"
    case kRemove_Subscription = "remove_aubscription"
    case kLogout = "logout"
    case kLinkSocial = "link_social"
    case kChangeLang = "change_lang"
    case kDeleteAccount = "delete_account"
    case kAboutUs = "about_us"
    case kCertificates = "certificates"
    case kTermsCondition = "terms_condition"
    case kPrivacyPolicy = "privacy_policy"
    case kHowITWork = "how_works"
    case kRateApp = "rate_app"
    
    case kMobile = "mobile"
    case kEmail = "email"
    case kDOB = "dob"
    case kName = "name"
    case kGender = "gender"
    
    case kweight = "weight"
    case kweightUnit = "weight_unit"
    case kheight = "height"
    case kheightUnit = "height_unit"
    
    case kheight_ft = "feet"
    case kheight_in = "inch"
    case kheight_cm = "cm"
    case kweight_kg = "Kilogram"
    case kweight_lbs = "Pound"

}

enum SideMenuOptionsName: String {
    case N_none = ""
    case kResult_His = "Result History"
    case kMyBooking = "My Bookings"
    case kMyList = "My Lists"
    case kAppleHealth = "Apple Health"
    case kMyAcPlan = "My Active Plan"
    case kMyAddress = "My Address"
    case kMyOrder = "My Orders"
    case kMyCart = "My Cart"
    case kWishlist = "My Wishlist"
    case kMyReward = "My Rewards"
    case kMyWallet = "My Wallet"
    case kReferEarn = "Refer & Earn"
    case kContactUs = "Contact Us"
    case kAccSetting = "Account Settings"
    case kLogout = "Log out"
    case kLinkSocial = "Link with Social Media"
    case kChangeLang = "Change Language"
    case kDeleteAccount = "Delete Account"
    case kAboutUs = "About Us"
    case kCertificates = "Certificates"
    case kTermsCondition = "Terms & Conditions"
    case kPrivacyPolicy = "Privacy Policy"
    case kHowITWork = "How it Works"
    case kRateApp = "Rate the App"
    case kRemoveSubscription = "Remove Subscription"
    case kMobile = "Mobile Number"
    case kEmail = "Email Address"
    case kPersonalDetails = "Personal Details"
    case kDOB = "Date of birth"
    case kName = "Your Name"
    case kSaveChanges = "Save Changes"
    
    case kWeight = "Weight"
    case kHeight = "Height"
    case kGender = "Gender"
    case kAppSetting = "App settings"
    case kGeneral = "General"
}

enum ProfileIconType: String {
    case kNone = ""
    case Pro = "Pro"
    case ProNotification = "Pro_with_Notification"
    case Notification = "Notification"
}


enum SideMenuOptionIDs: Int {
    case other
    case header
    case label
    case blank
    case button
    case textField
    case titleHeader
    case height_weightTextfield
    case gender
}

enum HeightWeigtType: String {
    case none = ""
    case kg = "kg"
    case lbs = "lbs"
    case ft = "ft"
    case cm = "cm"
}


enum kSubscription_Name_Type: String {
    case none = ""
    case prime = "prime club"
    case facenaadi = "facenaadi"
    case ayuMonk = "ayumonk"
    case sparshna = "sparshna"
    case diet_plan = "diet plan"
    case remedies = "home remedies"
}
