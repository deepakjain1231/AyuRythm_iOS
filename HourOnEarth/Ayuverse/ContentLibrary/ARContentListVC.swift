//
//  ARContentListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 04/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON

class ARContentListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var content: ARContentModel!
    var allContentItems = [ARContentLibraryDataModel]()
    var contentItems = [ARContentLibraryDataModel]()
    
    //let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
    let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(nibWithCellClass: ARContentLibraryDataCell.self)
        setupUI()
    }
    
    func setupUI() {
        self.title = content.type.title
        setBackButtonTitle()
        contentItems = content.items
        fetchContentData()
    }
    
    deinit {
        DebugLog("-")
    }
    
    @IBAction func searchBtnPressed(sender: AnyObject) {
        searchBar.isHidden.toggle()
    }
}

extension ARContentListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARContentLibraryDataCell.self, for: indexPath)
        let content = contentItems[indexPath.row]
        cell.selectionBtn.isHidden = false
        cell.data = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contentItems[indexPath.row]
        item.isSelected.toggle()
        ARContentLibraryManager.shared.addOrRemoveSelectContent(type: content.type, id: item.favoriteId, image: item.image, selected: item.isSelected)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension ARContentListVC {
    func fetchContentData() {
        self.showActivityIndicator()
        var params = ["type": recommendationVikriti,
                      "language_id" : Utils.getLanguageId()] as [String : Any]
        params["type"] = appDelegate.cloud_vikriti_status
        
        Utils.doAPICall(endPoint: content.getApiEndpoint, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            guard let self = self, let responseJSON = responseJSON else { return }
            if self.content.type == .playlist {
                self.contentItems = responseJSON["data"].arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }
            } else {
                self.contentItems = responseJSON.arrayValue.compactMap{ ARContentLibraryDataModel(fromJson: $0) }
            }
            if self.content.type == .yoga{
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.yoga.rawValue)
            }else if self.content.type == .meditation{
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.meditation.rawValue)
            }else if self.content.type == .pranayama{
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.paranayam.rawValue)
            }else if self.content.type == .kriya{
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.kriya.rawValue)
            }else if self.content.type == .mudra{
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.mudra.rawValue)
            }
            self.preselectSelectedItem()
            self.tableView.reloadData()
            self.hideActivityIndicator()
        }
    }
    
    func preselectSelectedItem() {
        let preSelectedItems = ARContentLibraryManager.shared.selectedContents
        self.contentItems.forEach { item in
            if let _ = preSelectedItems.firstIndex(where: { $0.type == self.content.type && $0.id == item.favoriteId }) {
                item.isSelected = true
            }
        }
        allContentItems = contentItems
    }
    
    static func showScreen(content: ARContentModel, fromVC: UIViewController) {
        let vc = ARContentListVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.content = content
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ARContentListVC: UISearchBarDelegate  {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty, text.count >= 2 {
            print(">> search : ", text)
            contentItems = allContentItems.filter{ $0.name.caseInsensitiveContains(text) }
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        contentItems = allContentItems
        preselectSelectedItem()
        tableView.reloadData()
    }
}
