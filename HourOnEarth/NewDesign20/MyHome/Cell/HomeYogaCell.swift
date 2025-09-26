//
//  HomeYogaCell.swift
//  HourOnEarth
//
//  Created by Apple on 30/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData

enum CellType {
    case yoga(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case pranayama(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case meditation(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case mudra(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case kriya(isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case food
    case foodDemo
    case herb
    case herbType
    case homeremedies
}

class HomeYogaCell: UITableViewCell, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var globalCatLockView: UIView!
    @IBOutlet weak var btnSeeMore: UIView!

    var dataArray = [NSManagedObject]()
    var delegate: RecommendationSeeAllDelegate?
    var indexPathNew: IndexPath?
    var cellType = CellType.yoga(isStatusVisible: true, recPrakriti: .kapha, recVikriti: .kapha)
    var isFromGlobalSearch = false
    var dataArrayHomeRem: [[String: Any]] = [[String: Any]]()

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "HOEYogaCell", bundle: nil), forCellWithReuseIdentifier: "HOEYogaCell")
        collectionView.register(UINib(nibName: "HOEFoodCell", bundle: nil), forCellWithReuseIdentifier: "HOEFoodCell")
        collectionView.register(UINib(nibName: "RemediesNewCell", bundle: nil), forCellWithReuseIdentifier: "RemediesNewCell")
        collectionView.register(UINib(nibName: "HOEHerbCell", bundle: nil), forCellWithReuseIdentifier: "HOEHerbCell")
        
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)
        self.collectionView.register(nibWithCellClass: ForYouFoodCollectionCell.self)
    }
    
