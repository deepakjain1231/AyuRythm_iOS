//
//  ConstantStrings.swift
//  AlertEm
//
//  Created by Pradeep on 4/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import Foundation

enum ARLoginType: Int {
    case normal
    case facebook
    case gmail
    case apple
    case whatsapp
    
    var stringValue: String {
        return "\(rawValue)"
    }
}

let APP_NAME = "AyuRythm"
let Healthkit = "HealthKit"

let APP_Form_incomplete = "Form incomplete".localized()
let Date_Of_BirthTitle = "Why do we need your Date of Birth?".localized()
let Opps = "Opps, something went wrong, please try after some time".localized()
let DateOfBirthDescription = "We use your age to calculate Kapha, Pitta and Vata based on Ayurvedic health parameters".localized()
let NO_NETWORK = "Please check your network connectivity".localized()
let AppStoreLink = "https://bit.ly/ayu-apple"
let PlayStoreLink = "https://bit.ly/ayu-android"
let AppClipsLink = "https://www.ayurythm.com"
let AppStoreAppID = "1401306733"
let IsFromMesarmentScreen = "FromMesurment"

//User defaults
let TOKEN = "Token"
let IS_LOGGEDIN = "Logged In"
let USER_DATA = "User Data"
let kFcmToken = "fcm"
let kDeviceToken = "deviceid"
let kIsFirstLaunch = "FirstLaunch"
let kAppLanguage = "AppLanguage"
let DEVICE_TYPE = "2"   //2 means iOS
let kSharedUserData = "sharedUserData"

let VIKRITI_PRASHNA = "VikritiPrashna"
let VIKRITI_DARSHNA = "VikritiDarshna"
let VIKRITI_SPARSHNA = "VikritiSparshna"


let RESULT_PRAKRITI = "ResultPrakriti"
let RESULT_VIKRITI = "ResultVikriti"

let kVikritiSparshanaCompleted = "VikritiSparshnaCompleted"
let kVikritiPrashnaCompleted = "VikritiPrashanCompleted"

let kPrakritiAnswers = "PrakritiAnswers"
let kSkippedQuestions = "SkippedQuestions"

let PRASHNA_VIKRITI_ANSWERS = "PrashnaVikritiAnswers"

let kUserMeasurementData  = "MeasurementData"
let LAST_ASSESSMENT_DATA = "LastAssessmentData"
let LAST_ASSESSMENT_DATE = "LastAssessmentDate"

let kUserImage = "Image"
let kDoNotShowTestInfo = "DoNotShowTestInfo"
let kPrakritiAnswersToSend = "PrakritiAnswersToSend"
let kDoNotShowAyuSeeds = "DoNotShowAyuSeedsWelcome"

let kUserListPoints = "UserListPoints"
let kUserListRedeemed = "UserListRedeemed"
let kUserReferralCode = "UserReferralCode"
let kReferralPointValue = "referral_val"
let kAppVersionCodeCode = "AppVersionCodeCode"
let kGoogleLinkEmail = "GoogleLinkEmail"
let kFacebookLinkEmail = "FacebookLinkEmail"
let kEmailVerifyStatus = "EmailVerifyStatus"
//let kisShowLastAssesmentShowcase = "isShowLastAssesmentShowcase"
//let kisShowPreferencesShowcase = "kisShowPreferencesShowcase"
let kIsCCRYNChallengeUnlocked = "isCCRYNChallengeUnlocked"
let kSuryaNamaskarCount = "kSuryaNamaskarCount"
let kGiftClaimedPrakritiQuestionIndices = "kGiftClaimedPrakritiQuestionIndices"
let kGiftClaimedVikritiQuestionIndices = "kGiftClaimedVikritiQuestionIndices"
let kStoredScratchCards = "kStoredScratchCards"
let kPedometerData = "kPedometerData"


let ksubscription_title = "subscription_title"
let ksubscription_subtitle = "subscription_subtitle"
let ksubscription_background = "subscription_background"
let ksubscription_textalignment = "subscription_textalignment"
let ksubscription_textColor = "subscription_textColor"
let ksubscription_button_text = "subscription_button_text"
let ksubscription_buttonColor = "subscription_buttonColor"
let ksubscription_button_textColor = "subscription_button_textColor"
let kDeliveryPincode = "DELIVERY_PINCODE"
let kDeliveryAddressID = "DELIVERY_ADDRESS_ID"
let kSanaayPatientID = "SANAAY_PATIENT_ID"
let kBYDoctorr = "check_by_doctor"

let kAyuMonkHistory = "AyuMonkHistory"
let kAyuMonkHistory_API = "AyuMonkHistory_API"


let k_ayumonk_hide = "is_ayumonk"


let is_showcase_1 = "showcase1"
let is_showcase_2 = "showcase2"
let is_showcase_3 = "showcase3"
let is_showcase_4 = "showcase4"
