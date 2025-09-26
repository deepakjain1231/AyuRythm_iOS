//
//  ARAyuverseHomeVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 04/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARAyuverseHomeVC: BaseViewController{
    
    enum Section: Int {
        case feed
        case group
        case questinAnswer
    }

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var feedListView: UIView!
    @IBOutlet weak var groupListView: UIView!
    @IBOutlet weak var qaListView: UIView!

    var is_GroupSearch = false
    var isFeedSearch  = false
    var isQASearch = false
    var currentSection = Section.feed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentControl.setTitle("Feed".localized(), forSegmentAt: 0)
        self.segmentControl.setTitle("Groups".localized(), forSegmentAt: 1)
        self.segmentControl.setTitle("Q&A".localized(), forSegmentAt: 2)
        updateUI()
        showNavProfileButton()
    }
    
    func updateUI() {
        feedListView.isHidden = true
        groupListView.isHidden = true
        qaListView.isHidden = true
        switch currentSection {
        case .feed:
            feedListView.isHidden = false
        case .group:
            groupListView.isHidden = false
        case .questinAnswer:
            qaListView.isHidden = false
        }
    }
    
    @IBAction func SearchClicked(_ sender: UIBarButtonItem) {
        if self.currentSection == .group {
            if self.is_GroupSearch == false {
                self.is_GroupSearch = true
                (self.children[1] as? ARGroupListVC)?.show_SearchBar()
            }
            else {
                if (self.children[1] as? ARGroupListVC)?.txt_Search.text == "" {
                    self.view.endEditing(true)
                    self.is_GroupSearch = false
                    (self.children[1] as? ARGroupListVC)?.hide_SearchBar()
                }
            }
        }else if self.currentSection == .feed{
            if self.isFeedSearch == false {
                self.isFeedSearch = true
                (self.children[0] as? ARFeedListVC)?.show_SearchBar()
            }
            else {
                if (self.children[0] as? ARFeedListVC)?.txt_Search.text == "" {
                    self.view.endEditing(true)
                    self.isFeedSearch = false
                    (self.children[0] as? ARFeedListVC)?.hide_SearchBar()
                }
            }
        }else if self.currentSection == .questinAnswer{
            if self.isQASearch == false {
                self.isQASearch = true
                (self.children[2] as? ARQAListVC)?.show_SearchBar()
            }
            else {
                if (self.children[2] as? ARQAListVC)?.txt_Search.text == "" {
                    self.view.endEditing(true)
                    self.isQASearch = false
                    (self.children[2] as? ARQAListVC)?.hide_SearchBar()
                }
            }
        }
        
    }
    @IBAction func profileBtnAct(_ sender: Any) {
    }
    @IBAction func segmentControlValueDidChange(sender: UISegmentedControl) {
        currentSection = Section(rawValue: sender.selectedSegmentIndex) ?? .feed
        updateUI()
    }
}

extension ARAyuverseHomeVC {
    
}
protocol AyuverseSearchDelegate {
    func ayuverseSearchAction(btn: UISearchBar)
}