    func configureUI(title: String, data: [NSManagedObject], cellType: CellType) {
        self.lblTitle.text = title == "Mudra" ? "Mudras".localized() : title == "Kriya" ? "Kriyas".localized() : title.localized()
        self.dataArray = data
        self.cellType = cellType
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cellType {
        case .yoga(isStatusVisible: _, recPrakriti: _, recVikriti: _):
            break
        case .pranayama(isStatusVisible: _, recPrakriti: _, recVikriti: _):
            break
        case .meditation(isStatusVisible: _, recPrakriti: _, recVikriti: _):
            break
        case .mudra(isStatusVisible: _, recPrakriti: _, recVikriti: _):
            break
        case .kriya(isStatusVisible: _, recPrakriti: _, recVikriti: _):
            break
        case .food, .foodDemo:
            break
        case .herb, .herbType:
            break
        case .homeremedies:
            return self.dataArrayHomeRem.count
        }
        return isFromGlobalSearch ? self.dataArray.count : (self.dataArray.count > 3 ? 3 : self.dataArray.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch cellType {
        case .yoga:
            return CGSize(width: 205 , height: 190.0)
        case .pranayama:
            return CGSize(width: 205 , height: 190.0)
        case .meditation:
            return CGSize(width: 205 , height: 190.0)
        case .mudra:
            return CGSize(width: 205 , height: 190.0)
        case .kriya:
            return CGSize(width: 205 , height: 190.0)
        case .food, .herb:
            return CGSize(width: 150 , height: 150.0)
        case .homeremedies:
            return CGSize(width: 130 , height: 130.0)
        case .foodDemo, .herbType:
            //return CGSize(width: 144 , height: 130.0)
            return CGSize(width: 150 , height: 150.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cellType {
        case .yoga(let isStatusVisible, let recPrakriti, let recVikriti):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let yoga = self.dataArray[indexPath.row] as? Yoga else {
                return UICollectionViewCell()
            }
            cell.delegate = delegate
            cell.indexPath = indexPathNew
            cell.btnLock.tag = indexPath.row
            if yoga.access_point == 0 {
                cell.lockView.isHidden = true
            }
            else {
                cell.lockView.isHidden = yoga.redeemed
            }
            cell.configureUI(yoga: yoga, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
            return cell
            
        case .pranayama(let isStatusVisible, let recPrakriti, let recVikriti):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let Pranayama = self.dataArray[indexPath.row] as? Pranayama else {
                return UICollectionViewCell()
            }
            cell.delegate = delegate
            cell.indexPath = indexPathNew
            if Pranayama.access_point == 0 {
                cell.lockView.isHidden = true
            }
            else {
                cell.lockView.isHidden = Pranayama.redeemed
            }
            cell.btnLock.tag = indexPath.row
            cell.configureUIPranayama(Pranayama: Pranayama, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
            return cell
            
        case .meditation(let isStatusVisible, let recPrakriti, let recVikriti):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let meditation = self.dataArray[indexPath.row] as? Meditation else {
                return UICollectionViewCell()
            }
            cell.delegate = delegate
            cell.indexPath = indexPathNew
            cell.btnLock.tag = indexPath.row
            debugPrint("meditation.access_point \(meditation.access_point)")
            if meditation.access_point == 0 {
                cell.lockView.isHidden = true
            }
            else {
                cell.lockView.isHidden = meditation.redeemed
            }
//            cell.btnLock.tag = Int(meditation.access_point)
            cell.configureUIMeditation(meditation: meditation, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
            return cell
            
        case .mudra(let isStatusVisible, let recPrakriti, let recVikriti):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let mudra = self.dataArray[indexPath.row] as? Mudra else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.configureUIMudra(mudra: mudra, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
            return cell
            
        case .kriya(let isStatusVisible, let recPrakriti, let recVikriti):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let kriya = self.dataArray[indexPath.row] as? Kriya else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.configureUIKriya(kriya: kriya, isStatusVisible: isStatusVisible, recPrakriti: recPrakriti, recVikriti: recVikriti)
            return cell

        case .food:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFoodCollectionCell", for: indexPath) as? ForYouFoodCollectionCell else {
                return UICollectionViewCell()
            }//HOEFoodCell
            
            guard let food = self.dataArray[indexPath.row] as? Food else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.configureUI(food: food)
            cell.delegate = delegate
            cell.indexPath = indexPath
            return cell
            
        case .foodDemo:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFoodCollectionCell", for: indexPath) as? ForYouFoodCollectionCell else {
                return UICollectionViewCell()//HOEFoodCell
            }
            
            guard let food = self.dataArray[indexPath.row] as? FoodDemo else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.configureUI(foodType: food)
            return cell
            
        case .herb:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFoodCollectionCell", for: indexPath) as? ForYouFoodCollectionCell else {
                return UICollectionViewCell()
            }
            
            guard let herb = self.dataArray[indexPath.row] as? Herb else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.configureUI(herb: herb)
            cell.delegate = delegate
            cell.indexPath = indexPath
            return cell
            
        case .herbType:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFoodCollectionCell", for: indexPath) as? ForYouFoodCollectionCell else {
                return UICollectionViewCell()
            }
            
            guard let herbType = self.dataArray[indexPath.row] as? HerbType else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.configureUI(herbType: herbType)
            return cell
            
        case .homeremedies:
            
            guard let cell: RemediesNewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemediesNewCell", for: indexPath) as? RemediesNewCell else {
                return UICollectionViewCell()
            }
            let dicDetail = dataArrayHomeRem[indexPath.row]
            
            let heading = dicDetail["categoryname"] as? String ?? ""
            cell.lblName.text = heading
            if let imageUrl = dicDetail["categoryimage"] as? String, let url = URL(string: imageUrl) {
                cell.imgView.af.setImage(withURL: url)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let indexValue = self.indexPathNew else {
            return
        }
        delegate?.didSelectedSelectRow(indexPath: indexValue, index: indexPath.item)
    }
    
    @IBAction func seeMoreClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPathNew else {
            return
        }
        delegate?.didSelectedSelectRow(indexPath: indexPath, index: nil)
    }
    
    @IBAction func globalCatLockTapped(_ sender: UIButton) {
        guard let indexPath = self.indexPathNew else {
            return
        }
        delegate?.didSelectedSelectRowForRedeem(indexPath: indexPath, index: nil)
    }
}
