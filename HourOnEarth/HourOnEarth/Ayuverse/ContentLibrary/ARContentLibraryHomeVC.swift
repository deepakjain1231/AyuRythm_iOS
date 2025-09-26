//
//  ARContentLibraryHomeVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARContentLibraryHomeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var contents = [ARContentModel]()
    let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(nibWithCellClass: ARContentLibraryHeaderCell.self)
        tableView.register(nibWithCellClass: ARContentLibraryDataCell.self)
        tableView.register(nibWithCellClass: ARContentLibraryCollectionDataCell.self)
        setupUI()
    }
    
    func setupUI() {
        self.title = "Select Content".localized()
        setBackButtonTitle()
        fetchContentData()
    }
    
    deinit {
        DebugLog("-")
        ARContentLibraryManager.shared.clearSelectedItems()
    }
    
    @IBAction func searchBtnPressed(sender: AnyObject) {
        // FIXME: - temp testing by Paresh, remove bellow code until first empty line
        ARContentLibraryFeedPostVC.showScreen(fromVC: self)
        
        //searchBar.isHidden.toggle()
    }
}

extension ARContentLibraryHomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return contents.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents[section].noOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.section]
        if content.isCollectionTypeData {
            let cell = tableView.dequeueReusableCell(withClass: ARContentLibraryCollectionDataCell.self, for: indexPath)
            cell.data = contents[indexPath.section]
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: ARContentLibraryDataCell.self, for: indexPath)
            cell.data = contents[indexPath.section].items[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withClass: ARContentLibraryHeaderCell.self)
        cell.content = contents[section]
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*let content = contents[indexPath.section]
        if !content.isCollectionTypeData {
            let item = content.items[indexPath.row]
            print(">> selected item : ", item)
            item.isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }*/
    }
}

extension ARContentLibraryHomeVC: ARContentLibraryHeaderCellDelegate {
    func contentLibraryHeaderCell(cell: ARContentLibraryHeaderCell, didSelectSeeMoreBtn data: ARContentModel?) {
        showDetailScreen(content: data, isSeeMore: true)
    }
}

extension ARContentLibraryHomeVC: ARContentLibraryCollectionDataCellDelegate {
    func contentLibraryCollectionDataCell(cell: ARContentLibraryCollectionDataCell, didSelect item: ARContentLibraryDataModel, ofContent content: ARContentModel?) {
        showDetailScreen(content: content, item: item)
    }
    
    func showDetailScreen(content: ARContentModel?, item: ARContentLibraryDataModel? = nil, isSeeMore: Bool = false) {
        guard let content = content else { return }
        if content.type == .homeRemedies {
            if isSeeMore {
                let vc = HomeRemediesViewController.instantiate(fromAppStoryboard: .HomeRemedies)
                vc.isFromAyuverseContentLibrary = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let item = item {
                let vc = HomeRemediesSubListViewController.instantiate(fromAppStoryboard: .HomeRemedies)
                vc.arrData = [HomeRemediesDetail]()
                vc.titleHeading = item.name
                vc.isFromAyuverseContentLibrary = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if content.type == .food {
            if isSeeMore {
                let vc = HOEYogaListVC.instantiate(fromAppStoryboard: .ForYou)
                vc.isFromAyuverseContentLibrary = true
                vc.recommendationVikriti = recommendationVikriti
                vc.sectionType = content.type
                vc.isFromHome = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let item = item {
                let vc = FoodsViewController.instantiate(fromAppStoryboard: .ForYou)
                vc.isFromAyuverseContentLibrary = true
                vc.type = recommendationVikriti
                vc.selectedType = item.foodTypes
                vc.selectedId = Int(item.favoriteId) ?? 0
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if content.type == .herbs {
            if isSeeMore {
                let vc = HOEYogaListVC.instantiate(fromAppStoryboard: .ForYou)
                vc.isFromAyuverseContentLibrary = true
                vc.recommendationVikriti = recommendationVikriti
                vc.sectionType = content.type
                vc.isFromHome = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let item = item {
                let vc = HerbsViewController.instantiate(fromAppStoryboard: .ForYou)
                vc.isFromAyuverseContentLibrary = true
                vc.type = recommendationVikriti
                vc.selectedType = item.herbsTypes
                vc.selectedId = Int(item.favoriteId) ?? 0
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if isSeeMore {
            ARContentListVC.showScreen(content: content, fromVC: self)
        }
    }
}

extension ARContentLibraryHomeVC {
    func fetchContentData() {
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        self.showActivityIndicator()
        Utils.doAPICall(endPoint: .getContentLibrary, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                self?.contents = ARContentModel.getContentData(fromJSON: responseJSON["data"])
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
}

extension ARContentLibraryHomeVC: UISearchBarDelegate  {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //allContentItems = contentItems
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty, text.count >= 2 {
            print(">> search : ", text)
//            contentItems = contentItems.filter{ $0.name.caseInsensitiveContains(text) }
//            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
    }
}

extension ARContentLibraryHomeVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = ARContentLibraryHomeVC.instantiate(fromAppStoryboard: .Ayuverse)
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
