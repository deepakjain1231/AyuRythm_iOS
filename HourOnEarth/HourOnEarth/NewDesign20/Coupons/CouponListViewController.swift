//
//  CouponListViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 12/11/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class CouponListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var availableSeedsL: UILabel!
    
    var couponCompany: CouponCompanyModel?
    var coupons = [CouponModel]()
    var totalAvailableSeed = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buy Coupons!".localized()
        tableView.allowsSelection = false
        
        //setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAyuSeedsDetailsAndSetupUI()
    }
    
    func setupUI() {
        availableSeedsL.text = totalAvailableSeed
        
        guard let couponCompany = couponCompany else { return }
        self.coupons = couponCompany.coupons
        self.tableView.reloadData()
    }
    
    @IBAction func redeemBtnPressed(sender: UIButton) {
        if sender.title(for: .normal) == "BUY SEEDS & REDEEM".localized() {
            //show buy seeds screen
            BuyAyuSeedsViewController.showScreen(presentingVC: self.tabBarController)
        } else {
            let coupon = coupons[sender.tag]
            let vc = CouponDetailViewController.instantiateFromStoryboard("Coupons")
            vc.coupon = coupon
            vc.couponCompany = couponCompany
            vc.totalAvailableSeed = totalAvailableSeed
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchAyuSeedsDetailsAndSetupUI() {
        showActivityIndicator()
        AyuSeedsRedeemManager.fetchAvailableSeedsInfo { (isSuccess, message, lifetimeSeeds, spentSeeds) in
//            if isSuccess {
                self.hideActivityIndicator()
                self.totalAvailableSeed = String(lifetimeSeeds - spentSeeds)
                self.setupUI()
//            } else {
//                self.hideActivityIndicator()
//                self.showAlert(message: message)
//            }
        }
    }
    
    static func showCoupons(couponCompany: CouponCompanyModel, presentingVC: UIViewController) {
        let vc = CouponListViewController.instantiateFromStoryboard("Coupons")
        vc.couponCompany = couponCompany
        presentingVC.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CouponListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell") as? CouponCell else {
            return UITableViewCell()
        }
        
        cell.coupon = coupons[indexPath.row]
        cell.couponCompany = couponCompany
        cell.redeemBtn.tag = indexPath.row
        cell.updateProgressView(with: totalAvailableSeed)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

class CouponCell: UITableViewCell {
    
    @IBOutlet weak var offerL: UILabel!
    @IBOutlet weak var companyNameL: UILabel!
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var redeemSeedsL: UILabel!
    @IBOutlet weak var availableSeedsL: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var couponBGIV: UIImageView!
    @IBOutlet weak var redeemBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        companyLogo.layer.cornerRadius = companyLogo.frame.width/2
        companyLogo.clipsToBounds = true
    }
    
    var coupon: CouponModel? {
        didSet {
            guard let coupon = coupon else { return }
            
            offerL.text = coupon.categoryName
            messageL.text = coupon.message
            redeemSeedsL.text = "Required Seeds: ".localized() + coupon.ayuseeds
        }
    }
    
    var couponCompany: CouponCompanyModel? {
        didSet {
            guard let couponCompany = couponCompany else { return }
            
            companyNameL.text = couponCompany.companyName
            if let logoURL = URL(string: couponCompany.logo) {
                companyLogo.af.setImage(withURL: logoURL)
            }
        }
    }
    
    func updateProgressView(with totalAvailableSeed: String) {
        if let coupon = coupon, let availableSeeds = Float(totalAvailableSeed), let redeemSeeds = Float(coupon.ayuseeds) {
            let progress = availableSeeds/redeemSeeds
            
            availableSeedsL.text = "Available Seeds: ".localized() + totalAvailableSeed
            if progress < 1 {
                redeemBtn.setTitle("BUY SEEDS & REDEEM".localized(), for: .normal)
                redeemBtn.setTitleColor(#colorLiteral(red: 0.2430000007, green: 0.5450000167, blue: 0.2269999981, alpha: 1), for: .normal)
                redeemBtn.backgroundColor = .white
            } else {
                redeemBtn.setTitle("REDEEM SEEDS NOW".localized(), for: .normal)
                redeemBtn.setTitleColor(.white, for: .normal)
                redeemBtn.backgroundColor = #colorLiteral(red: 0.2430000007, green: 0.5450000167, blue: 0.2269999981, alpha: 1)
            }
            
            let (bgImage, offerMessageColor) = coupon.getBGAndTintColors()
            couponBGIV.image = bgImage
            messageL.textColor = offerMessageColor
        }
    }
}
