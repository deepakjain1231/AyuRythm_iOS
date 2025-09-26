//
//  Constants.swift
//  AlertEm
//
//  Created by Pradeep on 4/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

let kSharedAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let kUserDefaults = UserDefaults.standard
let kDeviceWidth = UIScreen.main.bounds.width

enum APIEnvirnoment {
    case development
    case live
}

// FIXME: - temp testing by Paresh, make it live before push to app store
let envirnoment: APIEnvirnoment = .live



//MARK: - SHUKHAM BANNER LINK
let kShukhamBannerLink = "https://ayurythm.sukham.life/lp/performanceboosterplan/"

//MARK: - Common URLS
let kTermsAndCondition = "https://www.ayurythm.com/termsandconditions.html"
let kPrivacyPolicy = "https://www.ayurythm.com/privacypolicy.html"

//MARK: - Promotional Video Link
let kPromotionalYoutubeLink = "https://www.youtube.com/watch?v=iizxE1Hf4ZE"

//MARK: - What's Login URL
var BaseURLWhatsapp = "https://ayurythm.authlink.me"
var kWhatsappURL = "https://ayurythm.authlink.me/?redirectUri=otpless://ayurythm"
var kWhatsappLogiClientID = "hxycj26e"
var kWhatsappLogiClientSecret = "4ccm7bh16f2qo5vg"

//MARK: - Vimeo Access
var BaseURL_Vimeo = "https://api.vimeo.com/videos/"
var Kvimeo_access_Token = "Bearer 211e2d48814c3754f5c54417a75bdcce"
/*
//MARK: - DEV URLS

//RRozarrPay
//let kRazorpayKey = "rzp_test_tKVLjHNZ2a2ces" //rzp_test_tKVLjHNZ2a2ces
//let kRazorpayKey_Marketplace = "rzp_test_Ar8tyxDWRzSLY2"
 
var kBaseNewURL = "https://dev.ayurythm.com/api/v3/apiv2/"
let image_BaseURL = "https://dev.ayurythm.com/"
let kBaseUrlShop = "http://shop.ayurythm.com/rest/"
let kAPIforFaceNaadi = "https://ayurapi.ayurythm.com/algo1-prediction-ppg"
let kAPIforHeartRate = "https://ayurapi.ayurythm.com/ios_heart_rate"
//*****************************************************************************************//
//*****************************************************************************************//
//*****************************************************************************************//
*/


/*
//MARK: - Staging URLS

let is_APP_LIVE = false
//RRozarrPay
let kRazorpayKey_Subscription = "rzp_test_tKVLjHNZ2a2ces"
//let kRazorpayKey = "rzp_test_tKVLjHNZ2a2ces"// "rzp_test_Ar8tyxDWRzSLY2" //rzp_test_tKVLjHNZ2a2ces
let kRazorpayKey_Marketplace = "rzp_test_Ar8tyxDWRzSLY2"
 
var kBaseNewURL = "https://dev.ayurythm.com/api/v5/apiv2/"
let image_BaseURL = "https://dev.ayurythm.com/"
let kBaseUrlShop = "http://shop.ayurythm.com/rest/"
let kAPIforFaceNaadi = "https://ayurapi.ayurythm.com/algo1-prediction-ppg"
let kAPIforHeartRate = "https://ayurapi.ayurythm.com/ios_heart_rate"
let kAPIFaceAnalysis = "https://ayurapi.ayurythm.com/facial-analysis"

let kAPIVikritiPredction = "https://ayurapi.ayurythm.com/vikriti-dosha-pred-face-test"


//MARK: - MarketPlace API
let kBaseUrlShopImages = "http://shop.ayurythm.com/pub/media/catalog/product"
let kBaseUrl_MarketPlace = "https://shop.ayurythm.com/api/"
//***********************************************************************************//
//***********************************************************************************//
//***********************************************************************************//
*/







//MARK: - LIVE URLS
let is_APP_LIVE = true
let kRazorpayKey_Subscription = "rzp_live_MS9ty6S155jA9v"
let kRazorpayKey_Marketplace = "rzp_live_M1iuKv2veUma7Y"

