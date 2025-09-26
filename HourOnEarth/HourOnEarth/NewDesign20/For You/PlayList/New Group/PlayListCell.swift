//
//  PlayListCell.swift
//  HourOnEarth
//
//  Created by Apple on 27/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import AlamofireImage

class PlayListCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewYoga: UIImageView!
    @IBOutlet weak var lockView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(title: String, yoga: [Yoga], isBenefits: Bool) {
        self.lblTitle.text = title
        if isBenefits {
            guard let benefits = yoga.first?.benefits?.allObjects as? [Benefits], let urlString = benefits.filter({$0.benefitsname == title }).first?.benefitsimage, let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        } else {
            guard let urlString = yoga.first?.experiencelevelimage?.replacingOccurrences(of: "\r\n", with: ""), let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        }
        
    }
    
    func configureCell(title: String, urlString: String) {
        self.lblTitle.text = title
        guard let url = URL(string: urlString) else {
            return
        }
        imgViewYoga.af.setImage(withURL: url)
    }
    
    func configureKriya(title: String, kriya: [Kriya], isBenefits: Bool) {
        self.lblTitle.text = title
        if isBenefits {
            guard let benefits = kriya.first?.benefits?.allObjects as? [Benefits], let urlString = benefits.filter({$0.benefitsname == title }).first?.benefitsimage, let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        } else {
            guard let urlString = kriya.first?.experiencelevelimage?.replacingOccurrences(of: "\r\n", with: ""), let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        }
    }

    
    func configureMudra(title: String, mudra: [Mudra], isBenefits: Bool) {
        self.lblTitle.text = title
        if isBenefits {
            guard let benefits = mudra.first?.benefits?.allObjects as? [Benefits], let urlString = benefits.filter({$0.benefitsname == title }).first?.benefitsimage, let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        } else {
            guard let urlString = mudra.first?.experiencelevelimage?.replacingOccurrences(of: "\r\n", with: ""), let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        }
    }
    
    func configurePranayama(title: String, pranayama: [Pranayama], isBenefits: Bool) {
        self.lblTitle.text = title
        if isBenefits {
            guard let benefits = pranayama.first?.benefits?.allObjects as? [Benefits], let urlString = benefits.filter({$0.benefitsname == title }).first?.benefitsimage, let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        } else {
            guard let urlString = pranayama.first?.experiencelevelimage?.replacingOccurrences(of: "\r\n", with: ""), let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        }
    }
    
    func configureMeditation(title: String, meditation: [Meditation], isBenefits: Bool) {
        self.lblTitle.text = title
        if isBenefits {
            guard let benefits = meditation.first?.benefits?.allObjects as? [Benefits], let urlString = benefits.filter({$0.benefitsname == title }).first?.benefitsimage, let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        } else {
            guard let urlString = meditation.first?.experiencelevelimage?.replacingOccurrences(of: "\r\n", with: ""), let url = URL(string: urlString) else {
                return
            }
            imgViewYoga.af.setImage(withURL: url)
        }
    }


}
