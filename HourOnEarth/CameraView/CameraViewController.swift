//
//  CameraViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/29/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import Accelerate


protocol CameraViewDelegate: class {
    func cameraFailure()
}

class CameraViewController: BaseViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var order = 4.0
    var cutoffFrequency1 = 0.5
    var cutoffFrequency2 = 4.1
    var arr_ModelName = ["iPhone 6 Plus", "iPhone 6", "iPhone 6s Plus", "iPhone 6s", "iPhone SE", "iPhone 7 Plus", "iPhone 7", "iPhone 8 Plus", "iPhone 8", "iPhone X", "iPhone XR", "iPhone XS Max", "iPhone XS"]
    
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cameraText: UIImageView!
    @IBOutlet weak var view_animationLoad: UIView!
    @IBOutlet weak var lbl_infoText: UILabel!
    @IBOutlet weak var img_Infoanimation: UIImageView!
    
    //For Debug only
    @IBOutlet weak var debugView: UIView!
    @IBOutlet weak var debugL: UILabel!
    //set this variable true to show debug RGB value while doing sparshna and also show alert to enter custom maxRedValue
    var isDebugOn = false
    
    var progressRing: CircularProgressBar?
    weak var delegate: CameraViewDelegate?
    let FRAMES_PER_SECOND = 30
    
    var captureDevice:AVCaptureDevice? = nil
    let captureSession = AVCaptureSession()
    var count = 0
    
    var arrRed:[Float] = [Float]()
    var arrGreen:[Float] = [Float]()
    var arrBlue:[Float] = [Float]()
    var arraverage_Red:[Float] = [Float]()
    var arraverage_Red_Double:[Double] = [Double]()
    var arrHuePoints:[Float] = [Float]()
    var arrHeartRates:[Float] = [Float]()
    
    var dic_vikriti_params = [String: Any]()
    var str_facenaadi_sparshna_result = ""
    var str_facenaadi_graphParamsStringValue = ""
    
    
    var dAge = 0.0
    var dHei: Double = 1.0
    var dWei: Double = 1.0
    var demo_user_name = ""
    var maxRedValue = 210.0
    
    var isMale = true
    var Q = 0.0
    
    var ppgDataServer_double:[Double] = [Double]()
    var ppgDataServer:[String] = [String]()
    var fftDataServer:[String] = [String]()
    var newFFT = FFT()
    var isFingerPlaced = true
    var isFingerCheckEnable = true
    var timer: Timer?
    var isTalaRegular = false
    
    var start_TimeStampInSec: Int64 = 0
    var end_TimeStampInSec: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_animationLoad.isHidden = true
        self.img_Infoanimation.image = UIImage.gifImageWithName("sparshna_loader")
        self.lbl_infoText.text = "Personalizing your content".localized()
        
        self.debugView.isHidden = true
        if dAge == 0.0 {
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                let dob = empData["dob"] as! String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                if let birthday = dateFormatter.date(from: dob) {
                    let ageComponents = Calendar.current.dateComponents([.year], from: birthday, to: Date())
                    dAge = Double(ageComponents.year ?? 0)
                }
                
                if let measurement = empData["measurements"] as? String {
                    let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
                    if arrMeasurement.count >= 2 {
                        dHei = Double(arrMeasurement[0].replacingOccurrences(of: "\"", with: ""))!
                        dWei = Double(arrMeasurement[1].replacingOccurrences(of: "\"", with: ""))!
                    }
                }
            } else {
                if let height = kUserDefaults.value(forKey: "Height") as? Double {
                    dHei = height
                }
                
                if let weight = kUserDefaults.value(forKey: "Weight") as? Double {
                    dWei = weight
                }
                
                isMale = kUserDefaults.bool(forKey: "isMale")
                
                if let userAge = kUserDefaults.value(forKey: "Age") as? Double {
                    dAge = userAge
                }
            }
        } else {
            dAge = 1.0
        }
        
        Q = isMale ? 5.0 : 4.5
        
        //Camera permission setUp
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            print("CAMERA - AUTHORIZED")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setUpCamera()
                print("CAMERA - SETUP DONE")
                self.start_TimeStampInSec = self.getCurrentMillis()
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateProgressValue), userInfo: nil, repeats: true)
            }
            
        } else {
            print("CAMERA - NOT AUTHORIZED")
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    print("CAMERA - GRANTED")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.setUpCamera()
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateProgressValue), userInfo: nil, repeats: true)
                    }
                    
                } else {
                    // User rejected
                    DispatchQueue.main.async {
                        print("CAMERA - REJECTED")
                        self.showCameraAccessDeniedAlert()
                    }
                }
            })
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.captureDevice = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: === PROGRESS COMPLETED
    @objc func updateProgressValue() {
        if !isFingerPlaced && isFingerCheckEnable {
            return
        }
        count += 1
        progressView.progress = Float(count) / 32.0
        progressRing?.progress = CGFloat(Int(Float(count*100) / 32.0))
        
        //STOP AND MOVE TO NEXT SCREEN
        if count == 32 {
            self.stopCamera()
            if self.timer?.isValid ?? false {
                self.timer?.invalidate()
                self.timer = nil
            }
            
            #if !APPCLIP
            appDelegate.sparshanAssessmentDone = true
            #endif
            self.view_animationLoad.isHidden = false
            self.view.bringSubviewToFront(self.view_animationLoad)
            
            self.end_TimeStampInSec = self.getCurrentMillis()
            
            //AMRK: - Internal Algo
            var acounter = arrRed.count ;
            let sampleFrequency = acounter / 30
            
            let ignoreTime = 4//Float(ignoreSamples/sampleFrequency)
            
            // Ignore 120 samples from the beginning
            let ignoreSamples = ignoreTime * sampleFrequency ;
            
            var NaRed: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
            for z in ignoreSamples..<acounter  {
                NaRed[z - ignoreSamples] = Double((-1) * arrRed[z]);
                
            }
            
            acounter = acounter - ignoreSamples ;
            
            //Remove in PPG Data
            var NaPPG: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
            for z in ignoreSamples..<acounter  {
                NaPPG[z - ignoreSamples] = Double((-1) * ppgDataServer_double[z]);
            }
            //******************//
            
            
            //BUTTER WORTH
            let aRed_HR_ButterWorth: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(NaRed) as! [Double]
            
            /****************INVERSE FFT ON BUTTERWORTH*********************/
            
            let invFFT: [Double] =  newFFT.invCalculate(aRed_HR_ButterWorth, fps: Double(sampleFrequency))
            
            /**************************************/
            
            let arrFilteredData: [Double] = newFFT.calculate(invFFT, fps: Double(sampleFrequency))
            
            /***** For respiratory rate and gati , please use the raw signal not this filtered butterworth.  ****/
            //get the peak data ---
            //MARK: == GATI
            let gati_index = self.GatiCalculationAlgo(fft_gati: aRed_HR_ButterWorth, SamplingRate: sampleFrequency, numFrame: acounter)
            
            let fftDataForKPV = newFFT.calculate(NaRed, fps: Double(sampleFrequency))
            let absFftDataForKPV = fftDataForKPV.map({abs($0)})
            
            var kapha = 0.0
            var pitta = 0.0
            var vata = 0.0
            //KAPHA
            //let frequencyResolution = (Double(sampleFrequency) * 0.5)/Double(fftDataForKPV.count)
            
            let frequencyResolution = (Double(sampleFrequency) * 1.0)/Double(fftDataForKPV.count)
            
            let lowerIndex = Int(0.8 / frequencyResolution)
            let upperIndex = Int(1.16 / frequencyResolution)
            let subArray = absFftDataForKPV[lowerIndex..<upperIndex]
            let frequencyDiff = 1.16 - 0.8
            kapha = subArray.reduce(0, +)/frequencyDiff
            
            let lowerIndexP = Int(1.16 / frequencyResolution)
            let upperIndexP = Int(1.33 / frequencyResolution)
            let subArrayP = absFftDataForKPV[lowerIndexP..<upperIndexP]
            let frequencyDiffP = 1.33 - 1.16
            pitta = subArrayP.reduce(0, +)/frequencyDiffP
            
            let lowerIndexV = Int(1.33 / frequencyResolution)
            let upperIndexV = Int(1.6 / frequencyResolution)
            let subArrayV = absFftDataForKPV[lowerIndexV..<upperIndexV]
            let frequencyDiffV = 1.6 - 1.33
            vata = subArrayV.reduce(0, +)/frequencyDiffV
            
            var gatiType = ""
            if gati_index >= 0.8 && gati_index <= 1.16  {
                gatiType = "Kapha"
                
            }
            if gati_index > 1.16 && gati_index <= 1.33 {
                gatiType = "Pitta"
            }
            if gati_index > 1.33 && gati_index <= 1.6 {
                gatiType = "Vata"
            }
            print("GATI TYPE === \(gatiType)")
            
            //MARK: == RYTHM
            //s  let aRed_HR = aRed_HR_ButterWorth.compactMap({return $0 < 1 ? $0 : -1 * $0})
            
            //let aRed_HR = NaRed.compactMap({return -1 * (HeartRateDetectionModel.butterworthBandpassFilter([$0]) as! [Double]).first!})
            
            //TETSED  let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]
            
            //   PASS
            let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]
            
            
            //PREVIOUS USING BELOW ONE
            //  PASS
            //let mean_HR = arrHeartRates.last ?? 0.0 //HeartRateDetectionModel.getMeanHR(aRed_HR_ButterWorthHue, time: Float(actualTime))
//            let mean_HR = HeartRateDetectionModel.getMeanHR(aRed_HR_ButterWorthHue, time: Float(sampleFrequency))

            //Temp New Function for Cal HR
            var ppg_data = [Double]()
            let filterd_value = butterworthBandpassFilter(signal: NaRed)
            debugPrint("NEW filterd_value===>>", filterd_value)
            for filterValue in filterd_value {
                ppg_data.append(filterValue[0])
            }

            var mean_HR = HeartRateDetectionModel.getMeanHR(ppg_data, time: Float(sampleFrequency))
//            let mean_HR_2 = self.HRCalculationAlgo(ppgFiltData: ppg_data, samplingRate: Double(sampleFrequency), numFrame: Double(ppg_data.count), winSec: 6, winSlideSec: 0.5)
//            let mean_HR_3 = self.HRCalculationAlgo_AsPerAndroid(ppgFiltData: ppg_data, samplingRate: Double(sampleFrequency), winSec: 6, winSlideSec: 0.5)
//            debugPrint(mean_HR_1, mean_HR_2, mean_HR_3)
            
            //*****************************************************************//
            //Temp logic for matching Oximeter as per saying Ram Sir Abhilesh Sir
            mean_HR = mean_HR - 7
            //*****************************************************************//
            
            //========//
            var red_data = ""
            for red in self.arrRed {
                red_data = red_data + "\(red) "
            }
            debugPrint("Red Data in Strign=====>>\(red_data)")
            
//            var double_red_data = [Double]()
//            for red in self.arrRed {
//                double_red_data.append(Double(red))
//            }
            // Example usage
//            let normalizedData = normalize(data: double_red_data)
//            let filteredData = removeOutliers(data: normalizedData, threshold: 2.0)
            //let bandpassFilteredData = bandpassFilter(data: filteredData, lowFrequency: 0.5, highFrequency: 5.0, sampleRate: 20.0)

//            let bandpassFilteredData: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(filteredData) as! [Double]

//            let peaks = detectPeaks(data: bandpassFilteredData)

//            let heartRate = calculateHeartRate(peaksCount: peaks.count, timeInSeconds: Double(double_red_data.count) / 30.0)

//            print("Heart Rate: \(heartRate) beats per minute")
            
//            var filteredData = removeOutliers(data: red_data)
//            let maxp = filteredData.max() ?? 0
//            let minp = filteredData.min() ?? 0
//            let diff = maxp - minp
//
//            let peaks = findPeaks(red_data: red_data, delta: 0.1, threshold: diff)
//            print("Peaks found at indices:", peaks)

//            var ppgSignal = filteredData

//            var peaks = [Int]()
//            for (index, value) in ppgSignal.enumerated() {
//                if index > 0 && index < ppgSignal.count - 1 {
//                    if value > ppgSignal[index - 1] && value > ppgSignal[index + 1] && value > diff {
//                        peaks.append(index)
//                    }
//                }
//            }

//            let bpm = peaks.count * 2
//            debugPrint("The heart rate is", bpm)
           
//            let newMean = self.getMeanHR(redValues: self.arrRed)
            
            /** NEWTEST*/
            
            //let doubleHue = arrHuePoints.compactMap({Double($0)})
            
            //let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(doubleHue) as! [Double]
            
            //let mean_HR = HeartRateDetectionModel.getMeanHR(aRed_HR_ButterWorthHue, time: Float(sampleFrequency))
            
            
            /***/

            self.callAPIforGetHR(str_RedData: red_data, completion: { success, meanHeartRate, str_gati  in
                if success {
                    if meanHeartRate != 0 {
                        mean_HR = meanHeartRate ?? mean_HR
                        gatiType = str_gati ?? gatiType
                    }
                }
                self.localAlgorythm_calculations(kapha: kapha, pitta: pitta, vata: vata, counter: acounter, sampleFrequency: sampleFrequency, mean_HR: mean_HR, NaRed: NaRed, ignoreSamples: 6, arrFilteredData: arrFilteredData, gatiType: gatiType)
            })

        }
    }
    
    func localAlgorythm_calculations(kapha: Double, pitta: Double, vata: Double, counter: Int, sampleFrequency: Int, mean_HR: Float, NaRed: [Double], ignoreSamples: Int, arrFilteredData: [Double], gatiType: String) {

        let Rythm = self.getTalaValue()
        
        //MARK: == RR(Respiratory Rate)
        let rr = self.FFT2(input: NaRed, samplingFrequency: sampleFrequency, sizeOld: counter)
        let RR_red = ceil(60.0 * rr) ;
        print(RR_red)
        let mean_RR = Int(RR_red)
        let acounter = counter + ignoreSamples ;
        
        //calculating the mean of red and blue intensities on the whole period of recording
        let meanr = arrRed.reduce(0, +) / Float(acounter)
        let meanb = arrBlue.reduce(0, +) / Float(acounter);
        
        //calculating the standard  deviation
        var Stdb: Float = 0.0
        var Stdr: Float = 0.0
        for i in 0..<acounter - 1 {
            let bufferb = arrBlue[i];
            Stdb = Stdb + ((bufferb - meanb) * (bufferb - meanb));
            
            let bufferr = arrRed[i];
            Stdr = Stdr + ((bufferr - meanr) * (bufferr - meanr));
            
        }
        
        //calculating the variance
        let varr = sqrt(Stdr / Float(acounter - 1));
        let varb = sqrt(Stdb / Float(acounter - 1));
        
        //calculating ratio between the two means and two variances
        let R = (varr / meanr) / (varb / meanb);
        
        //estimating SPo2
        let spo2 = 100 - 5 * (R)
        
        //let o2 = spo2
        
        //MARK: - SPO2 Logic
        let slope = 0.5
        let intercept = 95.0

        // Use a linear equation or any other correlation formula
        var estimatedSpo2 = Int(slope * Double(mean_HR) + intercept)
        // Ensure the estimated SpO2 is within valid range (0-100%)
        if estimatedSpo2 > 100 {
            estimatedSpo2 = 99
        }
        else {
            estimatedSpo2 = Int(spo2)
        }
        //******************************//
        //******************************//
        let o2 = estimatedSpo2
        //************************************************************//
        //************************************************************//
        //************************************************************//
        
        
        //MARK: == BMI and BMR
        let total = ((dHei / 100) * (dHei / 100))
        let BMI = (dWei / (total <= 0 ? 1 : total));
        //let BMR = (66 + (13.7 * dWei) + (5 * dHei) - (6.8 * dAge));
        
        var BMR = 10*dWei + 6.25*dHei - 5*dAge + 5
        if kUserDefaults.isGenderFemale {
            BMR = 10*dWei + 6.25*dHei - 5*dAge - 161
        }
        
        // BP calculation
        let meanHRInt = Double(Int(mean_HR))
        let ROB = 18.5;
        let ET = (364.5 - 1.23 * meanHRInt);
        let BSA = 0.007184 * (pow(dWei, 0.425)) * (pow(dHei, 0.725));
        let temp = Double(0.62 * meanHRInt) - Double(40.4 * BSA)
        let temp2 = Double(-6.6 + (0.25 * (ET - 35)))
        let SV = temp2 - temp - Double(0.51 * dAge);
        let sTemp1 = Double(0.007 * dAge) + Double(0.004 * meanHRInt)
        let sTemp = Double(0.013 * dWei) - sTemp1
        let PP = SV / (sTemp + 1.307);
        let MPP = Q * ROB;
        let fraction = Int(3.0 / 2.0)
        let SP = Int(MPP + Double(fraction) * PP);
        let DP = Int(Double(MPP) - PP / 3);
        
        //MARK == Kathinya Calculation
        let t_pulse: Double = Double(60.0 / mean_HR);
        let kathinya = (dHei / t_pulse);
        
        //MARK == Bala - diff og SP and DP
        let bala = SP - DP;
        

        /************************
         CALCULATION FOR SENDING IN API
         *************************/
        let fs = Double(sampleFrequency) / 2.0
        let step = Double(fs / Double(acounter))
        
        let min_freq = 0.5
        let max_freq = 2.0
        
        let low_count = Int(min_freq / step)
        let hi_count = Int(max_freq / step)
        
        var cnt = Int(low_count);
        var value = min_freq;
        
        var g = 0;
        
        var running_avg_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: acounter / 3 - 1);
        
        while (cnt < hi_count) {
            running_avg_gati[g][0] = (arrFilteredData[cnt] + arrFilteredData[cnt + 1] + arrFilteredData[cnt + 2]) / 3.0;
            let data = "{" + "\(value)" + "," + "\(running_avg_gati[g][0])" + "}";
            fftDataServer.append(data)
            
            running_avg_gati[g][1] = value;
            value = value + 3 * step;
            cnt += 3;
            g += 1;
        }
        /******************************/
        
        //MARK: CALCULATE KPV
        var kaphaOld = 0.0
        var pittaOld = 0.0
        var vataOld = 0.0

        if (mean_HR <= 70) {
            kaphaOld += 1;
        } else if (mean_HR > 70 && mean_HR < 80) {
            pittaOld += 1
        } else {
            vataOld += 1
        }

        if (SP <= 90) {
            vataOld += 1;
        } else if (SP>90 && SP<=120) {
            pittaOld += 1;
        }
        else if (SP>120) {
            kaphaOld += 1;
        }

        if (DP<=60) {
            vataOld += 1;
        } else if (DP>60 && DP<=80) {
            pittaOld += 1;
        }
        else if (DP>80) {
            kaphaOld += 1;
        }

        //Tala
        if !isTalaRegular {
            vataOld += 1;
        }
        
        if (bala<=30) {
            vataOld += 1;
        } else if (bala>40) {
            pittaOld += 1;
        } else if (bala>30 && bala<=40) {
            kaphaOld += 1;
        }

        if (kathinya>310) {
            vataOld += 1;
        } else if (kathinya<210) {
            pittaOld += 1;
        } else if (kathinya>=210 && kathinya<=310) {
            kaphaOld += 1;
        }

        //If less than 5 min test ignore it
        if let lastAssessmentDate = kUserDefaults.value(forKey: LAST_ASSESSMENT_DATE) as? String {
            if let lastAssessment = Utils.getDateFromString(lastAssessmentDate, format: "yyyy-MM-dd HH:mm:ss") {
                if let diffInMinutes = Calendar.current.dateComponents([.minute], from: lastAssessment, to:Date() ).minute, diffInMinutes < 5 {
                    //if less then 5 min - show saved results

                    if UserDefaults.user.is_finger_subscribed == false {
                        let free_done_count = UserDefaults.user.finger_assessment_trial + 1
                        UserDefaults.user.set_finger_trialCount(data: free_done_count)
                    }
                    
                    LastAssessmentVC.showScreen(fromVC: self)
                    return
                }
            }
        }
        
        
        var sparshnaValue = ""
        
        let totalGatiKPV = kapha + pitta + vata
        let gatiKPercentage = (kapha * 100.0)/totalGatiKPV
        let gatiPPercentage = (pitta * 100.0)/totalGatiKPV
        let gatiVPercentage = (vata * 100.0)/totalGatiKPV
        
        var vataKPercentage = 0.0
        var vataPPercentage = 0.0
        var vataVPercentage = 0.0
                   
        
        if isTalaRegular { //6
            let totalVataKPV = kaphaOld * 154 + pittaOld * 154 + vataOld * 154
            vataKPercentage = Double((kaphaOld * 154 * 100)/totalVataKPV)
            vataPPercentage = Double((pittaOld * 154 * 100)/totalVataKPV)
            vataVPercentage = Double((vataOld * 154 * 100)/totalVataKPV)
             
            //commented for oximeter to put 75% weightage for gati KPV Percentage
            //sparshnaValue = "\(gatiKPercentage + vataKPercentage),\(gatiPPercentage + vataPPercentage ),\(gatiVPercentage + vataVPercentage)"
            sparshnaValue = "\((gatiKPercentage*0.75) + (vataKPercentage*0.25))" + "," +
                            "\((gatiPPercentage*0.75) + (vataPPercentage*0.25))" + "," +
                            "\((gatiVPercentage*0.75) + (vataVPercentage*0.25))"
            kUserDefaults.set(sparshnaValue, forKey: VIKRITI_SPARSHNA)
        } else { //7
            let totalVataKPV = kaphaOld * 132 + pittaOld * 132 + vataOld * 132
            vataKPercentage = Double((kaphaOld * 132 * 100)/totalVataKPV)
            vataPPercentage = Double((pittaOld * 132 * 100)/totalVataKPV)
            vataVPercentage = Double((vataOld * 132 * 100)/totalVataKPV)
            
            //commented for oximeter to put 75% weightage for gati KPV Percentage
            //sparshnaValue = "\(gatiKPercentage + vataKPercentage),\(gatiPPercentage + vataPPercentage ),\(gatiVPercentage + vataVPercentage)"
            sparshnaValue = "\((gatiKPercentage*0.75) + (vataKPercentage*0.25))" + "," +
                            "\((gatiPPercentage*0.75) + (vataPPercentage*0.25))" + "," +
                            "\((gatiVPercentage*0.75) + (vataVPercentage*0.25))"
            kUserDefaults.set(sparshnaValue, forKey: VIKRITI_SPARSHNA)
        }
        
        
        let str_vikriti_result = "[" + Utils.getVikritiValue() + "]"
        let str_prakriti_result = "[" + Utils.getPrakritiValue() + "]"
        
        let tbpm: Int = Int(arrHeartRates.last ?? 0.0)
        
        var sparshnaResults = ""
        let sparshnaDic = ["bpm": Int(mean_HR), "sp": Int(SP),"dp": Int(DP), "rythm": Rythm, "bala": Int(bala), "kath": Int(kathinya), "gati": "\(gatiType)", "o2r": Int(o2), "pbreath": mean_RR, "bmi": BMI, "bmr": Int(BMR), "tbpm": tbpm] as [String : Any]
        //TODO: need to check tbpm in android -- why used ??
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sparshnaDic, options: JSONSerialization.WritingOptions.prettyPrinted)
            sparshnaResults = String(bytes: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error)
        }

        let dic_graphParam = ["counter": acounter,
                              "SamplingFreq": sampleFrequency,
                              "Red_HR": arrRed.jsonStringRepresentation ?? "",
                              "fft_gati": arrFilteredData.jsonStringRepresentation ?? ""] as [String: Any]
        let graphParamsStringValue = dic_graphParam.jsonStringRepresentation ?? ""
        
        ARLog(">> Internal algo Vikriti Presentage: \n \(str_vikriti_result)")
        ARLog(">> Internal algo Prakriti Presentage: \n \(str_prakriti_result)")
        ARLog(">> Internal algo sparshnaResults: \n \(sparshnaResults)")
        ARLog(">> Internal algo sparshnaValue: \n \(sparshnaValue)")
        ARLog(">> Internal algo graphParamsStringValue: \n \(graphParamsStringValue)")
        ARLog(">> Internal algo arrHeartRates[\(arrHeartRates.count)] : \n \(arrHeartRates)")

        if UserDefaults.user.is_finger_subscribed == false {
            let free_done_count = UserDefaults.user.finger_assessment_trial + 1
            UserDefaults.user.set_finger_trialCount(data: free_done_count)
        }
        
        self.dic_vikriti_params = sparshnaDic
        self.str_facenaadi_sparshna_result = sparshnaResults
        self.str_facenaadi_graphParamsStringValue = graphParamsStringValue
        
        
        //MARK: - CallAPI for Get Vikriti
        self.callAPIforVikritiPredictioPythonAPI(vikriti_values: str_vikriti_result, prakriti_values: str_prakriti_result) { success, vikriti_pred  in
            if success {
                
                var d_kapha_V = 0.0
                var d_pitta_V = 0.0
                var d_vata_V = 0.0
                var str_v_presendtage = (vikriti_pred?.agg_kpv ?? "").trimed()
                if str_v_presendtage != "" {
                    str_v_presendtage = str_v_presendtage.replacingOccurrences(of: "[", with: "")
                    str_v_presendtage = str_v_presendtage.replacingOccurrences(of: "]", with: "")
                    str_v_presendtage = str_v_presendtage.replacingOccurrences(of: ",", with: "")
                    let arr_v = str_v_presendtage.components(separatedBy: " ")
                    if arr_v.count == 3 {
                        d_kapha_V = Double(arr_v[0].trimed()) ?? 0
                        d_pitta_V = Double(arr_v[1].trimed()) ?? 0
                        d_vata_V = Double(arr_v[2].trimed()) ?? 0
                    }
                }
                
                let str_vik = "[\(d_kapha_V), \(d_pitta_V), \(d_vata_V)]"
                
#if !APPCLIP
                appDelegate.cloud_vikriti_status = vikriti_pred?.type ?? ""
#endif

                debugPrint("str_vikriti_result========>>\(str_vikriti_result)")
                
                
                //MARK: - Upload sprashna Data on server
                Self.callAPIforUpdateGraphaperAPI_forSparshna(vikrati_value: str_vik, sparshnaResult: sparshnaResults, graphParams: graphParamsStringValue, fromVC: self) { success in
                    if success {
                        Self.postSparshan_Assessment_Data(vikriti_value: str_vik, fromVC: self)
                        Self.uploadMeasumentDataOnServer(graphParams: graphParamsStringValue, sparshnaResult: sparshnaResults, fromVC: self)
                    }
                }
            }
        }
        
        
        
        
        
        
    }
    
    func callAPIforGetHR(str_RedData: String, completion: @escaping (_ success: Bool, _ meanHeartRate: Float?, _ gati: String?)->Void) {
        if Utils.isConnectedToNetwork() {

            let parameters = "{\n    \"ppg\": \"\(str_RedData)\"\n}"
            let postData = parameters.data(using: .utf8)

            var request = URLRequest(url: URL(string: kAPIforHeartRate)!,timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            request.httpMethod = "POST"
            request.httpBody = postData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data else {
                        print(String(describing: error))
                        completion(false, nil, nil)
                        return
                    }
                    var HR: Float = 0.0
                    var gati_data = ""
                    print(String(data: data, encoding: .utf8)!)
                    if let dic_json = self.dataToJSON(data: data) as? [String: Any] {
                        HR = Float(dic_json["Heart_Rate"] as? Int ?? 0)
                        gati_data = dic_json["gati_index"] as? String ?? "Kapha"
                    }
                    completion(true, HR, gati_data)
                }
            }

            task.resume()
        }
        else {
            completion(false, nil, nil)
        }
    }
    
    func dataToJSON(data: Data) -> Any? {
       do {
           return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
       } catch let myJSONError {
           print(myJSONError)
       }
       return nil
    }
    
    func normalize(data: [Double]) -> [Double] {
        let maxVal = data.max() ?? 0
        let normalizedData = data.map { $0 / maxVal }
        return normalizedData
    }

    func removeOutliers(data: [Double], threshold: Double) -> [Double] {
        let mean = data.reduce(0, +) / Double(data.count)
        let stdDev = sqrt(data.map { pow($0 - mean, 2) }.reduce(0, +) / Double(data.count))
        let filteredData = data.filter { abs($0 - mean) <= threshold * stdDev }
        return filteredData
    }

    func detectPeaks(data: [Double]) -> [Int] {
        var peaks: [Int] = []
        for i in 1..<(data.count - 1) {
            if data[i] > data[i - 1] && data[i] > data[i + 1] {
                peaks.append(i)
            }
        }
        return peaks
    }

    func calculateHeartRate(peaksCount: Int, timeInSeconds: Double) -> Double {
        let heartRate = Double(peaksCount) / timeInSeconds * 60.0
        return heartRate
    }

    
    
    
    
    