var kBaseNewURL = "https://api.ayurythm.com/api/v5/apiv2/"
let image_BaseURL = "https://api.ayurythm.com/"
let kBaseUrlShop = "https://shop.ayurythm.com/api/"
let kAPIforFaceNaadi = "https://ayurapi.ayurythm.com/algo1-prediction-ppg"
let kAPIforHeartRate = "https://ayurapi.ayurythm.com/ios_heart_rate"
let kAPI_HR_SPO2 = "https://ayurapi.ayurythm.com/ios-hr-spo2"
let kAPIFaceAnalysis = "https://ayurapi.ayurythm.com/facial-analysis"
let kAPIVikritiPredction = "https://ayurapi.ayurythm.com/vikriti-dosha-pred-face-test"

//MARK: - MarketPlace API
let kBaseUrlShopImages = "http://shop.ayurythm.com/pub/media/catalog/product"
let kBaseUrl_MarketPlace = "https://shop.ayurythm.com/api/"
//***********************************************************************************//
//***********************************************************************************//
//***********************************************************************************//






let kAppColorWalletGreen = UIColor().hexStringToUIColor(hex: "#3E8B3A")
let kAppColorGreen = UIColor().hexStringToUIColor(hex: "#B5E0B3")

//let kRazorpayKey = "rzp_test_Ar8tyxDWRzSLY2"// "rzp_live_MS9ty6S155jA9v"
//let kRazorpayKey_Marketplace = "rzp_live_M1iuKv2veUma7Y"// "rzp_test_Ar8tyxDWRzSLY2"
//let kRazorpayKey_Test_Guru = "rzp_test_Ar8tyxDWRzSLY2"// "rzp_test_Ar8tyxDWRzSLY2"
//let kRazorpayKey = "rzp_test_BvhizHJ4ICMeiT"
//rzp_test_tKVLjHNZ2a2ces


enum endPoint: String {
    case register = "registerV3"
    case validateEmail = "validateEmail"
    case validateMobile = "validateMobile"
    case login = "loginV3"// "loginV2"
    case updategraph = "updategraph"
    case usergraphspar = "usergraphspar"
    case updateparkriti = "updateparkriti"
    //case prashnaprakriti = "prashnaprakriti"
    case getprakrutiquestionswithoptions = "getprakrutiquestionswithoptionsV2"
    case prashnaVikriti = "prashnavikritiV2"
    case blogs = "blogs"
    case foods = "foods"
    case fruitsByType = "fruitsByTypeV3"
    case getFoodType = "getFoodTypes"
    case getHerbsByType = "getHerbsByTypeV2"
    case getHerbsTypes = "getHerbsTypesV2"
    case herbsByTypeV2 = "HerbsByTypeV2" //get random herbs in home screen
    case getExpBenefitsPlayList = "getExpBenefitsPlayList"
    case getExpLevelPlayList = "getExpLevelPlayList"
    case getFoodByType = "getFoodByType"
    case UserOtp = "UserOtp"
    case generateOTP = "GenerateOTPV3"
    case verifyOTP = "VerifyOtpV3"
    case skincare = "skincare"
    case userinfo = "userinfo"
    case userinfoResult = "userinfoResultV3"// "userinfoResult"
    case updateuserdata = "updateuserdataV2"
    case uploadprofilepicture = "uploadprofilepicture"
    case getMyPlansYoga = "getMyPlansYoga"
    case getWellness = "getWellness"
    case todaysRecommendation = "todayRecommendation"
    case saveFourite = "getsavefourite"
    case getfetchFavouriteIOS = "getfetchFavouriteIOS"
    case getFourite = "getfetchFavourite"
    
    case deleteFourite = "deletefavourite"
    case homeRemediesCat = "getRemediesCategoryV2"
    case homeRemediesDesc = "getRemediesDesc"
    case savesparshnatest = "savesparshnatest"
    case contactus = "contactus"
    case changePassword = "changepassword"
    case changePasswordAfterLogin = "changepasswordAfterLogin"
    case getForYouYoga = "getMyPlansYogaIOSV4"
    case getPranayamaios = "getPranayamaiosV4"
    case getMeditationios = "getMeditationiosV4"
//    case getMudraios = "getMudraiosV4"
//    case getKriyaios = "getKriyaiosV4"
    case getKriyaiOS_NewAPI = "getlistiosV6" //getlistiosV5
    case getYogaPranayamDetail_iOS_NewAPI = "getlistiosDetailsV6"
    
