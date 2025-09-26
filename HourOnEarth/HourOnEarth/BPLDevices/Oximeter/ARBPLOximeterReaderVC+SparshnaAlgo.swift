//
//  ARBPLOximeterReaderVC+SparshnaAlgo.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class ARSparshnaAlgo {
    
    let FRAMES_PER_SECOND = 30
    
    var count = 0
    
    var arrRed = [Float]()
    var arrGreen = [Float]()
    var arrBlue = [Float]()
    var arrHuePoints = [Float]()
    var arrHeartRates = [Float]()
    
    var dAge = 0.0
    var dHei: Double = 1.0
    var dWei: Double = 1.0
    var demo_user_name = ""
    var maxRedValue = 210.0
    
    var isMale = true
    var Q = 0.0
    
    var ppgDataServer = [String]()
    var fftDataServer = [String]()
    var newFFT = FFT()
    
    var isTalaRegular = false
    
    var oximeterPulseArray = [Int]()
    var spO2Value = 98
    var aSamplingFreq = 0
    var fromVC: UIViewController?
    
    init() {
        doSetup()
    }
}

extension ARSparshnaAlgo {
    private func doSetup() {
        if dAge == 0.0 {
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                let dob = empData["dob"] as! String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let birthday = dateFormatter.date(from: dob)
                
                let ageComponents = Calendar.current.dateComponents([.year], from: birthday!, to: Date())
                dAge = Double(ageComponents.year!)
                
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
    }
    
    //MARK: === PROGRESS COMPLETED
    func processSparshnaLogic() {
        
        var acounter = arrRed.count
        let sampleFrequency = aSamplingFreq /*acounter / count*/
        
        let ignoreTime = 0//Float(ignoreSamples/sampleFrequency)
        
        // Ignore 120 samples from the beginning
        let ignoreSamples = ignoreTime * sampleFrequency ;
        
        let actualTime = 32 - ignoreTime
        
        var NaRed: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
        for z in ignoreSamples..<acounter  {
            NaRed[z - ignoreSamples] = Double((-1) * arrRed[z]);
            
        }
        
        acounter = acounter - ignoreSamples ;
        
        //BUTTER WORTH
        let aRed_HR_ButterWorth: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(NaRed) as! [Double]
        
        //            let butterWorthFFT: [Double] = newFFT.calculate(aRed_HR_ButterWorth, fps: Double(sampleFrequency))
        //            var absoluteValues: [Double] = butterWorthFFT.compactMap({return $0 < 0 ? -1 * $0 : $0})
        //            for i in 0...50 {
        //                absoluteValues[i] = 0
        //            }
        //            let maxValue = absoluteValues.max()
        //            let index = absoluteValues.firstIndex(of: maxValue ?? 0)
        //            let heartRate = Float( ((index ?? 0) * sampleFrequency * 120) / aRed_HR_ButterWorth.count )
        
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
        
        let aRed_HR = NaRed.compactMap({return -1 * (HeartRateDetectionModel.butterworthBandpassFilter([$0]) as! [Double]).first!})
        
        //TETSED  let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]
        
        //   PASS
        let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]
        
        
        //PREVIOUS USING BELOW ONE
        //  PASS
        //let mean_HR = arrHeartRates.last ?? 0.0
        //let mean_HR = Double(oximeterPulseArray.last ?? 0) ?? 0.0
        let avgHR = Double(oximeterPulseArray.reduce(0, +)) / Double(oximeterPulseArray.count)
        let mean_HR = avgHR
        
        //HeartRateDetectionModel.getMeanHR(aRed_HR_ButterWorthHue, time: Float(actualTime))
        
        /** NEWTEST*/
        
        //            let doubleHue = arrHuePoints.compactMap({Double($0)})
        //
        //             let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(doubleHue) as! [Double]
        //
        //             let mean_HR = HeartRateDetectionModel.getMeanHR(aRed_HR_ButterWorthHue, time: Float(actualTime))
        
        
        /***/
        
        let Rythm = self.getTalaValue()
        //self.HRVCalculationAlgo(ppgData: aRed_HR, samplingRate: sampleFrequency, numFrame: acounter, mean_HR: Int(mean_HR)) ;
        
        //MARK: == RR(Respiratory Rate)
        let rr = self.FFT2(input: NaRed, samplingFrequency: sampleFrequency, sizeOld: acounter)
        let RR_red = ceil(60.0 * rr) ;
        print(RR_red)
        let mean_RR = Int(RR_red)
        acounter = acounter + ignoreSamples ;
        
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
        let o2 = Float(spO2Value)
        
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
        
        //let vata = Int(Rythm) == 0 ? "" : "\(Int(Rythm))"
        //
        //            var resultDic: [String: [String: String]] = [String: [String: String]]()
        //            resultDic["Vega"] = ["value": "\(Int(mean_HR))","type": "Pitta"]
        //            resultDic["Akruti(Volume)"] = ["value": "\(Int(SP))","type": "Pitta"]
        //            resultDic["Akruti(Tension)"] = ["value": "\(Int(DP))","type": "Pitta"]
        //            resultDic["Tala"] = ["value": Rythm,"type": ""]
        //            resultDic["Bala"] = ["value": "\(Int(bala))","type": "Pitta"]
        //            resultDic["Kathinya"] = ["value": "\(Int(kathinya))","type": "Pitta(elastic/flex)"]
        //            resultDic["Gati"] = ["value": "","type": gatiType]
        //            resultDic["Spo2"] = ["value": "\(Int(o2))","type": ""]
        //            resultDic["Respiratory Rate"] = ["value": "\(mean_RR)","type": ""]
        //            resultDic["BMI"] = ["value": "\(BMI)","type": ""]
        //            resultDic["BMR"] = ["value": "\(Int(BMR))","type": ""]
        //
        //            print(resultDic)
        
        /**** VALIDATION *****/
        
        
        //
        //
        //            var isResultValid = true
        //           // 1. Heart rate is less than 40 or greater than 100
        //            if Int(mean_HR) < 40 || Int(mean_HR) > 100 {
        //                isResultValid = false
        //            } else if Int(bala) < 25 || Int(bala) > 65 {
        //                //2. Pulse pressure is less 35 or greater than 65
        //                isResultValid = false
        //            } else if Int(kathinya) < 80 {
        //                //3. Stiffness index is less than 80
        //                isResultValid = false
        //            } else if Int(SP) < Int(DP) {
        //                //4. Systolic is less than diastolic
        //                isResultValid = false
        //            } else if Int(SP) > 180 || Int(SP) < 90 {
        //                //5. systolic above 180 or below 90
        //                isResultValid = false
        //            } else if Int(DP) > 120 || Int(DP) < 60 {
        //               //6. Diastolic above 120 or below 60
        //                isResultValid = false
        //            }
        //
        //            if !isResultValid {
        //                Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Hold finger steady and repeat for accurate readings.", okTitle: "Ok", controller: self) {
        //                    self.navigationController?.popToRootViewController(animated: true)
        //                }
        //                return
        //            }
        
        /***********************/
        
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
        
        while ((cnt + 2) < hi_count) {
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

        //tala
        if !isTalaRegular {
            //                let rythmValue = 0
            //                if (rythmValue == 0 ) {
            vataOld += 1;
            //                } else {
//                kapha += 1;
//            }
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
                    DebugLog("??? sparshna done in less then 5 min ???")
                    return
                }
            }
        }
        //
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
            sparshnaValue = "\((gatiKPercentage*0.75) + (vataKPercentage*0.25))" + "," +
                            "\((gatiPPercentage*0.75) + (vataPPercentage*0.25))" + "," +
                            "\((gatiVPercentage*0.75) + (vataVPercentage*0.25))"
            kUserDefaults.set(sparshnaValue, forKey: VIKRITI_SPARSHNA)
        }
        
        let result = "[" + Utils.getVikritiValue() + "]"
        
        var sparshnaResults = ""
        //            let sparshnaDic = ["Vega":"\(Int(mean_HR))", "Akruti(Volume)":"\(Int(SP))","Akruti(Tension)": "\(Int(DP))", "Tala": Rythm, "Bala":"\(Int(bala))", "Kathinya": "\(Int(kathinya))", "Gati": "\(gatiType)", "Spo2": "\(Int(o2))", "Respiratory Rate": "\(mean_RR)", "BMI": "\(BMI)", "BMR": "\(Int(BMR))"]
        
        let sparshnaDic = ["bpm": Int(mean_HR), "sp": Int(SP),"dp": Int(DP), "rythm": Rythm, "bala": Int(bala), "kath": Int(kathinya), "gati": "\(gatiType)", "o2r": Int(o2), "pbreath": mean_RR, "bmi": BMI, "bmr": Int(BMR), "tbpm": 165] as [String : Any]
        //TODO: need to check tbpm in android -- why used ??
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sparshnaDic, options: JSONSerialization.WritingOptions.prettyPrinted)
            sparshnaResults = String(bytes: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error)
        }
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.sprashna_test.rawValue)
        /*let redHrStr = arrRed.map({return String($0)})
        let fftGatiStr = arrFilteredData.map({return String($0)})
        
        let graphParams  = "counter = \(acounter),SamplingFreq = \(sampleFrequency),Red_HR = \(redHrStr.joined(separator: ",")),fft_gati = \(fftGatiStr.joined(separator: ","))"*/
        let graphParamsDictValue = ["counter": acounter, "SamplingFreq": sampleFrequency, "Red_HR": arrRed.jsonStringRepresentation ?? "", "fft_gati": arrFilteredData.jsonStringRepresentation ?? ""] as [String: Any]
        let graphParamsStringValue = graphParamsDictValue.jsonStringRepresentation ?? ""
        
        ARLog(">> result: \n \(result)")
        ARLog(">> sparshnaResults: \n \(sparshnaResults)")
        ARLog(">> sparshnaValue: \n \(sparshnaValue)")
        ARLog(">> graphParamsStringValue: \n \(graphParamsStringValue)")
        
        // MARK: upload sprashna data on server
        if let fromVC = fromVC {
            CameraViewController.postSparshnaData(value: result, sparshnaResult: sparshnaResults, sparshnaValue: sparshnaValue, graphParams: graphParamsStringValue, fromVC: fromVC)
            CameraViewController.uploadMeasumentDataOnServer(graphParams: graphParamsStringValue, sparshnaResult: sparshnaResults, fromVC: fromVC)
        }
    }
}

// MARK: - Utilities
extension ARSparshnaAlgo {
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
        
        for x in 0..<output.count {
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
    func HRCalculationAlgo(ppgFiltData:[Double], samplingRate: Double, numFrame: Double, winSec: Double, winSlideSec:Double) -> Int {
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
        for loop1 in 1..<num_bpm_samples {
            sum_bpm_smooth = sum_bpm_smooth + bpm_smooth[loop1];
        }
        
        let mean_HR1 = (sum_bpm_smooth / Double(num_bpm_samples));
        return Int(mean_HR1);
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
        let step = (fs / Double(numFrame));
        
        let min_freq = 0.5;
        let max_freq = 2;
        
        let low_count = Int(min_freq / Double(step));
        let hi_count = Int(Double(max_freq) / step);
        
        var cnt = low_count;
        var value = min_freq;
        
        var g = 0;
        
        var running_avg_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: numFrame / 3 - 1)
        
        while ((cnt + 2) < hi_count)
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
}
