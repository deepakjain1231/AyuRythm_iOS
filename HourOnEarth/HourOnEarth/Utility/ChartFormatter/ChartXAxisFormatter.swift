//
//  ChartXAxisFormatter.swift
//  HourOnEarth
//
//  Created by Ayu on 13/07/20.
//  Copyright © 2020 Hour on Earth. All rights reserved.
//

import UIKit
import Charts

class ChartXAxisFormatter: NSObject, AxisValueFormatter {
    
    var dataArray = [Double : String]()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let time = dataArray[value]
        return time ?? ""
    }
    
}
