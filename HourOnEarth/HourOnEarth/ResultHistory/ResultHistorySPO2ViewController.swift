//
//  ResultHistorySPO2ViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 14/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftDate

class ResultHistorySPO2ViewController: BaseViewController, ChartViewDelegate {
    
    @IBOutlet weak var calendarSegmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    
    var deviationArray = [Date : NSNumber]()
    var index = 0
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchResultHistory()
    }
    
    // MARK: - Action Methods
    
    @IBAction func calendarSegementValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            calendarLabel.text = "Today"
            index = 0
            rightArrowButton.isEnabled = false
        } else if sender.selectedSegmentIndex == 1 {
            index = 0
            rightArrowButton.isEnabled = false
        } else if sender.selectedSegmentIndex == 2 {
            index = 0
            rightArrowButton.isEnabled = false
        } else if sender.selectedSegmentIndex == 3 {
            index = 0
            rightArrowButton.isEnabled = false
        }
        
        setChartData()
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        index = index + 1
        setChartData()
        
        if index == 0 {
            self.rightArrowButton.isEnabled = false;
        } else {
            self.rightArrowButton.isEnabled = true;
        }
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        index = index - 1
        setChartData()
        
        if index == 0 {
            self.rightArrowButton.isEnabled = false;
        } else {
            self.rightArrowButton.isEnabled = true;
        }
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        calendarLabel.text = "Today"
        rightArrowButton.isEnabled = false
        
        chartView.delegate = self
        chartView.chartDescription.enabled = false
        
        chartView.maxVisibleCount = 10
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1.0
        xAxis.labelWidth = 5.0
        xAxis.axisMinimum = 0
       
        chartView.leftAxis.axisMinimum = 70
        chartView.leftAxis.axisMaximum = 100
        //chartView.leftAxis

        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1), font: .systemFont(ofSize: 12), textColor: .white, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
        
        chartView.legend.form = .none
        
        chartView.noDataText = "Sorry! No Data! \n Please complete the assessments to view data!".localized()
        chartView.noDataTextColor = kGraphNoDataColor
        chartView.noDataFont = UIFont.boldSystemFont(ofSize: 14.0)
        chartView.noDataTextAlignment = .center
    }
    
    func fetchResultHistory() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
           let urlString = kBaseNewURL + endPoint.SpO2History.rawValue
        
           AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default,headers: headers).responseJSON { response in
               
               DispatchQueue.main.async(execute: {
                   Utils.stopActivityIndicatorinView(self.view)
               })
               switch response.result {
               case .success(let value):
                   print("API URL: - \(urlString)\n\nParams: - \n\nResponse: - \(value)")
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    if dicResponse["status"] as? String ?? "" == "success" {
                    
                    guard let dataResponse = (dicResponse["data"] as? [[String : Any]]) else {
                        return
                    }
                    
                    for ayurDict in dataResponse {
                        guard let deviationStr = ayurDict["sparshna"] as? String, deviationStr.count > 0 else {
                            continue
                        }

                        guard let deviationData = deviationStr.data(using: .utf8) else {
                            continue
                        }

                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: deviationData, options: .allowFragments)
                            let deviation = jsonData as! [String : NSNumber]
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            guard let dateString = ayurDict["timestamp"] as? String else {
                                continue
                            }
                            guard let date = dateFormatter.date(from: dateString) else {
                                continue
                            }

                            self.deviationArray[date] = deviation["SPO2"]
                        } catch let error {
                            debugPrint(error)
                        }
                    }
                
                    self.setChartData()
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to SpO2 result details."), controller: self)
                }
                
               case .failure(let error):
                   debugPrint(error)
                   Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
               }
           }
    }
    
    func setChartData() {
        if self.calendarSegmentControl.selectedSegmentIndex == 0 {
            setDayChartData()
        } else if self.calendarSegmentControl.selectedSegmentIndex == 1 {
            setWeekData()
        } else if self.calendarSegmentControl.selectedSegmentIndex == 2 {
            setMonthChartData()
        } else {
            setYearChartData()
        }
    }
    
    func setDayChartData() {
        let date = Date()
        let newDate = date + index.days
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        calendarLabel.text = dateFormatter.string(from: newDate)
        
        var graphDeviationArray = [Date : NSNumber]()
        var xValsArray = [Double : String]()
        
        let sortedDate = deviationArray.keys.sorted()
        var sortedChartData = [ChartDataEntry]()
        var sortIndex = 1
        
        for key in sortedDate {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if dateFormatter.string(from: key) == dateFormatter.string(from: newDate) {
                graphDeviationArray[key] = deviationArray[key]
                
                let value = deviationArray[key]
                
                dateFormatter.dateFormat = "hh:mm a"
                    
                xValsArray[Double(sortIndex)] = dateFormatter.string(from: key)
                
                sortedChartData.append(ChartDataEntry(x: Double(sortIndex), y: value?.doubleValue ?? 0.0))
                sortIndex+=1
            }
        }
        
        if sortedChartData.count == 0 {
            chartView.data = nil
        } else {
            let xAxisFormatter = ChartXAxisFormatter()
            xAxisFormatter.dataArray = xValsArray
            let xAxis = chartView.xAxis
            xAxis.valueFormatter = xAxisFormatter
            xAxis.gridLineWidth = 0
            
            let set = LineChartDataSet(entries: sortedChartData, label: "")
            set.drawIconsEnabled = false
            set.setColor(kLineGreenColor)
            set.setCircleColor(kLineGreenColor)
            set.lineWidth = 2
            set.circleRadius = 4
            set.drawCircleHoleEnabled = false
            set.valueFont = .systemFont(ofSize: 9)
            set.drawFilledEnabled = false
            
            let data = LineChartData(dataSet: set)
            chartView.data = data
            chartView.animate(yAxisDuration: 1)
        }
    }
    
    func setWeekData() {
        let date = Date()
        let newDate = date + index.weeks
                    
        let weekday = newDate.weekday
        let startDate = newDate - (weekday - 1).days
        var endDate = newDate + (7 - weekday).days
        if index == 0 {
            endDate = Date()
        }
        let increment = DateComponents.create {
            $0.day = 1
        }
        let daysOfWeek = Date.enumerateDates(from: startDate, to: endDate, increment: increment)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        calendarLabel.text = dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        
        var graphDeviationArray = [Date : NSNumber]()
        var xValsArray = [Double : String]()
        let sortedDate = deviationArray.keys.sorted()
        var sortedChartData = [ChartDataEntry]()
        var sortIndex = 1
        
        for day in daysOfWeek {
            for key in sortedDate {
                dateFormatter.dateFormat = "dd/MM/yyyy"
                if dateFormatter.string(from: key) == dateFormatter.string(from: day) {
                    graphDeviationArray[key] = deviationArray[key]
                    
                    let value = deviationArray[key]
                    
                    dateFormatter.dateFormat = "dd MMMM"
                        
                    xValsArray[Double(sortIndex)] = dateFormatter.string(from: key)
                    
                    sortedChartData.append(ChartDataEntry(x: Double(sortIndex), y: value?.doubleValue ?? 0.0))
                    sortIndex+=1
                    break
                }
            }
        }
        
        if sortedChartData.count == 0 {
            chartView.data = nil
        } else {
            let xAxisFormatter = ChartXAxisFormatter()
            xAxisFormatter.dataArray = xValsArray
            let xAxis = chartView.xAxis
            xAxis.valueFormatter = xAxisFormatter
            xAxis.gridLineWidth = 0
            
            let set = LineChartDataSet(entries: sortedChartData, label: "")
            set.drawIconsEnabled = false
            set.setColor(kLineGreenColor)
            set.setCircleColor(kLineGreenColor)
            set.lineWidth = 2
            set.circleRadius = 4
            set.drawCircleHoleEnabled = false
            set.valueFont = .systemFont(ofSize: 9)
            set.drawFilledEnabled = false
            
            let data = LineChartData(dataSet: set)
            chartView.data = data
            chartView.animate(yAxisDuration: 1)
        }
    }
    
    func setMonthChartData() {
        let date = Date()
        let newDate = date + index.months
        
        let monthDay = newDate.day
        let startDate = newDate - (monthDay - 1).days
        let endDate = startDate + newDate.monthDays.days
        
        let increment = DateComponents.create {
            $0.day = 1
        }
        let daysOfMonth = Date.enumerateDates(from: startDate, to: endDate, increment: increment)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        calendarLabel.text = dateFormatter.string(from: newDate)
        
        var graphDeviationArray = [Date : NSNumber]()
        var xValsArray = [Double : String]()
        
        let sortedDate = deviationArray.keys.sorted()
        var sortedChartData = [ChartDataEntry]()
        var sortIndex = 1
        
        for day in daysOfMonth {
            for key in sortedDate {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if dateFormatter.string(from: key) == dateFormatter.string(from: day) {
                    graphDeviationArray[key] = deviationArray[key]
                    
                    let value = deviationArray[key]
                    
                    dateFormatter.dateFormat = "dd MMMM"
                        
                    xValsArray[Double(sortIndex)] = dateFormatter.string(from: key)
                    
                    sortedChartData.append(ChartDataEntry(x: Double(sortIndex), y: value?.doubleValue ?? 0.0))
                    sortIndex+=1
                    
                    break
                }
            }
        }
        
        if sortedChartData.count == 0 {
            chartView.data = nil
        } else {
            let xAxisFormatter = ChartXAxisFormatter()
            xAxisFormatter.dataArray = xValsArray
            let xAxis = chartView.xAxis
            xAxis.valueFormatter = xAxisFormatter
            xAxis.gridLineWidth = 0
            
            let set = LineChartDataSet(entries: sortedChartData, label: "")
            set.drawIconsEnabled = false
            set.setColor(kLineGreenColor)
            set.setCircleColor(kLineGreenColor)
            set.lineWidth = 2
            set.circleRadius = 4
            set.drawCircleHoleEnabled = false
            set.valueFont = .systemFont(ofSize: 9)
            set.drawFilledEnabled = false
            
            let data = LineChartData(dataSet: set)
            chartView.data = data
            chartView.animate(yAxisDuration: 1)
        }
    }
    
    func setYearChartData() {
        let date = Date()
        let newDate = date + index.years
        
        let yearStartDay = newDate.dateAtStartOf(.year)
        var monthOfYear = [Date]()
        for i in 0...11 {
            let monthStart = yearStartDay.dateAtStartOf(.month) + i.months
            monthOfYear.append(monthStart)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        calendarLabel.text = dateFormatter.string(from: newDate)
        
        var graphDeviationArray = [Date : NSNumber]()
        var xValsArray = [Double : String]()
        
        let sortedDate = deviationArray.keys.sorted()
        var sortedChartData = [ChartDataEntry]()
        var sortIndex = 1
        
        for day in monthOfYear {
            for key in sortedDate {
                dateFormatter.dateFormat = "yyyy-MM"
                if dateFormatter.string(from: key) == dateFormatter.string(from: day) {
                    graphDeviationArray[key] = deviationArray[key]
                    let value = deviationArray[key]
                    
                    dateFormatter.dateFormat = "MM"
                        
                    xValsArray[Double(sortIndex)] = dateFormatter.string(from: key)
                    
                    sortedChartData.append(ChartDataEntry(x: Double(sortIndex), y: value?.doubleValue ?? 0.0))
                    sortIndex+=1
                    break
                }
            }
        }
        
        if sortedChartData.count == 0 {
            chartView.data = nil
        } else {
            let xAxisFormatter = ChartXAxisFormatter()
            xAxisFormatter.dataArray = xValsArray
            let xAxis = chartView.xAxis
            xAxis.valueFormatter = xAxisFormatter
            xAxis.gridLineWidth = 0
            
            let set = LineChartDataSet(entries: sortedChartData, label: "")
            set.drawIconsEnabled = false
            set.setColor(kLineGreenColor)
            set.setCircleColor(kLineGreenColor)
            set.lineWidth = 2
            set.circleRadius = 4
            set.drawCircleHoleEnabled = false
            set.valueFont = .systemFont(ofSize: 9)
            set.drawFilledEnabled = false
            
            let data = LineChartData(dataSet: set)
            chartView.data = data
            chartView.animate(yAxisDuration: 1)
        }
    }
    
    // MARK: - ChartView Delegate Methods
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