    case allHomeRemedies = "allHomeRemediesNewV2" // "allHomeRemediesNew"
    case notificationList = "notificationList"
    case notificationCount = "notificationCount"
    case changeNotificationStatus = "changeNotificationStatus"
    case getUserInfo = "getUserInfoV2"
    
    // Result History
    case history = "history"
    case SpO2History = "SpO2HistoryV2"
    
    // My Lists
    case AddList = "AddListV2"
    case GetList = "GetListV2"
    case DeleteList = "DeleteListV2"
    case AddListDetails = "AddListDetailsV2"
    case GetListDetails = "GetListDetailsV2"
    case DeleteListDetails = "DeleteListDetailsV2"
    case DeleteMultipleListDetails = "DeleteMultipleListDetailsV2"
    case UpdateListById = "UpdateListByIdV2"
    case AddListReOrder = "AddListReOrderV2"
    case getAllTypesDetails = "getAllTypesDetailsV2"
    case redeemPoints = "IndividualDataUnlockV2"
    case transactionhistoryV2 = "transactionhistoryV2"
    case referralcodeValidation = "referralcodeValidationV2"
    case globalSearch = "globalSearchForAllV2"
    case listSearchForAll = "listSearchForAllV2"
    
    case addEarnhistory = "AddEarnhistoryV2"
    case updateSocialConnectDetails = "updateSocialConnectDetailsV2"
    case addSocialData = "addSocialData"
    case emailVerify = "emailVerify"
    case updatefcm = "updatefcm"
    case fetchResultsPDF = "fetchResultsPDF"
    case getAllTypeDataForAppClipV2 = "getAllTypeDataForAppClipV2"
    case saveUserGoals = "save_user_goals"
    case resetUserGoals = "reset_user_goals"
    case getAyuseedsInfo = "getAyuseedsInfo"
    case AddAyuseedsOrderDetails = "AddAyuseedsOrderDetails"
    case updateAyuseedsOrderDetails = "updateAyuseedsOrderDetails"
    case getBannerInfo = "getBannerInfo"
    case getAllThirdPartyCouponsList = "getAllThirdPartyCouponsList"
    case getCouponsRedeemHistory = "getCouponsRedeemHistory"
    case getCouponsRedeemDetails = "getCouponsRedeemDetails"
    case checkCCRYNCode = "check_ccryn_code"
    case updateCCRYNValue = "store_ccryn_track"
    case getSuryathonTrackerData = "get_surya_thon_tracker"
    
    //Nadi Guru API
    case nadiGuruForm = "nadiguru_form"
    case updateNadiGuruPayment = "nadiguru_update_payment"

    //New onbording API
    case saveTodaysGoals = "save_user_goalsV4"
    case getDailyPlanner = "getDaily_PlannerV4"
    case setUserDailyPlanner = "setUsers_Daily_PlannerV4"
    case getTodaysGoal = "getUsersTodaysGoalV3"// "getUsersTodaysGoal"
    case SukhamBannerClick = "SukhamBannerClickCounter"
    case MeloohaBannerClick = "MeloohaBannerClickCounter"

    //Shop
    case shopCategories = "default/V1/categories"
    case shopRecommendation = "V1/products?searchCriteria[filter_groups][0][filters][0][field]=pitta&searchCriteria[filter_groups][0][filters][0][value]=yes&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][0][filters][1][field]=kapa&searchCriteria[filter_groups][0][filters][1][value]=yes&searchCriteria[filter_groups][0][filters][1][condition_type]=eq"
    case shopFeatured = "V1/products?searchCriteria[filter_groups][0][filters][0][field]=sm_featured&searchCriteria[filter_groups][0][filters][0][value]=1&searchCriteria[filter_groups][0][filters][0][condition_type]=eq"
    
