//
//  SlideShowViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/25/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class SlideShowViewController: UIViewController, UIScrollViewDelegate {
    
    var currentIndex = 0
    var isFromSettings: Bool = false
    @IBOutlet weak var collection_view: UICollectionView!
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var pagecontrol: UIPageControl?
    @IBOutlet var lbl_Next: UILabel!
    @IBOutlet var btn_NextArrow: UIControl!
    @IBOutlet var btn_letsStart: UIControl!
    @IBOutlet var btn_Skip: UIButton!
    
    let arrImages:[String]  = ["intro_1","intro_2","intro_3", "intro_5"]
    let arrSlideText:[(String, String)] = [("intro_title_1".localized(),
                                            "intro_description_1".localized()),
                                           ("intro_title_2".localized(),
                                            "intro_description_2".localized()),
                                           ("intro_title_3".localized(),
                                            "intro_description_3".localized()),
                                           ("intro_title_5".localized(),
                                            "intro_description_5".localized())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btn_letsStart.isHidden = true
        self.lbl_Next.text = "LET'S START".localized()
        kUserDefaults.synchronize()
        imgBack.isHidden = !isFromSettings
        btnBack.isHidden = !isFromSettings
        self.btn_Skip.setTitle("SKIP".localized().capitalized, for: .normal)
        
        
        //Register Collection Cell
        self.collection_view.register(nibWithCellClass: SlideCollectionCell.self)
        
        self.collection_view.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func changePage(sender: UIPageControl) {
        let x = CGFloat((pagecontrol?.currentPage)!) * (collection_view?.frame.size.width)!
        self.collection_view.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        if self.isFromSettings {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            kUserDefaults.set(true, forKey: kIsFirstLaunch)
            let objLoginView: LoginViewController = Story_LoginSignup.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(objLoginView, animated: true)
        }
        
        /*
        guard let objLetsStartView = Story_Main.instantiateViewController(withIdentifier: "LetsStartViewController") as? LetsStartViewController else {
            return
        }
        self.navigationController?.pushViewController(objLetsStartView, animated: true)
        */
    }
    
    @IBAction func btn_NextArrow_Clicked(_ sender: UIControl) {
        self.currentIndex = self.currentIndex + 1
        self.pagecontrol?.currentPage = self.currentIndex
        if self.currentIndex == 3 {
            self.btn_Skip.isHidden = true
            self.btn_NextArrow.isHidden = true
            self.btn_letsStart.isHidden = false
        }
        else {
            self.btn_Skip.isHidden = false
            self.btn_NextArrow.isHidden = false
            self.btn_letsStart.isHidden = true
        }
        self.collection_view.scrollToItem(at: IndexPath.init(row: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func btn_Skip_Action(_ sender: UIButton) {
        kUserDefaults.set(true, forKey: kIsFirstLaunch)
        let objLoginView: LoginViewController = Story_LoginSignup.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(objLoginView, animated: true)
    }
    
}

extension SlideShowViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collection_view.contentOffset, size: collection_view.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collection_view.indexPathForItem(at: visiblePoint)
        self.pagecontrol?.currentPage = visibleIndexPath?.row ?? 0
        self.currentIndex = visibleIndexPath?.row ?? 0
        if visibleIndexPath?.row ?? 0 == 3 {
            self.btn_Skip.isHidden = true
            self.btn_NextArrow.isHidden = true
            self.btn_letsStart.isHidden = false
        }
        else {
            self.btn_Skip.isHidden = false
            self.btn_NextArrow.isHidden = false
            self.btn_letsStart.isHidden = true
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideCollectionCell", for: indexPath) as! SlideCollectionCell
        cell.img_intro.image = UIImage.init(named: arrImages[indexPath.row])// UIImage.gifImageWithName(arrImages[index])
        cell.lbl_title.text = arrSlideText[indexPath.row].0.localized()
        cell.lblsubtitle.text = arrSlideText[indexPath.row].1.localized()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
