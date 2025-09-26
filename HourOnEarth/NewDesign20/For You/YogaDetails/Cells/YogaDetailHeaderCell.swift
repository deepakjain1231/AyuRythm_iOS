//
//  YogaDetailHeaderCell.swift
//  HourOnEarth
//
//  Created by Apple on 19/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol YogaDetailHeaderDelegate: class {
    func readMoreClicked()
    func playVideoClicked()
    func starClicked()
    func shareClickedwith(hindiName: String, enName: String, desc: String) // Added by Aakash
    func myListClicked()
}

class YogaDetailHeaderCell: UITableViewCell {

    @IBOutlet weak var lblEntryLevel: UILabel!
    @IBOutlet weak var lblPV: UILabel!
    @IBOutlet weak var lblEnglishName: UILabel!
    @IBOutlet weak var lblHindiName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnFavoutite: UIButton!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var btnMyLists: UIButton!
    @IBOutlet weak var btnShare: UIButton!

    weak var delegate: YogaDetailHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        #if APPCLIP
        // Code your app clip may access.
        btnShare.isHidden = true
        btnFavoutite.isHidden = true
        btnMyLists.isHidden = true
        #endif
    }
    
    func configureUIKriya(kriya: Kriya, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = kriya.name
        lblHindiName.text = kriya.english_name
        lblEntryLevel.text = "\(kriya.experiencelevel?.capitalized ?? "")"
        if let types = kriya.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
        lblDescription.text = kriya.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
        btnMyLists.isSelected = (kriya.listids?.count ?? 0) > 0 ? true : false
        btnMyLists.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
    }

    func configureUIMudra(mudra: Mudra, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = mudra.name
        lblHindiName.text = mudra.english_name
        lblEntryLevel.text = "\(mudra.experiencelevel?.capitalized ?? "")"
        if let types = mudra.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
        lblDescription.text = mudra.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
        btnMyLists.isSelected = (mudra.listids?.count ?? 0) > 0 ? true : false
        btnMyLists.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
    }

    func configureUIMeditation(meditation: Meditation, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = meditation.name
        lblHindiName.text = meditation.english_name
        lblEntryLevel.text = "\(meditation.experiencelevel?.capitalized ?? "")"
        if let types = meditation.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
        lblDescription.text = meditation.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
        btnMyLists.isSelected = (meditation.listids?.count ?? 0) > 0 ? true : false
        btnMyLists.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
    }

    func configureUIPranayama(pranayama: Pranayama, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = pranayama.name
        lblHindiName.text = pranayama.english_name
        lblEntryLevel.text = "\(pranayama.experiencelevel?.capitalized ?? "")"
        if let types = pranayama.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
        lblDescription.text = pranayama.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
        btnMyLists.isSelected = (pranayama.listids?.count ?? 0) > 0 ? true : false
        btnMyLists.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
    }

    func configureUI(yoga: Yoga, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = yoga.name
        lblHindiName.text = yoga.english_name
        lblEntryLevel.text = "\(yoga.experiencelevel?.capitalized ?? "")"
        if let types = yoga.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
        lblDescription.text = yoga.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
        btnMyLists.isSelected = (yoga.listids?.count ?? 0) > 0 ? true : false
        btnMyLists.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
    }
    
    
    func configureUIKriya(kriya: FavouriteKriya, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = kriya.name
        lblHindiName.text = kriya.english_name
     //   lblEntryLevel.text = "\(yoga.experiencelevel?.capitalized ?? "")"
        if let types = kriya.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
     //   lblDescription.text = yoga.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
    }

    
    func configureUIMudra(mudra: FavouriteMudra, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = mudra.name
        lblHindiName.text = mudra.english_name
     //   lblEntryLevel.text = "\(yoga.experiencelevel?.capitalized ?? "")"
        if let types = mudra.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
     //   lblDescription.text = yoga.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
    }

    
    func configureUIMeditation(meditation: FavouriteMeditation, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = meditation.name
        lblHindiName.text = meditation.english_name
     //   lblEntryLevel.text = "\(yoga.experiencelevel?.capitalized ?? "")"
        if let types = meditation.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
     //   lblDescription.text = yoga.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
    }

    
    func configureUIPranayama(pranayama: FavouritePranayama, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = pranayama.name
        lblHindiName.text = pranayama.english_name
     //   lblEntryLevel.text = "\(yoga.experiencelevel?.capitalized ?? "")"
        if let types = pranayama.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
     //   lblDescription.text = yoga.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
    }

    
    func configureUI(yoga: FavouriteYoga, isFavourite: Bool, isMoreOpen: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        lblEnglishName.text = yoga.name
        lblHindiName.text = yoga.english_name
     //   lblEntryLevel.text = "\(yoga.experiencelevel?.capitalized ?? "")"
        if let types = yoga.type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        lblDescription.numberOfLines = isMoreOpen ? 0 : 3
     //   lblDescription.text = yoga.shortdescription?.replacingOccurrences(of: "\\n", with: "\n")
        btnReadMore.isSelected = isMoreOpen
//        btnMyLists.isSelected = (mudra.listids?.count ?? 0) > 0 ? true : false
        btnMyLists.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
    }

    @IBAction func readMoreClicked(_ sender: UIButton) {
        delegate?.readMoreClicked()
    }
    
    @IBAction func starClicked(_ sender: UIButton) {
        delegate?.starClicked()
    }
    
    @IBAction func playVideoClicked(_ sender: UIButton) {
        delegate?.playVideoClicked()
    }
    
    // Added by Aakash
    @IBAction func shareClicked(_ sender: UIButton) {
        delegate?.shareClickedwith(hindiName: lblHindiName.text ?? "", enName: lblEnglishName.text ?? "", desc: lblDescription.text ?? "")
    }

    @IBAction func myListButtonPressed(_ sender: UIButton) {
        delegate?.myListClicked()
    }

}

