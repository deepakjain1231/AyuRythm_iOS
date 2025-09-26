//
//  ContestWinnerVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/03/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ContestWinnerVC: BaseViewController {
    
    @IBOutlet weak var contestNameL: UILabel!
    @IBOutlet weak var contestSubtitleL: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topOrangeView: UIView!
    
    var contest: ARContestModel?
    var winners = [ARContestWinnerModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Winners".localized()
        setBackButtonTitle()
        tableView.register(nibWithCellClass: ContestWinnerCell.self)
        tableView.allowsSelection = false
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topOrangeView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 26)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupUI() {
        guard let contest = contest else {
            return
        }

        contestNameL.text = contest.name
        //contestSubtitleL.text = contest.subtitle
        getContestWinnerList()
    }
    
    @IBAction func checkLeaderBoardBtnPressed(sender: UIButton) {
        ContestLeaderBoardVC.showScreen(contest: contest, isFromContestHomeScreen: true, from: self)
    }
}

extension ContestWinnerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return winners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ContestWinnerCell.self, for: indexPath)
        cell.data = winners[indexPath.row]
        return cell
    }
}

extension ContestWinnerVC {
    func getContestWinnerList() {
        showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId(), "contest_id": contest?.id ?? ""] as [String : Any]
        Utils.doAPICall(endPoint: .getContestWinners, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.winners = responseJSON?["winners"].array?.compactMap{ ARContestWinnerModel(fromJson: $0) } ?? []
                self.tableView.reloadData()
                self.hideActivityIndicator()
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
}
