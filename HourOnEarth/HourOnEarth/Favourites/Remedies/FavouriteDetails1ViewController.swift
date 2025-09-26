//
//  FavouriteDetails1ViewController.swift
//  HourOnEarth
//
//  Created by Debu on 12/03/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class FavouriteDetails1ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataArray: [FavouriteHomeRemedies] = [FavouriteHomeRemedies]()
    var remediesArray: [FavouriteHomeRemedies] = [FavouriteHomeRemedies]()
    var dicData = [String: [FavouriteHomeRemedies]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home Remedies".localized()
        collectionView.register(UINib(nibName: "RemediesNewCell", bundle: nil), forCellWithReuseIdentifier: "RemediesNewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getGroupedData()
        collectionView.reloadData()
    }
    
    // MARK: - Button Actions
    func getGroupedData() {
        var uniqueKeys = [String]()
        for remedies in remediesArray {
            let title = remedies.category ?? ""
            if !uniqueKeys.contains(title), !title.isEmpty {
                uniqueKeys.append(remedies.category ?? "")
            }
        }
        var dicDataFiltered = [String: [FavouriteHomeRemedies]]()
        for key in uniqueKeys {
            let filteredData = remediesArray.filter({$0.category == key})
            dicDataFiltered[key] = filteredData
        }
        self.dicData = dicDataFiltered
    }
}

// MARK: UICollectionViewDataSource
extension FavouriteDetails1ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dicData.keys.sorted().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let key = self.dicData.keys.sorted()[indexPath.item]
        
        guard let cell: RemediesNewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemediesNewCell", for: indexPath) as? RemediesNewCell else {
            return UICollectionViewCell()
        }
        cell.lblName.text = key
        if let arrRemedy = dicData[key], let imgUrl = arrRemedy.first?.categoryimage, let url = URL(string: imgUrl) {
                cell.imgView.af.setImage(withURL: url)
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size:CGFloat = (kDeviceWidth) / 3.0
        return CGSize(width: size, height: size)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = self.dicData.keys.sorted()[indexPath.item]
        guard let arrRemedy = dicData[key] else {
            return
        }
       let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
       let objRemedyView: FavRemediesDetailViewController = storyBoard.instantiateViewController(withIdentifier: "FavRemediesDetailViewController") as! FavRemediesDetailViewController
        objRemedyView.titleRemedy = key
       objRemedyView.remediesArr = arrRemedy
       self.navigationController?.pushViewController(objRemedyView, animated: true)
    }
}
