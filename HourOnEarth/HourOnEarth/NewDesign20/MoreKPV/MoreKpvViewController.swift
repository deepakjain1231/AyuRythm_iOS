//
//  MoreKpvViewController.swift
//  HourOnEarth
//
//  Created by Apple on 26/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class MoreKpvViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MoreExpandCollapseDelagate {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var tblViewResult: UITableView!
    @IBOutlet weak var lblHeading1: UILabel!
    @IBOutlet weak var lblHeading2: UILabel!
    
    var arrData: [(String, String, String)] = [(String, String, String)]()
    var kpvType: KPVType = .KAPHA
    var selectedIndex = -1
    var isFromOnBoarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_title.text = ""
        self.tblViewResult.tableFooterView = UIView()
        if isFromOnBoarding {
            self.navigationController?.isNavigationBarHidden = false
        }
        switch kpvType {
        case .KAPHA:
            self.lbl_title.text = "Kapha".localized()
            imgIcon.image = UIImage(named: "kaphaInfoCombined")
            lblHeading1.text = "Calm\nThoughtful\nLoving\nEnjoys life\nComfortable\nwith routine".localized()
            lblHeading2.text = "Kapha governs all structure and lubrication in the mind and body. It controls weight, growth, lubrication for the joints and lungs, and formation of all the 7 tissues - nutritive fluids, blood, fat, muscles, bones, marrow and reproductive tissues.".localized()
            arrData = [("balance".localized(),"Tips for Balancing".localized(), "• Vigorous regular exercise, a little each day \n• Warm temperatures \n• Fresh fruits, vegetables and legumes \n• Favour pungent, bitter, astringent tastes and light, dry and warm foods \n• Reduce heavy, oily, cold foods and sweet, sour and salty tastes \n• Seek out variety and new experiences \n• Stay warm in cold, damp weather \n• Early to bed, early to rise".localized()),
                ("government".localized(),"Kapha Governs".localized(), "• Moisture for nose, mouth, eyes and brain \n• Sense of taste, which is essential for good digestion \n• Moisture of the stomach lining for good digestion \n• Protects the heart, strong muscles, healthy lungs \n• Lubrication of the joints, soft and supple skin".localized()),
                ("imbalance".localized(),"Out of Balance".localized(), "• Sinus congestion, poor sense of smell \n• Poor sense of taste, food cravings due to lack of fulfillment \n• Impaired digestion, poor absorption \n• Lethargy, respiratory problems, lower back pain \n• Weight gain, oily skin, loose or painful joints".localized())
            ]
            
        case .PITTA:
            imgIcon.image = UIImage(named: "pittaInfoCombined")
            self.lbl_title.text = "Pitta".localized()
            lblHeading1.text = "Intellectual\nFocused\nPrecise\nDirect\nPassionate".localized()
            lblHeading2.text = "Pitta governs all heat, metabolism and transformation in the mind and body. It controls how we digest foods, how we metabolize our sensory perceptions, and how we discriminate between right and wrong. Pitta governs the important digestive \"agnis\" or fires of the body.".localized()
            arrData = [("balance".localized(),"Tips for Balancing".localized(), "• Keep cool. Avoid hot temperatures and food. \n• Favor cool, heavy, dry foods and sweet, bitter and astringent tastes. \n• Reduce pungent, sour, salty tastes and warm, oily and light foods. \n• Moderation; don't overwork. \n• Allow for leisure time. \n• Regular mealtimes, especially lunch at noon. \n• Abhyanga (ayurvedic oil massage) with a cooling oil such as coconut.".localized()),
                ("government".localized(),"Pitta Governs".localized(), "• Functioning of the eyes \n• Healthy glow of the skin \n• Desire, drive, decisiveness, spirituality \n• Digestion, assimilation, metabolism for healthy nutrients and tissues \n• Healthy, toxin-free blood.".localized()),
                ("imbalance".localized(),"Out of Balance".localized(), "• Bloodshot eyes, poor vision \n• Skin rashes, acne \n• Demanding, perfectionist, workaholic \n• Acid stomach \n• Early graying, anger, toxins in blood".localized())
            ]

        case .VATA:
            imgIcon.image = UIImage(named: "vataInfoCombined")
            self.lbl_title.text = "Vata".localized()
            lblHeading1.text = "Spontaneous\nEnthusiastic\nCreative\nFlexible\nEnergetic".localized()
            lblHeading2.text = "Vata governs all movement in the mind and body. It controls blood flow, elimination of wastes, breathing and the movement of thoughts across the mind. Since Pitta and Kapha cannot move without it, Vata is considered the leader of the three Ayurvedic Principles in the body. It's very important to keep Vata in good balance.".localized()
            arrData = [("balance".localized(),"Tips for Balancing".localized(), "• Abhyanga (daily ayurvedic massage with sesame oil) \n• Warm temperatures. \n• Warm, cooked foods (less raw foods) \n• Early bedtimes, lots of rest \n• Favor warm, oily, heavy foods and sweet, sour, and salty tastes. \n• Reduce light, dry, cold foods and pungent, bitter and astringent tastes. \n• Avoid stimulants \n• Regular, daily elimination \n• Stay warm in cold, windy weather".localized()),
                ("government".localized(),"Vata Governs".localized(), "• The senses, creative thinking, reasoning, enthusiasm \n• Quality of voice, memory, movements of thought \n• Movement of food through digestive tract \n• Elimination of wastes, sexual function, menstrual cycle \n• Blood flow, heart rhythm, perspiration, sense of touch".localized()),
                ("imbalance".localized(),"Out of Balance".localized(), "• Worries, overactive mind, sleep problems, difficulty breathing \n• Dry cough, sore throats, earaches, general fatigue. \n• Slow or rapid digestion, gas, intestinal cramps, poor assimilation, weak tissues. \n• Intestinal cramps, menstrual problems, lower back pain, irregularity, diarrhea, constipation, gas \n• Dry or rough skin, nervousness, shakiness, poor blood flow, stress-related problems".localized())
            ]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let headerView = tblViewResult.tableHeaderView {

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tblViewResult.tableHeaderView = headerView
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFromOnBoarding {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellMoreKPV") as? MoreKpvCell else {
            return UITableViewCell()
        }
        cell.configure(image: self.arrData[indexPath.row].0, title: self.arrData[indexPath.row].1, subTitle: self.arrData[indexPath.row].2, isSelected: self.selectedIndex == indexPath.row)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        expandCollapseClicked(indexPath: indexPath)
    }
    
    func expandCollapseClicked(indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            if selectedIndex == -1 {
                selectedIndex = indexPath.row
            } else {
                selectedIndex = -1
            }
        } else {
            selectedIndex = indexPath.row
        }
        self.tblViewResult.reloadData()
    }
}
