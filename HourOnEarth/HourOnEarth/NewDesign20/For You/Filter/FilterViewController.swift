//
//  FilterViewController.swift
//  HourOnEarth
//
//  Created by Apple on 01/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var tblView: UITableView!
    var dataArray = [(title: String,values: [String])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.estimatedRowHeight = 44.0
        
        let recommendation = ("RECOMMENDATIONS BASED ON:", ["Prakriti", "Vikriti"])
        dataArray.append(recommendation)

        guard let yoga = self.getYogaFromDB() else {
            return
        }
        
        guard let groupedData = Dictionary(grouping: yoga, by: {$0.experiencelevel}) as? [String: [Yoga]] else {
            return
        }
        let sortedKeys = groupedData.keys.sorted()
        
        let levels = ("LEVELS:", sortedKeys)
        dataArray.append(levels)
        
        var benefitTags = [String]()
        for objYoga in yoga {
            let benefits = (objYoga.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            benefitTags.append(contentsOf: benefits)
        }
        let unique = Array(Set(benefitTags))

        let tags = ("TAGS:", unique.sorted())
        dataArray.append(tags)

        tblView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: TableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataArray[section].title.localized()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray[section].values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.accessoryType = .none
        let sectionTitle =  self.dataArray[indexPath.section].title
        let titleText = self.dataArray[indexPath.section].values[indexPath.row]
        if sectionTitle == "RECOMMENDATIONS BASED ON:" {
            if Shared.sharedInstance.filterRecommendation.contains(titleText) {
                cell.accessoryType = .checkmark
            }
        } else if sectionTitle == "LEVELS:" {
            if Shared.sharedInstance.filterLevels.contains(titleText) {
                cell.accessoryType = .checkmark
            }
        } else {
            if Shared.sharedInstance.filterTags.contains(titleText) {
                cell.accessoryType = .checkmark
            }
        }
        cell.textLabel?.text = titleText.localized()
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle =  self.dataArray[indexPath.section].title
        let titleText = self.dataArray[indexPath.section].values[indexPath.row]
        if sectionTitle == "RECOMMENDATIONS BASED ON:" {
            if Shared.sharedInstance.filterRecommendation.contains(titleText) {
                guard let index = Shared.sharedInstance.filterRecommendation.firstIndex(of: titleText) else { return }
                Shared.sharedInstance.filterRecommendation.remove(at: index)
            } else {
                Shared.sharedInstance.filterRecommendation.append(titleText)
            }
        } else if sectionTitle == "LEVELS:" {
            if Shared.sharedInstance.filterLevels.contains(titleText) {
                guard let index = Shared.sharedInstance.filterLevels.firstIndex(of: titleText) else { return }
                Shared.sharedInstance.filterLevels.remove(at: index)
            } else {
                Shared.sharedInstance.filterLevels.append(titleText)
            }
        } else {
            if Shared.sharedInstance.filterTags.contains(titleText) {
                guard let index = Shared.sharedInstance.filterTags.firstIndex(of: titleText) else { return  }
                Shared.sharedInstance.filterTags.remove(at: index)
            } else {
                Shared.sharedInstance.filterTags.append(titleText)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func resetClicked(_ sender: UIBarButtonItem) {
        Shared.sharedInstance.clearFilterData()
        self.tblView.reloadData()
    }
    
    @IBAction func dismissClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getYogaFromDB() -> [Yoga]? {
        guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("Yoga", withPredicate: nil, sortKey: "name", isAscending: true) as? [Yoga] else {
            return nil
        }
        return arrYoga
    }
    
    
}


