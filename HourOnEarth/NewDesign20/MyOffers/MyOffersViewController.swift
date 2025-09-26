//
//  MyOffersViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class BannerInfo{

    var accessPoint : String!
    var clickUrl : String!
    var createdOn : String!
    var id : String!
    var activity_favorite_id: String!
    var image : String!
    var name : String!
    var sequenceNo : String!
    var status : String!
    var updatedOn : String!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        accessPoint = dictionary["access_point"] as? String
        clickUrl = dictionary["click_url"] as? String
        createdOn = dictionary["created_on"] as? String
        id = dictionary["id"] as? String
        activity_favorite_id = dictionary["activity_favorite_id"] as? String
        image = dictionary["image"] as? String
        name = dictionary["name"] as? String
        sequenceNo = dictionary["sequence_no"] as? String
        status = dictionary["status"] as? String
        updatedOn = dictionary["updated_on"] as? String
    }

}

class MyOffersViewController: UIViewController {
    
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var banners = [BannerInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = topHeaderView.frame
        gradientLayer.colors = [UIColor(red: 255.0/255.0, green: 184.0/255.0, blue: 82.0/255.0, alpha: 1).cgColor,
                                UIColor(red: 250.0/255.0, green: 157.0/255.0, blue: 68.0/255.0, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        topHeaderView.layer.insertSublayer(gradientLayer, at: 0)
        
        showActivityIndicator()
        getBannerInfoFromServer { (isSuccess, message, banners) in
            if isSuccess {
                self.banners = banners
                self.tableView.reloadData()
                self.hideActivityIndicator()
            } else {
                self.hideActivityIndicator()
                self.showAlert(message: message)
            }
        }
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    static func showOffers(presentingVC: UIViewController) {
        let vc = MyOffersViewController.instantiateFromStoryboard("Offers")
        vc.modalPresentationStyle = .fullScreen
        presentingVC.present(vc, animated: true, completion: nil)
    }
}

extension MyOffersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyOfferCell") as? MyOfferCell else {
            return UITableViewCell()
        }
        
        let banner = banners[indexPath.row]
        //cell.banner = banner
        if let url = URL(string: banner.image) {
            cell.imageV.af.setImage(withURL: url, completion:  { [weak self] response in
                if let strongSelf = self, let width = response.value?.size.width, let height = response.value?.size.height, cell.imageVHeight.constant != height {
                    let ratio = height/width
                    let finalHeight = cell.imageV.frame.width * ratio
                    print("image : \(width) x \(height)")
                    print("final height : ", finalHeight)
                    cell.imageVHeight.constant = max(finalHeight, 60)
                    //cell.layoutIfNeeded()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let banner = banners[indexPath.row]
        //print("Banner ID : \(banner.id), URL : \(banner.url)")
        
        addEarnHistoryFromServer(banner: banner) {
            let bannerURL = banner.clickUrl
            if let url = URL(string: bannerURL!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension MyOffersViewController {
    func addEarnHistoryFromServer(banner: BannerInfo, completion: @escaping ()->Void) {
        //showActivityIndicator()
        let params = ["activity_favorite_id": "\(banner.activity_favorite_id!)", "banner_id": banner.id!, "language_id" : Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            //self?.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInController(title, message: message, controller: self)
            }
            completion()
        }
    }
    
    func getBannerInfoFromServer(completion: @escaping (Bool, String, [BannerInfo])->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getBannerInfo.rawValue

            AF.request(urlString, method: .post, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", [BannerInfo]())
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get AyuSeeds info, please try after some time".localized()
                    var bannerInfos = [BannerInfo]()
                    if let dataArray = dicResponse["data"] as? [[String: Any]] {
                        bannerInfos = dataArray.map{ BannerInfo(fromDictionary: $0) }
                    }
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, bannerInfos)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [BannerInfo]())
                }
            }
        } else {
            completion(false, NO_NETWORK, [BannerInfo]())
        }
    }
}

class MyOfferCell: UITableViewCell {
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageVHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageV.contentMode = .scaleAspectFit
        /*imageV.layer.cornerRadius = 12
        imageV.clipsToBounds = true
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.layer.applySketchShadow()
        changeCellSelectionBackgroundColor()*/
    }
    
    /*var banner: BannerInfo? {
        didSet {
            if let banner = banner, let url = URL(string: banner.image) {
                imageV.af.setImage(withURL: url, completion:  { [weak self] response in
                    print("image : \(response.value?.size.width) x \(response.value?.size.height)")
                    if let height = response.value?.size.height {
                        self?.imageVHeight.constant = height
                    }
                })
            }
        }
    }*/
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
        shadowPath = nil
    } else {
        let dx = -spread
        let rect = bounds.insetBy(dx: dx, dy: dx)
        shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
