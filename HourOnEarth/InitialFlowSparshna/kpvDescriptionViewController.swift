//
//  kpvDescriptionViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/15/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

struct KPVData {
    var imageName: String
    var title: String
    var subTitle: String
    var description: String
    var type: KPVType
}

import UIKit

class KPVDescriptionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MoreDetailsDelagate {

    @IBOutlet weak var lblDescription: UILabel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrData: [KPVData] = [KPVData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let kapha = KPVData(imageName: "Kaphaa", title: "KAPHA".localized(), subTitle: "Strength/Energy Index".localized(), description: "Energy of physical form, structure, and smooth functioning".localized(), type: .KAPHA)
        let pitta = KPVData(imageName: "PittaN", title: "PITTA".localized(), subTitle: "Metabolic Index".localized(), description: "Energy of digestion and metabolism".localized(), type: .PITTA)
        let vata = KPVData(imageName: "VataN", title: "VATA".localized(), subTitle: "Emotional/Stress Index".localized(), description: "Energy of movement and the force governing all biological activity".localized(), type: .VATA)
        arrData.append(kapha)
        arrData.append(pitta)
        arrData.append(vata)
        self.collectionView.register(UINib(nibName: "VikritiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VikritiCollectionViewCell")
        self.collectionView.reloadData()
        
        let attributedString = NSMutableAttributedString(string: "We start with the Naadi Pariksha \nor Pulse Diagnosis to discover your Kapha, Pitta and Vata imbalances or your Vikriti (Current You)".localized(), attributes: [
          .font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.41
        ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 91, length: 13) : NSRange(location: 18, length: 14))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 110, length: 15) : NSRange(location: 37, length: 15))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 46, length: 23) : NSRange(location: 111, length: 21))
        
        self.lblDescription.attributedText = attributedString
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VikritiCollectionViewCell", for: indexPath) as? VikritiCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(data: arrData[indexPath.item])
        cell.delegate = self
        cell.setColor(index: indexPath)
        return cell
    }
    
    
    @IBAction func startNowClicked(_ sender: Any) {
        if kUserDefaults.bool(forKey: kDoNotShowTestInfo) {
            let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
            let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
            objAlert.modalPresentationStyle = .overCurrentContext
            objAlert.completionHandler = {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let dob = Shared.sharedInstance.dob
                let birthday = dateFormatter.date(from: dob)
                
                let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
                if birthday != nil {
                    if Shared.sharedInstance.isInFt {
                        let height = Double(Shared.sharedInstance.inFt)! * 30.48 + (Double(Shared.sharedInstance.inInc)! * 2.54)
                        objSlideView.dHei = height
                    } else {
                        objSlideView.dHei = Double(Shared.sharedInstance.inFt)!
                    }
                    
                    if !Shared.sharedInstance.isInKg {
                        
                        objSlideView.dWei =              Double(Utils.convertPoundsToKg(lb: Shared.sharedInstance.weigh))!

                    } else {
                        objSlideView.dWei = Double(Shared.sharedInstance.weigh)!
                    }
                    objSlideView.isMale = Shared.sharedInstance.isMale
                    let ageComponents = Calendar.current.dateComponents([.year], from: birthday!, to: Date())
                    objSlideView.dAge = Double(ageComponents.year!)
                }
                
                objSlideView.demo_user_name =  Shared.sharedInstance.name
                self.navigationController?.pushViewController(objSlideView, animated: true)
            }
            self.present(objAlert, animated: true)
        } else {
                   let storyBoard = UIStoryboard(name: "SparshnaTestInfo", bundle: nil)
                   let objSlideView: SparshnaTestInfoViewController = storyBoard.instantiateViewController(withIdentifier: "SparshnaTestInfoViewController") as! SparshnaTestInfoViewController
                   self.navigationController?.pushViewController(objSlideView, animated: true)

               }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
       }
    
    func moreClicked(kpvType: KPVType) {
        let storyboard = UIStoryboard(name: "MoreKpv", bundle: nil)
        let moreController = storyboard.instantiateViewController(withIdentifier:"MoreKpvViewController" ) as! MoreKpvViewController
        moreController.kpvType = kpvType
        moreController.isFromOnBoarding = true
        self.navigationController?.pushViewController(moreController, animated: true)
    }
    
}
extension KPVDescriptionViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width , height: 160.0)
    }
}
