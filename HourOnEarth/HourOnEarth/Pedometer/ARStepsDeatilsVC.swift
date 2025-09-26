//
//  ARStepsDeatilsVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 30/03/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import MKMagneticProgress
import Charts

class ARChartFilterData {
    var year = 0
    var month = 0
    var week = 0
}

class ARStepsDeatilsVC: UIViewController {
    
    enum ChartFilterType: Int {
        case week
        case month
        case year
    }
    
    var current_Week = 0
    var current_Month = 0
    var current_Year = 0
    
    @IBOutlet weak var progressView_steps: MKMagneticProgress!
    @IBOutlet weak var progressView_distance: MKMagneticProgress!
    
    @IBOutlet weak var lbl_todaySteps: UILabel!
    @IBOutlet weak var lbl_todayTotalSteps: UILabel!
    @IBOutlet weak var lbl_todayDistance: UILabel!
    @IBOutlet weak var lbl_todayDistance_Unit: UILabel!
    @IBOutlet weak var lbl_todayCalorie: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var sectionTitleL: UILabel!
    //@IBOutlet weak var averageStepsL: UILabel!
//    @IBOutlet weak var totalStepsL: UILabel!
//    @IBOutlet weak var totalCalorieL: UILabel!
//    @IBOutlet weak var totalDistanceL: UILabel!

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var chartTileL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var view_Main_BG: UIView!
    @IBOutlet weak var view_TodayData_BG: UIView!
    @IBOutlet weak var lbl_week: UILabel!
    @IBOutlet weak var lbl_month: UILabel!
    @IBOutlet weak var lbl_year: UILabel!
    
    @IBOutlet weak var view_Average_BG: UIView!
    @IBOutlet weak var view_Calori_BG: UIView!
    @IBOutlet weak var view_Steps_BG: UIView!
    @IBOutlet weak var view_Distance_BG: UIView!
    
    @IBOutlet weak var btn_week: UIControl!
    @IBOutlet weak var btn_month: UIControl!
    @IBOutlet weak var btn_year: UIControl!
    
    @IBOutlet weak var lbl_average: UILabel!
    @IBOutlet weak var lbl_calori: UILabel!
    @IBOutlet weak var lbl_total_step: UILabel!
    @IBOutlet weak var lbl_total_distance: UILabel!
    @IBOutlet weak var lbl_total_distance_subTitle: UILabel!
    
    
    var selectChartFilter = ChartFilterType.week
    var chartData = ARGraphDataModel(month: 0)
    var currentFilterData = ARChartFilterData()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Steps".localized()
        self.segmentSelection()
        self.view_Main_BG.backgroundColor = UIColor.white
        setBackButtonTitle()
        setupChart()
        
        NotificationCenter.default.addObserver(forName: .refreshPedometerData, object: nil, queue: nil) { [weak self] notif in
            self?.updateTodayUI()
        }
        
