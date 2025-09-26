//
//	ARGraphDataModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import Charts
import UIKit

class ARGraphDataModel{

	var averagedata : ARAveragedata!
	var graphdata : [ARGraphdata]!
	var month : Int!
	var weeknumber : Int!
	var year : Int!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		
        averagedata = ARAveragedata(fromJson: json)
		graphdata = [ARGraphdata]()
		let graphdataArray = json["graphdata"].arrayValue
		for graphdataJson in graphdataArray{
			let value = ARGraphdata(fromJson: graphdataJson)
			graphdata.append(value)
		}
		month = json["month"].intValue
		weeknumber = json["weeknumber"].intValue
		year = json["year"].intValue
	}

}

extension ARGraphDataModel {
    convenience init(month: Int) {
        self.init(fromJson: JSON(["month": month]))
    }
    
    func getBarChartData() -> (dataEntries: [BarChartDataEntry], barColors: [UIColor]) {
        var dataEntries = [BarChartDataEntry]()
        var barColors = [UIColor]()
        
        for (index, data) in graphdata.enumerated() {
            let dataEntry = BarChartDataEntry(x: Double(index), y: data.avgSteps)
            dataEntries.append(dataEntry)
            barColors.append(data.isAchiveGoal ? UIColor.app.barChart.green : UIColor.app.barChart.gray)
        }
        return (dataEntries, barColors)
    }
    
    func getChartViewTitles(chartFilter: ARStepsDeatilsVC.ChartFilterType, filterData: ARChartFilterData) -> (chartTitle: String, sectionTitle: String) {
        switch chartFilter {
        case .week:
            let chartTile = String(format: "Week %d, %d".localized(), weeknumber, year)
            var sectionTitle = chartTile
            if filterData.year == year {
                if filterData.week - 1 == weeknumber {
                    sectionTitle = "This Week".localized()
                } else {
                    sectionTitle = String(format: "Week %d".localized(), weeknumber)
                }
            }
            return (chartTile, sectionTitle)
            
        case .month:
            let monthName = DateFormatter().monthSymbols[month - 1]
            let chartTile = monthName + ", \(year!)"
            var sectionTitle = chartTile
            if filterData.year == year {
                if filterData.month == month {
                    sectionTitle = "This Month".localized()
                } else {
                    sectionTitle = monthName
                }
            }
            return (chartTile, sectionTitle)
            
        case .year:
            let chartTile = year.stringValue
            let sectionTitle = filterData.year == year ? "This Year".localized() :
            String(format: "Year %@".localized(), chartTile)
            return (chartTile, sectionTitle)
        }
    }
    
    var averageStepsAttribText: NSAttributedString {
        return NSAttributedString(string: averagedata.avgSteps.stringWithCommas) + getUnitAttribText(for: " steps/day")
    }
    
    var caloriesAttribText: NSAttributedString {
        return NSAttributedString(string: averagedata.calories.stringWithCommas) + getUnitAttribText(for: " kcal")
    }
    
    var totalDistanceAttribText: NSAttributedString {
        //return NSAttributedString(string: averagedata.distance.twoDigitStringValue) + getUnitAttribText(for: " km")
        
        let data = ARPedometerData.distanceValueInLocal(distanceInKm: averagedata.distance)
        return NSAttributedString(string: data.value) + getUnitAttribText(for: " \(data.unit)")
    }
    
    func getUnitAttribText(for unit: String) -> NSAttributedString {
        return NSAttributedString(string: unit, attributes: [.foregroundColor: UIColor.fromHex(hexString: "#777777"), .font : UIFont.systemFont(ofSize: 14)])
    }
}

// MARK: -
class ARAveragedata{

    var avgSteps : Int!
    var calories : Int!
    var distance : Double!
    var totalSteps : Int!
    var distance_unit : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }

        if json["monthdata"].exists() {
            let averagedataJson = json["monthdata"]
            avgSteps = averagedataJson["monthly_avg_steps"].intValue
            calories = averagedataJson["monthly_calories"].intValue
            distance = averagedataJson["monthly_distance"].doubleValue
            totalSteps = averagedataJson["monthly_steps"].intValue
            distance_unit = averagedataJson["monthly_distance_unit"].stringValue
        } else if json["yeardata"].exists() {
            let averagedataJson = json["yeardata"]
            avgSteps = averagedataJson["yearly_avg_steps"].intValue
            calories = averagedataJson["yearly_calories"].intValue
            distance = averagedataJson["yearly_distance"].doubleValue
            totalSteps = averagedataJson["yearly_steps"].intValue
            distance_unit = averagedataJson["yearly_distance_unit"].stringValue
        } else {
            //weekly data
            let averagedataJson = json["weekdata"]
            avgSteps = averagedataJson["weekly_avg_steps"].intValue
            calories = averagedataJson["weekly_calories"].intValue
            distance = averagedataJson["weekly_distance"].doubleValue
            totalSteps = averagedataJson["weekly_steps"].intValue
            distance_unit = averagedataJson["weekly_distance_unit"].stringValue
        }
    }

}

// MARK: -
class ARGraphdata{

    var avgGoal : Double!
    var avgSteps : Double!
    var title : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        avgGoal = json["avg_goal"].doubleValue
        if json["goal"].exists() {
            avgGoal = json["goal"].doubleValue
        }
        avgSteps = json["avg_steps"].doubleValue
        if json["steps"].exists() {
            avgSteps = json["steps"].doubleValue
        }
        title = json["title"].stringValue
        if json["day"].exists() {
            title = json["day"].stringValue
        } else if json["week"].exists() {
            title = json["week"].stringValue
        } else if json["month"].exists() {
            let monthNo = json["month"].intValue
            title = DateFormatter().shortMonthSymbols[monthNo - 1]
        }
    }

}

extension ARGraphdata {
    var isAchiveGoal: Bool {
        //return avgSteps >= avgGoal
        return avgSteps >= Double(ARPedometerManager.shared.pedometerData.goal)
    }
}

// MARK: -
extension Int {
    var stringWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self)) ?? "0"
    }
}

extension Double {
    var stringWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter.string(from: NSNumber(value:self)) ?? "0"
    }
}