//    func findPeaks(red_data: [Double], delta: Double, threshold: Double) -> [Double] {
//        var peaks = [Double]()
//
//        for i in 1 ..< red_data.count - 1 {
//            if red_data[i] > red_data[i - 1] && red_data[i] > red_data[i + 1] {
//                if red_data[i] - red_data[i - 1] > delta && red_data[i] - red_data[i + 1] > delta {
//                    peaks.append(red_data[i])
//                }
//            }
//        }
//
//        return peaks
//    }
    
//    func getMeanHR(redValues: [Float]) -> Int {
//        let sum = redValues.reduce(0, +)
//        let count: Float = Float(redValues.count)
//        let meanRed = sum / count
//
//        // Convert the red value to a range of heart rates.
//        let heartRateRange: ClosedRange<Int> = {
//            let minHeartRate = 60
//            let maxHeartRate = 180
//            let range = minHeartRate...maxHeartRate
//            return range
//        }()
//
//        // Calculate the mean heart rate based on the range.
//        let upper_lowerValue: Float = Float(heartRateRange.upperBound - heartRateRange.lowerBound)
//        let withmultiplymeanRed = meanRed * upper_lowerValue
//        let meanHR = (Float(heartRateRange.lowerBound) + withmultiplymeanRed) / 255.0
//
//        return Int(meanHR)
//    }
    
    
//    func removeOutliers(data: [Double], threshold: Double = 3) -> [Double] {
//        let mean = data.reduce(0, +) / Double(data.count)
//
//        debugPrint("mean====>>\(mean)")
//
//        var squaredSum: Double = 0
//        for value in data {
//            squaredSum += pow(value - mean, 2)
//        }
//        let variance = squaredSum / Double(data.count)
//        let stdDev = sqrt(variance)
//
//        let lowerBound = mean - threshold * stdDev
//        let upperBound = mean + threshold * stdDev
//
//        debugPrint("lowerBound======>>>\(lowerBound)\n\n\nupperBound=====>>\(upperBound)")
//
//        var filteredData = [Double]()
//        for value in data {
//            if value >= lowerBound && value <= upperBound {
//                filteredData.append(value)
//            }
//        }
//
//        return filteredData
//    }


    
//    func calculateHeartRate(redValues: [Float], width: Int, height: Int) -> Int {
//
//        // Calculate the average red value for each row of pixels.
//        var rowAverages = [Double](repeating: 0.0, count: height)
//        for y in 0 ..< height - 1 {
//            for x in 0 ..< width {
//                rowAverages[y] += Double(redValues[x + y * width])
//            }
//            rowAverages[y] /= Double(width)
//        }
//
//        // Calculate the heart rate from the average red values.
//        let heartRate = 60.0 * ((rowAverages.max() ?? 0.0) - (rowAverages.min() ?? 0.0)) / ((rowAverages.max() ?? 0.0) + (rowAverages.min() ?? 0.0))
//
//        return Int(heartRate)
//
//    }
    
    
    
    //MARK: FFT2
    /*
     Implementation use for RR
     */
    func FFT2(input:[Double], samplingFrequency: Int, sizeOld: Int) -> Double {
        
        let size = 512 //self.highestPowerof2(n: sizeOld) //ceil(log(Double(size))/log(2)) //512
        
        var temp: Double = 0.0;
        var POMP = 0.0;
        var frequency = 0.0
        var output = [Double](repeating: 0, count: 2*size)
        
        for x in 0..<input.count {
            output[x] = input[x]
        }
        
        let doubleOutput = output.map { return Double($0) }
        
        let arrAfterFFT: [Double] =  newFFT.calculate(doubleOutput, fps: Double(samplingFrequency))//fft.bandFrequencies
        
        for x in 0..<size {
            //Befor Resp not 1
            var aRed_HR: [Double] = HeartRateDetectionModel.butterworthBandpassFilter([arrAfterFFT[x]]) as! [Double]//([arrAfterFFT[x]], sample: Int32(samplingFrequency)) as! [Double]
            if aRed_HR.count > 0{
                output[x] = aRed_HR[0]
            }
        }
        
        for x in 0..<2*size {
            output[x] = abs(output[x])
        }
        
        //max Resp index   === 0  7
        //Size
        for p in 0..<size {
            if(temp < output[p]) {
                temp = output[p];
                POMP = Double(p);
            }
        }
        
        frequency = Double(POMP*Double(samplingFrequency)/Double(2*size));
        
        print("FREQUENCY ======= \(samplingFrequency) = \(frequency)=====\(POMP)")
        return frequency;
    }
    
    func highestPowerof2(n: Int) -> Int
    {
        var res = 0;
        for i in stride(from: n, to: 1, by: -1) {
            // If i is a power of 2
            if ((i & (i - 1)) == 0)
            {
                res = i;
                break;
            }
        }
        return res;
    }
    
    //MARK: HRCalculationAlgo
    func HRCalculationAlgo(ppgFiltData:[Double], samplingRate: Double, numFrame: Double, winSec: Double, winSlideSec:Double) -> Float {
        var red_window:[Double] = [Double](repeating: 0, count: ppgFiltData.count)
        
        // Sliding Widow, Number of samples in a window 6*fps = 180
        let window_seconds = winSec;
        // Number of samples in the 6 sec window
        let num_window_samples = Int(round(window_seconds * samplingRate))// 64
        //TODO:
        //Int(round(window_seconds * samplingRate));
        
        // Time between heart rate estimations - 0.5 * fps(30) = 15
        let bpm_sampling_period = winSlideSec;
        // number of samples in 0.5 seconds
        let bpm_sampling_period_samples = Int(round(bpm_sampling_period * samplingRate));
        
        // Processing through sliding window
        // Take first window with 180 samples and slide through window with 15 samples
        //         Finds out the number of windows which need to be processed
        // E.g. for 30 seconds, number of samples = 30*fps(30) = 900 samples
        //        First window is 180, then the window slides every 15 samples
        //        Hence in remaining (900-180) = 720 samples, the number of window is 720/15 = 60
        
        let num_bpm_samples = Int(floor(Double((numFrame - Double(num_window_samples)) / Double(bpm_sampling_period_samples))));
        
        var bpm: [Double] = [Double](repeating: 0, count: num_bpm_samples + 10) // 180
        var bpm_smooth: [Double] = [Double](repeating: 0, count: num_bpm_samples + 10)
        
        // Loop through each window
        for loop in 1...num_bpm_samples {
            
            //                    Log.v(TAG, " inside loop, count: " + loop);
            
            let window_start = (loop - 1) * bpm_sampling_period_samples; // start of sample in each window
            for l in window_start...window_start + num_window_samples where loop - window_start >= 0 {
                red_window[loop - window_start] = ppgFiltData[l];  // store in red_window[]
            }
            
            //                        for (int m = 0; m <= num_window_samples; m++) {
            //                            Log.v(TAG, " red_window : " + red_window[m].toString() + "  " + Integer.toString(m));
            //                        }
            
            // Calculate Hanning Window
            for l in 1...num_window_samples {
                // i = index into Hann window function
                red_window[l] = (red_window[l] * 0.5 * (1.0 - cos(2.0 * Double.pi * Double(l) / Double(num_window_samples))));
            }
            
            // FFT
            /*    let fft = TempiFFT(withSize: num_window_samples, sampleRate: Float(samplingRate))
             fft.windowType = TempiFFTWindowType.hanning
             let arrF = red_window.map { return Float($0) }
             
             fft.fftForward(arrF)
             
             // Interpoloate the FFT data so there's one band per pixel.
             let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
             fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))
             */
            let fft_ret:[Double] =  newFFT.calculate(red_window, fps: samplingRate) //fft.bandFrequencies
            //let  fft_ret: [Double] = Fft.FFT(red_window, num_window_samples, samplingRate);
            
            //                        for (int m = 0; m < num_window_samples; m++) {
            //                            Log.v(TAG, " fft_ret : " + Double.toString(fft_ret[m]) );
            //                        }
            
            // BPM range has been taken as 40 and 230
            let il = (40.0 / 60.0) * (Double(num_window_samples) / samplingRate) + 1; // value 5
            let ih = (230.0 / 60.0) * (Double(num_window_samples) / samplingRate) + 1;   // value 25
            // index_range = il:ih;
            
            //            Log.v(TAG, " il ; ih : " + il + "  " + ih);
            
            let il1 = Int(ceil(il));
            let ih1 = Int(floor(ih));
            //                    Log.v(TAG, " il ; ih : il1 ; ih1 " + il + "  " + ih + "  " + il + "  " + ih1);
            
            var fft_range: [Double] = [Double](repeating: 0, count: ih1)
            //TODO===
            for p in il1...Int(ih-1) where p - il1 >= 0 {
                fft_range[p - il1] = Double(fft_ret[p]);
            }
            
            //            for (int m = 0; m < ih; m++) {
            //                        Log.v(TAG, " fft_range : " + Double.toString(fft_range[m]) + "  " + Integer.toString(m));
            //            }
            
            // Find peaks
            var peak_arr: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: fft_range.count);
            
            //            // Initialise peak_arr
            //            for z in 0..<fft_range.count {
            //                peak_arr[z][0] = 0;
            //                peak_arr[z][1] = 0;
            //            }
            
            // TODO find out the index of the maximum peak
            peak_arr = self.findpeaks(arr: fft_range);
            
            //            for (int m = 0; m < 7; m++) {
            //                        Log.v(TAG, " peak_arr : " + Double.toString(peak_arr[m][0]) + "  " + Double.toString(peak_arr[m][1]));
            //            }
            
            var max_val = 0.0;
            var max_index = 0;
            // Find max in peak_arr[z]
            for z in 0..<fft_range.count {
                if (peak_arr[z][0] >= max_val) {
                    max_val = peak_arr[z][0];
                    max_index = Int(peak_arr[z][1]);
                }
                
            }
            
            let max_f_index = il + Double(max_index);
            bpm[loop] = (max_f_index) * (samplingRate * 60.0) / Double(num_window_samples);
            
            let freq_resolution = 1 / winSec; // WINDOW_SECONDS = 6
            
            // lowest, hence (-), half the resolution (half the samples)
            let lowf = bpm[loop] / 60.0 - winSlideSec * freq_resolution;
            let freq_inc = 1 / 60.0;     // FINE_TUNING_FREQ_INCREMENT = 1
            let test_freqs = freq_resolution / freq_inc; // 10
            let test_freq: Int = Int(test_freqs);
            
            
            // Initialise power
            var power: [Double] = [Double](repeating: 0, count: test_freq)
            for z in 0..<test_freq {
                power[z] = 0;
            }
            
            var freqs = [Double](repeating: 0, count: test_freq)
            for z in 0..<test_freq {
                freqs[z] = Double(z) * freq_inc + lowf;
            }
            for h in 0..<test_freq {
                var re = 0.0;
                var im = 0.0;
                var phi = 0.0;
                for j in 0..<num_window_samples {
                    phi = 2.0 * (22.0 / 7.0) * freqs[h] * (Double(j) / samplingRate);
                    re = re + red_window[j + 1] * cos(Double(phi));
                    im = im + red_window[j + 1] * sin(Double(phi));
                }
                
                power[h] = Double(re * re + im * im);
            }
            
            // Peak power
            var peak_power: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: power.count)
            
            // Initialise peak_arr
            for z in 0..<power.count {
                peak_power[z][0] = 0;
                peak_power[z][1] = 0;
            }
            
            // TODO find out the index of the maximum peak
            peak_power = self.findpeaks(arr: power);
            max_val = 0;
            max_index = 0;
            for z in 0..<power.count - 1 {
                if (peak_power[z][0] >= max_val) {
                    max_val = peak_power[z][0];
                    max_index = z;
                }
            }
            
            let max_index_1 = Int(max_index);
            bpm_smooth[loop] = 60 * freqs[max_index_1];
        }
        
        
        // Find mean of bpm_smooth
        var sum_bpm_smooth = 0.0;
        for loop1 in 1..<num_bpm_samples + 1 {
            if bpm_smooth[loop1] != 0.0 {
                sum_bpm_smooth = sum_bpm_smooth + bpm_smooth[loop1];
            }
        }
        
        let mean_HR1 = (sum_bpm_smooth / Double(num_bpm_samples));
        return Float(mean_HR1);
    }
    
    func HRCalculationAlgo_AsPerAndroid(ppgFiltData: [Double], samplingRate: Double, winSec: Double, winSlideSec: Double) -> Double {
        let numFrame = ppgFiltData.count;
        
        // Sliding Widow, Number of samples in a window 6*fps = 180 // Number of samples in the 6 sec window
        let  num_window_samples = round(winSec * samplingRate);
        
        // BPM range has been taken as 40 and 230
        let expectedLowFrequency = (40.0 / 60.0) * (num_window_samples / samplingRate) + 1; // value 5
        let expectedHighFrequency = (230.0 / 60.0) * (num_window_samples / samplingRate) + 1; // value 25
        
        // index_range = il:ih;
        let expectedLowFrequencyInt: Int = Int(ceil(expectedLowFrequency));
        let expectedHighFrequencyInt: Int = Int(floor(expectedHighFrequency));
        
        // Time between heart rate estimations - 0.5 * fps(30) = 15
        // number of samples in 0.5 seconds
        let bpm_sampling_period_samples: Int = Int(round(winSlideSec * samplingRate));
        // Processing through sliding window
        // Take first window with 180 samples and slide through window with 15 samples
        // Finds out the number of windows which need to be processed
        
        
        // E.g. for 30 seconds, number of samples = 30*fps(30) = 900 samples
        // First window is 180, then the window slides every 15 samples
        // Hence in remaining (900-180) = 720 samples, the number of window is 720/15 = 60
        let num_bpm_samples: Int = (numFrame - Int(num_window_samples)) / bpm_sampling_period_samples;
        
        var bpm_smooth: [Double] = [Double](repeating: 0, count: num_bpm_samples + 10)

        // Loop through each window
        for loop in 1...num_bpm_samples {
            // 0 - 180, 15 - 195, 30 - 210, 45 - 225 ....
            let window_start = (loop - 1) * bpm_sampling_period_samples;
            let red_window = self.getSlidingWindowAndCalculateHanningWindow(windowSize: Int(num_window_samples), windowStart: window_start, originalSignal: ppgFiltData);
            
            //FFT and ROI
            let fft_range: [Double] = findFFTAndRangeOfInterest(hanningWindowSample: red_window, samplingRate: Int(samplingRate), rangeStart: expectedLowFrequencyInt, rangeEnd: expectedHighFrequencyInt);
            
            
            // Find peaks
            let max_f_index = peakDetection(rangeOfInterest: fft_range, offset: Double(expectedLowFrequencyInt));
            let bpmPeak = (max_f_index) * (samplingRate * 60.0) / num_window_samples; //most powerful tone in the frequency band has been found
            let fftResolution = 1 / winSec; // WINDOW_SECONDS = 6
            let smoothingResolution = 1 / 60.0; // FINE_TUNING_FREQ_INCREMENT = 1
            
            let testFreq = (fftResolution / smoothingResolution); // 10
            // lowest, hence (-), half the resolution (half the samples)
            let lowf = bpmPeak / 60.0 - winSlideSec * fftResolution;
            
            var freqs = [Double](repeating: 0, count: Int(testFreq + 1))// new double[testFreq];
            
            for z in 0...Int(testFreq) {
                freqs[z] = Double(z) * smoothingResolution + lowf;
            }
            
            
            //Smoothing of signal
            let power = self.smoothingOfHrSignal(windowSize: num_window_samples, red_window: red_window, freqs: freqs, fftResolution: fftResolution, smoothingResolution: smoothingResolution, samplingRate: samplingRate)
            
            let max_index_1 = peakDetection(rangeOfInterest: power, offset: 0);
            bpm_smooth[loop] = 60 * freqs[Int(max_index_1)];
            
        }
        // Find mean of bpm_smooth
        var sum_bpm_smooth = 0.0;
        for loop1 in 1...num_bpm_samples {
            sum_bpm_smooth = sum_bpm_smooth + bpm_smooth[loop1];
        }
        let mean_HR1 = sum_bpm_smooth / Double(num_bpm_samples);
        
        return mean_HR1;
    }
    
    
    func getSlidingWindowAndCalculateHanningWindow(windowSize: Int, windowStart: Int, originalSignal: [Double]) -> [Double] {
        // 0 - 180, 15 - 195, 30 - 210, 45 - 225 ....
        var red_window: [Double] = [Double](repeating: 0, count: windowSize)
        let windowEnd = windowStart + windowSize;
        
        for l in windowStart...windowEnd - 1 {
            let relativePositionToWindow = l - windowStart;
            red_window[relativePositionToWindow] = originalSignal[l]; // store in red_window[]
        }
        
        /* Calculate Hanning Window
         Step 2: Apply Hann window:
         Step a: for every sample[i] (the sample element), multiply the sample with the multiplier:
         (1 - cos(2*PI*i/Sample_size))/2
         Step b: repeat Step a for every sample element in the Sample matrix
         */
        
        // Calculate Hanning Window
        for l in 0...red_window.count - 1 {
            red_window[l] = (red_window[l] * 0.5 * (1.0 - cos(2.0 * Double.pi * Double(l) / Double(windowSize))));
        }
        
        return red_window;
    }
    
    
    
    func findFFTAndRangeOfInterest(hanningWindowSample: [Double], samplingRate: Int, rangeStart: Int, rangeEnd: Int) -> [Double] {
        
        // FFT
        let fft_ret:[Double] =  newFFT.calculate(hanningWindowSample, fps: Double(samplingRate))

        //RANGE OF INTEREST
        //% Translate the frequency range of interest to indices within the FFT vector
        //rangeOfInterest = ((BPM_L:BPM_H) / 60) * (size(fftMagnitude, 2) / samplingFrequency) + 1;
        var fft_range = [Double](repeating: 0, count: rangeEnd)

        for p in rangeStart...rangeEnd - 1 {
            if (p < fft_ret.count && (p - rangeStart) < fft_range.count) {
                fft_range[p - rangeStart] = fft_ret[p];
            }
        }
        
        return fft_range;
        
    }
    