    case getTrainer = "get_trainer" //"get_trainer_v2"
    case placeTrainerOrder = "place_trainer_order_v2"
    case paymentResponse = "payment_response_v2"
    case getTrainingBooking = "get_training_booking"
    case getPackageWeeks = "get_package_weeks"
    case getTrainerFreeSlots = "get_trainer_free_slots"
    
    case get_sparshna_master_result = "get_sparshna_master_result"
    case get_sparshna_result = "get_sparshna_result"
    
    case trainer_coupon_validation = "trainer_coupon_validation"
    
    enum v2:String {
        case register = "registerV3"
        case referralcodeValidation = "referralcodeValidationV2"
        case homeRemediesCat = "getRemediesCategoryV2"
        case homeRemediesDesc = "getRemediesDescV2"
        case todaysRecommendation = "todayrecommendationV2"
        case getprakrutiquestionswithoptions = "getprakrutiquestionswithoptionsV2"
        case getfetchFavouriteIOS = "getfetchFavouriteIOSV2"
        case prashnaVikriti = "prashnavikritiV2"
        case getFoodType = "getFoodTypesV2"
        case getExpBenefitsPlayList = "getExpBenefitsPlayListV2"
        case getExpLevelPlayList = "getExpLevelPlayListV2"
        case getFoodByType = "getFoodByTypeV2"
    }
    
    
    //Gamification
    case getContestsList = "getContestsListV4"
    case getContestDetails = "getContestDetailsV4"
    case getUserContestQuestions = "getUserContestQuestionsV4"
    case getContestUserStatus = "getContestUserStatusV4"
    case getContestSubmission = "getContestSubmissionV4"
    case getcontestLeaderboard = "getcontestLeaderboardV4"
    case getContestWinners = "GetContestWinnersV4"
    case getDailyTaskList = "getDailyTaskListV3"
    case getDailyTaskUpdate = "getDailyTaskUpdateV3"
    case getUserStreak = "getUserStreakDataV3"
    case getUserStreakDetails = "getUserStreakDetailsV3"
    
    //Scratch Card
    case getScratchCard = "getScratchCard"
    case getScratchCardWithoutRegistration = "getScratchCardWithoutRegistration"
    case updateMyScratchCard = "updateMyScratchCard"
    case getMyScratchCards = "getMyScratchCards"
    case getScratchCardUpdate = "getScratchCardUpdateV3"
    
    //Subscription
    case getSubscriptionPacks = "getSubscriptionPacks"
    case placeSubscriptionOrderIOS = "placeSubscriptionOrderIOS"
    case getActiveSubscription = "GetActiveSubscription"
    case getAllAvailableNActivePlans = "getAllAvailableNActivePlans"

    
    case pauseScription = "pauseScription"
    case resumeScription = "resumeScription"
    case checkSubscriptionPromocode = "checkPromocodeValidOrNotForsubSubscriptionV2"
    case checkFaceNaadiSubscriptionPromocode = "facenaadi_validate_coupon_for_doctor"
    
    //Razorpay Prime
    case addRazorpaySubscriptionOrderDetails = "AddSubscriptionOrderDetailsV2"
    case updateRazorpaySubscriptionOrderDetail = "updateSubscriptionOrderDetailsV2"
    
    //Razorpay FaceNaadi
    case addFaceNaadiRazorpaySubscription = "AddFacenaadiSubscriptionOrderDetailsV2"
    case updateFaceNaadiRazorpaySubscription = "updateFacenaadiSubscriptionOrderDetailsV2"

    //Razorpay Sparshna:
    case addSparshnaRazorpaySubscription = "AddFingerAssessmentSubscriptionOrderDetails"
    case updateSparshnaRazorpaySubscription = "updateFingerAssessmentSubscriptionOrderDetails"
    
    //Razorpay Home Remedies:
    case addHomeRemediesRazorpaySubscription = "AddHomeRemediesSubscriptionOrderDetails"
    case updateHomeRemediesRazorpaySubscription = "updateHomeRemediesSubscriptionOrderDetails"

