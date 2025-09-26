//
//  HomeYogaCell.swift
//  HourOnEarth
//
//  Created by Apple on 30/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData

//enum CellType {
//    case yoga(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
//    case pranayama(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
//    case meditation(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
//    case mudra(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
//    case kriya(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
//    case food
//    case foodDemo
//}

class GlobalSearchYogaCell: UITableViewCell, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var dataArray = [NSManagedObject]()
    var delegate: RecommendationSeeAllDelegate?
    var indexPath: IndexPath?
    var cellType = CellType.yoga(isStatusVisible: true, recPrakriti: .kapha, recVikriti: .kapha)

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "HOEYogaCell", bundle: nil), forCellWithReuseIdentifier: "HOEYogaCell")
        collectionView.register(UINib(nibName: "HOEFoodCell", bundle: nil), forCellWithReuseIdentifier: "HOEFoodCell")
    }
    
//    func configureUI(title: String, data: [NSManagedObject], cellType: CellType) {
//
//
//        self.lblTitle.text = title == "Mudra" ? "Mudras" : title == "Kriya" ? "Kriyas" : title
//        self.dataArray = data
//        self.cellType = cellType
//        self.collectionView.reloadData()
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch cellType {
//        case .yoga:
//            return CGSize(width: 205 , height: 190.0)
//        case .pranayama:
//            return CGSize(width: 205 , height: 190.0)
//        case .meditation:
//            return CGSize(width: 205 , height: 190.0)
//        case .mudra:
//            return CGSize(width: 205 , height: 190.0)
//        case .kriya:
//            return CGSize(width: 205 , height: 190.0)
//        case .food:
//            return CGSize(width: 144 , height: 162.0)
//        case .foodDemo:
//            return CGSize(width: 144 , height: 130.0)
//        }
        return CGSize(width: 205 , height: 190.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch cellType {
//        case .yoga(let isStatusVisible, let recPrakriti, let recVikriti):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
//            guard let yoga = self.dataArray[indexPath.row] as? Yoga else {
//                return UICollectionViewCell()
//            }
//            cell.configureUI(yoga: yoga, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
            return cell
            
//        case .pranayama(let isStatusVisible, let recPrakriti, let recVikriti):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
//                return UICollectionViewCell()
//            }
//            guard let Pranayama = self.dataArray[indexPath.row] as? Pranayama else {
//                return UICollectionViewCell()
//            }
//            cell.configureUIPranayama(Pranayama: Pranayama, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
//            return cell
//
//        case .meditation(let isStatusVisible, let recPrakriti, let recVikriti):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
//                return UICollectionViewCell()
//            }
//            guard let meditation = self.dataArray[indexPath.row] as? Meditation else {
//                return UICollectionViewCell()
//            }
//            cell.configureUIMeditation(meditation: meditation, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
//            return cell
//
//        case .mudra(let isStatusVisible, let recPrakriti, let recVikriti):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
//                return UICollectionViewCell()
//            }
//            guard let mudra = self.dataArray[indexPath.row] as? Mudra else {
//                return UICollectionViewCell()
//            }
//            cell.configureUIMudra(mudra: mudra, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
//            return cell
//
//        case .kriya(let isStatusVisible, let recPrakriti, let recVikriti):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
//                return UICollectionViewCell()
//            }
//            guard let kriya = self.dataArray[indexPath.row] as? Kriya else {
//                return UICollectionViewCell()
//            }
//            cell.configureUIKriya(kriya: kriya, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
//            return cell
//
//        case .food:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEFoodCell", for: indexPath) as? HOEFoodCell else {
//                return UICollectionViewCell()
//            }
//
//            guard let food = self.dataArray[indexPath.row] as? Food else {
//                return UICollectionViewCell()
//            }
//            cell.configureUI(food: food)
//            return cell
//
//        case .foodDemo:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEFoodCell", for: indexPath) as? HOEFoodCell else {
//                return UICollectionViewCell()
//            }
//
//            guard let food = self.dataArray[indexPath.row] as? FoodDemo else {
//                return UICollectionViewCell()
//            }
//            cell.configureUI(foodType: food)
//            return cell
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let indexValue = self.indexPath else {
            return
        }
        delegate?.didSelectedSelectRow(indexPath: indexValue, index: indexPath.item)
    }
    
    @IBAction func seeMoreClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        delegate?.didSelectedSelectRow(indexPath: indexPath, index: nil)
    }
}