//    func FFT(inputData: [Double], size: Int, samplingFrequency: Double) -> [Double] {
//
//        var output: [Double] = [Double](repeating: 0, count: 2 * size)
//        var amp_output: [Double] = [Double](repeating: 0, count: size)
//
//        for i in 0...output.count - 1 {
//            output[i] = 0;
//        }
//
//        for x in 0...size {
//            output[x] = inputData[x];
//        }
//
//        var fft: [Double] = [Double](repeating: 0, count: size)
//
//        DoubleFft1d fft = new DoubleFft1d(size);
//        fft.realForward(output);
//
//        for x in 0...(2 * size) {
//            output[x] = Math.abs(output[x]);
//        }
//
//        int j = 0;
//        for (int x = 0; x < 2 * (size - 1); x = x + 2) {
//            amp_output[j] = Math.sqrt(output[x] * output[x] + output[x + 1] * output[x + 1]);
//            j++;
//        }
//
//        return amp_output;
//    }
    
    
    
    
    
    
    
    
    
    func peakDetection(rangeOfInterest: [Double], offset: Double) -> Double {
        let findpeaks = self.findpeaks(arr: rangeOfInterest);
        var max_val = 0.0;
        var max_index = 0.0;
        
        
        for z in 0..<findpeaks.count - 1 {
            if (findpeaks[z][0] >= max_val) {
                max_val = findpeaks[z][0];
                max_index = Double(z);
            }
        }
        return offset + max_index;
    }
    
    
    func smoothingOfHrSignal(windowSize: Double, red_window: [Double], freqs: [Double], fftResolution: Double, smoothingResolution: Double, samplingRate: Double) -> [Double] {
        let test_freq: Int = Int(fftResolution / smoothingResolution); // 10

        // Initialise power
        var power: [Double] = [Double](repeating: 0, count: test_freq)
        for h in 0..<test_freq {
            var re = 0;
            var im = 0;
            for j in 0..<Int(windowSize - 1) {
                let phi = 2.0 * (22.0 / 7.0) * freqs[h] * (Double(j) / samplingRate);
                re = re + Int(red_window[j + 1] * cos(Double(phi)));
                im = im + Int(red_window[j + 1] * sin(Double(phi)));
            }
            power[h] = Double(re * re + im * im);
        }
        
        return power;
    }
    
    
    

    
    /*
     Method used to find peaks
     */
    func findpeaks(arr:[Double]) -> [[Double]] {
        var j = 0;
        let size  = arr.count ;
        var peaks: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: size)
        for i in 1..<size - 1 {
            if ((arr[i] > arr[i-1] ) && (arr[i + 1] < arr[i])) {
                peaks[j][0] = arr[i] ;
                peaks[j][1] = Double(i) ;
                j += 1;
            }
        }
        return peaks ;
    }
    
    //MARK: HRVCalculationAlgo
    func HRVCalculationAlgo(ppgData:[Double], samplingRate: Int, numFrame: Int, mean_HR: Int) -> Int {
        // Find HRV
        // Find peaks
        var dbydt_HR = [Double]()
        var daRed_HR = [Double]()
        // Initialise peak_arr
        daRed_HR = ppgData;
        
        // Size of one window is mean_HR/60,
        // Since need to take 3 RR in one window, size of one window will be meah_HR*4/60
        // Hence number of samples per window is (mean_HR*4*SamplingRate/60)
        // Example: Lets say framerate 30, samples 900 for 30 seconds, HR is 60
        
        let window_size_RR =  (mean_HR * 4 * samplingRate / 60);  // based on number of samples window size 120
        // find peak locations where dbydt = 0
        var RR_peaks:[[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: window_size_RR + 1);  // Find the peaks of each pulse within the window
        // Window slides with one pulse width
        let sliding_samples_window_RR = mean_HR * samplingRate / 60;
        
        
        // Number of sliding window in this example = (900 -120) / 30 = 26
        let num_sliding_window_RR = (numFrame - window_size_RR) / sliding_samples_window_RR; //
        
        var RR_vals: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 3), count: num_sliding_window_RR + 1) // RR1, RR2 and RR3
        
        var category:[Int] = [Int](repeating: 0, count: num_sliding_window_RR) // identify category for each window
        // Inside window
        
        for iter in 1...num_sliding_window_RR {
            // num_sliding_window_RR, loop for 26 times
            
            let win_start = (iter - 1) * sliding_samples_window_RR; // start of sample in each window
            for l in win_start...win_start + window_size_RR {
                daRed_HR[l - win_start] = ppgData[l];  // store in daRed_HR
            }
            
            // TODO find out the index of the peaks
            //TODO: ===
            dbydt_HR = self.derivative(arr: daRed_HR, size: window_size_RR, fps: samplingRate)
            
            var k = 0;
            for j in 1...window_size_RR {
                // Take positive peaks
                if (((dbydt_HR[j] > 0 && dbydt_HR[j + 1] < 0) || dbydt_HR[j] == 0)) {
                    RR_peaks[k][0] = daRed_HR[j];
                    RR_peaks[k][1] = Double(j);
                    k += 1
                }  // All the peaks (+) peaks are in RR_peaks value in index 0 and offset in [1]
            }
            var temp = 0;
            // Sort the RR_peaks and take the maximum, below is the algo to sort in decending order i.e. Max => min
            for i in 0..<window_size_RR {
                for j in 0..<(window_size_RR - i - 1) {
                    if (RR_peaks[j][0] < RR_peaks[j + 1][0]) {
                        temp = Int(RR_peaks[j][0]);
                        RR_peaks[j][0] = RR_peaks[j + 1][0];
                        RR_peaks[j + 1][0] = Double(temp);
                    }
                }
            }
            
            //var RtoR = [Double]();
            RR_vals[iter][0] =  abs(RR_peaks[0][1] - RR_peaks[1][1]) // RR1
            RR_vals[iter][1] = abs(RR_peaks[1][1] - RR_peaks[2][1]); // RR2
            RR_vals[iter][2] = abs(RR_peaks[2][1] - RR_peaks[3][1]); //RR3
            
            
        }  // End of sliding window if loop
        
        // Apply the algo for Regular/Irregular Rythm
        // Now iterate through each of the window and find the category
        guard num_sliding_window_RR - 3 > 0 else  {
            return 0
        }
        
        for iter1 in 1..<(num_sliding_window_RR - 3)  {
            category[iter1] = 1; // Initially set as category 1 by default i.e. Regular - Step - 2
            
            // If RR2 < .6 sec
            if (((RR_vals[iter1][1] / Double(samplingRate)) < 0.6) && (RR_vals[iter1][1] < RR_vals[iter1][2])) {
                category[iter1] = 5;  // Step - 3
            }
            var pulse = 1;
            for i in 1...3 {
                if ((RR_vals[iter1 + i][0] / Double(samplingRate)) < 0.8 && (RR_vals[iter1 + i][1] / Double(samplingRate)) < 0.8 &&
                    (RR_vals[iter1 + i][2] / Double(samplingRate)) < 0.8 &&
                    (RR_vals[iter1][0] + RR_vals[iter1][1] + RR_vals[iter1][2]) / Double(samplingRate) < 1.8) {
                    category[iter1] = 5;   // Step - 3a
                    pulse += 1;
                }
            }  // end of local loop
            
            if (pulse < 4) {
                category[iter1] = 1;
                // Step - 3b
            }
            
            if (RR_vals[iter1][1] < 0.9 * RR_vals[iter1][0] && RR_vals[iter1][0] < 0.9 * RR_vals[iter1][2]) {
                
                if ((RR_vals[iter1][1] + RR_vals[iter1][2]) < 2 * RR_vals[iter1][1]) {
                    category[iter1] = 2;
                } else {
                    category[iter1] = 3;
                }
            }   // Step 4a and 4b
            if (RR_vals[iter1][1] > 1.5 * RR_vals[iter1][0]) {
                category[iter1] = 4;   // Step - 5
            }
        }  // End of sliding window algo loop Rythm
        var count = 0.0;
        for iter2 in 1..<(num_sliding_window_RR - 3) {
            if (category[iter2] == 1) {
                count += 1;
            }
        }
        
        var Rythm = 0 ;
        if (count >= 0.95 * Double(num_sliding_window_RR)) {
            Rythm = 1;
        }
        return Rythm ;
    }
    
    func getTalaValue() -> Int {
        let arrTimePerBeat = self.arrHeartRates.compactMap({$0/60.0})
        let total = arrTimePerBeat.reduce(0) { x, y in
            x + y
        }
        var squaredData = [Float]()
        for i in 1...(arrTimePerBeat.count-1) {
            let diff = arrTimePerBeat[i] - arrTimePerBeat[i - 1]
            squaredData.append(diff*diff)
        }
        squaredData.append(0)
        
        let totalSquare = squaredData.reduce(0) { x, y in
            x + y
        }
        
        let mean = totalSquare/total
        // let interval = totalSquare / Float(self.arrHeartRates.count - 1)
        let result = mean.squareRoot()
        if result >= 0.115 {
            isTalaRegular = false
            return 0 //(Vata)Irregular
        }
        isTalaRegular = true
        return 1 //Regular
    }
    
    
    /*
     Method to calculate derivative
     */
    func derivative(arr:[Double], size: Int, fps: Int) -> [Double]
    {
        var diffs = [Double]()
        for i in 1...(arr.count-1) {
            diffs.append(arr[i] - arr[i - 1])
        }
        return diffs;
    }
    
    //MARK: GATI CALCULATION
    func GatiCalculationAlgo(fft_gati:[Double], SamplingRate: Int, numFrame: Int) -> Double
    {
        var peak_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: numFrame)
        // Initialise peak_arr
        for z in 0..<numFrame {
            peak_gati[z][0] = 0;
            peak_gati[z][1] = 0;
        }
        
        let fs = Double(SamplingRate / 2);