    //Razorpay Ayumonk:
    case addAyumonkRazorpaySubscription = "AddAyumonkSubscriptionOrderDetails"
    case updateAyumonkRazorpaySubscription = "updateAyumonkSubscriptionOrderDetails"
    
    
    //Razorpay Diet Plan
    case addDietPlanRazorpaySubscription = "AddDietPlanSubscriptionOrderDetails"
    case updateDietPlanRazorpaySubscription = "updateDietPlanSubscriptionOrderDetails"
    
    
    //Pedometer
    case setUserPedometerGoal = "SetUserPedometerGoal"
    case getUserGoal = "GetUserGoal"
    case getPedometerUpdate = "GetPedometerUpdate"
    case bulkUpdatePedometer = "BulkUpdatePedometer"
    case getWeeklyPedometer = "GetWeeklyPedometer"
    case getMonthlyPedometer = "GetMonthlyPedometer"
    case getYearlyPedometer = "GetYearlyPedometer"
    
    //Wellness Plan
    case getWellnessDataByUser = "getWellnessDataByUserV4"// "getWellnessDataByUserV3"// "getWellnessDataByUserV2"
    case addUserWellnessPreference = "AddUserWellnessPreferenceV2"
    case getWellnessPreference = "getWellnessPreferenceV2"
    
    case getDietInfo = "getDietPlanInfo"
    case getAlternativeFoodNames = "getAlternativeFoodNames"
    
    
    case DeleteMyAccount = "DeleteMyAccount"
    case checkAndSetNadiBandProjectCode = "CheckAndSetNadiBandProjectCode"
    
    //Ayuverse
    case getMyFeedList = "FetchMyFeeds"
    case getAllFeedList = "AllFeeds"
    case addFeed =     "AddFeeds"
    case likeAFeed = "LikeAFeed"
    case shareFeed = "ShareAFeedorPostorQuestionAnswer"
    
    case searchTag = "SearchTags"
    
    case getreportMessage = "GetReportMessages"
    
    case getCategoriesList = "GetCategoriesList"
    case getContentLibrary = "GetContentLibrary"
    case fetchComments = "FetchComments"
    case likeAComment = "LikeAComment"
    case commentOnFeed = "CommentOnAFeed"
    case getGroupList = "GetGroupLists"
    case createGroup  = "CreateAGroup"
    case EditGroup = "EditAGroup"
    case getMyGroupList = "GetMyGroups"
    case joinAGroup = "JoinAGroup"
    case getGroupFeed = "GetSingleGroupFeeds"
    case postInAGroup = "PostInAGroup"
    case groupFeedComment = "CommentOnAGroupPost"
    case getGroupFeedComment = "GetGroupFeedComments"
    case fetchGroupRules  = "FetchGroupRules"
    case getGroupMembers = "GetGroupMembers"
    case postQuestions   = "PostAQuestion"
    case editQuestions   = "EditAQuestion"
    case fetchQuestionList = "FetchQuestionsList"
    case fetchAnswerList = "FetchAnswersList"
    case postAnAnswer  = "PostAnAnswer"
    case likeUnlikeQA = "LikeUnlikeAQuestionAnswer"
    case acceptRejectMember = "AcceptMemberInPrivateGroup"
    case removeGroupMember = "RemoveFromGroup"
    case leaveAGroup = "LeaveAGroup"
    case DeleteAGroup = "DeleteAGroup"
    
    case EditorDeleteACommentGroup = "EditorDeleteACommentGroup"
    
    case EditorDeleteAComment = "EditorDeleteAComment"
    case deleteFeed  = "DeleteFeed"
    case searchFeed = "SearchFeeds"
    case group_searchFeed = "SearchinGroupPosts"
    case editFeed = "EditFeeds"
    case editPostInAGroup = "EditPostInAGroup"
    case deleteGroupFeed = "DeletePostInAGroup"
    case reportFeedOrComment = "ReportAFeedorComment"
    case deleteAnswer = "DeleteAnAnswer"
    case deletQuestion = "DeleteAQuestion"
    case editAnswer = "EditAnAnswer"
    
