//
//  ARBPLOximeterReaderVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 15/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import MKMagneticProgress
import CoreBluetooth
import Charts

// MARK: - Oximeter
enum BPLOximeterParams {
    static let SupportedBPLOximeterDeviceNames = ["BPL iOxy", "My Oximeter"]
    
    // services and charcteristics Identifiers
    static let HeartRateServiceUUID = CBUUID.init(string: "CDEACB80-5235-4C07-8846-93A37EE6B86D")
    static let HeartRateCharacteristicUUID = CBUUID.init(string: "CDEACB81-5235-4C07-8846-93A37EE6B86D")
    static let ClientConfigCharacteristicUUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    static func getServiceList() -> [CBUUID] {
        return [BPLOximeterParams.HeartRateServiceUUID]
    }
    
    static func getCharacteristicList() -> [CBUUID] {
        return [BPLOximeterParams.HeartRateCharacteristicUUID]
    }
}

// MARK: -
class ARBPLOximeterReaderVC: UIViewController {
    
    @IBOutlet weak var spO2L: UILabel!
    @IBOutlet weak var pulseL: UILabel!
    @IBOutlet weak var plL: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var progressView: MKMagneticProgress!
    
    var oximeterDevice: ARBleDevice?
    var heartRateChar: CBCharacteristic?
    
    var timer: Timer?
    var readingTimeInterval: TimeInterval = 0.1 //100 miliseconds
    var maxReadingTimeInterval = 30.0
    var readingStartTime = 0.0
    var currentReadingTime = 0.0
    var isDataReadingDone = false
    
    //Algo data
    var aCounter = 0
    var aSamplingFreq = 0
    var arrHeartRates = [Float]()
    
    var gData = [Float]()
    var pData = [Int]()
    var spO2Value = 0
    var pulseValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BPL Oximeter".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBleScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopReadingOximeterDevice()
        ARBleManager.shareInstance.delegate = nil
    }
    
    func setupUI() {
        progressView.setProgress(progress: 0, animated: false)
        setupChartView()
        setupBleDevice()
    }
    
    func setupBleDevice() {
        ARBleConfig.continueScan = true
        ARBleConfig.acceptableDeviceNames = BPLOximeterParams.SupportedBPLOximeterDeviceNames
        ARBleConfig.acceptableDeviceServiceUUIDs = [BPLOximeterParams.HeartRateServiceUUID.uuidString]
        ARBleManager.shareInstance.delegate = self
    }
    
    func setupChartView() {
        // enable description text
        chartView.chartDescription.enabled = true
        
        // disable touch gestures
        chartView.isUserInteractionEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        let xl = chartView.xAxis
        xl.labelTextColor = .clear
        xl.gridLineDashLengths = [4, 4]
        xl.labelPosition = .bottom
        xl.granularity = 1
        xl.granularityEnabled = true
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .clear
        leftAxis.gridLineDashLengths = [4, 4]
        leftAxis.drawGridLinesEnabled = true
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        let lineData = LineChartData()
        lineData.setValueTextColor(.black)
        
        let holoBlueColor = UIColor.fromHex(hexString: "#33B5E5")
        let dataSet = LineChartDataSet(entries: [], label: "Pulse Data".localized())
        dataSet.axisDependency = .left
        dataSet.setColor(holoBlueColor)
        dataSet.setCircleColor(.clear)
        dataSet.lineWidth = 2
        dataSet.circleRadius = 1
        dataSet.fillAlpha = 65
        dataSet.fillColor = holoBlueColor.withAlphaComponent(0.5)
        dataSet.highlightColor = holoBlueColor
        dataSet.valueTextColor = .black
        dataSet.valueFont = UIFont.systemFont(ofSize: 8)
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        // lineData.addDataSet(dataSet)
        lineData.append(dataSet)
        chartView.data = lineData
    }
    
    func startBleScanning() {
        if oximeterDevice != nil {
            ARBle_debug_log("already connected to oximeter, don't start scan")
            return
        }
        
        if isDataReadingDone {
            ARBle_debug_log("already done reading oximeter data, don't start scan")
            return
        }
        
        if ARBleManager.shareInstance.isBleEnable {
            ARBle_debug_log("scanning ...")
            ARBleManager.shareInstance.scanForDevices()
        } else {
            ARBle_debug_log("Bluetooth is OFF")
        }
    }
    
    func updateUI(spO2: Int, pi: Float, pluse: Int) {
        spO2L.text = "\(spO2)%"
        pulseL.text = String(pluse)
        plL.text = String(format: "%.1f", pi)
    }
    
    deinit {
        DebugLog("-")
        stopReadingOximeterDevice()
    }
}

