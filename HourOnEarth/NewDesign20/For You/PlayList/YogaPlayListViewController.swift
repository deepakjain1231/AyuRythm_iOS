//
//  YogaPlayListViewController.swift
//  HourOnEarth
//
//  Created by Apple on 27/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

enum PlayListCellType {
    case playlits(title: String, yoga:[Yoga], isBenefits: Bool)
    case playlitsmeditation(title: String, meditation:[Meditation], isBenefits: Bool)
    case playlitspranayama(title: String, pranayama:[Pranayama], isBenefits: Bool)
    case playlitsmudra(title: String, mudra:[Mudra], isBenefits: Bool)
    case playlitskriya(title: String, kriya:[Kriya], isBenefits: Bool)
}

class YogaPlayListViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    var dataArray = [PlayListCellType]()
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var yogaArray = [Yoga]()
    var meditationArray = [Meditation]()
    var pranayamaArray = [Pranayama]()
    var mudraArray = [Mudra]()
    var kriyaArray = [Kriya]()
    private var filteredDataArray = [Yoga] ()
    private var filteredDataArraymeditation = [Meditation] ()
    private var filteredDataArraypranayama = [Pranayama] ()
    private var filteredDataArraymudra = [Mudra] ()
    private var filteredDataArraykriya = [Kriya] ()
    private var isSearching = false
    var istype : IsSectionType = .yoga
    var selectedIndex = IndexPath()
    var accessPoint = Int()
    var name = String()
    var favID = Int()
    var isFromHomeScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButtonItem = UIBarButtonItem(image: UIImage(named: "invalidName_menu"), style: .plain, target: self, action: #selector(rightButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        collectionview.register(UINib(nibName: "PlayListCell", bundle: nil), forCellWithReuseIdentifier: "PlayListCell")
        collectionview.register(UINib(nibName: "HOEYogaCell", bundle: nil), forCellWithReuseIdentifier: "HOEYogaCell")
        if isFromHomeScreen {
            showActivityIndicator()
            fetchDataFromServer(type: istype) {
                self.hideActivityIndicator()
                self.setupUI()
                self.prepareData()
            }
        } else {
            setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.prepareData()
    }
    
    func setupUI() {
        if istype == IsSectionType.yoga
        {
            searchBar.placeholder = "Yogasanas".localized()
            self.title = "Yoga".localized()
            self.filteredDataArray = yogaArray
            print("self.filteredDataArray=",self.filteredDataArray)
        }
        else if istype == IsSectionType.meditation
        {
            searchBar.placeholder = "Meditation".localized()
            self.title = "Meditation".localized()
            self.filteredDataArraymeditation = meditationArray
        }
        else if istype == IsSectionType.pranayama
        {
            searchBar.placeholder = "Pranayama".localized()
            self.title = "Pranayama".localized()
            self.filteredDataArraypranayama = pranayamaArray
        }
        else if istype == IsSectionType.mudra
        {
            searchBar.placeholder = "Mudras".localized()
            self.title = "Mudras".localized()
            self.filteredDataArraymudra = mudraArray
        }
        else
        {
            searchBar.placeholder = "Kriyas".localized()
            self.title = "Kriyas".localized()
            self.filteredDataArraykriya = kriyaArray
        }
    }
    
    func prepareData() {
        
            if istype == IsSectionType.yoga
               {
                self.dataArray.removeAll()
                guard let groupedData = Dictionary(grouping: self.yogaArray, by: {$0.experiencelevel}) as? [String: [Yoga]] else {
                    return
                }
                let sortedKeys = ["Beginner", "Intermediate", "Advanced"]
                let filteredKeys = Shared.sharedInstance.filterLevels.count > 0 ? sortedKeys.filter({Shared.sharedInstance.filterLevels.contains($0)}) : sortedKeys
                for key in filteredKeys {
                    guard let value = groupedData[key] else { continue }
//                    self.dataArray.append(PlayListCellType.playlits(title: key, yoga: value, isBenefits: false))
                }
                
                //ROWS FOR BENEFITS ---
                var benefitTags = [String]()
                for objYoga in yogaArray {
                    let benefits = (objYoga.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                    benefitTags.append(contentsOf: benefits)
                }
                
                let uniqueBenefits = Array(Set(benefitTags)).sorted()
                let filteredTags = Shared.sharedInstance.filterTags.count > 0 ? uniqueBenefits.filter({Shared.sharedInstance.filterTags.contains($0)}) : uniqueBenefits

                for key in filteredTags {
                    var value = [Yoga]()
                    for yoga in yogaArray {
                        let benefits = (yoga.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                        if benefits.contains(key) {
                            value.append(yoga)
                        }
                    }
//                    self.dataArray.append(PlayListCellType.playlits(title: key, yoga: value, isBenefits: true))
                }
                
                var filteredValues = [Yoga]()
                
                for yoga in self.yogaArray where Shared.sharedInstance.filterRecommendation.count == 1 {
                    let valueToCheck = Shared.sharedInstance.filterRecommendation.first ?? ""
                    let kpvType: String = valueToCheck == "Vikriti" ? self.recommendationVikriti.rawValue : self.recommendationPrakriti.rawValue
                    
                    if yoga.type?.contains(kpvType) ?? false {
                        //"Prakriti"
                        filteredValues.append(yoga)
                    } else if yoga.type?.contains(valueToCheck) ?? false {
                        //"Vikriti"
                        filteredValues.append(yoga)
                    }
                }
                
                if Shared.sharedInstance.filterRecommendation.count == 1 {
                    self.filteredDataArray = self.getFilterByLevels(arrYoga: filteredValues)
                } else {
                    self.filteredDataArray = getFilterByLevels(arrYoga: self.yogaArray)
                }
                
                self.filteredDataArray = self.getFilterByTags(arrYoga: self.filteredDataArray)

               }
               else if istype == IsSectionType.meditation
               {
                self.dataArray.removeAll()
                guard let groupedData = Dictionary(grouping: self.meditationArray, by: {$0.experiencelevel}) as? [String: [Meditation]] else {
                    return
                }
                let sortedKeys = ["Beginner", "Intermediate", "Advanced"]
                let filteredKeys = Shared.sharedInstance.filterLevels.count > 0 ? sortedKeys.filter({Shared.sharedInstance.filterLevels.contains($0)}) : sortedKeys
                for key in filteredKeys {
                    guard let value = groupedData[key] else { continue }
//                self.dataArray.append(PlayListCellType.playlitsmeditation(title: key, meditation: value, isBenefits: false))
                }
                
                //ROWS FOR BENEFITS ---
                var benefitTags = [String]()
                for objMeditation in meditationArray {
                    let benefits = (objMeditation.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                    benefitTags.append(contentsOf: benefits)
                }
                
                let uniqueBenefits = Array(Set(benefitTags)).sorted()
                let filteredTags = Shared.sharedInstance.filterTags.count > 0 ? uniqueBenefits.filter({Shared.sharedInstance.filterTags.contains($0)}) : uniqueBenefits

                for key in filteredTags {
                    var value = [Meditation]()
                    for meditation in meditationArray {
                        let benefits = (meditation.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                        if benefits.contains(key) {
                            value.append(meditation)
                        }
                    }
//                self.dataArray.append(PlayListCellType.playlitsmeditation(title: key, meditation: value, isBenefits: true))
                }
                
                var filteredValues = [Meditation]()
                
                for meditation in self.meditationArray where Shared.sharedInstance.filterRecommendation.count == 1 {
                    let valueToCheck = Shared.sharedInstance.filterRecommendation.first ?? ""
                    let kpvType: String = valueToCheck == "Vikriti" ? self.recommendationVikriti.rawValue : self.recommendationPrakriti.rawValue
                    
                    if meditation.type?.contains(kpvType) ?? false {
                        //"Prakriti"
                        filteredValues.append(meditation)
                    } else if meditation.type?.contains(valueToCheck) ?? false {
                        //"Vikriti"
                        filteredValues.append(meditation)
                    }
                }
                
                if Shared.sharedInstance.filterRecommendation.count == 1 {
                    self.filteredDataArraymeditation = self.getFilterByLevelsMeditation(arrMeditation: filteredValues)
                } else {
                    self.filteredDataArraymeditation = getFilterByLevelsMeditation(arrMeditation: self.meditationArray)
                }
                
                self.filteredDataArraymeditation = self.getFilterByTagsMeditation(arrMeditation: self.filteredDataArraymeditation)

               }
               else if istype == IsSectionType.pranayama
               {
                self.dataArray.removeAll()
                guard let groupedData = Dictionary(grouping: self.pranayamaArray, by: {$0.experiencelevel}) as? [String: [Pranayama]] else {
                    return
                }
                let sortedKeys = ["Beginner", "Intermediate", "Advanced"]
                let filteredKeys = Shared.sharedInstance.filterLevels.count > 0 ? sortedKeys.filter({Shared.sharedInstance.filterLevels.contains($0)}) : sortedKeys
                for key in filteredKeys {
                    guard let value = groupedData[key] else { continue }
//                self.dataArray.append(PlayListCellType.playlitspranayama(title: key, pranayama: value, isBenefits: false))
                }
                
                //ROWS FOR BENEFITS ---
                var benefitTags = [String]()
                for objPranayama in pranayamaArray {
                    let benefits = (objPranayama.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                    benefitTags.append(contentsOf: benefits)
                }
                
                let uniqueBenefits = Array(Set(benefitTags)).sorted()
                let filteredTags = Shared.sharedInstance.filterTags.count > 0 ? uniqueBenefits.filter({Shared.sharedInstance.filterTags.contains($0)}) : uniqueBenefits

                for key in filteredTags {
                    var value = [Pranayama]()
                    for pranayama in pranayamaArray {
                        let benefits = (pranayama.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                        if benefits.contains(key) {
                            value.append(pranayama)
                        }
                    }
//                    self.dataArray.append(PlayListCellType.playlitspranayama(title: key, pranayama: value, isBenefits: true))
                }
                
                var filteredValues = [Pranayama]()
                
                for pranayama in self.pranayamaArray where Shared.sharedInstance.filterRecommendation.count == 1 {
                    let valueToCheck = Shared.sharedInstance.filterRecommendation.first ?? ""
                    let kpvType: String = valueToCheck == "Vikriti" ? self.recommendationVikriti.rawValue : self.recommendationPrakriti.rawValue
                    
                    if pranayama.type?.contains(kpvType) ?? false {
                        //"Prakriti"
                        filteredValues.append(pranayama)
                    } else if pranayama.type?.contains(valueToCheck) ?? false {
                        //"Vikriti"
                        filteredValues.append(pranayama)
                    }
                }
                
                if Shared.sharedInstance.filterRecommendation.count == 1 {
                    self.filteredDataArraypranayama = self.getFilterByLevelsPranayama(arrPranayama: filteredValues)
                } else {
                    self.filteredDataArraypranayama = getFilterByLevelsPranayama(arrPranayama: self.pranayamaArray)
                }
                
                self.filteredDataArraypranayama = self.getFilterByTagsPranayama(arrPranayama: self.filteredDataArraypranayama)

               }
               else if istype == IsSectionType.mudra
               {
                self.dataArray.removeAll()
                guard let groupedData = Dictionary(grouping: self.mudraArray, by: {$0.experiencelevel}) as? [String: [Mudra]] else {
                    return
                }
                let sortedKeys = ["Beginner", "Intermediate", "Advanced"]
                let filteredKeys = Shared.sharedInstance.filterLevels.count > 0 ? sortedKeys.filter({Shared.sharedInstance.filterLevels.contains($0)}) : sortedKeys
                for key in filteredKeys {
                    guard let value = groupedData[key] else { continue }
//                    self.dataArray.append(PlayListCellType.playlitsmudra(title: key, mudra: value, isBenefits: false))
                }
                
                //ROWS FOR BENEFITS ---
                var benefitTags = [String]()
                for objMudra in mudraArray {
                    let benefits = (objMudra.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                    benefitTags.append(contentsOf: benefits)
                }
                
                let uniqueBenefits = Array(Set(benefitTags)).sorted()
                let filteredTags = Shared.sharedInstance.filterTags.count > 0 ? uniqueBenefits.filter({Shared.sharedInstance.filterTags.contains($0)}) : uniqueBenefits

                for key in filteredTags {
                    var value = [Mudra]()
                    for mudra in mudraArray {
                        let benefits = (mudra.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                        if benefits.contains(key) {
                            value.append(mudra)
                        }
                    }
//                    self.dataArray.append(PlayListCellType.playlitsmudra(title: key, mudra: value, isBenefits: true))
                }
                
                var filteredValues = [Mudra]()
                
                for mudra in self.mudraArray where Shared.sharedInstance.filterRecommendation.count == 1 {
                    let valueToCheck = Shared.sharedInstance.filterRecommendation.first ?? ""
                    let kpvType: String = valueToCheck == "Vikriti" ? self.recommendationVikriti.rawValue : self.recommendationPrakriti.rawValue
                    
                    if mudra.type?.contains(kpvType) ?? false {
                        //"Prakriti"
                        filteredValues.append(mudra)
                    } else if mudra.type?.contains(valueToCheck) ?? false {
                        //"Vikriti"
                        filteredValues.append(mudra)
                    }
                }
                
                if Shared.sharedInstance.filterRecommendation.count == 1 {
                    self.filteredDataArraymudra = self.getFilterByLevelsMudra(arrMudra: filteredValues)
                } else {
                    self.filteredDataArraymudra = getFilterByLevelsMudra(arrMudra: self.mudraArray)
                }
                
                self.filteredDataArraymudra = self.getFilterByTagsMudra(arrMudra: self.filteredDataArraymudra)
               }
               else
               {
                self.dataArray.removeAll()
                guard let groupedData = Dictionary(grouping: self.kriyaArray, by: {$0.experiencelevel}) as? [String: [Kriya]] else {
                    return
                }
                let sortedKeys = ["Beginner", "Intermediate", "Advanced"]
                let filteredKeys = Shared.sharedInstance.filterLevels.count > 0 ? sortedKeys.filter({Shared.sharedInstance.filterLevels.contains($0)}) : sortedKeys
                for key in filteredKeys {
                    guard let value = groupedData[key] else { continue }
//                    self.dataArray.append(PlayListCellType.playlitskriya(title: key, kriya: value, isBenefits: false))
                }
                
                //ROWS FOR BENEFITS ---
                var benefitTags = [String]()
                for objKriya in kriyaArray {
                    let benefits = (objKriya.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                    benefitTags.append(contentsOf: benefits)
                }
                
                let uniqueBenefits = Array(Set(benefitTags)).sorted()
                let filteredTags = Shared.sharedInstance.filterTags.count > 0 ? uniqueBenefits.filter({Shared.sharedInstance.filterTags.contains($0)}) : uniqueBenefits

                for key in filteredTags {
                    var value = [Kriya]()
                    for kriya in kriyaArray {
                        let benefits = (kriya.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
                        if benefits.contains(key) {
                            value.append(kriya)
                        }
                    }
//                    self.dataArray.append(PlayListCellType.playlitskriya(title: key, kriya: value, isBenefits: true))
                }
                
                var filteredValues = [Kriya]()
                
                for kriya in self.kriyaArray where Shared.sharedInstance.filterRecommendation.count == 1 {
                    let valueToCheck = Shared.sharedInstance.filterRecommendation.first ?? ""
                    let kpvType: String = valueToCheck == "Vikriti" ? self.recommendationVikriti.rawValue : self.recommendationPrakriti.rawValue
                    
                    if kriya.type?.contains(kpvType) ?? false {
                        //"Prakriti"
                        filteredValues.append(kriya)
                    } else if kriya.type?.contains(valueToCheck) ?? false {
                        //"Vikriti"
                        filteredValues.append(kriya)
                    }
                }
                
                if Shared.sharedInstance.filterRecommendation.count == 1 {
                    self.filteredDataArraykriya = self.getFilterByLevelsKriya(arrKriya: filteredValues)
                } else {
                    self.filteredDataArraykriya = getFilterByLevelsKriya(arrKriya: self.kriyaArray)
                }
                
                self.filteredDataArraykriya = self.getFilterByTagsKriya(arrKriya: self.filteredDataArraykriya)
               }
        self.collectionview.reloadData()
    }
    
    
    func getFilterByTagsKriya(arrKriya: [Kriya]) -> [Kriya] {
        guard Shared.sharedInstance.filterTags.count > 0 else {
            return arrKriya
        }
        var filteredArray = [Kriya]()
        for kriya in arrKriya {
            let benefits = (kriya.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            let filteredData = Shared.sharedInstance.filterTags.filter({benefits.contains($0)})
            if filteredData.count > 0 {
                filteredArray.append(kriya)
            }
        }
        return filteredArray
    }

    
    func getFilterByTagsMudra(arrMudra: [Mudra]) -> [Mudra] {
        guard Shared.sharedInstance.filterTags.count > 0 else {
            return arrMudra
        }
        var filteredArray = [Mudra]()
        for mudra in arrMudra {
            let benefits = (mudra.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            let filteredData = Shared.sharedInstance.filterTags.filter({benefits.contains($0)})
            if filteredData.count > 0 {
                filteredArray.append(mudra)
            }
        }
        return filteredArray
    }
    
    func getFilterByTagsPranayama(arrPranayama: [Pranayama]) -> [Pranayama] {
        guard Shared.sharedInstance.filterTags.count > 0 else {
            return arrPranayama
        }
        var filteredArray = [Pranayama]()
        for pranayama in arrPranayama {
            let benefits = (pranayama.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            let filteredData = Shared.sharedInstance.filterTags.filter({benefits.contains($0)})
            if filteredData.count > 0 {
                filteredArray.append(pranayama)
            }
        }
        return filteredArray
    }
    
    func getFilterByTagsMeditation(arrMeditation: [Meditation]) -> [Meditation] {
        guard Shared.sharedInstance.filterTags.count > 0 else {
            return arrMeditation
        }
        var filteredArray = [Meditation]()
        for meditation in arrMeditation {
            let benefits = (meditation.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            let filteredData = Shared.sharedInstance.filterTags.filter({benefits.contains($0)})
            if filteredData.count > 0 {
                filteredArray.append(meditation)
            }
        }
        return filteredArray
    }

    
    func getFilterByTags(arrYoga: [Yoga]) -> [Yoga] {
        guard Shared.sharedInstance.filterTags.count > 0 else {
            return arrYoga
        }
        var filteredArray = [Yoga]()
        for yoga in arrYoga {
            let benefits = (yoga.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            let filteredData = Shared.sharedInstance.filterTags.filter({benefits.contains($0)})
            if filteredData.count > 0 {
                filteredArray.append(yoga)
            }
        }
        return filteredArray
    }
    
    
    func getFilterByLevelsKriya(arrKriya: [Kriya]) -> [Kriya] {
        guard Shared.sharedInstance.filterLevels.count > 0 else {
            return arrKriya
        }
        var filteredArray = [Kriya]()
        for kriya in arrKriya {
            if Shared.sharedInstance.filterLevels.contains(kriya.experiencelevel ?? "") {
                filteredArray.append(kriya)
            }
        }
        return filteredArray
    }

    
    func getFilterByLevelsMudra(arrMudra: [Mudra]) -> [Mudra] {
        guard Shared.sharedInstance.filterLevels.count > 0 else {
            return arrMudra
        }
        var filteredArray = [Mudra]()
        for mudra in arrMudra {
            if Shared.sharedInstance.filterLevels.contains(mudra.experiencelevel ?? "") {
                filteredArray.append(mudra)
            }
        }
        return filteredArray
    }
    
    func getFilterByLevelsPranayama(arrPranayama: [Pranayama]) -> [Pranayama] {
        guard Shared.sharedInstance.filterLevels.count > 0 else {
            return arrPranayama
        }
        var filteredArray = [Pranayama]()
        for pranayama in arrPranayama {
            if Shared.sharedInstance.filterLevels.contains(pranayama.experiencelevel ?? "") {
                filteredArray.append(pranayama)
            }
        }
        return filteredArray
    }

    func getFilterByLevelsMeditation(arrMeditation: [Meditation]) -> [Meditation] {
        guard Shared.sharedInstance.filterLevels.count > 0 else {
            return arrMeditation
        }
        var filteredArray = [Meditation]()
        for meditation in arrMeditation {
            if Shared.sharedInstance.filterLevels.contains(meditation.experiencelevel ?? "") {
                filteredArray.append(meditation)
            }
        }
        return filteredArray
    }

    func getFilterByLevels(arrYoga: [Yoga]) -> [Yoga] {
        guard Shared.sharedInstance.filterLevels.count > 0 else {
            return arrYoga
        }
        var filteredArray = [Yoga]()
        for yoga in arrYoga {
            if Shared.sharedInstance.filterLevels.contains(yoga.experiencelevel ?? "") {
                filteredArray.append(yoga)
            }
        }
        return filteredArray
    }
    
//    //MARK: CollectionViewDataSource/Delegates
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PlayListHeaderCell", for: indexPath) as? PlayListHeaderCell else {
//            return UICollectionReusableView()
//        }
//        if isSearching {
//            header.configureUI(title: "")
//        }else {
//            header.configureUI(title: "")
//        }
//        
////        if isSearching {
////            header.configureUI(title: "")
////        }else if indexPath.section == 0 {
////            header.configureUI(title: "Playlist")
////        } else {
////            header.configureUI(title: "Explore More")
////        }
//
//        return header
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isSearching ? 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            if istype == IsSectionType.yoga
            {
                return self.filteredDataArray.count
            }
            else if istype == IsSectionType.meditation
            {
                return self.filteredDataArraymeditation.count
            }
            else if istype == IsSectionType.pranayama
            {
                return self.filteredDataArraypranayama.count
            }
            else if istype == IsSectionType.mudra
            {
                return self.filteredDataArraymudra.count
            }
            else
            {
                return self.filteredDataArraykriya.count
            }
        } else {
                if istype == IsSectionType.yoga
                {
                    return self.filteredDataArray.count
                }
                else if istype == IsSectionType.meditation
                {
                    return self.filteredDataArraymeditation.count
                }
                else if istype == IsSectionType.pranayama
                {
                    return self.filteredDataArraypranayama.count
                }
                else if istype == IsSectionType.mudra
                {
                    return self.filteredDataArraymudra.count
                }
                else
                {
                    return self.filteredDataArraykriya.count
                }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSearching {
            if istype == IsSectionType.yoga
            {
                return getCellForYoga(indexPath: indexPath)
            }
            else if istype == IsSectionType.meditation
            {
                return getCellForMeditation(indexPath: indexPath)
            }
            else if istype == IsSectionType.pranayama
            {
                return getCellForPranayama(indexPath: indexPath)
            }
            else if istype == IsSectionType.mudra
            {
                return getCellForMudra(indexPath: indexPath)
            }
            else
            {
                return getCellForKriya(indexPath: indexPath)
            }
            
        } else {
                if istype == IsSectionType.yoga
                {
                    return getCellForYoga(indexPath: indexPath)
                }
                else if istype == IsSectionType.meditation
                {
                    return getCellForMeditation(indexPath: indexPath)
                }
                else if istype == IsSectionType.pranayama
                {
                    return getCellForPranayama(indexPath: indexPath)
                }
                else if istype == IsSectionType.mudra
                {
                    return getCellForMudra(indexPath: indexPath)
                }
                else
                {
                    return getCellForKriya(indexPath: indexPath)
                }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearching {
            return CGSize(width: kDeviceWidth/2, height: kDeviceWidth/2)
        } else {
                return CGSize(width: kDeviceWidth/2, height: kDeviceWidth/2)
        }
    }
    func heightForLable(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        // pass string, font, LableWidth
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
         label.numberOfLines = 0
         label.lineBreakMode = NSLineBreakMode.byWordWrapping
         label.font = font
         label.text = text
         label.sizeToFit()

         return label.frame.height
    }
    func getCellForYoga(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
            return UICollectionViewCell()
        }
        let yoga = filteredDataArray[indexPath.row]
        cell.indexPath = indexPath
        cell.configureUI(yoga: yoga, isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
        cell.delegate = self
        cell.btnLock.tag = indexPath.row
        if yoga.access_point == 0 {
            cell.lockView.isHidden = true
        }
        else {
            cell.lockView.isHidden = yoga.redeemed
        }
        return cell
    }
    
    func getCellForMeditation(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
            return UICollectionViewCell()
        }
        let meditation = filteredDataArraymeditation[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.btnLock.tag = indexPath.row
        if meditation.access_point == 0 {
            cell.lockView.isHidden = true
        }
        else {
            cell.lockView.isHidden = meditation.redeemed
        }

        cell.configureUIMeditation(meditation: meditation, isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
        return cell
    }
    
    func getCellForPranayama(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
            return UICollectionViewCell()
        }
        let pranayama = filteredDataArraypranayama[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.btnLock.tag = indexPath.row
        if pranayama.access_point == 0 {
            cell.lockView.isHidden = true
        }
        else {
            cell.lockView.isHidden = pranayama.redeemed
        }

        cell.configureUIPranayama(Pranayama: pranayama, isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
        return cell
    }

    func getCellForMudra(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
            return UICollectionViewCell()
        }
        //cell.lockView.isHidden = true
        let mudra = filteredDataArraymudra[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        if mudra.access_point == 0 {
            cell.lockView.isHidden = true
        } else {
            cell.lockView.isHidden = mudra.redeemed
        }
        cell.configureUIMudra(mudra: mudra, isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
        return cell
    }
    
    func getCellForKriya(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
            return UICollectionViewCell()
        }
        cell.indexPath = indexPath
        cell.delegate = self
        let kriya = filteredDataArraykriya[indexPath.row]
        if kriya.access_point == 0 {
            cell.lockView.isHidden = true
        } else {
            cell.lockView.isHidden = kriya.redeemed
        }
        cell.configureUIKriya(kriya: kriya, isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
        return cell
    }



    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSearching {
            if istype == IsSectionType.yoga
            {
                let yoga = filteredDataArray[indexPath.item]
                yogaSelectedAtIndex(index: indexPath.item, yoga: yoga)
            }
            else if istype == IsSectionType.meditation
            {
                let meditation = filteredDataArraymeditation[indexPath.item]
                meditationSelectedAtIndex(index: indexPath.item, meditation: meditation)
            }
            else if istype == IsSectionType.pranayama
            {
                let pranayama = filteredDataArraypranayama[indexPath.item]
                pranayamaSelectedAtIndex(index: indexPath.item, pranayama: pranayama)
            }
            else if istype == IsSectionType.mudra
            {
               let mudra = filteredDataArraymudra[indexPath.item]
               mudraSelectedAtIndex(index: indexPath.item, mudra: mudra)
            }
            else
            {
                let kriya = filteredDataArraykriya[indexPath.item]
                kriyaSelectedAtIndex(index: indexPath.item, kriya: kriya)
            }
        } else {
                if istype == IsSectionType.yoga
                {
                    let yoga = filteredDataArray[indexPath.item]
                    yogaSelectedAtIndex(index: indexPath.item, yoga: yoga)
                }
                else if istype == IsSectionType.meditation
                {
                    let meditation = filteredDataArraymeditation[indexPath.item]
                    meditationSelectedAtIndex(index: indexPath.item, meditation: meditation)
                }
                else if istype == IsSectionType.pranayama
                {
                    let pranayama = filteredDataArraypranayama[indexPath.item]
                    pranayamaSelectedAtIndex(index: indexPath.item, pranayama: pranayama)
                }
                else if istype == IsSectionType.mudra
                {
                   let mudra = filteredDataArraymudra[indexPath.item]
                   mudraSelectedAtIndex(index: indexPath.item, mudra: mudra)
                }
                else
                {
                    let kriya = filteredDataArraykriya[indexPath.item]
                    kriyaSelectedAtIndex(index: indexPath.item, kriya: kriya)
                }
            
        }
    }
    
    func yogaSelectedAtIndex(index: Int, yoga: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.yoga = yoga
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .yoga
        self.present(objYoga, animated: true, completion: nil)
    }
    
    func meditationSelectedAtIndex(index: Int, meditation: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.meditation = meditation
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .meditation
        self.present(objYoga, animated: true, completion: nil)
    }

    func pranayamaSelectedAtIndex(index: Int, pranayama: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.pranayama = pranayama
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .pranayama
        self.present(objYoga, animated: true, completion: nil)
    }
    
    func mudraSelectedAtIndex(index: Int, mudra: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.mudra = mudra
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .mudra
        self.present(objYoga, animated: true, completion: nil)
    }

    func kriyaSelectedAtIndex(index: Int, kriya: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.kriya = kriya
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .kriya
        self.present(objYoga, animated: true, completion: nil)
    }


    //MARK: Actions
       @objc func rightButtonAction(sender: UIBarButtonItem) {
           let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
           guard let objFilterView = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController else {
               return
           }
           objFilterView.modalPresentationStyle = .fullScreen
           self.navigationController?.pushViewController(objFilterView, animated: true)
           //present(objFilterView, animated: true, completion: nil)
       }
}

extension YogaPlayListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        if istype == IsSectionType.yoga {
            filteredDataArray.removeAll()
            filteredDataArray = yogaArray
        }
        else if istype == IsSectionType.meditation
        {
            filteredDataArraymeditation.removeAll()
            filteredDataArraymeditation = meditationArray
        }
        else if istype == IsSectionType.pranayama
        {
            filteredDataArraypranayama.removeAll()
            filteredDataArraypranayama = pranayamaArray
        }
        else if istype == IsSectionType.mudra
        {
            filteredDataArraymudra.removeAll()
            filteredDataArraymudra = mudraArray
        }
        else
        {
            filteredDataArraykriya.removeAll()
            filteredDataArraykriya = kriyaArray
        }

        self.collectionview.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            isSearching = false
            if istype == IsSectionType.yoga
            {
                filteredDataArray.removeAll()
                filteredDataArray = yogaArray
            }
            else if istype == IsSectionType.meditation
            {
                filteredDataArraymeditation.removeAll()
                filteredDataArraymeditation = meditationArray
            }
            else if istype == IsSectionType.pranayama
            {
                filteredDataArraypranayama.removeAll()
                filteredDataArraypranayama = pranayamaArray
            }
            else if istype == IsSectionType.mudra
            {
                filteredDataArraymudra.removeAll()
                filteredDataArraymudra = mudraArray
            }
            else
            {
                filteredDataArraykriya.removeAll()
                filteredDataArraykriya = kriyaArray
            }
            
        } else {
            isSearching = true
            
            if istype == IsSectionType.yoga
            {
                filteredDataArray = yogaArray.filter { (data: Yoga) -> Bool in
                    if data.english_name?.uppercased().contains(searchText.uppercased()) ?? false || data.name?.uppercased().contains(searchText.uppercased()) ?? false {
                        return true
                    } else {
                        return false
                    }
                }
            }
            else if istype == IsSectionType.meditation
            {
                filteredDataArraymeditation = meditationArray.filter { (data: Meditation) -> Bool in
                    if data.english_name?.uppercased().contains(searchText.uppercased()) ?? false || data.name?.uppercased().contains(searchText.uppercased()) ?? false {
                        return true
                    } else {
                        return false
                    }
                }
            }
            else if istype == IsSectionType.pranayama
            {
                filteredDataArraypranayama = pranayamaArray.filter { (data: Pranayama) -> Bool in
                    if data.english_name?.uppercased().contains(searchText.uppercased()) ?? false || data.name?.uppercased().contains(searchText.uppercased()) ?? false {
                        return true
                    } else {
                        return false
                    }
                }
            }
            else if istype == IsSectionType.mudra
            {
                filteredDataArraymudra = mudraArray.filter { (data: Mudra) -> Bool in
                    if data.english_name?.uppercased().contains(searchText.uppercased()) ?? false || data.name?.uppercased().contains(searchText.uppercased()) ?? false {
                        return true
                    } else {
                        return false
                    }
                }
            }
            else
            {
                filteredDataArraykriya = kriyaArray.filter { (data: Kriya) -> Bool in
                    if data.english_name?.uppercased().contains(searchText.uppercased()) ?? false || data.name?.uppercased().contains(searchText.uppercased()) ?? false {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        self.collectionview.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        isSearching = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        if istype == IsSectionType.yoga
        {
            filteredDataArray.removeAll()
            filteredDataArray = yogaArray
        }
        else if istype == IsSectionType.meditation
        {
            filteredDataArraymeditation.removeAll()
            filteredDataArraymeditation = meditationArray
        }
        else if istype == IsSectionType.pranayama
        {
            filteredDataArraypranayama.removeAll()
            filteredDataArraypranayama = pranayamaArray
        }
        else if istype == IsSectionType.mudra
        {
            filteredDataArraymudra.removeAll()
            filteredDataArraymudra = mudraArray
        }
        else
        {
            filteredDataArraykriya.removeAll()
            filteredDataArraykriya = kriyaArray
        }

        collectionview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension YogaPlayListViewController: RecommendationSeeAllDelegate {
    
    func didSelectedSelectRow(indexPath: IndexPath, index: Int?) {
        
    }
    
    func didSelectedSelectRowForRedeem(indexPath: IndexPath, index: Int?) {

        self.selectedIndex = indexPath
        if self.istype == IsSectionType.yoga
        {
            let yoga = self.filteredDataArray[indexPath.row]
            accessPoint = Int(yoga.access_point)
            name = "yoga"
            favID = Int(yoga.id)
        }
        else if self.istype == IsSectionType.meditation
        {
            let meditation = self.filteredDataArraymeditation[indexPath.row]
            accessPoint = Int(meditation.access_point)
            name = "meditation"
            favID = Int(meditation.id)
        }
        else if self.istype == IsSectionType.pranayama
        {
            let pranayama = self.filteredDataArraypranayama[indexPath.row]
            accessPoint = Int(pranayama.access_point)
            name = "pranayama"
            favID = Int(pranayama.id)
        }
        else if self.istype == IsSectionType.mudra
        {
            let mudra = self.filteredDataArraymudra[indexPath.row]
            accessPoint = Int(mudra.access_point)
            name = "mudra"
            favID = 0
        }
        else if self.istype == IsSectionType.kriya
        {
            let kriya = self.filteredDataArraykriya[indexPath.row]
            accessPoint = Int(kriya.access_point)
            name = "kriya"
            favID = 0
        }
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            
            if self.istype == IsSectionType.yoga {
                let yoga = self.filteredDataArray[self.selectedIndex.row]
                yoga.redeemed = true
                self.filteredDataArray[self.selectedIndex.item] = yoga
            } else if self.istype == IsSectionType.meditation {
                let meditation = self.filteredDataArraymeditation[self.selectedIndex.row]
                meditation.redeemed = true
                self.filteredDataArraymeditation[self.selectedIndex.item] = meditation
            } else if self.istype == IsSectionType.pranayama {
                let pranayama = self.filteredDataArraypranayama[self.selectedIndex.row]
                pranayama.redeemed = true
                self.filteredDataArraypranayama[self.selectedIndex.item] = pranayama
            } else if self.istype == IsSectionType.mudra {
                self.filteredDataArraymudra.forEach{ $0.redeemed = true }
            } else if self.istype == IsSectionType.kriya {
                self.filteredDataArraykriya.forEach{ $0.redeemed = true }
            }
            self.collectionview.reloadData()
        }
    }
}
