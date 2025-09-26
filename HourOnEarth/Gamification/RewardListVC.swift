//
//  RewardListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class RewardListVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var scratchCards = [ARScratchCardModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Rewards".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        collectionView.setupUISpace(allSide: 0, itemSpacing: 20, lineSpacing: 20)
        collectionView.register(nibWithCellClass: ScratchCardCell.self)
        fetchScratchCardList()
        
        NotificationCenter.default.addObserver(forName: .refreshScratchCardList, object: nil, queue: nil) { [weak self] notif in
            self?.fetchScratchCardList(isShowActivityIndicator: false)
        }
    }
}

extension RewardListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scratchCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.widthOfItemCellFor(noOfCellsInRow: 2)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ScratchCardCell.self, for: indexPath)
        cell.scratchCard = scratchCards[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let scratchCard = scratchCards[indexPath.row]
        ScratchCardVC.showScreenFromRewardList(scratchCard: scratchCard, fromVC: self)
    }
}

extension RewardListVC {
    func fetchScratchCardList(isShowActivityIndicator: Bool = true) {
        if isShowActivityIndicator {
            self.showActivityIndicator()
        }
        Self.getScratchCardList() { [weak self] isSuccess, status, message, scratchCards in
            if isSuccess {
                self?.scratchCards = scratchCards
                self?.collectionView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
    
    static func getScratchCardList(limit: Int? = nil, completion: @escaping (Bool, String, String, [ARScratchCardModel]) -> Void ) {
        var params = ["language_id" : Utils.getLanguageId()] as [String: Any]
        if let limit = limit {
            params["limit"] = limit
        }
        Utils.doAPICall(endPoint: .getMyScratchCards, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                let cards = responseJSON?["data"].array?.compactMap{ ARScratchCardModel(fromJson: $0) } ?? []
                completion(isSuccess, status, message, cards)
            } else {
                completion(isSuccess, status, message, [])
            }
        }
    }
}
