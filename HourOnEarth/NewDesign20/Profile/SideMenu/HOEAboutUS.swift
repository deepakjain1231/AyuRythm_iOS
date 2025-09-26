//
//  HOEAboutUS.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 22/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class HOEAboutUS: BaseViewController {

    @IBOutlet var textView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "About Us".localized()

        // Do any additional setup after loading the view.
        textView?.text = "AyuRythm is the world's first completely digital solution for personalized holistic wellness based on Ayurvedic principles. Our solution works on any smartphone.\n\nAyuRythm's patent-pending technology and approval from leading Ayurvedic doctors makes our solution a one-stop for all wellness needs. It assesses the user's ideal and current body type based on a one-time response to 30 questions followed by daily 30-second pulse diagnostic test using your mobile phone camera. Based on the tests, the application makes personalized recommendations on ideal yoga, pranayama, food, spa and herbal.\n\nThe solution comes integrated with a market place where users have a choice to purchase product and services to further their wellness goals.".localized()
    }

}
