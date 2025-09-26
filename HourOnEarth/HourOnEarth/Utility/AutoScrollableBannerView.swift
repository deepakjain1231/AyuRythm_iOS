//
//  AutoScrollableBannerView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

struct BannerModel {
    var id: Int = 1
    var activityFavoriteId: Int
    var url: String = ""
    var image: UIImage
}

class AutoScrollableBannerView: CustomXIBView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionView: UICollectionView!
    
    let banners = [BannerModel(id: 1, activityFavoriteId: 9, url: "https://bit.ly/2ZTVWrl", image: #imageLiteral(resourceName: "vaidyaBanner.png")),
                   BannerModel(id: 2, activityFavoriteId: 49, url: "https://ayurvedclinic.com/?ref=houronearth", image: #imageLiteral(resourceName: "HerbalhillsBanner.png"))]
    let maxLenth = 2000    //Int.max
    let loopTimeInterval: TimeInterval = 6    //in seconds
    var bannerClickedBlock: ((BannerModel)->Void)?
    
    override func initialSetUp() {
        super.initialSetUp()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: BannerCollectionViewCell.identifier)
        startTimer()
    }
    
    static func addBanner(in view: UIView, height: CGFloat = 60, bannerClickBlock: ((BannerModel)->Void)? = nil) {
        let bannerView = AutoScrollableBannerView(frame: CGRect.zero)
        bannerView.bannerClickedBlock = bannerClickBlock
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: height)
        ])
        bannerView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = banners.count
        return maxLenth //banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.identifier, for: indexPath) as! BannerCollectionViewCell
        let banner = banners[indexPath.row % banners.count]
        cell.bannerImageView.image = banner.image
        //cell.bannerImageView.image = banners[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banner = banners[indexPath.row % banners.count]
        //print("Banner ID : \(banner.id), URL : \(banner.url)")
        //bannerClickedBlock?(banner)
        addEarnHistoryFromServer(banner: banner) {
            let bannerURL = banner.url
            if let url = URL(string: bannerURL), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    /**
     Scroll to Next Cell
     */
    var x = 1
    @objc func scrollToNextCell() {
        if x < maxLenth {
            let indexPath = IndexPath(item: x, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            x = x + 1
        }else{
            x = 0
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    /**
     Invokes Timer to start Automatic Animation with repeat enabled
     */
    
    func startTimer() {
        Timer.scheduledTimer(timeInterval: loopTimeInterval, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true);
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // If the scroll animation ended, update the page control to reflect the current page we are on
        //let pageNumber = Int((collectionView.contentOffset.x / collectionView.contentSize.width) * CGFloat(banners.count))
        let pageNumber = Int((collectionView.contentOffset.x / collectionView.contentSize.width) * CGFloat(maxLenth))
        pageControl.currentPage = pageNumber % banners.count
        x = pageNumber
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Called when manually setting contentOffset
        scrollViewDidEndDecelerating(scrollView)
    }
}

extension AutoScrollableBannerView {
    func addEarnHistoryFromServer(banner: BannerModel, completion: @escaping ()->Void) {
        //showActivityIndicator()
        let params = ["activity_favorite_id": banner.activityFavoriteId, "banner_id": banner.id, "language_id" : Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            //self?.hideActivityIndicator()
            if isSuccess, let topVC = UIApplication.topViewController() {
                Utils.showAlertWithTitleInController(title, message: message, controller: topVC)
            }
            completion()
        }
    }
}

class BannerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BannerCollectionViewCell"
    
    let bannerImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bannerImageView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: bannerImageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomXIBView: UIView {
    var contentView : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Adding custom subview on top of our view
        addSubview(contentView)
        
        //pin contentView to view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    func initialSetUp() {
        // custom initial setup for view
        // over ride this method to do some initial setup
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        initialSetUp()
        
        return view
    }
}
