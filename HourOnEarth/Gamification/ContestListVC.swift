//
//  ContestListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContestListVC: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var contests = [ARContestModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contests".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        collectionView.setupUISpace(allSide: 0, itemSpacing: 0, lineSpacing: 8)
        collectionView.register(nibWithCellClass: ContestDetailCell.self)
        fetchContestList()
        
        NotificationCenter.default.addObserver(forName: .refreshContestList, object: nil, queue: nil) { [weak self] notif in
            self?.fetchContestList()
        }
    }
}

extension ContestListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let cellWidth = collectionView.widthOfItemCellFor(noOfCellsInRow: 1)
        //let cellHeight = 154 + cell.detailL.requiredHeight
        //return CGSize(width: cellWidth, height: cellHeight/*210*/)
        return size(for: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ContestDetailCell.self, for: indexPath)
        cell.data = contests[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contest = contests[indexPath.row]
        ContestHomeVC.showScreen(contest: contest, fromVC: self)
    }
    
    private func size(for indexPath: IndexPath) -> CGSize {
        // load cell from Xib
        let cell = Bundle.main.loadNibNamed("ContestDetailCell", owner: self, options: nil)?.first as! ContestDetailCell
        
        // configure cell with data in it
        cell.data = contests[indexPath.item]
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        // width that you want
        let width = collectionView.frame.width
        let height: CGFloat = 0
        
        let targetSize = CGSize(width: width, height: height)
        
        // get size with width that you want and automatic height
        let size = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel)
        // if you want height and width both to be dynamic use below
        // let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        return size
    }
}

extension ContestListVC {
    func fetchContestList() {
        self.showActivityIndicator()
        Self.fetchContestList() { [weak self] isSuccess, status, message, contests in
            if isSuccess {
                self?.contests = contests
                self?.collectionView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
    
    static func fetchContestList(limit: Int? = nil, completion: @escaping (Bool, String, String, [ARContestModel]) -> Void ) {
        var params = ["language_id" : Utils.getLanguageId()] as [String: Any]
        if let limit = limit {
            params["limit"] = limit
        }
        Utils.doAPICall(endPoint: .getContestsList, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                let contests = responseJSON?["contest_list"].array?.compactMap{ ARContestModel(fromJson: $0) } ?? []
                completion(isSuccess, status, message, contests)
            } else {
                completion(isSuccess, status, message, [])
            }
        }
    }
}