extension ARBPLOximeterReaderVC {
    func processOnOximterData(_ data: [UInt8]) {
        ARBle_debug_log("did rececive data : \(data), count : \(data.count)")
        let packageType = data[0]
        if packageType == 128 {
            //1. Flag information ( send one datagram every 200 MS, each has 11 bytes data)
            /*
             Byte0:0x80(package type bit0=0，bit1=0.)
             Byte1:flag 1
             Byte2:flag2
             ......
             Byte10: flag10
             */
            if currentReadingTime > 0 { //added to fix infinite or NaN value
                aCounter += 1
                aSamplingFreq = Int(Double(aCounter) / currentReadingTime) //calculating sampling frequency
                //ARBle_debug_log(">> aSamplingFreq : \(aSamplingFreq)")
            }
            
            for (index, value) in data.enumerated() where index != 0 { //ignore 0 index value bcoz its just package type
                
                let dataValue = Float(value)
                gData.append(dataValue)
                
                //Update data on chart view
                let lineData = chartView.data ?? LineChartData()
                let dataSet = lineData.dataSets.first ?? LineChartDataSet()
                let chartEntry = ChartDataEntry(x: Double(dataSet.entryCount), y: Double(dataValue))
                lineData.appendEntry(chartEntry, toDataSet: 0)

                //lineData.addEntry(chartEntry, dataSetIndex: 0)
                lineData.notifyDataChanged()
                
                chartView.notifyDataSetChanged()
                chartView.setVisibleXRangeMaximum(150)
                chartView.moveViewToX(Double(lineData.entryCount))
            }
            
            //FOR TALA
            //if gData.count % 30 == 0 {
            if currentReadingTime >= 15 && currentReadingTime <= 25 {
                let hr = HeartRateDetectionModel.getMeanHR(gData, time: 0)
                arrHeartRates.append(hr)
                //ARBle_debug_log(">> HEART RATE = \(hr)")
            }
            
            /*if currentReadingTime >= 15 && currentReadingTime <= 25 {
                try {
                    Double[] aRed_HR = gData.toArray(new Double[gData.size() - 1]);
                    int HRFreq = acomputeAlgo.HRCalculationAlgo(aRed_HR, aSamplingFreq, acounter, 6, 0.5);
                    HRPS.add(HRFreq);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }*/
            
        } else if packageType == 129, data.count >= 4 {
            //2. Information of SPO2 and PR (each datagram was sent per second, each has 4 bytes data)
            /*
             Byte0:0x81(package type bit0=1, bit1=0.)
             byte1: PR bit0--­7
             byte2: SPO2
             byte3: PI index
             
             Data signification:
             
             SPO2(SpO2, unit %): 35--­100,
             127 is invalid value.
             Invalid value can be showed as`--­--­--­'
             
             PR(pulse rate, unit bpm):25--­250,
             255 is invalid value.
             
             flag(Plethysmogram, without unit):0--­100,
             127 is invalid value.
             Invalid value can be showed in the centralpositon.
             
             PI index 0--­200
             0 is invalid value.
             */
            pulseValue = Int(data[1])
            spO2Value = Int(data[2])
            let pi = (Float(data[3]) * 10)/100
            
            if !isTimerStarted && !isDataReadingDone {
                if spO2Value != 127, pulseValue != 255, pi != 0 {
                    startTimer()
                }
            } else {
                if spO2Value == 127 || pulseValue == 255 || pi == 0 {
                    stopProcessOnOximterData(isError: true)
                } else if spO2Value <= 0 || spO2Value > 100 {
                    updateUI(spO2: 0, pi: 0, pluse: 0)
                } else if isTimerStarted {
                    pData.append(pulseValue)
                    updateUI(spO2: spO2Value, pi: pi, pluse: pulseValue)
                }
            }
        }
    }
    
    func stopProcessOnOximterData(isError: Bool = false) {
        stopReadingOximeterDevice()
        //Reset values
        //updateUI(spO2: 0, pi: 0, pluse: 0)
        if isError {
            showDataReadingErrorAlert()
        }
    }
    
