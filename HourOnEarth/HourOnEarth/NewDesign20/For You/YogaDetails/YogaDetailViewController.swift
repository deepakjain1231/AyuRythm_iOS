//
//  YogaDetailViewController.swift
//  HourOnEarth
//
//  Created by Apple on 19/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
//import IGVimeoExtractor
import AVKit
import CoreData


protocol delegateCheckMarkRefresh {
    func screenRefresh(_ is_success: Bool)
}


enum IsSectionType {
    case yoga
    case pranayama
    case meditation
    case mudra
    case kriya
    case food
    case herbs

    var title: String {
        switch self {
        case .yoga:
            return "Yogasana".localized()
        case .pranayama:
            return "Pranayama".localized()
        case .meditation:
            return "Meditation".localized()
        case .mudra:
            return "Mudra".localized()
        case .kriya:
            return "Kriya".localized()
        case .food:
            return "Food".localized()
        case .herbs:
            return "Herbs".localized()
        }
    }
    
    var dailyTaskType: String {
        switch self {
        case .yoga:
            return "yogasana"
        case .pranayama:
            return "pranayama"
        case .meditation:
            return "meditation"
        case .mudra:
            return "mudra"
        case .kriya:
            return "kriya"
        case .food:
            return "food"
        case .herbs:
            return "herbs"
        }
    }
}
enum YogaDetailCellType {
    case yogaHeader(yoga: Yoga, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case yogaHeaderFav(yoga: FavouriteYoga, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case yogaSubHeader(title: String, subTitle: String)
}
enum PranayamaDetailCellType {
    case pranayamaHeader(pranayama: Pranayama, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case pranayamaHeaderFav(pranayama: FavouritePranayama, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case pranayamaSubHeader(title: String, subTitle: String)
}
enum MeditationDetailCellType {
    case meditationHeader(meditation: Meditation, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case meditationHeaderFav(meditation: FavouriteMeditation, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case meditationSubHeader(title: String, subTitle: String)
}
enum MudraDetailCellType {
    case mudraHeader(mudra: Mudra, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case mudraHeaderFav(mudra: FavouriteMudra, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case mudraSubHeader(title: String, subTitle: String)
}
enum KriyaDetailCellType {
    case kriyaHeader(kriya: Kriya, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case kriyaHeaderFav(kriya: FavouriteKriya, recPrakriti: RecommendationType, recVikriti: RecommendationType)
    case kriyaSubHeader(title: String, subTitle: String)
}

class YogaDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, YogaExpandCollapseDelagate {
        
    @IBOutlet weak var tblYogaDetail: UITableView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var topConstratint: NSLayoutConstraint!

    var dataArray: [YogaDetailCellType] = [YogaDetailCellType]()
    var dataArrayPranayama: [PranayamaDetailCellType] = [PranayamaDetailCellType]()
    var dataArrayMeditation: [MeditationDetailCellType] = [MeditationDetailCellType]()
    var dataArrayMudra: [MudraDetailCellType] = [MudraDetailCellType]()
    var dataArrayKriya: [KriyaDetailCellType] = [KriyaDetailCellType]()
    var isReadMoreOpen = false
    var yoga: NSManagedObject?
    var pranayama: NSManagedObject?
    var meditation: NSManagedObject?
    var mudra: NSManagedObject?
    var kriya: NSManagedObject?
    var isFavourite = false
    var selectedIndex = -1
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var isFromForYou = true
    var yogaPlaylist: [Yoga] = [Yoga]()
    var meditationPlaylist: [Meditation] = [Meditation]()
    var pranayamaPlaylist: [Pranayama] = [Pranayama]()
    var mudraPlaylist: [Mudra] = [Mudra]()
    var kriyaPlaylist: [Kriya] = [Kriya]()
    var istype : IsSectionType = .yoga
    var objectFavoriteId = ""
    var str_id = ""
    var screenFrom = ScreenType.k_none
    var delegate: delegateCheckMarkRefresh?
    var is_needDetails_ApiCall = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblYogaDetail.tableFooterView = UIView()
        self.tblYogaDetail.estimatedRowHeight = 50.0
        tblYogaDetail.register(UINib(nibName: "YogaDetailHeaderCell", bundle: nil), forCellReuseIdentifier: "YogaDetailHeaderCell")
        tblYogaDetail.register(UINib(nibName: "YogaSubDetailsCell", bundle: nil), forCellReuseIdentifier: "YogaSubDetailsCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name:
            NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
//        if isFromForYou {
            self.strupFor_callAPIDetailsData()
//        } else {
//            
//            if istype == IsSectionType.yoga {
//                
//                guard let objYoga = self.yoga as? FavouriteYoga else {
//                    return
//                }
//                objectFavoriteId = String(objYoga.id)
//                dataArray.append(.yogaHeaderFav(yoga: objYoga, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
//                
//                if let data = objYoga.precautions, !data.isEmpty {
//                    dataArray.append(.yogaSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objYoga.benefit_description, !data.isEmpty {
//                    dataArray.append(.yogaSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                let steps = /*"- " + */(objYoga.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
//                dataArray.append(.yogaSubHeader(title: "Steps".localized(), subTitle: steps))
//                if let star = objYoga.star {
//                    self.isFavourite = !(star == "no")
//                }
//                
//                if let star = objYoga.star {
//                    self.isFavourite = !(star == "no")
//                }
//                guard let urlString = objYoga.verticleimage, let url = URL(string: urlString) else {
//                    return
//                }
//                imgView.af.setImage(withURL: url)
//
//            } else if istype == IsSectionType.meditation {
//                
//                guard let objmeditation = self.meditation as? FavouriteMeditation else {
//                    return
//                }
//                objectFavoriteId = String(objmeditation.id)
//                dataArrayMeditation.append(.meditationHeaderFav(meditation: objmeditation, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
//                
//                if let data = objmeditation.precautions, !data.isEmpty {
//                    dataArrayMeditation.append(.meditationSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objmeditation.preparation, !data.isEmpty {
//                    dataArrayMeditation.append(.meditationSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objmeditation.benefit_description, !data.isEmpty {
//                    dataArrayMeditation.append(.meditationSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                let steps = /*"- " + */(objmeditation.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
//                dataArrayMeditation.append(.meditationSubHeader(title: "Steps".localized(), subTitle: steps))
//                if let star = objmeditation.star {
//                    self.isFavourite = !(star == "no")
//                }
//                guard let urlString = objmeditation.verticleimage, let url = URL(string: urlString) else {
//                    return
//                }
//                imgView.af.setImage(withURL: url)
//
//            } else if istype == IsSectionType.pranayama {
//                
//                guard let objpranayama = self.pranayama as? FavouritePranayama else {
//                    return
//                }
//                objectFavoriteId = String(objpranayama.id)
//                dataArrayPranayama.append(.pranayamaHeaderFav(pranayama: objpranayama, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
//                
//                if let data = objpranayama.precautions, !data.isEmpty {
//                    dataArrayPranayama.append(.pranayamaSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objpranayama.preparation, !data.isEmpty {
//                    dataArrayPranayama.append(.pranayamaSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objpranayama.benefit_description, !data.isEmpty {
//                    dataArrayPranayama.append(.pranayamaSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                let steps = /*"- " + */(objpranayama.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
//                dataArrayPranayama.append(.pranayamaSubHeader(title: "Steps".localized(), subTitle: steps))
//                if let star = objpranayama.star {
//                    self.isFavourite = !(star == "no")
//                }
//                guard let urlString = objpranayama.verticleimage, let url = URL(string: urlString) else {
//                    return
//                }
//                imgView.af.setImage(withURL: url)
//
//            } else if istype == IsSectionType.mudra {
//                
//                guard let objmudra = self.mudra as? FavouriteMudra else {
//                    return
//                }
//                objectFavoriteId = String(objmudra.id)
//                dataArrayMudra.append(.mudraHeaderFav(mudra: objmudra, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
//                
//                if let data = objmudra.precautions, !data.isEmpty {
//                    dataArrayMudra.append(.mudraSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objmudra.preparation, !data.isEmpty {
//                    dataArrayMudra.append(.mudraSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objmudra.benefit_description, !data.isEmpty {
//                    dataArrayMudra.append(.mudraSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                let steps = /*"- " + */(objmudra.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
//                dataArrayMudra.append(.mudraSubHeader(title: "Steps".localized(), subTitle: steps))
//                if let star = objmudra.star {
//                    self.isFavourite = !(star == "no")
//                }
//                guard let urlString = objmudra.verticleimage, let url = URL(string: urlString) else {
//                    return
//                }
//                imgView.af.setImage(withURL: url)
//
//            } else if istype == IsSectionType.kriya {
//                
//                guard let objkriya = self.kriya as? FavouriteKriya else {
//                    return
//                }
//                objectFavoriteId = String(objkriya.id)
//                dataArrayKriya.append(.kriyaHeaderFav(kriya: objkriya, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
//                
//                if let data = objkriya.precautions, !data.isEmpty {
//                    dataArrayKriya.append(.kriyaSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objkriya.preparation, !data.isEmpty {
//                    dataArrayKriya.append(.kriyaSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                if let data = objkriya.benefit_description, !data.isEmpty {
//                    dataArrayKriya.append(.kriyaSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
//                }
//                
//                let steps = /*"- " + */(objkriya.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
//                dataArrayKriya.append(.kriyaSubHeader(title: "Steps".localized(), subTitle: steps))
//                if let star = objkriya.star {
//                    self.isFavourite = !(star == "no")
//                }
//                guard let urlString = objkriya.verticleimage, let url = URL(string: urlString) else {
//                    return
//                }
//                imgView.af.setImage(withURL: url)
//
//            }
//        }
        
        tblYogaDetail.reloadData()
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            self.topConstratint.constant = -(topPadding ?? 0)
        }
    }
    
    func strupFor_callAPIDetailsData() {
        if istype == IsSectionType.yoga {
            
            guard let objYoga = self.yoga as? Yoga else {
                return
            }
            self.str_id = objYoga.content_id ?? ""
            self.objectFavoriteId = objYoga.favorite_id ?? ""
        } 
        else if istype == IsSectionType.meditation {
            
            guard let objmeditation = self.meditation as? Meditation else {
                return
            }
            self.str_id = objmeditation.content_id ?? ""
            self.objectFavoriteId = objmeditation.favorite_id ?? ""
        }
        else if istype == IsSectionType.pranayama {
            
            guard let objpranayama = self.pranayama as? Pranayama else {
                return
            }
            self.str_id = objpranayama.content_id ?? ""
            self.objectFavoriteId = objpranayama.favorite_id ?? ""
        }
        else if istype == IsSectionType.mudra {
            
            guard let objmudra = self.mudra as? Mudra else {
                return
            }
            self.str_id = objmudra.content_id ?? ""
            self.objectFavoriteId = objmudra.favorite_id ?? ""
        }
        else {
            
            guard let objkriya = self.kriya as? Kriya else {
                return
            }
            self.str_id = objkriya.content_id ?? ""
            self.objectFavoriteId = objkriya.favorite_id ?? ""
        }
        
        self.callAPIforDetails()
    }
    
    func setupDetailData() {
        if istype == IsSectionType.yoga {
            
            guard let objYoga = self.yoga as? Yoga else {
                return
            }
            objectFavoriteId = objYoga.favorite_id ?? ""
            dataArray.append(.yogaHeader(yoga: objYoga, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            if let data = objYoga.precautions, !data.isEmpty {
                dataArray.append(.yogaSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objYoga.benefit_description, !data.isEmpty {
                dataArray.append(.yogaSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            let steps = /*"- " + */(objYoga.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
            dataArray.append(.yogaSubHeader(title: "Steps".localized(), subTitle: steps))
            if let star = objYoga.star {
                self.isFavourite = !(star == "no")
            }
            guard let urlString = objYoga.verticleimage, let url = URL(string: urlString) else {
                return
            }
            imgView.af.setImage(withURL: url)
            
        } else if istype == IsSectionType.meditation {
            
            guard let objmeditation = self.meditation as? Meditation else {
                return
            }
            objectFavoriteId = objmeditation.favorite_id ?? ""
            dataArrayMeditation.append(.meditationHeader(meditation: objmeditation, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
            if let data = objmeditation.precautions, !data.isEmpty {
                dataArrayMeditation.append(.meditationSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objmeditation.preparation, !data.isEmpty {
                dataArrayMeditation.append(.meditationSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objmeditation.benefit_description, !data.isEmpty {
                dataArrayMeditation.append(.meditationSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            let steps = /*"- " + */(objmeditation.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
            dataArrayMeditation.append(.meditationSubHeader(title: "Steps".localized(), subTitle: steps))
            
            if let star = objmeditation.star {
                self.isFavourite = !(star == "no")
            }
            guard let urlString = objmeditation.verticleimage, let url = URL(string: urlString) else {
                return
            }
            imgView.af.setImage(withURL: url)
            
        } else if istype == IsSectionType.pranayama {
            
            guard let objpranayama = self.pranayama as? Pranayama else {
                return
            }
            objectFavoriteId = objpranayama.favorite_id ?? ""
            dataArrayPranayama.append(.pranayamaHeader(pranayama: objpranayama, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
            if let data = objpranayama.precautions, !data.isEmpty {
                dataArrayPranayama.append(.pranayamaSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objpranayama.preparation, !data.isEmpty {
                dataArrayPranayama.append(.pranayamaSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objpranayama.benefit_description, !data.isEmpty {
                dataArrayPranayama.append(.pranayamaSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            let steps = /*"- " + */(objpranayama.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
            dataArrayPranayama.append(.pranayamaSubHeader(title: "Steps".localized(), subTitle: steps))
            if let star = objpranayama.star {
                self.isFavourite = !(star == "no")
            }
            guard let urlString = objpranayama.verticleimage, let url = URL(string: urlString) else {
                return
            }
            imgView.af.setImage(withURL: url)
            
        } else if istype == IsSectionType.mudra {
            
            guard let objmudra = self.mudra as? Mudra else {
                return
            }
            objectFavoriteId = objmudra.favorite_id ?? ""
            dataArrayMudra.append(.mudraHeader(mudra: objmudra, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
            if let data = objmudra.precautions, !data.isEmpty {
                dataArrayMudra.append(.mudraSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objmudra.preparation, !data.isEmpty {
                dataArrayMudra.append(.mudraSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objmudra.benefit_description, !data.isEmpty {
                dataArrayMudra.append(.mudraSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            let steps = /*"- " + */(objmudra.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
            dataArrayMudra.append(.mudraSubHeader(title: "Steps".localized(), subTitle: steps))
            if let star = objmudra.star {
                self.isFavourite = !(star == "no")
            }
            guard let urlString = objmudra.verticleimage, let url = URL(string: urlString) else {
                return
            }
            imgView.af.setImage(withURL: url)
            
        } else {
            
            guard let objkriya = self.kriya as? Kriya else {
                return
            }
            objectFavoriteId = objkriya.favorite_id ?? ""
            dataArrayKriya.append(.kriyaHeader(kriya: objkriya, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
            if let data = objkriya.precautions, !data.isEmpty {
                dataArrayKriya.append(.kriyaSubHeader(title: "Precautions".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objkriya.preparation, !data.isEmpty {
                dataArrayKriya.append(.kriyaSubHeader(title: "Preparation".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            if let data = objkriya.benefit_description, !data.isEmpty {
                dataArrayKriya.append(.kriyaSubHeader(title: "Benefits".localized(), subTitle: data.newlineSeperatedValues()))
            }
            
            let steps = /*"- " + */(objkriya.steps?.replacingOccurrences(of: "\\n", with: "\n") ?? "")
            dataArrayKriya.append(.kriyaSubHeader(title: "Steps".localized(), subTitle: steps))
            if let star = objkriya.star {
                self.isFavourite = !(star == "no")
            }
            guard let urlString = objkriya.verticleimage, let url = URL(string: urlString) else {
                return
            }
            imgView.af.setImage(withURL: url)
        }
        
        self.tblYogaDetail.reloadData()
    }
    
    func callAPIforDetails() {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getYogaPranayamDetail_iOS_NewAPI.rawValue
            
            var params = ["id": self.str_id,
                          "favorite_id": objectFavoriteId,//Video fav ID from Todaysgoal api
                          "list_type": "",
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            
            if istype == IsSectionType.yoga {
                params["list_type"] = "yogasana"
            }
            else if istype == .pranayama {
                params["list_type"] = "pranayam"
            }
            else if istype == .meditation {
                params["list_type"] = "meditation"
            }
            else if istype == .kriya {
                params["list_type"] = "kriya"
            }
            else if istype == .mudra {
                params["list_type"] = "mudra"
            }
            
            debugPrint("API URL=====>>\(urlString)\n\nParams:----->>\(params)")
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dic_Response = (value as? [String: Any]) else {
                        return
                    }
                    if self.istype == .yoga {
                        self.yoga = Yoga.createYogaData(dicYoga: dic_Response)
                    }
                    else if self.istype == .pranayama {
                        self.pranayama = Pranayama.createPranayamaData(dicData: dic_Response)
                    }
                    else if self.istype == .meditation {
                        self.meditation = Meditation.createMeditationData(dicData: dic_Response)
                    }
                    else if self.istype == .kriya {
                        self.kriya = Kriya.createKriyaData(dicData: dic_Response)
                    }
                    else if self.istype == .mudra {
                        self.mudra = Mudra.createMudraData(dicData: dic_Response)
                    }
                    self.setupDetailData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if istype == IsSectionType.yoga
        {
            return self.dataArray.count
        }
        else if istype == IsSectionType.meditation
        {
            return self.dataArrayMeditation.count
        }
        else if istype == IsSectionType.pranayama
        {
            return self.dataArrayPranayama.count
        }
        else if istype == IsSectionType.mudra
        {
            return self.dataArrayMudra.count
        }
        else
        {
            return self.dataArrayKriya.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if istype == IsSectionType.yoga
        {
            let rowType = self.dataArray[indexPath.row]
            switch rowType {
                
            case .yogaHeader(let yoga, let recPrakriti, let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUI(yoga: yoga, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
                
            case .yogaSubHeader(let title, let subTitle):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaSubDetailsCell") as? YogaSubDetailsCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.indexPath = indexPath
                cell.configure(title: title, subTitle: subTitle, isSelected: self.selectedIndex == indexPath.row)
                cell.selectionStyle = .none
                return cell
                
            case .yogaHeaderFav(yoga: let yoga, recPrakriti: let recPrakriti, recVikriti: let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUI(yoga: yoga, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            }
        }
        else if istype == IsSectionType.meditation
        {
            let rowType = self.dataArrayMeditation[indexPath.row]
            switch rowType {
                
            case .meditationHeader(let meditation, let recPrakriti, let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIMeditation(meditation: meditation, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
                
            case .meditationSubHeader(let title, let subTitle):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaSubDetailsCell") as? YogaSubDetailsCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.indexPath = indexPath
                cell.configure(title: title, subTitle: subTitle, isSelected: self.selectedIndex == indexPath.row)
                cell.selectionStyle = .none
                return cell
                
            case .meditationHeaderFav(meditation: let meditation, recPrakriti: let recPrakriti, recVikriti: let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIMeditation(meditation: meditation, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            }
        }
        else if istype == IsSectionType.pranayama
        {
            let rowType = self.dataArrayPranayama[indexPath.row]
            switch rowType {
                
            case .pranayamaHeader(let pranayama, let recPrakriti, let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIPranayama(pranayama: pranayama, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            case .pranayamaSubHeader(let title, let subTitle):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaSubDetailsCell") as? YogaSubDetailsCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.indexPath = indexPath
                cell.configure(title: title, subTitle: subTitle, isSelected: self.selectedIndex == indexPath.row)
                cell.selectionStyle = .none
                return cell
                
            case .pranayamaHeaderFav(pranayama: let pranayama, recPrakriti: let recPrakriti, recVikriti: let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIPranayama(pranayama: pranayama, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            }
        }
        else if istype == IsSectionType.mudra
        {
            let rowType = self.dataArrayMudra[indexPath.row]
            switch rowType {
                
            case .mudraHeader(let mudra, let recPrakriti, let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIMudra(mudra: mudra, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            case .mudraSubHeader(let title, let subTitle):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaSubDetailsCell") as? YogaSubDetailsCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.indexPath = indexPath
                cell.configure(title: title, subTitle: subTitle, isSelected: self.selectedIndex == indexPath.row)
                cell.selectionStyle = .none
                return cell
                
            case .mudraHeaderFav(mudra: let mudra, recPrakriti: let recPrakriti, recVikriti: let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIMudra(mudra: mudra, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            }
        }
        else
        {
            let rowType = self.dataArrayKriya[indexPath.row]
            switch rowType {
                
            case .kriyaHeader(let kriya, let recPrakriti, let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIKriya(kriya: kriya, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            case .kriyaSubHeader(let title, let subTitle):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaSubDetailsCell") as? YogaSubDetailsCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.indexPath = indexPath
                cell.configure(title: title, subTitle: subTitle, isSelected: self.selectedIndex == indexPath.row)
                cell.selectionStyle = .none
                return cell
                
            case .kriyaHeaderFav(kriya: let kriya, recPrakriti: let recPrakriti, recVikriti: let recVikriti):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "YogaDetailHeaderCell") as? YogaDetailHeaderCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.configureUIKriya(kriya: kriya, isFavourite: self.isFavourite, isMoreOpen: isReadMoreOpen, recPrakriti: recPrakriti, recVikriti: recVikriti)
                cell.selectionStyle = .none
                return cell
            }

        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if istype == IsSectionType.yoga
        {
            let rowType = self.dataArray[indexPath.row]
            switch rowType {
                
            case .yogaHeader(_, _, _):
                return
                
            case .yogaSubHeader(_, _):
                expandCollapseClicked(indexPath: indexPath)
                
            case .yogaHeaderFav(_, _, _):
                return
                
            }
            
        }
        else if istype == IsSectionType.meditation
        {
            let rowType = self.dataArrayMeditation[indexPath.row]
            switch rowType {
                
            case .meditationHeader(_, _, _):
                return
                
            case .meditationSubHeader(_, _):
                expandCollapseClicked(indexPath: indexPath)
                
            case .meditationHeaderFav(_, _, _):
                return
                
            }
        }
        else if istype == IsSectionType.pranayama
        {
            let rowType = self.dataArrayPranayama[indexPath.row]
            switch rowType {
                
            case .pranayamaHeader(_, _, _):
                return
                
            case .pranayamaSubHeader(_, _):
                expandCollapseClicked(indexPath: indexPath)
                
            case .pranayamaHeaderFav(_, _, _):
                return
                
            }
        }
        else if istype == IsSectionType.mudra
        {
            let rowType = self.dataArrayMudra[indexPath.row]
            switch rowType {
                
            case .mudraHeader(_, _, _):
                return
                
            case .mudraSubHeader(_, _):
                expandCollapseClicked(indexPath: indexPath)
                
            case .mudraHeaderFav(_, _, _):
                return
                
            }
        }
        else
        {
            let rowType = self.dataArrayKriya[indexPath.row]
            switch rowType {
                
            case .kriyaHeader(_, _, _):
                return
                
            case .kriyaSubHeader(_, _):
                expandCollapseClicked(indexPath: indexPath)
                
            case .kriyaHeaderFav(_, _, _):
                return
                
            }
        }
    }
    
    @IBAction func dismissClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func expandCollapseClicked(indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            if selectedIndex == -1 {
                selectedIndex = indexPath.row
            } else {
                selectedIndex = -1
            }
        } else {
            selectedIndex = indexPath.row
        }
        self.tblYogaDetail.reloadData()
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
//        self.showNextVideo()
        Utils.completeDailyTask(favorite_id: objectFavoriteId, taskType: istype.dailyTaskType) { is_success, str_status, str_msg in
            if self.screenFrom == .from_herbListVC {
            #if !APPCLIP
                appDelegate.apiCallingAsperDataChage = true
            #endif
                self.delegate?.screenRefresh(true)
            }
        }
        
        //Utils.completeDailyTask(favorite_id: objectFavoriteId, taskType: istype.dailyTaskType)
    }
}

extension YogaDetailViewController: YogaDetailHeaderDelegate {
    func readMoreClicked() {
        isReadMoreOpen = !isReadMoreOpen
        self.tblYogaDetail.reloadData()
    }
    
    func playVideoClicked() {
        if isFromForYou {
            if istype == IsSectionType.yoga
            {
                guard let objYoga = self.yoga as? Yoga else {
                    return
                }
                loadVideo(url: objYoga.video_link ?? "")
                
            }
            else if istype == IsSectionType.meditation
            {
                guard let objMeditation = self.meditation as? Meditation else {
                    return
                }
                loadVideo(url: objMeditation.video_link ?? "")
                
            }
            else if istype == IsSectionType.pranayama
            {
                guard let objPranayama = self.pranayama as? Pranayama else {
                    return
                }
                loadVideo(url: objPranayama.video_link ?? "")
                
            }
            else if istype == IsSectionType.mudra
            {
                guard let objMudra = self.mudra as? Mudra else {
                    return
                }
                loadVideo(url: objMudra.video_link ?? "")
                
            }
            else
            {
                guard let objKriya = self.kriya as? Kriya else {
                    return
                }
                loadVideo(url: objKriya.video_link ?? "")
                
            }
        } else {
            if istype == IsSectionType.yoga
            {
                guard let objYoga = self.yoga as? FavouriteYoga else {
                    return
                }
                loadVideo(url: objYoga.video_link ?? "")
                
            }
            else if istype == IsSectionType.meditation
            {
                guard let objMeditation = self.meditation as? FavouriteMeditation else {
                    return
                }
                loadVideo(url: objMeditation.video_link ?? "")
                
            }
            else if istype == IsSectionType.pranayama
            {
                guard let objPranayama = self.pranayama as? FavouritePranayama else {
                    return
                }
                loadVideo(url: objPranayama.video_link ?? "")
                
            }
            else if istype == IsSectionType.mudra
            {
                guard let objMudra = self.mudra as? FavouriteMudra else {
                    return
                }
                loadVideo(url: objMudra.video_link ?? "")
                
            }
            else
            {
                guard let objKriya = self.kriya as? FavouriteKriya else {
                    return
                }
                loadVideo(url: objKriya.video_link ?? "")
                
            }
        }
    }
    
    func loadVideo(url: String) {
#if !APPCLIP
        // Code you don't want to use in your app clip.
        kSharedAppDelegate.callAPIforVimeoExtracter(vimeo_url: url, current_view: self, completion: { is_success, str_videoURL in
            if is_success {
                guard let videoURL = URL(string: str_videoURL) else {
                    return
                }
                DispatchQueue.main.async {
                    let player = AVPlayer(url: videoURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        player.play()
                    }
                }
            }
        })
#else
        // Code your app clip may access.
#endif
    }
//        //API Call
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let arr_url = url.components(separatedBy: "/")
//            let urlString = BaseURL_Vimeo + (arr_url.last ?? "")
//
//            AF.request(urlString, method: .get, parameters: nil, encoding:URLEncoding.default, headers: ["Authorization": Kvimeo_access_Token]).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\n\nResponse: - \(response)")
//                    guard let dicResponse = (value as? [String: Any]) else {
//                        return
//                    }
//                    
//                    guard let arr_video_file = dicResponse["files"] as? [[String: Any]] else {
//                        return
//                    }
//                    
//                    if arr_video_file.count != 0 {
//                        var str_video_url = ""
//                        let arr_filter_video_file = arr_video_file.filter({ dic_vimeo in
//                            return (dic_vimeo["rendition"] as? String ?? "") == "540p"
//                        })
//                        
//                        if arr_filter_video_file.count != 0 {
//                            str_video_url = arr_filter_video_file.first?["link"] as? String ?? ""
//                        }
//                        else {
//                            str_video_url = arr_video_file.first?["link"] as? String ?? ""
//                        }
//                        
//                        guard let videoURL = URL(string: str_video_url) else {
//                            return
//                        }
//                        DispatchQueue.main.async {
//                            let player = AVPlayer(url: videoURL)
//                            let playerViewController = AVPlayerViewController()
//                            playerViewController.player = player
//                            self.present(playerViewController, animated: true) {
//                                player.play()
//                            }
//                        }
//                    }
//                    else {
//                        Utils.showAlertWithTitleInController(APP_NAME, message: "Something went wrong, please try again later", controller: self)
//                    }
//                    
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//            }
//        }
//        else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
    
    // Added by Aakash
    func shareClickedwith(hindiName: String, enName: String, desc: String) {
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        let text = hindiName + "\n\n" + enName + "\n\n" + desc.truncated() + "\n\n" + Utils.shareRegisterDownloadString
        let shareAll = [ text ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        #else
        // Code your app clip may access.
        let text = hindiName + "\n\n" + enName + "\n\n" + desc.truncated()
        showAppClipsShareActivityViewController(text: text)
        #endif
        
    }

    func starClicked() {
        var yogaId = 0
        var pranayamaId = 0
        var meditationId = 0
        var mudraId = 0
        var kriyaId = 0
        
        if isFromForYou {
            if istype == IsSectionType.yoga
            {
                guard let objYoga = self.yoga as? Yoga else {
                    return
                }
                yogaId = Int(objYoga.id)
            }
            else if istype == IsSectionType.meditation
            {
                guard let objMeditation = self.meditation as? Meditation else {
                    return
                }
                meditationId = Int(objMeditation.id)
            }
            else if istype == IsSectionType.pranayama
            {
                guard let objPranayama = self.pranayama as? Pranayama else {
                    return
                }
                pranayamaId = Int(objPranayama.id)
            }
            else if istype == IsSectionType.mudra
            {
                guard let objMudra = self.mudra as? Mudra else {
                    return
                }
                mudraId = Int(objMudra.id)
            }
            else
            {
                guard let objKriya = self.kriya as? Kriya else {
                    return
                }
                kriyaId = Int(objKriya.id)
            }
        } else {
            if istype == IsSectionType.yoga
            {
                guard let objYoga = self.yoga as? FavouriteYoga else {
                    return
                }
                yogaId = Int(objYoga.id)
            }
            else if istype == IsSectionType.meditation
            {
                guard let objMeditation = self.meditation as? FavouriteMeditation else {
                    return
                }
                meditationId = Int(objMeditation.id)
            }
            else if istype == IsSectionType.pranayama
            {
                guard let objPranayama = self.pranayama as? FavouritePranayama else {
                    return
                }
                pranayamaId = Int(objPranayama.id)
            }
            else if istype == IsSectionType.mudra
            {
                guard let objMudra = self.mudra as? FavouriteMudra else {
                    return
                }
                mudraId = Int(objMudra.id)
            }
            else
            {
                guard let objKriya = self.kriya as? FavouriteKriya else {
                    return
                }
                kriyaId = Int(objKriya.id)
            }
        }
        
        if isFavourite {
            //Remove
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            if istype == IsSectionType.yoga
            {
                deleteFavOnServer(params: ["favourite_type_id": yogaId, "favourite_type": "yoga" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else if istype == IsSectionType.meditation
            {
                deleteFavOnServer(params: ["favourite_type_id": meditationId, "favourite_type": "meditation" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else if istype == IsSectionType.pranayama
            {
                deleteFavOnServer(params: ["favourite_type_id": pranayamaId, "favourite_type": "pranayama" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else if istype == IsSectionType.mudra
            {
                deleteFavOnServer(params: ["favourite_type_id": mudraId, "favourite_type": "mudra" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else
            {
                deleteFavOnServer(params: ["favourite_type_id": kriyaId, "favourite_type": "kriya" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            
        } else {
            //add
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            if istype == IsSectionType.yoga
            {
                updateFavOnServer(params: ["favourite_type_id": yogaId, "favourite_type": "yoga" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else if istype == IsSectionType.meditation
            {
                updateFavOnServer(params: ["favourite_type_id": meditationId, "favourite_type": "meditation" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else if istype == IsSectionType.pranayama
            {
                updateFavOnServer(params: ["favourite_type_id": pranayamaId, "favourite_type": "pranayama" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else if istype == IsSectionType.mudra
            {
                updateFavOnServer(params: ["favourite_type_id": mudraId, "favourite_type": "mudra" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
            else
            {
                updateFavOnServer(params: ["favourite_type_id": kriyaId, "favourite_type": "kriya" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
        }
    }
    
    func myListClicked() {
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        var id = String()
        var favoriteId = String()
        var selectedList = [String]()
        if istype == IsSectionType.yoga {
            guard let objYoga = self.yoga as? Yoga else {
                return
            }
            id = "\(objYoga.id)" ?? ""
            favoriteId = objYoga.favorite_id ?? ""
            selectedList = objYoga.listids?.components(separatedBy: ",") as! [String]
        } else if istype == IsSectionType.meditation {
            guard let objMeditation = self.meditation as? Meditation else {
                return
            }
            id = "\(objMeditation.id)" ?? ""
            favoriteId = objMeditation.favorite_id ?? ""
            selectedList = objMeditation.listids?.components(separatedBy: ",") as! [String]
        } else if istype == IsSectionType.pranayama {
            guard let objPranayama = self.pranayama as? Pranayama else {
                return
            }
            id = "\(objPranayama.id)" ?? ""
            favoriteId = objPranayama.favorite_id ?? ""
            selectedList = objPranayama.listids?.components(separatedBy: ",") as! [String]
        } else if istype == IsSectionType.mudra {
            guard let objMudra = self.mudra as? Mudra else {
                return
            }
            id = "\(objMudra.id)" ?? ""
            favoriteId = objMudra.favorite_id ?? ""
            selectedList = objMudra.listids?.components(separatedBy: ",") as! [String]
        } else {
            guard let objKriya = self.kriya as? Kriya else {
                return
            }
            id = "\(objKriya.id)" ?? ""
            favoriteId = objKriya.favorite_id ?? ""
            selectedList = objKriya.listids?.components(separatedBy: ",") as! [String]
        }
        let storyBoard = UIStoryboard(name: "MyLists", bundle: nil)
        let addToMyListViewController = storyBoard.instantiateViewController(withIdentifier: "ForYouAddToMyListViewController") as! ForYouAddToMyListViewController
        addToMyListViewController.favouriteType = istype
        addToMyListViewController.favouriteId = favoriteId
        addToMyListViewController.id = id
        addToMyListViewController.delegate = self
        addToMyListViewController.selectedList = selectedList
        self.present(addToMyListViewController, animated: true, completion: nil)
//        self.navigationController?.pushViewController(addToMyListViewController, animated: true)
        #endif
    }
}

extension YogaDetailViewController {
    func updateFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.saveFourite.rawValue
           

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Added".localized(), message: "Successfully added to your favourite list.".localized(), controller: self)
                    self.isFavourite = true
                    self.tblYogaDetail.reloadData()
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            completion()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func deleteFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.deleteFourite.rawValue
           

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Removed".localized(), message: "Successfully removed from your favourite list.".localized(), controller: self)
                    self.isFavourite = false
                    self.tblYogaDetail.reloadData()
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            completion()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}

#if !APPCLIP
// Code you don't want to use in your app clip.
extension YogaDetailViewController: ForYouAddToMyListDelegate {
    func refreshView() {
        tblYogaDetail.reloadData()
    }
}
#endif