    //BPL device integration
    case fetchBplDeviceInfo = "FetchBplDeviceInfo"
    case setBplDeviceInfo = "SetBplDeviceInfo"
    case setBplWeightValue = "SetBplWeightValue"
    case setBplOximeterValue = "SetBplOximeterValue"
    case setBplBpMonitorValue = "SetBplBpMonitorValue"
    case fetchBplWeightReport = "FetchBplWeightReport"
    case fetchBplCouponCode = "FetchBplCouponCode"
    
    //Sanaay Patient ID
    case patient_history = "patient_history"
    case patient_validation = "patient_validation"
    
    
    
    
    //Market Place
    case mp_none = ""
    case mp_login = "user/login"
    case mp_categories = "front/categories/"
    case mp_popularProducts = "front/product/popularProducts"
    case mp_recommendedProducts = "front/product/recommendedProducts"
    
    case mp_brands = "front/brands"
    case mp_featured_brands = "front/featured_brands/"
    case mp_product_tranding = "front/product/tranding"
    case mp_product_topProducts = "front/product/topProducts"
    case mp_product_newlylaunched = "front/product/newlylaunched"
    case mp_listBrandWise = "front/product/%@/listBrandWise"
    case mp_listCategoryWise = "front/product/%@/listCategoryWise"
    case mp_product_details = "front/product/%@/details"
    case mp_popular_herbs = "front/product/popular_herbs"
    
    case mp_search_item = "front/search_item"
    case mp_search_item_do_you_mean = "front/search_item_do_you_mean"
    case mp_front_coupon_getList = "front/coupon/getList"
    case mp_front_mycart_getCartPriceDetail = "front/mycart/getCartPriceDetail"
    case mp_front_coupon_applyCoupon = "front/coupon/applyCoupon"
    case mp_user_offersList = "user/offersList"
    case mp_user_get_product_review = "user/get_product_review/%@"
    case mp_user_mycart_getUserAddress = "user/mycart/getUserAddress"
    case mp_user_mycart_addNewUserAddress = "user/mycart/addNewUserAddress"
    case mp_user_mycart_editUserAddress = "user/mycart/editUserAddress"
    case mp_user_order_SaveOrder = "user/order/SaveOrder"
    case mp_user_order_SaveOrderCOD = "user/order/CashonDelivery"
    case mp_user_mycart_savecartdetails = "user/mycart/savecartdetails"
    case mp_user_order_UpdateRazorpayPaymentStatus = "user/order/UpdateRazorpayPaymentStatus"
    
    case mp_recently_product = "user/product/recentlyViewedProducts"
    
    case mp_product_sort = "front/sortinglist"
    case mp_product_filterOption = "front/filterlist"
    
    //MARK: - Market Place Login User API End Point
    case mp_user_categories = "user/categories/"
    case mp_user_brands = "user/brands"
    case mp_user_popularProducts = "user/product/popularProducts"
    case mp_user_featured_brands = "user/featured_brands/"
    case mp_user_product_tranding = "user/product/tranding"
    case mp_user_product_topProducts = "user/product/topProducts"
    case mp_user_product_newlylaunched = "user/product/newlylaunched"
    case mp_user_listBrandWise = "user/product/%@/listBrandWise"
    case mp_user_listCategoryWise = "user/product/%@/listCategoryWise"
    case mp_user_popular_herbs = "user/product/popular_herbs"
    case mp_user_product_details = "user/product/%@/details"
    case mp_user_add_recently_products = "user/product/AddProductInrecentlyViewedProducts"
    
    case mp_user_recommendedProducts = "user/product/recommendedProducts"
    
    
    case mp_user_Wishlist = "user/wishlists"
    case mp_user_addWishlist_product = "user/wishlist/add"
    case mp_user_removeWishlist_product = "user/wishlist/remove/%@"
    
    case mp_user_mycart = "user/mycart"
    case mp_user_addProductcart = "user/mycart/add"
    case mp_user_removeProductcart = "user/mycart/remove/%@/%@"
    case mp_user_mycart_changeQuantity = "user/mycart/changeQuantity"
    case mp_user_mycart_getCartPriceDetail = "user/mycart/getCartPriceDetail"