    func showDataReadingErrorAlert() {
        let title = "Unable to capture data\nProbable causes:".localized()
        let message = "1. Finger not placed properly\n2. Finger is removed from oximeter".localized()
        Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok".localized(), controller: self) {
            DispatchQueue.delay(.milliseconds(100), closure: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func calculateResult() {
        DebugLog("--> last aSamplingFreq : \(aSamplingFreq)")
        DebugLog("--> aCounter : \(aCounter)")
        DebugLog("--> sample data count[\(gData.count)] : \(gData)")
        DebugLog("--> pulse data count[\(pData.count)] : \(pData)")
        DebugLog("--> arrHeartRates[\(arrHeartRates.count)] : \(arrHeartRates), ")
        
        let sparshnaAlgo = ARSparshnaAlgo()
        sparshnaAlgo.arrRed = gData
        sparshnaAlgo.arrGreen = gData
        sparshnaAlgo.arrBlue = gData
        sparshnaAlgo.arrHeartRates = arrHeartRates
        sparshnaAlgo.count = aCounter
        sparshnaAlgo.spO2Value = spO2Value
        sparshnaAlgo.aSamplingFreq = aSamplingFreq
        sparshnaAlgo.oximeterPulseArray = pData
        sparshnaAlgo.fromVC = self
        sparshnaAlgo.processSparshnaLogic()
    }
}

extension ARBPLOximeterReaderVC {
    var isTimerStarted: Bool {
        return (timer != nil)
    }
    
    func startTimer() {
        stopTimer()
        readingStartTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: readingTimeInterval,
                                     target: self,
                                     selector: #selector(timerFire(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFire(timer: Timer) {
        //Total time since timer started, in seconds
        currentReadingTime = Date().timeIntervalSinceReferenceDate - readingStartTime
        ARBle_debug_log(">>> timer currentReadingTime : \(String(format: "%.2f", currentReadingTime))")
        
        let progress = currentReadingTime/maxReadingTimeInterval
        progressView.setProgress(progress: progress)
        
        //The rest of your code goes here
        if currentReadingTime >= maxReadingTimeInterval {
            isDataReadingDone = true
            stopProcessOnOximterData()
            calculateResult()
        }
    }
}

extension ARBPLOximeterReaderVC: ARBleManagerDelegate {
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState) {
        ARBle_debug_log("status change : \(state)")
    }
    
    func manager(_ manager: ARBleManager, didScan device: ARBleDevice) {
        ARBle_debug_log("scanned oximeter : \(device.name)")
        oximeterDevice = device
        ARBleManager.shareInstance.connectDevice(device)
    }
    
    func managerDidScanTimeout(_ manager: ARBleManager) {
        ARBle_debug_log("scan timeout")
    }
    
    func manager(_ manager: ARBleManager, didConnect device: ARBleDevice) {
        ARBle_debug_log("oximeter did connect : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, didConnectTimeout device: ARBleDevice) {
        ARBle_debug_log("connect timeout : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, didFailToConnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did fail to connect : \(device.name), error: \(error?.localizedDescription ?? "-")")
    }
    
    func manager(_ manager: ARBleManager, didDisconnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did disconnect : \(device.name), error: \(error?.localizedDescription ?? "-")")
    }
    
    func manager(_ manager: ARBleManager, didReceiveAdvertisementData data: Data) {
        let finalData = [UInt8](data)
        ARBle_debug_log("did rececive adv data : \(finalData), count : \(finalData.count)")
    }
    
    func manager(_ manager: ARBleManager, deviceDidReady device: ARBleDevice) {
        ARBle_debug_log("oximeter did ready : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        ARBle_debug_log("did discover characteristics for service : \(service.uuid.uuidString)")
        guard let oximeterDevice = oximeterDevice, oximeterDevice.uuid == device.uuid else { return }
        
        if let char = device.allCharacteristics.first(where: { $0.uuid == BPLOximeterParams.HeartRateCharacteristicUUID }) {
            heartRateChar = char
            oximeterDevice.setNotification(for: char, enable: true)
        }
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?) {
        guard let data = value, !data.isEmpty else { return }
        DispatchQueue.main.async {
            self.processOnOximterData([UInt8](data))
        }
    }
    
    func stopReadingOximeterDevice() {
        stopTimer()
        if let oximeterDevice = oximeterDevice {
            if oximeterDevice.peripheral?.state == .connected {
                oximeterDevice.setNotification(for: heartRateChar, enable: false)
            }
            ARBleManager.shareInstance.disonnectDevice(oximeterDevice)
        }
        oximeterDevice = nil
        ARBleManager.shareInstance.stopScan()
    }
}

extension ARBPLOximeterReaderVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = ARBPLOximeterReaderVC.instantiate(fromAppStoryboard: .BPLDevices)
        if let fromVC = fromVC as? UINavigationController {
            fromVC.pushViewController(vc, animated: true)
        } else {
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