        updateTodayUI()
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear, .month, .year], from: date)
        self.current_Year = components.year ?? 0
        self.current_Month = components.month ?? 0
        self.current_Week = components.weekOfYear ?? 0
        
        fetchChartData()
    }
    
    func segmentSelection() {
        if self.selectChartFilter == .week {
            self.lbl_week.textColor = UIColor.white
            self.btn_month.backgroundColor = UIColor.white
            self.btn_year.backgroundColor = UIColor.white
            self.lbl_year.textColor = UIColor.fromHex(hexString: "326F2E")
            self.lbl_month.textColor = UIColor.fromHex(hexString: "326F2E")
            self.btn_week.backgroundColor = UIColor.fromHex(hexString: "326F2E")
        }
        else if self.selectChartFilter == .month {
            self.lbl_month.textColor = UIColor.white
            self.btn_week.backgroundColor = UIColor.white
            self.btn_year.backgroundColor = UIColor.white
            self.lbl_year.textColor = UIColor.fromHex(hexString: "326F2E")
            self.lbl_week.textColor = UIColor.fromHex(hexString: "326F2E")
            self.btn_month.backgroundColor = UIColor.fromHex(hexString: "326F2E")
        }
        else if self.selectChartFilter == .year {
            self.lbl_year.textColor = UIColor.white
            self.btn_week.backgroundColor = UIColor.white
            self.btn_month.backgroundColor = UIColor.white
            self.lbl_week.textColor = UIColor.fromHex(hexString: "326F2E")
            self.lbl_month.textColor = UIColor.fromHex(hexString: "326F2E")
            self.btn_year.backgroundColor = UIColor.fromHex(hexString: "326F2E")
        }
    }
    
    func updateTodayUI() {
        let data = ARPedometerManager.shared.pedometerData
        self.lbl_todaySteps.text = data.todaysData.stepCount.stringWithCommas
        self.lbl_todayTotalSteps.text = "out of \(data.goal.stringWithCommas)"

        let dic_data = ARPedometerData.distanceValueInLocal(distanceInKm: data.todaysData.distance)
        self.lbl_todayDistance.text = "\(dic_data.value)"
        self.lbl_todayDistance_Unit.text = "\(dic_data.unit)"
        
        self.lbl_todayCalorie.text = String(format: "%@", data.todaysData.calorie.stringWithCommas)

        self.progressView_steps.transform = self.progressView_steps.transform.rotated(by: .pi/2)
        self.progressView_distance.transform = self.progressView_distance.transform.rotated(by: .pi/2)
        
        self.progressView_steps.setProgress(progress: data.todayStepsProgressValue)
        self.progressView_distance.setProgress(progress: data.todayStepsProgressValue)
        
        //Set Shadow
        self.view_TodayData_BG.layer.cornerRadius = 12
        self.view_TodayData_BG.shadowColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)
        
        self.view_Average_BG.layer.cornerRadius = 12
        self.view_Average_BG.shadowColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        
        self.view_Calori_BG.layer.cornerRadius = 12
        self.view_Calori_BG.shadowColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        
        self.view_Steps_BG.layer.cornerRadius = 12
        self.view_Steps_BG.shadowColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        
        self.view_Distance_BG.layer.cornerRadius = 12
        self.view_Distance_BG.shadowColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        
        //fetchChartData()
    }
    
    @IBAction func setGoalBtnPressed(sender: UIButton) {
        showSetGoalCountAlert(from: self)
    }
    
    @IBAction func btn_Week_Action(_ sender: UIControl) {
        selectChartFilter = .week
        self.segmentSelection()
        fetchChartData()
    }
    
    @IBAction func btn_Month_Action(_ sender: UIControl) {
        selectChartFilter = .month
        self.segmentSelection()
        fetchChartData()
    }
    
    @IBAction func btn_Year_Action(_ sender: UIControl) {
        selectChartFilter = .year
        self.segmentSelection()
        fetchChartData()
    }
    
    @IBAction func segmentControlValueDidChange(_ sender: UISegmentedControl) {
        selectChartFilter = ChartFilterType(rawValue: sender.selectedSegmentIndex) ??  .week
        fetchChartData()
    }
    
    
    @IBAction func nextBtnPressed(sender: UIButton) {
        if selectChartFilter == .year {
            if chartData.year >= self.current_Year {
                return
            }
        }
        else if selectChartFilter == .month {
            if chartData.month >= self.current_Month && chartData.year >= self.current_Year {
                return
            }
        }
        else if selectChartFilter == .week {
            if chartData.weeknumber >= self.current_Week && chartData.month >= self.current_Month && chartData.year >= self.current_Year {
                return
            }
        }
        updateChartFilter(by: 1, isNext: true)
    }
    
    @IBAction func previousBtnPressed(sender: UIButton) {
        updateChartFilter(by: -1, isNext: false)
    }
}

// MARK: Chart methods
extension ARStepsDeatilsVC {
    
