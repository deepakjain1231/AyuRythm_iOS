//
//  HomeScreenVoucherTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenVoucherTableCell: UITableViewCell {

    var currentVC: UIViewController?
    var strCompanyName = ""
    var arr_VoucherData = [CouponModel]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var collect_View: UICollectionView!
    
    var didTappedonSelectedCoupon: ((CouponModel)->Void)? = nil
    
    var voucherData: [CouponCompanyModel]? {
        didSet {
            guard let listData = voucherData?.first?.coupons else {
                return
            }
            self.strCompanyName = voucherData?.first?.companyName ?? ""
            self.arr_VoucherData = listData
            self.collect_View.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collect_View.register(nibWithCellClass: VoucherCollectionCell.self)
        
        //Register Collection Cell
        self.collect_View.delegate = self
        self.collect_View.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UICollectionView Delegate DataSource Method
extension HomeScreenVoucherTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_VoucherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: VoucherCollectionCell.self, for: indexPath)
        cell.lbl_couponTitle.text = self.strCompanyName

        let dic_Data = self.arr_VoucherData[indexPath.row]
        cell.lbl_offer_prensantage.text = dic_Data.categoryName
        cell.lbl_ayuseed.text = dic_Data.ayuseeds
        cell.view_innerforColor.backgroundColor = UIColor.fromHex(hexString: dic_Data.colorCode)
        cell.img_logo.sd_setImage(with: URL.init(string: dic_Data.detail_image), placeholderImage: nil, progress: nil)
        
        
        /*
        if indexPath.row == 0 {
            cell.view_innerforColor.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.8431372549, blue: 0.4862745098, alpha: 1)
        }
        else if indexPath.row == 1 {//180, 163, 232
            cell.view_innerforColor.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.9137254902, blue: 0.6470588235, alpha: 1)
        }
        else {
            cell.view_innerforColor.backgroundColor = #colorLiteral(red: 0.7058823529, green: 0.6392156863, blue: 0.9098039216, alpha: 1)
        }
        */
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 225, height: self.collect_View.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dic_Data = self.arr_VoucherData[indexPath.row]
        self.didTappedonSelectedCoupon?(dic_Data)
        //self.fetchAyuSeedsDetailsAndSetupUI(dic_Data)
    }
    
//    func fetchAyuSeedsDetailsAndSetupUI(_ dic_Data: CouponModel) {
//        self.currentVC?.showActivityIndicator()
//        AyuSeedsRedeemManager.fetchAvailableSeedsInfo { (isSuccess, message, lifetimeSeeds, spentSeeds) in
//            self.currentVC?.hideActivityIndicator()
//            let str_totalAvailableSeed = String(lifetimeSeeds - spentSeeds)
//
//            if let availableSeeds = Float(str_totalAvailableSeed), let redeemSeeds = Float(dic_Data.ayuseeds) {
//                let progress = availableSeeds/redeemSeeds
//                if progress < 1 {
//                    self.didTappedonSelectedCoupon?("BUY SEEDS & REDEEM".localized(), dic_Data, str_totalAvailableSeed)
//                } else {
//                    self.didTappedonSelectedCoupon?("REDEEM SEEDS NOW".localized(), dic_Data, str_totalAvailableSeed)
//                }
//            }
//        }
//    }
}