//        let fs = Double(SamplingRate);// Changes by 10 th June 2023
        let step = (fs / Double(numFrame));
        
        let min_freq = 0.5;
        let max_freq = 2;
        
        let low_count = Int(min_freq / Double(step));
        let hi_count = Int(Double(max_freq) / step);
        
        var cnt = low_count;
        var value = min_freq;
        
        var g = 0;
        
        var running_avg_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: numFrame / 3 - 1)
        
        while (cnt <= hi_count)
            
        {
            running_avg_gati[g][0] = (fft_gati[cnt] + fft_gati[cnt + 1] + fft_gati[cnt + 2]) / 3.0;
            running_avg_gati[g][1] = value;
            value = value + 3 * Double(step);
            cnt += 3;
            g += 1;
        }
        peak_gati = self.darray_findpeaks(arr: running_avg_gati);
        var max_peak_gati = 0.0;
        var max_peak_index = 0.0;
        for z in 0..<peak_gati.count {
            if (peak_gati[z][0] >= max_peak_gati) {
                
                if ( (peak_gati[z][1] > 0.8) && (peak_gati[z][1] <= 1.6) ) {
                    max_peak_gati = peak_gati[z][0];
                    max_peak_index = peak_gati[z][1];
                }
            }
        }
        return Double(max_peak_index);
    }
    
    /*
     Method to find peak in array
     */
    func darray_findpeaks(arr:[[Double]]) -> [[Double]] {
        var j = 0;
        let size  = arr.count ;
        
        var  peaks = [[Double]](repeating: [Double](repeating: 0, count: 2), count: size)
        for i in 1..<size - 1 {
            if ((arr[i][0] >= arr[i-1][0] ) && (arr[i + 1][0] <= arr[i][0])) {
                peaks[j][0] = arr[i][0] ;
                peaks[j][1] = arr[i][1] ;
                j += 1;
            }
        }
        return peaks ;
    }
    
    deinit {
        print("DINIT")
    }
}

