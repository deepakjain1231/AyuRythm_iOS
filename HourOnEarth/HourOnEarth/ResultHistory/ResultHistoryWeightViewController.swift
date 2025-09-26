//
//  ResultHistoryWeightViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 09/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftDate

class ResultHistoryWeightViewController: BaseViewController, ChartViewDelegate {
    
    @IBOutlet weak var calendarSegmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    
    var index = 0
    var filter = HistoryResultFilter.day
    var dataFetchRequest: DataRequest?
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setChartData()
    }
    
    // MARK: - Action Methods
    
    @IBAction func calendarSegementValueChanged(_ sender: UISegmentedControl) {
        filter = HistoryResultFilter(rawValue: sender.selectedSegmentIndex) ?? .day
        switch filter {
        case .day:
            calendarLabel.text = "Today"
            index = 0
            rightArrowButton.isEnabled = false
        default:
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
        
        chartView.extraLeftOffset = 25
        chartView.extraRightOffset = 25

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
    
    func setChartData() {
        switch filter {
        case .day:
            setDayChartData()
        case .week:
            setWeekData()
        case .month:
            setMonthChartData()
        case .year:
            setYearChartData()
        }
    }
    
    func setDayChartData() {
        let date = Date()
        let newDate = date + index.days
        
        let dataString = dateFormatter.string(from: newDate, dateFormat: serverSendDateFormat)
        calendarLabel.text = dateFormatter.string(from: newDate, dateFormat: "dd MMMM yyyy")
        let params = ["filter": filter.filterParam, "start_date": dataString, "end_date": dataString]
        getDataAndUpdateChart(with: params)
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
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        calendarLabel.text = dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        let params = ["filter": filter.filterParam, "start_date": dateFormatter.string(from: startDate, dateFormat: serverSendDateFormat), "end_date": dateFormatter.string(from: endDate, dateFormat: serverSendDateFormat)]
        getDataAndUpdateChart(with: params)
    }
    
    func setMonthChartData() {
        let date = Date()
        let newDate = date + index.months
        
        let monthDay = newDate.day
        let startDate = newDate - (monthDay - 1).days
        let endDate = startDate + newDate.monthDays.days
        
        dateFormatter.dateFormat = "MMMM yyyy"
        calendarLabel.text = dateFormatter.string(from: newDate)
        let params = ["filter": filter.filterParam, "start_date": dateFormatter.string(from: startDate, dateFormat: serverSendDateFormat), "end_date": dateFormatter.string(from: endDate, dateFormat: serverSendDateFormat)]
        getDataAndUpdateChart(with: params)
    }
    
    func setYearChartData() {
        let date = Date()
        let newDate = date + index.years
        
        let startDate = newDate.dateAtStartOf(.year)
        let endDate = newDate.dateAtEndOf(.year)
        dateFormatter.dateFormat = "yyyy"
        calendarLabel.text = dateFormatter.string(from: newDate)
        let params = ["filter": filter.filterParam, "start_date": dateFormatter.string(from: startDate, dateFormat: serverSendDateFormat), "end_date": dateFormatter.string(from: endDate, dateFormat: serverSendDateFormat)]
        getDataAndUpdateChart(with: params)
    }
    
    func getDataAndUpdateChart(with params: [String: Any]) {
        getHistoryDataFromServer(params: params) { success, title, message, data in
            if success {
                if data.isEmpty {
                    self.chartView.data = nil
                } else {
                    self.updateChartData(from: data)
                }
            } else {
                Utils.showAlertWithTitleInController(title, message: message, controller: self)
            }
        }
    }
    
    func updateChartData(from data: [ARChartData]) {
        var xValsArray = [Double : String]()
        var sortedChartData = [ChartDataEntry]()
        for (index, value) in data.enumerated() {
            xValsArray[Double(index)] = value.displayDateString(for: filter)
            sortedChartData.append(ChartDataEntry(x: Double(index), y: Double(value.total) ?? 0.0))
        }
        
        let xAxisFormatter = ChartXAxisFormatter()
        xAxisFormatter.dataArray = xValsArray
        let xAxis = self.chartView.xAxis
        xAxis.valueFormatter = xAxisFormatter
        xAxis.gridLineWidth = 0
        xAxis.granularityEnabled = true
        
        let set = LineChartDataSet(entries: sortedChartData, label: "")
        set.drawIconsEnabled = false
        set.setColor(kLineGreenColor)
        set.setCircleColor(kLineGreenColor)
        set.lineWidth = 2
        set.circleRadius = 4
        set.drawCircleHoleEnabled = false
        set.valueFont = .systemFont(ofSize: 9)
        set.drawFilledEnabled = false
        
        let chartData = LineChartData(dataSet: set)
        self.chartView.data = chartData
        self.chartView.animate(yAxisDuration: 0.45)
    }
    
    // MARK: - ChartView Delegate Methods
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
}

extension ResultHistoryWeightViewController {
    func getHistoryDataFromServer(params: [String : Any], completion: @escaping (Bool, String, String, [ARChartData])->Void) {
        if Utils.isConnectedToNetwork() {
            dataFetchRequest?.cancel()
            
            let urlString = kBaseNewURL + endPoint.fetchBplWeightReport.rawValue
            print(">>>> PARAMS :: ", params)
            dataFetchRequest = AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, APP_NAME, "", [])
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let isSuccess = status.lowercased() == "success"
                    let title = status.isEmpty ? APP_NAME : status.capitalizingFirstLetter()
                    let message = dicResponse["message"] as? String ?? ""
                    var chartData = [ARChartData]()
                    if let data = dicResponse["data"] as? [[String: String]] {
                        data.forEach{
                            if let weight = $0["weight"], let createdAt = $0["created_at"] {
                                let item = ARChartData(total: weight, createdAt: createdAt)
                                chartData.append(item)
                            }
                        }
                    }
                    completion(isSuccess, title, message, chartData)
                case .failure(let error):
                    print(error)
                    if error.localizedDescription != "Request explicitly cancelled." {
                        completion(false, APP_NAME, error.localizedDescription, [])
                    }
                }
            }
        } else {
            completion(false, APP_NAME, NO_NETWORK, [])
        }
    }
}