    case mp_user_coupon_getList = "user/coupon/getList"
    case mp_user_coupon_applyCoupon = "user/coupon/applyCoupon"
    
    
    case mp_user_DeleteAddress = "user/mycart/deleteUserAddress"
    case mp_userProductNotifyMe = "user/product/notifyme"
    
    case mp_UserMyOrder = "user/ordersProductwiseFilter"
    case mp_UserCancelOrder = "user/order/cancel"
    case mp_userReturnOrder = "user/order/return"
    
    case mp_UserOrderHelpFaq = "user/get_faq_categorywise/Order"
    case mp_user_product_sort = "user/sortinglist"
    case mp_user_product_filterOption = "user/filterlist"
    
    case mp_user_product_submitRating = "user/submit_rating"
    case mp_user_Similar_products = "user/product/%@/similarProducts"
    
    case mp_my_wallet = "user/wallet/getMyWallet"
    
    //For Weekly Planner
    case mp_rasayan_category_list = "user/product/rasayan_category_list"
    case mp_rasayan_product_list = "user/ordersRasayanProductsList"
    case mp_reminderTime = "user/reminder_time"
    case mp_setProductReminder = "user/set_productwise_reminder"
    case mp_setuserReminder = "user/set_user_reminder"
    case mp_start_weeklyPlanner = "user/start_weekly_planner"
    case mp_daywiseProductList = "user/get_daywise_productlist"
    case mp_howtouse_product = "user/get_how_to_apply_product_details/%@"
    
    case mp_trackOrder = "Carriers/getTrackingDetails?api_token=%@&reference_code=%@"
    
    case Available_ayuseedinfo = "ayuseedinfo"
    
    case getAllTypeData = "getAllTypesDataV2"
    
    //Ayumonk
    case get_ayumonk_config = "ayuMonkDetail"
    case add_ayumonk_log = "AddAyumonkChatLog"
    case get_ayumonk_log = "GetAyumonkChatLog"
    case delete_ayumonk_log = "DeleteAyumonkChatLog"
    
    //Finger Assessment Subscription
    case getFingerSubscriptionPacks = "getFingerAssessmentSubscriptionPacks"
    case placeFingerSubscriptionOrderIOS = "placeFingerAssessmentSubscriptionOrderIOS"
    
    //FaceNaadi Subscription
    case addFacenaadiDoneByUser = "addFacenaadiDoneByUser"
    case getFacenaadiSubscriptionPacks = "getFacenaadiSubscriptionPacks"
    case placeFacenaddiSubscriptionOrderIOS = "placeFacenaddiSubscriptionOrderIOS"
        
    
    //AyuMonk Subscription
    case getAyumonkSubscriptionPacks = "getAyumonkSubscriptionPacks"
    case placeAyumonkSubscriptionOrderIOS = "placeAyumonkSubscriptionOrderIOS"
    
    //Remedies Subscription
    case getRemediesSubscriptionPacks = "getHomeRemediesSubscriptionPacks"
    case placeHomeRemediesSubscriptionOrderIOS = "placeHomeRemediesSubscriptionOrderIOS"
    
    //Diet Plan Subscription
    case getDietPlanSubscriptionPacks = "getDietPlanSubscriptionPacks"
    case placeDietPlanSubscriptionOrderIOS = "placeDietPlanSubscriptionOrderIOS"
    
    //Delete Subscription
    case delete_subscription = "DeleteSubscriptionOrder"
}

func getHeaders() -> [String : String] {
    let token = kUserDefaults.value(forKey: TOKEN) as? String
    return ["Authorization": token ?? ""]
    //, "content-type": "application/json"
}

// MARK: -

class App {
    enum dateFormat {
        static let commonDisplayDate = "dd-MM-yyyy"
        static let commonDisplayTime = "hh:mm a"
        static let ddMMyyyy = "dd-MM-yyyy"
        static let yyyyMMdd = "yyyy-MM-dd"
        static let hhmma = "hh:mm a"
        static let subscriptionSummeryDate = "dd MMM, yyyy"
        