extension CameraViewController {
    func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Camera access was denied. Please enable it in app settings.".localized(),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Open Settings".localized(), style: .default) { _ in
            if let url = URL.init(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - API Call

//MARK: - API Call
extension CameraViewController {
 
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let birthdayDate = dateFormater.date(from: birthday) ?? Date()
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate, to: now, options: [])
        let age = calcAge.year
        return age ?? 0
    }
    
    func toJSON(_ strData: String) -> Any? {
        guard let data = strData.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    func trimed(_ strData: String) -> String{
       return  strData.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

//    func uploadMeasumentDataOnServer_forTemp(graphParams: String, sparshnaResult: String) {
//        if Utils.isConnectedToNetwork() {
//            let dateOfSparshna = Date().dateString(format: "dd-MM-yyyy hh:mm:ss a")
//            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
//                //REGISTERED USER
//                let userIdOld = (empData["id"] as? String ?? "")
//                
//                //graphParams
//                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : userIdOld]
//                
//                Utils.doAPICall(endPoint: .savesparshnatest, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
//                    if isSuccess  || status.caseInsensitiveEqualTo("Sucess") {
//                        //DebugLog(">> Response : \(responseJSON?.rawString() ?? "-")")
//                    } else {
//                        //fromVC.hideActivityIndicator(withTitle: APP_NAME, Message: message)
//                    }
//                }
//            } else {
//                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : ""]
//                kUserDefaults.set(params, forKey: kUserMeasurementData)
//            }
//            kUserDefaults.set(sparshnaResult, forKey: LAST_ASSESSMENT_DATA)
//        }
//    }

    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}


//MARK: - NEW FUNCTION FOR BANDPASS FILTER
extension CameraViewController {
    
    func butterworthBandpassFilter(signal: [Double]) -> [[Double]] {
        
        // Calculate the filter coefficients.
        let coefficients = butterworthBandpassFilterCoefficients()
        
        // Apply the filter to the signal.
        var filteredSignal = [[Double]]()
        for sample in signal {
            filteredSignal.append(butterworthBandpassFilter(sample: sample, coefficients: coefficients))
        }
        
        return filteredSignal
    }
    
    func butterworthBandpassFilterCoefficients() -> [[Double]] {

        // Calculate the filter's natural resonant frequency.
        let wn = 2 * .pi * cutoffFrequency1

        // Calculate the filter's damping ratio.
        let zeta = 1 / (2 * order)

        // Calculate the filter's poles.
        let zetaSquared = zeta * zeta
        let oneMinusZetaSquared = 1 - zetaSquared
        let sqrtOneMinusZetaSquared = sqrt(Double(oneMinusZetaSquared))
        let zetaValue = -wn * sqrtOneMinusZetaSquared
        let poles = [zetaValue, -zetaValue]

        // Calculate the filter's coefficients.
        let coefficients = butterworthBandpassFilterCoefficients(poles: poles)

        return coefficients
    }
    
    
//    func butterworthBandpassFilterCoefficients() -> [[Double]] {
//
//      // Calculate the filter's natural resonant frequency.
//      let wn1 = 2 * .pi * cutoffFrequency1
//      let wn2 = 2 * .pi * cutoffFrequency2
//
//      // Calculate the filter's damping ratio.
//      let zeta = 1 / (2 * order)
//
//      // Calculate the filter's poles.
//      let poles = [-wn1 * sqrt(1 - zeta * zeta), wn1 * sqrt(1 - zeta * zeta), -wn2 * sqrt(1 - zeta * zeta), wn2 * sqrt(1 - zeta * zeta)]
//
//      // Calculate the filter's coefficients.
//      let coefficients = butterworthBandpassFilterCoefficients(poles: poles)
//
//      return coefficients
//    }
    
    
    
    
    func butterworthBandpassFilterCoefficients(poles: [Double]) -> [[Double]] {
        
        // Calculate the filter's gain.
        let gain = 1 / (2 * poles[0] * poles[1])
        
        // Calculate the filter's numerator coefficients.
        var numeratorCoefficients = [gain]
        let int_order: Int = Int(self.order)
        for i in 0 ..< int_order {
            let new_order = pow(poles[0], (order - Double(i) - 1))
            numeratorCoefficients.append(new_order)
        }
        
        // Calculate the filter's denominator coefficients.
        var denominatorCoefficients = [1.0]
        for i in 0 ..< int_order {
            let new_order1 = pow(poles[1], (order - Double(i) - 1))
            denominatorCoefficients.append(new_order1)
        }

        return [numeratorCoefficients, denominatorCoefficients]
    }
    
    func butterworthBandpassFilter(sample: Double, coefficients: [[Double]]) -> [Double] {

      // Calculate the filter's output.
      var output = [Double]()
      for i in 0 ..< coefficients.count {
        let new_order_1 = pow(sample, Double(i) - 1)
        output.append(coefficients[i][0] * new_order_1)
      }

      return output
    }
    
    
    
    
    //MARK: - Call API for Get Vikriti Python Logic
    func callAPIforVikritiPredictioPythonAPI(vikriti_values: String, prakriti_values: String, completion: @escaping (_ success: Bool, _ model_result: Vikriti_Prediction_Model?)->Void) {
        
        if Utils.isConnectedToNetwork() {
            self.showActivityIndicator()
            
            var str_ppgData = ""
            let urlString = kAPIVikritiPredction
            
            for ppgData in self.arrRed {
                str_ppgData += "\(ppgData) "
            }
            
            var kapha_Prakriti = 0.0
            var pitta_Prakriti = 0.0
            var vata_Prakriti = 0.0
            var kapha_Vikriti = 0.0
            var pitta_Vikriti = 0.0
            var vata_Vikriti = 0.0
            
            var strPrashna = prakriti_values.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kapha_Prakriti = (Double(arrPrashnaScore[0].trimed()) ?? 0).rounded(.up)
                pitta_Prakriti = (Double(arrPrashnaScore[1].trimed()) ?? 0).rounded(.up)
                vata_Prakriti = 100 - kapha_Prakriti - pitta_Prakriti
            }
            
            var strVikriti = vikriti_values.replacingOccurrences(of: "[", with: "")
            strVikriti = strVikriti.replacingOccurrences(of: "]", with: "")
            strVikriti = strVikriti.replacingOccurrences(of: "\"", with: "")
            let arrVikritiScore:[String] = strVikriti.components(separatedBy: ",")
            if  arrVikritiScore.count == 3 {
                kapha_Vikriti = (Double(arrVikritiScore[0].trimed()) ?? 0).rounded(.up)
                pitta_Vikriti = (Double(arrVikritiScore[1].trimed()) ?? 0).rounded(.up)
                vata_Vikriti = 100 - kapha_Vikriti - pitta_Vikriti
            }
            
            var str_aggravation = ""
            let str_prakriti = "\(Int(kapha_Prakriti)) \(Int(pitta_Prakriti)) \(Int(vata_Prakriti))"
            let str_vikriti = "\(Int(kapha_Vikriti)) \(Int(pitta_Vikriti)) \(Int(vata_Vikriti))"
            
            if kUserDefaults.value(forKey: VIKRITI_SPARSHNA) != nil {
                let currentKPVStatus = Utils.getYourCurrentKPVState(isHandleBalanced: false)
                str_aggravation = currentKPVStatus.rawValue.lowercased()
            }
            
            let params = ["ppg": str_ppgData.trimed(),
                          "age": Int(self.dAge),
                          "height": self.dHei,
                          "weight": self.dWei,
                          "vikriti": str_vikriti,
                          "prakriti": str_prakriti,
                          "doshaSelected": str_aggravation,
                          "gender": self.isMale ? "Male" : "Female",
                          "spo2": self.dic_vikriti_params["o2r"] as? Int ?? 0,
                          "sysbp": self.dic_vikriti_params["sp"] as? Int ?? 0,
                          "diabp": self.dic_vikriti_params["dp"] as? Int ?? 0,
                          "bpm": self.dic_vikriti_params["bpm"] as? Int ?? 0,
                          "tbpm": self.dic_vikriti_params["tbpm"] as? Int ?? 0,
                          "kath": self.dic_vikriti_params["kath"] as? Int ?? 0,
                          "bala": self.dic_vikriti_params["bala"] as? Int ?? 0,
                          "gati": self.dic_vikriti_params["gati"] as? String ?? "",
                          "bmi": self.dic_vikriti_params["bmi"] as? Double ?? 0.0,
                          "bmr": self.dic_vikriti_params["bmr"] as? Int ?? 0,
                          "pbreath": self.dic_vikriti_params["pbreath"] as? Int ?? 0] as [String : Any]
            
            debugPrint("API URL========>>>\(urlString)\n\n\nAPI Params========>>", params)
            
            let paramsJSON = JSON(params)
            let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
            let postData = paramsString.data(using: .utf8)
            var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: 60)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    DismissProgressHud()
                    completion(true, nil)
                    print("vikriti prediction api response:======>>", response ?? [])
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Vikriti_Prediction_Model.self, from: data)
                    debugPrint("Prakriti Cloud Result--------> \(result)")
                    
                    DismissProgressHud()
                    
                    DispatchQueue.main.async {
                        completion(true, result)
                    }
                    
                }catch {
                    DismissProgressHud()
                    completion(true, nil)
                    debugPrint("APIService: Unable to decode \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        }
        else {
            completion(true, nil)
            self.hideActivityIndicator()
        }
        
    }
}