    func setupChart() {
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        //barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.gridColor = UIColor.app.barChart.gray
        barChartView.leftAxis.spaceBottom = 0.0
        barChartView.highlightPerTapEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        
        let components = Calendar.current.dateComponents([.month, .year, .weekOfYear], from: Date())
        if let year = components.year, let month = components.month, let week = components.weekOfYear {
            currentFilterData.year = year
            currentFilterData.month = month
            currentFilterData.week = week
        }
    }
    
    func updateChart() {
        let viewTitles = chartData.getChartViewTitles(chartFilter: selectChartFilter, filterData: currentFilterData)
        chartTileL.text = viewTitles.chartTitle
        sectionTitleL.text = viewTitles.sectionTitle
        
        self.lbl_average.text = chartData.averagedata.avgSteps.stringWithCommas
        self.lbl_calori.text = "\(chartData.averagedata.calories ?? 0)"
        self.lbl_total_step.text = chartData.averagedata.totalSteps.stringWithCommas
        
        let dic_data = ARPedometerData.distanceValueInLocal(distanceInKm: chartData.averagedata.distance)
        self.lbl_total_distance.text = "\(dic_data.value)"
        self.lbl_total_distance_subTitle.text = "\(dic_data.unit)"
        
        
        //averageStepsL.attributedText = chartData.averageStepsAttribText
        //totalStepsL.text = chartData.averagedata.totalSteps.stringWithCommas
        //totalCalorieL.attributedText = chartData.caloriesAttribText
        //totalDistanceL.attributedText = chartData.totalDistanceAttribText
        
        let titles = chartData.graphdata.compactMap{ $0.title }
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: titles)
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.labelPosition = .bottom
        
        let finalData = chartData.getBarChartData()
        let chartDataSet = BarChartDataSet(entries: finalData.dataEntries, label: "")
        chartDataSet.colors = finalData.barColors
        chartDataSet.highlightEnabled = false
        
        let cData = BarChartData(dataSet: chartDataSet)
        cData.setDrawValues(false)
        cData.barWidth = Double(0.2)
        barChartView.data = cData
        barChartView.animate(yAxisDuration: 0.35)
    }
    
    func updateChartFilter(by value: Int, isNext: Bool) {
        switch selectChartFilter {
        case .week:
            chartData.weeknumber += value
            let totalWeeks = Date.weeks(in: chartData.year)
            if chartData.weeknumber <= 0 {
                chartData.year -= 1
                let totalWeeks = Date.weeks(in: chartData.year)
                chartData.weeknumber = totalWeeks
            }
            else if chartData.weeknumber == totalWeeks {
            }
            else if chartData.weeknumber < totalWeeks {
            }
            else if chartData.weeknumber > totalWeeks {
                chartData.weeknumber = 1
                chartData.year += 1
            }
        
        case .month:
            chartData.month += value
            if chartData.month <= 0 {
                chartData.month = 12
                chartData.year -= 1
            } else if chartData.month > 12 {
                chartData.month = 1
                chartData.year += 1
            }
            
        case .year:
            chartData.year += value
        }
        
        //print(">>> weeknumber : \(chartData.weeknumber), month : \(chartData.month), year : \(chartData.year)")
        fetchChartData()
    }
}

extension ARStepsDeatilsVC {
    func showSetGoalCountAlert(from vc: UIViewController) {
        let alert = UIAlertController(title: "Set your goal".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter goal step counts".localized()
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive))
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { [weak alert] (_) in
            let value = alert?.textFields?.first?.text ?? ""
            //print("Count Value: \(value)")
            
            if !value.isEmpty, let intValue = Int(value) {
                self.updateStepGoalOnServer(goal: intValue)
            } else {
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Please enter valid step count value".localized(), okTitle: "Ok".localized(), controller: vc) {
                    self.showSetGoalCountAlert(from: vc)
                }
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}

// MARK: APIs
extension ARStepsDeatilsVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = ARStepsDeatilsVC.instantiate(fromAppStoryboard: .Pedometer)
        fromVC.navigationController?.isNavigationBarHidden = false
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
