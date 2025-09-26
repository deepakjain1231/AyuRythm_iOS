//
//  DietBenifitTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 23/02/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class DietBenifitTableCell: UITableViewCell {

    var arr_BenifitsData = [JSON]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var collection_view: UICollectionView!
    
    var arrBenifits: [JSON]? = nil {
        didSet {
            guard let benifitData = arrBenifits else { return }
            self.arr_BenifitsData = benifitData
            self.collection_view.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
        
        //Register Collection Cell
        self.collection_view.register(nibWithCellClass: BenifitCollectionCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UICollection Delegate DataSource Method
extension DietBenifitTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_BenifitsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: BenifitCollectionCell.self, for: indexPath)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        let dic_Detail = self.arr_BenifitsData[indexPath.row]
        cell.lbl_title.text = dic_Detail["title"].string ?? ""
        
        let img_banner = dic_Detail["image"].string ?? ""
        cell.img_icon.sd_setImage(with: URL.init(string: img_banner), placeholderImage: nil, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 85, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
