////
////  FavouriteYogaViewController.swift
////  HourOnEarth
////
////  Created by Apple on 18/04/20.
////  Copyright © 2020 Pradeep. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class FavouriteYogaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//    var arrData: [NSManagedObject] = [NSManagedObject]()
//    @IBOutlet weak var _tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Yoga"
//        _tableView.register(UINib(nibName: "MyPlanSubCell", bundle: nil), forCellReuseIdentifier: "MyPlanSubCell")
//        _tableView.separatorStyle = .none
//        _tableView.tableFooterView = UIView()
//    }
//
//    // MARK: - Button Actions
//    @IBAction func backBtnAction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrData.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPlanSubCell", for: indexPath) as! MyPlanSubCell
//        cell.backgroundColor = .white
//        let dic = arrData[indexPath.item]
//        cell.configure(title: (dic as? FavouriteYoga)?.english_name ?? "", subTitle: (dic as? FavouriteYoga)?.name ?? "", imageUrl: (dic as? FavouriteYoga)?.image ?? "")
//        cell.selectionStyle = .none
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyBoard = UIStoryboard(name: "MyPlan", bundle: nil)
//        let objCollectionView:YogaVideoPlayerViewController = storyBoard.instantiateViewController(withIdentifier: "YogaVideoPlayerViewController") as! YogaVideoPlayerViewController
//        objCollectionView.planType = .YogaMyPlanFavourite
//        objCollectionView.dic = arrData[indexPath.item]
//        self.navigationController?.pushViewController(objCollectionView, animated: true)
//    }
//}
