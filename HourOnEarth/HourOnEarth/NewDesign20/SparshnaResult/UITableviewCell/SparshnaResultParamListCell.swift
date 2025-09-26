//
//  SparshnaResultParamListCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

protocol SparshnaResultParamListCellDelegate {
    func showInfoOfParam(at index: Int)
    func showHideDetailedResult(isShow: Bool)
}

class SparshnaResultParamListCell: UITableViewCell {
    
    static let maxCellHeight: CGFloat = 140
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showDetailResults: UIButton!
    @IBOutlet weak var hideDetailResults: UIButton!
    
    var resultParams = [SparshnaResultParamModel]()
    var resultFilteredParams = [SparshnaResultParamModel]()
    var delegate: SparshnaResultParamListCellDelegate?
    var isDetailedResultVisible = false

    override func awakeFromNib() {
        super.awakeFromNib()
        hideDetailResults.isHidden = true
        collectionView.register(UINib(nibName: "SparshnaResultParamCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SparshnaResultParamCellCollectionViewCell")
    }
    
    func configureUI(resultParams: [SparshnaResultParamModel], resultFilteredParams: [SparshnaResultParamModel], isDetailedResultVisible: Bool) {
        self.isDetailedResultVisible = isDetailedResultVisible
        self.showDetailResults.isHidden = isDetailedResultVisible
        self.hideDetailResults.isHidden = !isDetailedResultVisible
        self.resultParams = resultParams
        self.resultFilteredParams = resultFilteredParams
        self.collectionView.reloadData()
    }
    
    @IBAction func showHideDetailedResultsBtnPressed(sender: UIButton) {
        sender.isHidden = true
        if sender == showDetailResults {
            hideDetailResults.isHidden = false
            isDetailedResultVisible = true
        } else {
            showDetailResults.isHidden = false
            isDetailedResultVisible = false
        }
        //collectionView.reloadData()
        delegate?.showHideDetailedResult(isShow: isDetailedResultVisible)
    }
    
    @objc func infoBtnPressed(sender: UIButton) {
        delegate?.showInfoOfParam(at: sender.tag)
    }
}

extension SparshnaResultParamListCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isDetailedResultVisible ? resultParams.count : resultFilteredParams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kDeviceWidth/2, height: Self.maxCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SparshnaResultParamCellCollectionViewCell", for: indexPath) as? SparshnaResultParamCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        let paramData = isDetailedResultVisible ? resultParams[indexPath.item] : resultFilteredParams[indexPath.item]
        cell.paramData = paramData
        cell.infoBtn.tag = indexPath.row
        cell.infoBtn.removeTarget(self, action: nil, for: .touchUpInside)
        cell.infoBtn.addTarget(self, action: #selector(infoBtnPressed(sender:)), for: .touchUpInside)
        
        return cell
    }
}

class DynamicCollectionView: UICollectionView {
  override func layoutSubviews() {
    super.layoutSubviews()
    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
        self.invalidateIntrinsicContentSize()
     }
  }

   override var intrinsicContentSize: CGSize {
    return collectionViewLayout.collectionViewContentSize
   }
}
