//
//  CouponDetailViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 16/11/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class CouponDetailViewController: UIViewController, delegateAedPoppupBack {
    
    @IBOutlet weak var offerL: UILabel!
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var couponCodeL: UILabel!
    @IBOutlet weak var redeemSeedsL: UILabel!
    @IBOutlet weak var availableSeedsL: UILabel!
    @IBOutlet weak var couponBGIV: UIImageView!
    @IBOutlet weak var companyLogo: UIImageView!
    
    @IBOutlet weak var redeemBtn: UIButton!
    
    @IBOutlet weak var aboutL: UILabel!
    @IBOutlet weak var detailL: UILabel!
    
    var coupon: CouponModel?
    var couponCompany: CouponCompanyModel?
    var totalAvailableSeed = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buy Coupons!".localized()
        companyLogo.layer.cornerRadius = companyLogo.frame.width/2
        companyLogo.clipsToBounds = true
        
        //setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAyuSeedsDetailsAndSetupUI()
    }
    
    func setupUI() {
        guard let coupon = coupon, let couponCompany = couponCompany else { return }
        
        offerL.text = coupon.categoryName
        couponCodeL.text = couponCompany.companyName
        messageL.text = coupon.message
        aboutL.text = coupon.about
        detailL.text = coupon.descriptionField
        redeemSeedsL.text = "Required Seeds: ".localized() + coupon.ayuseeds
        availableSeedsL.text = "Available Seeds: ".localized() + totalAvailableSeed
        if let logoURL = URL(string: couponCompany.logo) {
            companyLogo.af.setImage(withURL: logoURL)
        }
        
        if let availableSeeds = Float(totalAvailableSeed), let redeemSeeds = Float(coupon.ayuseeds) {
            let progress = availableSeeds/redeemSeeds
            
            if progress < 1 {
                redeemBtn.setTitle("Buy Seeds".localized(), for: .normal)
                redeemBtn.setTitleColor(.black, for: .normal)
                redeemBtn.backgroundColor = UIColor(red: 181.0 / 255.0, green: 224.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
            } else {
                redeemBtn.setTitle("Redeem Seeds".localized(), for: .normal)
                redeemBtn.setTitleColor(.white, for: .normal)
                redeemBtn.backgroundColor = #colorLiteral(red: 0.2430000007, green: 0.5450000167, blue: 0.2269999981, alpha: 1)
            }
            
            let (bgImage, offerMessageColor) = coupon.getBGAndTintColors()
            couponBGIV.image = bgImage
            messageL.textColor = offerMessageColor
        }
    }
    
    func fetchAyuSeedsDetailsAndSetupUI() {
        showActivityIndicator()
        AyuSeedsRedeemManager.fetchAvailableSeedsInfo { (isSuccess, message, lifetimeSeeds, spentSeeds) in
            if isSuccess {
                self.hideActivityIndicator()
                self.totalAvailableSeed = String(lifetimeSeeds - spentSeeds)
                self.setupUI()
            } else {
                self.hideActivityIndicator()
                self.showAlert(message: message)
            }
        }
    }
    
    @IBAction func redeemBtnPressed(sender: UIButton) {
        let title = sender.title(for: .normal)
        if title == "Buy Seeds".localized() {
            //show buy seeds screen
            BuyAyuSeedsViewController.showScreen(presentingVC: self.tabBarController)
        } else {
            //call redeem seeds api
            guard let coupon = coupon,
                  let id = coupon.favoriteId, let favID = Int(id),
                  let ayuseeds = coupon.ayuseeds, let accessPoint = Int(ayuseeds) else { return }
            
            showActivityIndicator()
            AyuSeedsRedeemManager.callRedeemAPI(fav_type: "Buy Coupons", fav_id: favID, access_point: accessPoint, extraParam: ["thirdparty_id": favID]) { [weak self] (isSuccess, title, message) in
                guard let strongSelf = self else { return }
                if isSuccess {
                    strongSelf.getCouponDetailsAndShowSuccessScreen(favourite_id: favID)
                } else {
                    strongSelf.hideActivityIndicator()
                    strongSelf.showAlert(message: message)
                }
            }
            
            /*AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self, isShowSuccessAlert: false, extraParam: ["thirdparty_id": favID]) { [weak self] (isSuccess, message) in
                guard let strongSelf = self else { return }
                if isSuccess {
                    strongSelf.getCouponDetailsAndShowSuccessScreen(favourite_id: favID)
                } else {
                    strongSelf.hideActivityIndicator()
                    strongSelf.showAlert(message: message)
                }
            }*/
        }
    }
    
    func getCouponDetailsAndShowSuccessScreen(favourite_id: Int) {
        getCouponDetailsFromServer(favourite_id: favourite_id) { (isSuccess, message, coupons) in
            if isSuccess {
                self.hideActivityIndicator()
                let vc = CouponRedeemSuccessViewController.instantiateFromStoryboard("Coupons")
                vc.delegate = self
                vc.coupon = coupons.first ?? self.coupon
                vc.couponCompany = self.couponCompany
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.tabBarController?.present(vc, animated: true, completion: nil)
            } else {
                self.hideActivityIndicator()
                self.showAlert(message: message)
            }
        }
    }
    
    func seedPopupBack_action(_ success: Bool) {
        if success {
            self.navigationController?.popToRootViewController(animated: true)
            
            if let arrViewControllers = self.navigationController?.viewControllers {
                for aViewController in arrViewControllers {
                    if aViewController.isKind(of: AyuSeedsViewController.self) {
                        (aViewController as? AyuSeedsViewController)?.tabBarController?.selectedIndex = 2
                    }
                }
            }
        }
    }
}

extension CouponDetailViewController {
    
    func getCouponDetailsFromServer(favourite_id: Int, completion: @escaping (Bool, String, [CouponModel])->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getCouponsRedeemDetails.rawValue
            let params = ["favourite_id": favourite_id, "language_id" : Utils.getLanguageId()]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", [CouponModel]())
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get coupons, please try after some time".localized()
                    var data = [CouponModel]()
                    if let dataArray = dicResponse["data"] as? [[String: Any]] {
                        data = dataArray.map{ CouponModel(fromDictionary: $0) }
                    }
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, data)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [CouponModel]())
                }
            }
        } else {
            completion(false, NO_NETWORK, [CouponModel]())
        }
    }
}
