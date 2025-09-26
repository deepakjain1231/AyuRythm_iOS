//
//  HOEYogaCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 12/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import AlamofireImage

class HOEYogaCell: RoundedCell
{
    //MARK: IBOutlets
    @IBOutlet weak var imgKapha: UIImageView!
    @IBOutlet weak var imgPitta: UIImageView!
    @IBOutlet weak var imgVata: UIImageView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lblEngName: UILabel!
    @IBOutlet weak var lblHindiName: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var btnLock: UIButton!

    var delegate: RecommendationSeeAllDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgThumb.image = nil
    }
    
    func configureUIKriyaFav(kriya: FavouriteKriya, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
              lblEngName.text = kriya.name
              lblHindiName.text = kriya.english_name
              if isStatusVisible {
                  viewStatus.isHidden = false
                  if let types = kriya.type?.components(separatedBy: ","){
                      if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                        status.text = "Prakriti/Vikriti".localized()
                          status.textColor = colorTextTagGreen
                          viewStatus.backgroundColor = colorBgTagGreen
                      } else if types.contains(recPrakriti.rawValue) {
                        status.text = "Prakriti".localized()
                          status.textColor = colorTextTagGreen
                          viewStatus.backgroundColor = colorBgTagGreen
                      } else if types.contains(recVikriti.rawValue) {
                        status.text = "Vikriti".localized()
                          status.textColor = colorTextTagBlue
                          viewStatus.backgroundColor = colorBgTagBlue
                      }
                  }
              } else {
                  viewStatus.isHidden = true
              }
              
              imgKapha.isHidden = true
              imgPitta.isHidden = true
              imgVata.isHidden = true
              
              let kpvType = kriya.type?.split(separator: ",") ?? []
              imgKapha.isHidden = !kpvType.contains("kapha")
              imgPitta.isHidden = !kpvType.contains("pitta")
              imgVata.isHidden = !kpvType.contains("vata")

              guard let urlString = kriya.image, let url = URL(string: urlString) else {
                  return
              }
              imgThumb.af.setImage(withURL: url)
          }

    
    func configureUIKriya(kriya: Kriya, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
              lblEngName.text = kriya.name
              lblHindiName.text = kriya.english_name
              if isStatusVisible {
                  viewStatus.isHidden = false
                  if let types = kriya.type?.components(separatedBy: ","){
                      if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                        status.text = "Prakriti/Vikriti".localized()
                          status.textColor = colorTextTagGreen
                          viewStatus.backgroundColor = colorBgTagGreen
                      } else if types.contains(recPrakriti.rawValue) {
                        status.text = "Prakriti".localized()
                          status.textColor = colorTextTagGreen
                          viewStatus.backgroundColor = colorBgTagGreen
                      } else if types.contains(recVikriti.rawValue) {
                        status.text = "Vikriti".localized()
                          status.textColor = colorTextTagBlue
                          viewStatus.backgroundColor = colorBgTagBlue
                      }
                  }
              } else {
                  viewStatus.isHidden = true
              }
              
              imgKapha.isHidden = true
              imgPitta.isHidden = true
              imgVata.isHidden = true
              
              let kpvType = kriya.type?.split(separator: ",") ?? []
              imgKapha.isHidden = !kpvType.contains("kapha")
              imgPitta.isHidden = !kpvType.contains("pitta")
              imgVata.isHidden = !kpvType.contains("vata")

              guard let urlString = kriya.image, let url = URL(string: urlString) else {
                  return
              }
              imgThumb.af.setImage(withURL: url)
          }
    
    func configureUIMudraFav(mudra: FavouriteMudra, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
           lblEngName.text = mudra.name
           lblHindiName.text = mudra.english_name
           if isStatusVisible {
               viewStatus.isHidden = false
               if let types = mudra.type?.components(separatedBy: ","){
                   if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                       status.textColor = colorTextTagBlue
                       viewStatus.backgroundColor = colorBgTagBlue
                   }
               }
           } else {
               viewStatus.isHidden = true
           }
           
           imgKapha.isHidden = true
           imgPitta.isHidden = true
           imgVata.isHidden = true
           
           let kpvType = mudra.type?.split(separator: ",") ?? []
           imgKapha.isHidden = !kpvType.contains("kapha")
           imgPitta.isHidden = !kpvType.contains("pitta")
           imgVata.isHidden = !kpvType.contains("vata")

           guard let urlString = mudra.image, let url = URL(string: urlString) else {
               return
           }
           imgThumb.af.setImage(withURL: url)
       }
    
    func configureUIMudra(mudra: Mudra, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
           lblEngName.text = mudra.name
           lblHindiName.text = mudra.english_name
           if isStatusVisible {
               viewStatus.isHidden = false
               if let types = mudra.type?.components(separatedBy: ","){
                   if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                       status.textColor = colorTextTagBlue
                       viewStatus.backgroundColor = colorBgTagBlue
                   }
               }
           } else {
               viewStatus.isHidden = true
           }
           
           imgKapha.isHidden = true
           imgPitta.isHidden = true
           imgVata.isHidden = true
           
           let kpvType = mudra.type?.split(separator: ",") ?? []
           imgKapha.isHidden = !kpvType.contains("kapha")
           imgPitta.isHidden = !kpvType.contains("pitta")
           imgVata.isHidden = !kpvType.contains("vata")

           guard let urlString = mudra.image, let url = URL(string: urlString) else {
               return
           }
           imgThumb.af.setImage(withURL: url)
       }

    
    func configureUIMeditation(meditation: Meditation, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
           lblEngName.text = meditation.name
           lblHindiName.text = meditation.english_name
           if isStatusVisible {
               viewStatus.isHidden = false
               if let types = meditation.type?.components(separatedBy: ","){
                   if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                       status.textColor = colorTextTagBlue
                       viewStatus.backgroundColor = colorBgTagBlue
                   }
               }
           } else {
               viewStatus.isHidden = true
           }
           
           imgKapha.isHidden = true
           imgPitta.isHidden = true
           imgVata.isHidden = true
           
           let kpvType = meditation.type?.split(separator: ",") ?? []
           imgKapha.isHidden = !kpvType.contains("kapha")
           imgPitta.isHidden = !kpvType.contains("pitta")
           imgVata.isHidden = !kpvType.contains("vata")

           guard let urlString = meditation.image, let url = URL(string: urlString) else {
               return
           }
           imgThumb.af.setImage(withURL: url)
       }

    func configureUIMeditationFav(meditation: FavouriteMeditation, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
           lblEngName.text = meditation.name
           lblHindiName.text = meditation.english_name
           if isStatusVisible {
               viewStatus.isHidden = false
               if let types = meditation.type?.components(separatedBy: ","){
                   if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                       status.textColor = colorTextTagBlue
                       viewStatus.backgroundColor = colorBgTagBlue
                   }
               }
           } else {
               viewStatus.isHidden = true
           }
           
           imgKapha.isHidden = true
           imgPitta.isHidden = true
           imgVata.isHidden = true
           
           let kpvType = meditation.type?.split(separator: ",") ?? []
           imgKapha.isHidden = !kpvType.contains("kapha")
           imgPitta.isHidden = !kpvType.contains("pitta")
           imgVata.isHidden = !kpvType.contains("vata")

           guard let urlString = meditation.image, let url = URL(string: urlString) else {
               return
           }
           imgThumb.af.setImage(withURL: url)
       }

    func configureUIPranayamaFav(Pranayama: FavouritePranayama, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
           lblEngName.text = Pranayama.name
           lblHindiName.text = Pranayama.english_name
           if isStatusVisible {
               viewStatus.isHidden = false
               if let types = Pranayama.type?.components(separatedBy: ","){
                   if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                       status.textColor = colorTextTagBlue
                       viewStatus.backgroundColor = colorBgTagBlue
                   }
               }
           } else {
               viewStatus.isHidden = true
           }
           
           imgKapha.isHidden = true
           imgPitta.isHidden = true
           imgVata.isHidden = true
           
           let kpvType = Pranayama.type?.split(separator: ",") ?? []
        print("kpvType=",kpvType)
           imgKapha.isHidden = !kpvType.contains("kapha")
           imgPitta.isHidden = !kpvType.contains("pitta")
           imgVata.isHidden = !kpvType.contains("vata")

           guard let urlString = Pranayama.image, let url = URL(string: urlString) else {
               return
           }
           imgThumb.af.setImage(withURL: url)
       }

    
    func configureUIPranayama(Pranayama: Pranayama, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
           lblEngName.text = Pranayama.name
           lblHindiName.text = Pranayama.english_name
           if isStatusVisible {
               viewStatus.isHidden = false
               if let types = Pranayama.type?.components(separatedBy: ","){
                   if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                       status.textColor = colorTextTagGreen
                       viewStatus.backgroundColor = colorBgTagGreen
                   } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                       status.textColor = colorTextTagBlue
                       viewStatus.backgroundColor = colorBgTagBlue
                   }
               }
           } else {
               viewStatus.isHidden = true
           }
           
           imgKapha.isHidden = true
           imgPitta.isHidden = true
           imgVata.isHidden = true
           
           let kpvType = Pranayama.type?.split(separator: ",") ?? []
        print("kpvType=",kpvType)
           imgKapha.isHidden = !kpvType.contains("kapha")
           imgPitta.isHidden = !kpvType.contains("pitta")
           imgVata.isHidden = !kpvType.contains("vata")

           guard let urlString = Pranayama.image, let url = URL(string: urlString) else {
               return
           }
           imgThumb.af.setImage(withURL: url)
       }
    
    func configureUI(yoga: Yoga, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        lblEngName.text = yoga.name
        lblHindiName.text = yoga.english_name
        if isStatusVisible {
            viewStatus.isHidden = false
            if let types = yoga.type?.components(separatedBy: ","){
                if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                    status.textColor = colorTextTagGreen
                    viewStatus.backgroundColor = colorBgTagGreen
                } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                    status.textColor = colorTextTagGreen
                    viewStatus.backgroundColor = colorBgTagGreen
                } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                    status.textColor = colorTextTagBlue
                    viewStatus.backgroundColor = colorBgTagBlue
                }
            }
        } else {
            viewStatus.isHidden = true
        }
        
        imgKapha.isHidden = true
        imgPitta.isHidden = true
        imgVata.isHidden = true
        
        let kpvType = yoga.type?.split(separator: ",") ?? []
        imgKapha.isHidden = !kpvType.contains("kapha")
        imgPitta.isHidden = !kpvType.contains("pitta")
        imgVata.isHidden = !kpvType.contains("vata")

        guard let urlString = yoga.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    func configureUI(yoga: FavouriteYoga, isStatusVisible: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        lblEngName.text = yoga.name
        lblHindiName.text = yoga.english_name
        if isStatusVisible {
            viewStatus.isHidden = false
            if let types = yoga.type?.components(separatedBy: ","){
                if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                    status.text = "Prakriti/Vikriti".localized()
                    status.textColor = colorTextTagGreen
                    viewStatus.backgroundColor = colorBgTagGreen
                } else if types.contains(recPrakriti.rawValue) {
                    status.text = "Prakriti".localized()
                    status.textColor = colorTextTagGreen
                    viewStatus.backgroundColor = colorBgTagGreen
                } else if types.contains(recVikriti.rawValue) {
                    status.text = "Vikriti".localized()
                    status.textColor = colorTextTagBlue
                    viewStatus.backgroundColor = colorBgTagBlue
                }
            }
        } else {
            viewStatus.isHidden = true
        }
        
        imgKapha.isHidden = true
        imgPitta.isHidden = true
        imgVata.isHidden = true
        
        let kpvType = yoga.type?.split(separator: ",") ?? []
        imgKapha.isHidden = !kpvType.contains("kapha")
        imgPitta.isHidden = !kpvType.contains("pitta")
        imgVata.isHidden = !kpvType.contains("vata")

        guard let urlString = yoga.image, let url = URL(string: urlString) else {
            return
        }
        imgThumb.af.setImage(withURL: url)
    }
    
    @IBAction func lockClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        delegate?.didSelectedSelectRowForRedeem(indexPath: indexPath, index: sender.tag)
    }
}
