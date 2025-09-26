//
//  MPCategoryCollectionCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 12/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import AlamofireImage

class MPCategoryCollectionCell: UITableViewCell {
    var typee = MPDataType.none
    var str_ScreenType = ScreenType.k_none
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var didTappedView_All: ((UIButton)->Void)? = nil
    var completionClickonCategory: ((String, [MPProductData])->Void)? = nil
    
    var data: MPData? {
        didSet {
            guard let data = data else { return }
            titleL.text = data.title
            collectionView.reloadData()
        }
    }
    
    var screentype: ScreenType? {
        didSet {
            self.str_ScreenType = self.screentype ?? ScreenType.k_none
//            if self.str_ScreenType == ScreenType.MP_ViewAllScreen {
//                collectionView.setupUISpace(allSide: 0, itemSpacing: 15, lineSpacing: 16 )
//                if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                    flowLayout.scrollDirection = .horizontal
//                }
//            }
//            else {
                collectionView.setupUISpace(allSide: 0, itemSpacing: 15, lineSpacing: 0)
                if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.scrollDirection = .vertical
                }
//            }
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        if self.str_ScreenType == ScreenType.MP_ViewAllScreen {
//            collectionView.setupUISpace(allSide: 0, itemSpacing: 15, lineSpacing: 16 )
//        }
//        else {
            collectionView.setupUISpace(allSide: 0, itemSpacing: 15, lineSpacing: 0)
//        }
        collectionView.register(nibWithCellClass: MPCategoryCell.self)
        collectionView.register(nibWithCellClass: MPBrandCell.self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    
    @IBAction func viewAllBtnPressed(sender: UIButton) {
        print("View all btn pressed")
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btn_viewAll_Action(_ sender: UIButton) {
        if self.didTappedView_All != nil {
            self.didTappedView_All!(sender)
        }
    }
}


extension MPCategoryCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dic_category = self.data?.subData.first as? MPCategoryModel else { return 0 }
        if str_ScreenType == .MP_ViewALL_Popular_brands {
            return dic_category.data.count
        }else if str_ScreenType == .MP_ViewALL_Categories {
            return dic_category.data.count
        }else{
            return dic_category.data.count >= 6 ? 6 : dic_category.data.count
        }
//        if let dic_category = self.data?.subData.first as? MPCategoryModel{
//            return dic_category.data.count
//        }else{
//            return 0
//        }
        
        //return data?.subData.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if self.str_ScreenType == ScreenType.MP_ViewAllScreen {
//            let cellHeight = ((collectionView.frame.size.width/3) + 30)
//            return CGSize(width: (collectionView.frame.size.width/3) , height: collectionView.frame.size.height)
//        }
//        else {
//            let cellHeight = ((collectionView.frame.size.width/3) + 30)
//            return CGSize(width: ((collectionView.frame.size.width/3) - 13), height: cellHeight)
//        }
        if typee == .popular_brands{
            //let cellHeight = ((collectionView.frame.size.width/3) + 30)
            return CGSize(width: ((collectionView.frame.size.width/3) - 13), height: 150)
        }else{
            let cellHeight = ((collectionView.frame.size.width/3) + 30)
            return CGSize(width: ((collectionView.frame.size.width/3) - 13), height: cellHeight)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if typee == .popular_brands{
            let cell = collectionView.dequeueReusableCell(withClass: MPBrandCell.self, for: indexPath)
            if let dic_category = self.data?.subData.first as? MPCategoryModel{
                
                cell.lblTitle.text = dic_category.data[indexPath.row].name
                //cell.titleL.text = dic_category.name ?? ""
                let urlString = dic_category.data[indexPath.row].image
                if let url = URL(string: urlString) {
                    cell.picIV.af.setImage(withURL: url)
                    //af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: nil)
                }
            }
            //--
            cell.viewbgInner.layer.cornerRadius = 10
            cell.viewbgInner.clipsToBounds = true
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withClass: MPCategoryCell.self, for: indexPath)
            if let dic_category = self.data?.subData.first as? MPCategoryModel{
                
                cell.titleL.text = dic_category.data[indexPath.row].name
                //cell.titleL.text = dic_category.name ?? ""
                let urlString = dic_category.data[indexPath.row].image
                if let url = URL(string: urlString) {
                    cell.picIV.af.setImage(withURL: url)
                    //af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: nil)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let dic_category = self.data?.subData[indexPath.item] as? CategoryListModel {
//            self.completionClickonCategory?((dic_category.name ?? ""), dic_category.products ?? [])
//        }
    }
}
