//
//  VikritiCollectionViewCell.swift
//  HourOnEarth
//
//  Created by hardik mulani on 22/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

protocol MoreDetailsDelagate: class {
    func moreClicked(kpvType: KPVType)
}

class VikritiCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: DesignableView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSubTitile: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    @IBOutlet weak var btnMore: UIButton!
    weak var delegate: MoreDetailsDelagate?
    private var type: KPVType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(data: KPVData) {
           imgView.image = UIImage(named: data.imageName)
           lblTitle.text = data.title
           lblSubTitile.text = data.subTitle
           //lblDetail.text = data.description
            type = data.type
            btnMore.setTitle("KNOW MORE".localized(), for: .normal)
    }
    func setColor(index:IndexPath){
        if index.row == 0{
            lblTitle.textColor = UIColor().hexStringToUIColor(hex: "#6CC068")
            //BGView.layer.borderColor = UIColor().hexStringToUIColor(hex: "#3E8B3A").cgColor
            //lblSubTitile.textColor = UIColor().hexStringToUIColor(hex: "#6CC068")
            bgView.shadowOnVIew(.green)
           // BGView.shadowRadius = 5
            
        }else if index.row == 1{
            lblTitle.textColor = UIColor().hexStringToUIColor(hex: "#FB0903")
          //  BGView.layer.borderColor = UIColor().hexStringToUIColor(hex: "#E42348").cgColor
          //  lblSubTitile.textColor = UIColor().hexStringToUIColor(hex: "#ED6F87")
           // BGView.shadowColor = UIColor(red: 234/244, green: 82/255, blue: 111/255, alpha: 1)
            //BGView.shadowRadius = 5
            bgView.shadowOnVIew(.pink)


        }else if index.row == 2 {
            lblTitle.textColor = UIColor().hexStringToUIColor(hex: "#3C91E6")
         //   BGView.layer.borderColor = UIColor().hexStringToUIColor(hex: "#A949AE").cgColor
         //   BGView.shadowColor = UIColor(red: 60/244, green: 145/255, blue: 230/255, alpha: 1)
           // BGView.shadowRadius = 5
            bgView.shadowOnVIew(.blue)

           // lblSubTitile.textColor = UIColor().hexStringToUIColor(hex: "#C781CB")
        }
    }
    
    
    
    
    @IBAction func knowMoreClicked(_ sender: UIButton) {
        self.delegate?.moreClicked(kpvType: type ?? .KAPHA)
    }
}
