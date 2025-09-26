//
//  StreakDetailVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ARStreakLevel {
    var name: String
    var colorCode: String
    var progress: Float
    var isFinished = false
    var isNext = false
    
    internal init(name: String, colorCode: String, progress: Float = 0, isFinished: Bool = false, isNext: Bool = false) {
        self.name = name
        self.colorCode = colorCode
        self.progress = progress
        self.isFinished = isFinished
        self.isNext = isNext
    }
    
    var isLocked: Bool {
        return progress == 0 && !isNext
    }
    
    static func getAllLevels() -> [ARStreakLevel] {
        return [ARStreakLevel(name: "Bronze", colorCode: "#A77C3D", progress: 1),
                ARStreakLevel(name: "Silver", colorCode: "#939393", progress: 0.3),
                ARStreakLevel(name: "Gold", colorCode: "#F3C900", isNext: true),
                ARStreakLevel(name: "Amethyst", colorCode: "#CE65FF"),
                ARStreakLevel(name: "Emerald", colorCode: "#6CC068")]
    }
}

class StreakDetailVC: UIViewController {
    
    @IBOutlet weak var streakTimelineView: StreakTimelineView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteL: UILabel!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var streakDaysSV: UIStackView!
    @IBOutlet weak var streakDaysCollectionView: UICollectionView!
    
    var streakLevels = [ARStreakLevelModel]()
    var streakDays = [ARStreakDayModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Streak".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserStreakLevelDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        streakDaysCollectionView.invalidateIntrinsicContentSize()
        streakDaysCollectionView.layoutIfNeeded()
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: StreakLevelCell.self)
//        tableView.estimatedRowHeight = 160
        streakDaysCollectionView.setupUISpace(allSide: 0, itemSpacing: 12, lineSpacing: 16)
        streakDaysCollectionView.register(nibWithCellClass: StreakDayCell.self)
        
        updateUI(from: kSharedAppDelegate.userStreakLevel)
    }
    
    func updateUI(from data: ARUserStreakLevelModel?) {
        streakTimelineView.updateUI(from: data)
        
        guard let userStreakLevel = data else { print("no userStreakLevel found !!!!"); return }
        streakLevels = userStreakLevel.allRanks
        streakDays = userStreakLevel.streakDays
        streakDaysSV.isHidden = userStreakLevel.isUserOnNoRankLevel
        noteL.text = String(format: "Note : You’ll be droped to previous level if you miss sparshna for straight %d days.".localized(), userStreakLevel.nextLevelDetails.missday)
        tableView.reloadData()
        streakDaysCollectionView.reloadData()
    }
    
    @IBAction func arrowBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        streakDaysCollectionView.isHidden.toggle()
        
        DispatchQueue.delay(.milliseconds(10)) {
            self.streakDaysCollectionView.reloadData()
        }
    }
}

extension StreakDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streakLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: StreakLevelCell.self, for: indexPath)
        cell.level = streakLevels[indexPath.row]
        let isHideProgress = (indexPath.row == streakLevels.count - 1)
        cell.progressBar.isHidden = isHideProgress
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let level = streakLevels[indexPath.row]
        showStreakLevelDetailScreen(for: level)
    }
}

extension StreakDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streakDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfcell = UIScreen.main.bounds.size.width > 320 ? 4 : 0
        let cellWidth = collectionView.widthOfItemCellFor(noOfCellsInRow: noOfcell)
        return CGSize(width: cellWidth, height: 26)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: StreakDayCell.self, for: indexPath)
        cell.setupUI(data: streakDays[indexPath.item], index: indexPath.item)
        return cell
    }
}

extension StreakDetailVC {
    func fetchUserStreakLevelDetails() {
        streakTimelineView.refreshUIByAPICall { userStreakLevel in
            self.updateUI(from: userStreakLevel)
        }
    }
    
    func showStreakLevelDetailScreen(for level: ARStreakLevelModel) {
        if !level.isMoreRewards {
            print("no more rewards in this level")
            return
        }
        
        if !level.lock && !level.isNext {
            self.showActivityIndicator()
            StreakLevelDetailVC.getStreakRewardList(id: level.id) { [weak self] isSuccess, status, message, rewards in
                if isSuccess {
                    self?.hideActivityIndicator()
                    let vc = StreakLevelDetailVC.instantiate(fromAppStoryboard: .Gamification)
                    vc.level = level
                    vc.levelRewards = rewards
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self?.hideActivityIndicator()
                    self?.showAlert(title: status, message: message)
                }
            }
        }
    }
    
    static func getUserStreakDetails(completion: ((Bool, String, String, ARUserStreakLevelModel?) -> Void)? = nil ) {
        Utils.doAPICall(endPoint: .getUserStreak, parameters: ["language_id" : Utils.getLanguageId()], headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let userStreakLevel = ARUserStreakLevelModel(fromJson: responseJSON["data"])
                kSharedAppDelegate.userStreakLevel = userStreakLevel
                completion?(isSuccess, status, message, userStreakLevel)
            } else {
                completion?(isSuccess, status, message, nil)
            }
        }
    }
}