        static let serverSendDate = "yyyy-MM-dd"
        static let serverSendDateTime = "yyyy-MM-dd HH:mm:ss"
        static let serverReceiveDate = "dd-MM-yyyy"
        static let serverReceiveDate2 = "yyyy-MM-dd"
        static let serverReceiveTime = "HH:mm:ss"
        static let serverReceiveDateTime = "dd-MM-yyyy HH:mm:ss"
        static let onlyYear = "YYYY"
        static let onlyMonth = "MMMM"
        static let onlyDate = "dd"
    }
}

extension UIColor {
    enum app {
        static let blueDark = #colorLiteral(red: 0.3098039216, green: 0.4705882353, blue: 0.8901960784, alpha: 1)
        static let linkColor = UIColor().hexStringToUIColor(hex: "#3C91E6")
        static let gamificationOrangeDark = #colorLiteral(red: 0.9215686275, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
        
        enum text {
            static let blue = #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2549019608, alpha: 1)
        }
        
        enum barChart {
            static let gray = UIColor().hexStringToUIColor(hex: "#DDDDDD")
            static let green = UIColor().hexStringToUIColor(hex: "#6CC068")
        }
    }
}

extension Notification.Name {
    static let refreshContestList = Notification.Name("refreshContestList")
    static let refreshScratchCardList = Notification.Name("refreshScratchCardList")
    //static let refreshDailyTaskList = Notification.Name("refreshDailyTaskList")
    static let refreshPedometerData = Notification.Name("refreshPedometerData")
    static let refreshActiveSubscriptionData = Notification.Name("refreshActiveSubscriptionData")
    static let refreshWellnessPlanData = Notification.Name("refreshWellnessPlanData")
    static let refreshBPLDeviceList = Notification.Name("refreshBPLDeviceList")
    static let refreshProductData = Notification.Name("refreshProductData")
    static let refreshWishlistProductData = Notification.Name("refreshWishlistProductData")
}


enum event :String{
    case login = "Login"
    case signup = "SignUp"
    case logout = "Log out"
    case parakriti_prashna = "Prakriti - Prashna"
    case vikriti_prashna = "Vikriti - Prashna"
    case sprashna_test =  "Sparshna Test"
    case view_suggestion = "View Suggestions"
    case set_prefrence = "Set Preferences"
    case yoga = "Yoga"
    case meditation = "Meditation"
    case paranayam = "Pranayama"
    case kriya = "Kriya"
    case mudra = "Mudra"
    case food_suggestion = "Food suggestions"
    case herbs_suggestion = "Herbs suggetions"
    case view_subscription_plans =  "View Subscription plans"
    case buy_subscriptions = "Buy subscription"
    case view_trainers = "View Trainers"
    case book_trainer = "Booking Trainer"
    case unlock_content = "Unlock content"
    case play_contest = "Play Contest"
    case home_remedies = "Home Remedies"
    case today_plan = "Today's Plan"
    case creating_list = "Creating List"
    
    
    //Marketplace Event
    case ItemaddedCart = "EventAddToCart"// "Add to Cart"
    case ItemremoveCart = "EventRemoveFromCart"// "Remove from Cart"
    case ItemaddedWishlist = "EventAddToWishlist"// "Added in wishlist"
    case ItemremoveWishlist = "EventRemoveFromWishlist"// "Remove from wishlist"
    case GoToCart = "EventVisitCart"// "Go to Cart"
    case CouponApplied = "EventApplyCoupon"// "Coupon applied"
    case PRODUCT_DETAILS = "EventOpeningProductDetails"
    case EVENT_CAT_CLICK = "EventCateogryClicked"
    case WalletApplied = "Wallet applied"
    case ProceedtoBuy = "Proceed to Buy"
    case CODPaymentOption = "COD Payment option selected"
    case OnlinePaymentOption = "Online Payment option selected"
    case OnlinePaymentSuccess = "Online Payment Successful"
    case OnlinePaymentFailed = "Online Payment Failed"
    case OrderPlacedwithCOD = "Order Placed with COD"
    case OrderPlacedwithOnlinePayment = "Order Placed with Online Payment"
    case RateProduct = "Rate Product"
}



//Face Detection
//******************************************************************************//
