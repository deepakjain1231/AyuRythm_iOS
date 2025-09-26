//
//  StreakLevelDetailVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class StreakLevelDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var level: ARStreakLevelModel?
    var levelRewards = [ARStreakRewardModel]()
    var scratchCardReward: ARScratchCardModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = level?.rank
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: RewardDetailCell.self)
        if let scratchCardReward = scratchCardReward {
            self.title = "My Reward".localized()
            levelRewards = [ARStreakRewardModel.getModel(from: scratchCardReward)]
        }
        tableView.reloadData()
    }
}

extension StreakLevelDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelRewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: RewardDetailCell.self, for: indexPath)
        cell.streakReward = levelRewards[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StreakLevelDetailVC: RewardDetailCellDelegate {
    func rewardDetailCellDidClickCopyCode(_ cell: RewardDetailCell, data: ARStreakRewardModel?) {
        UIPasteboard.general.string = data?.rewardCode
        Utils.showAlertWithTitleInControllerWithCompletion("", message: "Code copied successfully".localized(), okTitle: "Ok".localized(), controller: self) {}
    }
    
    func rewardDetailCellDidClickDropDown(_ cell: RewardDetailCell, data: ARStreakRewardModel?) {
        tableView.reloadData()
    }
}

extension StreakLevelDetailVC {
    static func getStreakRewardList(id: String, completion: @escaping (Bool, String, String, [ARStreakRewardModel]) -> Void ) {
        let params = ["language_id" : Utils.getLanguageId(), "rank_id": id] as [String: Any]
        Utils.doAPICall(endPoint: .getUserStreakDetails, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                let rewards = responseJSON?["data"].array?.compactMap{ ARStreakRewardModel(fromJson: $0) } ?? []
                completion(isSuccess, status, message, rewards)
            } else {
                completion(isSuccess, status, message, [])
            }
        }
    }
}
