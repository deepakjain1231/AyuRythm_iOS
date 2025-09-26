//
//  FaceNaadiCameraVC.swift
//  FaceLandmarker
//
//  Created by DEEPAK JAIN on 14/10/23.
//

import UIKit
import Charts
import CoreVideo
import AVFoundation
import Alamofire
import SwiftyJSON
import MediaPipeTasksVision
import UniformTypeIdentifiers

class FaceNaadiCameraVC: UIViewController, didTappedBeginFaceNaadi {

    var order = 4.0
    var cutoffFrequency1 = 0.5
    var cutoffFrequency2 = 4.1
    
    var str_facenaadi_process = ""
    var str_facenaadi_result = ""
    var str_facenaadi_sparshna_result = ""
    var str_facenaadi_graphParamsStringValue = ""
    
    var is_facenaadiProcess = false
    var is_faceAnalycsAPI = false
    var is_startFaceTimer = false
    var timerr: Timer?
    var timer_faceDetection: Timer?
    var timer_facenaadiStart:Timer? = nil
    
    var timer_get_faceImage: Timer?
    var timerInterval = 30
    var timerInterval_FACEDETECTION = 3
    var arr_RedData = [Float]()
    var arr_GreenData = [Float]()
    var arr_BlueData = [Float]()
    var arr_greenAverage = [Float]()
    
    var arrHuePoints:[Float] = [Float]()
    var arrHeartRates = [Float]()
    var dAge = 0.0
    var dHei: Double = 1.0
    var dWei: Double = 1.0
    var demo_user_name = ""
    var maxRedValue = 210.0
    let FRAMES_PER_SECOND = 30
    
    var isMale = true
    var Q = 0.0
    var is_EyesBlink = false
    var onTimeStartTimer = false
    var is_showingPopup = true
    
    var ppgDataServer:[String] = [String]()
    var fftDataServer:[String] = [String]()
    var newFFT = FFT()
    var isTalaRegular = false
    var tempData = arr_DummyData_forChart
    var dic_face_anylysic = [String: Any]()
    var dic_vikriti_params = [String: Any]()
    
    var readingTimeInterval: TimeInterval = 0.1 //100 miliseconds
    var maxReadingTimeInterval = 30.0
    var readingStartTime = 0.0
    var currentReadingTime = 0.0

    var bitmapImage = UIImage()
    var bitmapImage_CI: CIImage?
    
    let leftEyeIndices = [0, 1, 2, 3, 4, 5]
    let rightEyeIndices = [6, 7, 8, 9, 10, 11]
    
    
    // MARK: Storyboards Connections
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    @IBOutlet weak var img_bitmap: UIImageView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var progress_Vieww: UIProgressView!
    
    @IBOutlet weak var view_animationLoad: UIView!
    @IBOutlet weak var lbl_infoText: UILabel!
    @IBOutlet weak var img_Infoanimation: UIImageView!

    // MARK: Instance Variables
    private var numFaces = DefaultConstants.numFaces
    private var detectionConfidence = DefaultConstants.detectionConfidence
    private var presenceConfidence = DefaultConstants.presenceConfidence
    private var trackingConfidence = DefaultConstants.trackingConfidence
    private let modelPath = DefaultConstants.modelPath
    private var runingModel: RunningMode = .liveStream {
        didSet {
            faceLandmarkerHelper = FaceLandmarkerHelper(
                modelPath: modelPath,
                numFaces: numFaces,
                minFaceDetectionConfidence: detectionConfidence,
                minFacePresenceConfidence: presenceConfidence,
                minTrackingConfidence: trackingConfidence,
                runningModel: runingModel,
                delegate: self)
        }
    }
    let backgroundQueue = DispatchQueue(
        label: "com.google.mediapipe.examples.facelandmarker",
        qos: .userInteractive
    )
    private var isProcess = false

    // MARK: Controllers that manage functionality
    // Handles all the camera related functionality
    private lazy var cameraCapture = CameraFeedManager(previewView: previewView)

    // Handles all data preprocessing and makes calls to run inference through the
    // `FaceLandmarkerHelper`.
    private var faceLandmarkerHelper: FaceLandmarkerHelper?


    // MARK: View Handling Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create object detector helper
        self.img_bitmap.isHidden = true
        self.view_animationLoad.isHidden = true
        self.img_Infoanimation.image = UIImage.gifImageWithName("sparshna_loader")
        self.lbl_infoText.text = "Personalizing your content".localized()
        self.setupUI()
        
        self.openInfoDialouge()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func didLoadSetup() {
        faceLandmarkerHelper = FaceLandmarkerHelper(
            modelPath: modelPath,
            numFaces: numFaces,
            minFaceDetectionConfidence: detectionConfidence,
            minFacePresenceConfidence: presenceConfidence,
            minTrackingConfidence: trackingConfidence,
            runningModel: runingModel,
            delegate: self)

        cameraCapture.delegate = self
        overlayView.clearsContextBeforeDrawing = true

        self.setupUI()
        
        if dAge == 0.0 {
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                let dob = empData["dob"] as? String ?? ""
                let gender = empData["gender"] as? String ?? ""
                
                if dob.trimed() == "" && gender.trimed() == "" {
                    Utils.showAlertWithTitleInController("", message: "Please update your profile with correct data", controller: self)
                    return
                }
                else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    if let birthday = dateFormatter.date(from: dob) {
                        let ageComponents = Calendar.current.dateComponents([.year], from: birthday, to: Date())
                        dAge = Double(ageComponents.year ?? 0)
                    }
                    else {
                        Utils.showAlertWithTitleInController("", message: "Please update your date of birth", controller: self)
                        return
                    }
                }

                if let measurement = empData["measurements"] as? String {
                    let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
                    if arrMeasurement.count >= 2 {
                        dHei = Double(arrMeasurement[0].replacingOccurrences(of: "\"", with: ""))!
                        dWei = Double(arrMeasurement[1].replacingOccurrences(of: "\"", with: ""))!
                    }
                }
                
                isMale = gender.lowercased() == "male" ? true : false
                
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
    
    
    func setupUI() {
        self.progress_Vieww.transform = self.progress_Vieww.transform.scaledBy(x: 1, y: 0.8)
        self.progress_Vieww.setProgress(0, animated: false)
        
        // Set the rounded edge for the outer bar
        self.progress_Vieww.layer.cornerRadius = 5
        self.progress_Vieww.clipsToBounds = true

        // Set the rounded edge for the inner bar
        self.progress_Vieww.layer.sublayers![1].cornerRadius = 5
        self.progress_Vieww.subviews[1].clipsToBounds = true
        
        setupChartView()
    }
    
    func openInfoDialouge() {
        let objDialouge = EyeBlinkDialouge(nibName:"EyeBlinkDialouge", bundle:nil)
        objDialouge.delegate = self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func didTappedStart_facenaadi(_ success: Bool) {
        self.timerInterval = 30
        self.is_showingPopup = false
        self.timerr?.invalidate()
        self.didLoadSetup()
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
        lineData.setValueTextColor(AppColor.app_DarkGreenColor)
        
        let purpleColor = AppColor.app_DarkGreenColor//
        let dataSet = LineChartDataSet(entries: [], label: "Representative pulse wavefort")
        dataSet.axisDependency = .left
        dataSet.setColor(purpleColor)
        dataSet.setCircleColor(.clear)
        dataSet.lineWidth = 2
        dataSet.circleRadius = 1
        dataSet.fillAlpha = 65
        dataSet.fillColor = purpleColor.withAlphaComponent(0.5)
        dataSet.highlightColor = purpleColor
        dataSet.valueTextColor = AppColor.app_DarkGreenColor
        dataSet.valueFont = UIFont.systemFont(ofSize: 8)
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        // lineData.addDataSet(dataSet)
        lineData.append(dataSet)
        chartView.data = lineData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
#if !targetEnvironment(simulator)
        if runingModel == .liveStream {
            cameraCapture.checkCameraConfigurationAndStartSession()
        }
#endif
    }

#if !targetEnvironment(simulator)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer_facenaadiStart = nil
        self.timer_faceDetection = nil
        self.timer_facenaadiStart?.invalidate()
        self.timer_faceDetection?.invalidate()
        cameraCapture.stopSession()
    }
#endif

}

    // MARK: CameraFeedManagerDelegate Methods
extension FaceNaadiCameraVC: CameraFeedManagerDelegate {
    
    func didOutput(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) {
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        guard let cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciimage = CIImage(cvPixelBuffer: cvimgRef)
        self.bitmapImage_CI = ciimage
        self.bitmapImage = self.convert(cmage: ciimage)

        //Logic for Eye Blinking
        if self.is_showingPopup == false {
            if self.is_EyesBlink == false {
                if let faceImage = CIImage(image: self.bitmapImage) {
                    let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
                    let faces = faceDetector?.features(in: faceImage, options: [CIDetectorSmile:true, CIDetectorEyeBlink: true])
                    
                    if !faces!.isEmpty {
                        for face in faces as! [CIFaceFeature] {
                            let leftEyeClosed = face.leftEyeClosed
                            let rightEyeClosed = face.rightEyeClosed
                            let blinking = face.rightEyeClosed && face.leftEyeClosed
                            let isSmiling = face.hasSmile
                            
                            if self.is_EyesBlink == false {
                                if blinking {
                                    self.is_EyesBlink = true
                                }
                            }

                            print("blinking \(blinking)")
                        }
                    } else {
                        print("No faces found")
                    }
                }
            }
            
            if self.is_EyesBlink {
                if self.onTimeStartTimer == false {
                    debugPrint("Your Eyes blinked and Start Process")
                    self.onTimeStartTimer = true
                    //self.start_Timer()
                    DispatchQueue.main.async {
                        self.readingStartTime = Date().timeIntervalSinceReferenceDate
                        self.timer_facenaadiStart?.invalidate()
                        self.timer_facenaadiStart = nil
                        self.timer_facenaadiStart = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update_facenaadi_Timer), userInfo: nil, repeats: true)

                        self.timer_facenaadiStart = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.get_face_Image), userInfo: nil, repeats: false)
                    }
                }
            }
        }
        
        
        
        backgroundQueue.async {
            self.faceLandmarkerHelper?.detectAsync(videoFrame: sampleBuffer, orientation: orientation, timeStamps: Int(currentTimeMs))
        }
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alertController = UIAlertController(
            title: "Camera Permissions Denied",
            message:
                "Camera permissions have been denied for this app. You can change this by going to Settings",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
        
        previewView.shouldUseClipboardImage = true
    }
    
    func presentVideoConfigurationErrorAlert() {
        let alert = UIAlertController(
            title: "Camera Configuration Failed", message: "There was an error while configuring camera.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
        previewView.shouldUseClipboardImage = true
    }
    
    func sessionRunTimeErrorOccured() {
        previewView.shouldUseClipboardImage = true
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        //Updates the UI when session is interupted.
        if resumeManually {
        } else {
            self.cameraUnavailableLabel.isHidden = false
        }
    }
    
    func sessionInterruptionEnded() {
        // Updates UI once session interruption has ended.
        if !self.cameraUnavailableLabel.isHidden {
            self.cameraUnavailableLabel.isHidden = true
        }
    }

    // Convert CIImage to UIImage
    func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage)
        return image
    }

}

extension FaceNaadiCameraVC: FaceLandmarkerHelperDelegate {
    
    func faceLandmarkerHelper(_ faceLandmarkerHelper: FaceLandmarkerHelper, didFinishDetection result: ResultBundle?, error: Error?) {
        guard let dic_result = result,
              let faceLandmarkerResult = dic_result.faceLandmarkerResults.first,
              let faceLandmarkerResult = faceLandmarkerResult else { return }
        DispatchQueue.main.async {
            self.overlayView.drawLandmarks(faceLandmarkerResult.faceLandmarks,
                                           orientation: self.cameraCapture.orientation,
                                           withImageSize: self.cameraCapture.videoFrameSize)

            if self.overlayView.objectOverlays.count == 0 {
                debugPrint("Face not there")
                
                if self.is_startFaceTimer == false {
                    self.is_startFaceTimer = true
                    self.start_Timer_face_not_detect()
                }

                return
            }
            
            self.timerInterval_FACEDETECTION = 3
            
            let size = CGSize(width: 100, height: 100)
            let get_x: Int = Int(CGFloat(faceLandmarkerResult.faceLandmarks.first?[50].x ?? 0) * self.bitmapImage.size.width)
            let get_y: Int = Int(CGFloat(faceLandmarkerResult.faceLandmarks.first?[50].y ?? 0) * self.bitmapImage.size.height)
            let img_rect = CGRect.init(x: get_x, y: get_y, width: 100, height: 100)
            if let imageRef = self.bitmapImage_CI?.cropped(to: img_rect) {
                let image = UIImage(ciImage: imageRef, scale: 1.0, orientation: .right)

                let ctx = CIContext(options: [.useSoftwareRenderer: false])
                guard let cgImage = ctx.createCGImage(image.ciImage!, from: image.ciImage!.extent) else { return }
                let newImage = UIImage.init(cgImage: cgImage)
                self.img_bitmap.image = newImage
                //let newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)

                let getRGB = newImage.getPixelColors(atLocation: CGPoint.init(x: 0, y: 0), withFrameSize: size)
                if getRGB.count != 0 {
                    self.arr_RedData.append(getRGB.first ?? 0.0)
                    self.arr_GreenData.append(getRGB[1])
                    self.arr_BlueData.append(getRGB.last ?? 0.0)
                    self.arr_greenAverage.append(self.avg(greenData: self.arr_GreenData, offset: 0, length: Float(self.arr_GreenData.count)))

                    let color: UIColor = UIColor(red: CGFloat(getRGB.first ?? 0.0), green: CGFloat(getRGB[1]), blue: CGFloat(getRGB.last ?? 0.0), alpha: 1.0)
                    var hue: CGFloat = 0
                    var sat: CGFloat = 0
                    var bright: CGFloat = 0
                    
                    color.getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
                    
                    self.arrHuePoints.append(Float(hue))
                    
                    //FOR TALA
                    if self.arrHuePoints.count % self.FRAMES_PER_SECOND == 0 {
                        let hr = HeartRateDetectionModel.getMeanHR(self.arrHuePoints, time: 0)
                        self.arrHeartRates.append(hr)
                        //print("HEART RATE = \(hr)")
                    }
                    
                    self.ppgDataServer.append("{\(self.ppgDataServer.count + 1),\(getRGB.first ?? 0.0)}")

                }
                //debugPrint("converted image to RGB========>>>\(getRGB)")
                
                if self.is_EyesBlink {
                    self.updateChart()
                }
                
                
                //self.updateChart()
            }
        }
    }
    
    func start_Timer_face_not_detect() {
        self.timer_faceDetection = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update_face_detect), userInfo: nil, repeats: true)
    }
    
    @objc func update_face_detect() {
        if self.timerInterval_FACEDETECTION < 1 {
            self.timer_faceDetection?.invalidate()
            self.timer_get_faceImage?.invalidate()
            cameraCapture.stopSession()
            debugPrint("Screen Back")
            
            DispatchQueue.main.async {
                self.timerr?.invalidate()
                self.navigationController?.popViewController(animated: true)
                
                Utils.showAlertWithTitleInControllerWithCompletion("Unable to capture data".localized(), message: "Probable cause face not placed.".localized(), okTitle: "Ok".localized(), controller: appDelegate.window?.rootViewController ?? self) {
                }
            }
            
        } else {
            self.timerInterval_FACEDETECTION -= 1
        }
    }
    
    @objc func get_face_Image() {
        let get_Image = self.bitmapImage
        //debugPrint("bitmapImage=======>>>\(get_Image)")
        debugPrint("callAPIforGetFaceImageAnalysis")
        self.callAPIforGetFaceImageAnalysis()
    }

    func avg(greenData: [Float], offset: Float, length: Float) -> Float {
        var total: Float = 0.0
        for greenDatum in greenData {
            total += greenDatum
        }
        let avgValue = total/length
        return avgValue
    }


    @objc func update_facenaadi_Timer() {
        if self.str_facenaadi_process != "Algorithm_start" {
            currentReadingTime = Date().timeIntervalSinceReferenceDate - readingStartTime
            
            if self.is_showingPopup || self.is_EyesBlink == false {
                self.progress_Vieww.setProgress(0.0, animated: true)
            }
            else {
                let progress = currentReadingTime/maxReadingTimeInterval
                self.progress_Vieww.setProgress(Float(progress), animated: true)
            }
            
            if self.timerInterval > 1 {
                self.timerInterval -= 1
            } else {
                self.timer_facenaadiStart?.invalidate()
                self.timer_faceDetection?.invalidate()
                self.timer_facenaadiStart = nil
                self.timer_faceDetection = nil
                cameraCapture.stopSession()
                
                if self.str_facenaadi_process == "" {
                    self.str_facenaadi_process = "Algorithm_start"
                    self.updateProgressValue()
                }
            }
            
            debugPrint("timerInterval=====>>", self.timerInterval)
        }
    }
    
    @objc func updateChart() {
        let lineData = chartView.data ?? LineChartData()
        let dataSet = lineData.dataSets.first ?? LineChartDataSet()

        if tempData.count == 0 {
            tempData = arr_DummyData_forChart
        }
        let curveThrough = tempData[0]
        tempData.remove(at: 0)
        
        let chartEntry = ChartDataEntry(x: Double(dataSet.entryCount), y: Double(curveThrough))
        lineData.appendEntry(chartEntry, toDataSet: 0)
        lineData.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.setVisibleXRangeMaximum(200)
        chartView.moveViewToX(Double(lineData.entryCount))
    }
    
    //MARK: - Inter Process
    //MARK: === PROGRESS COMPLETED
    
    //MARK: GATI CALCULATION
    func GatiCalculationAlgo(fft_gati:[Double], SamplingRate: Int, numFrame: Int) -> Double {
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
            let aRed_HR: [Double] = HeartRateDetectionModel.butterworthBandpassFilter([arrAfterFFT[x]]) as! [Double]//([arrAfterFFT[x]], sample: Int32(samplingFrequency)) as! [Double]
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
        
        //print("FREQUENCY ======= \(samplingFrequency) = \(frequency)=====\(POMP)")
        return frequency;
    }

    
    
}


//MARK: Define default constants
enum DefaultConstants {
  static let numFaces = 3
  static let detectionConfidence: Float = 0.5
  static let presenceConfidence: Float = 0.5
  static let trackingConfidence: Float = 0.5
  static let outputFaceBlendshapes: Bool = false
  static let modelPath: String? = Bundle.main.path(forResource: "face_landmarker", ofType: "task")
}


//Calculation and Logic
extension FaceNaadiCameraVC {
    
    //MARK: === PROGRESS COMPLETED
    func updateProgressValue() {

        appDelegate.sparshanAssessmentDone = true
        self.view_animationLoad.isHidden = false
        self.view.bringSubviewToFront(self.view_animationLoad)
        
        //AMRK: - Internal Algo
        var acounter = arr_RedData.count ;
        let sampleFrequency = acounter / 30

        let ignoreTime = 4

        // Ignore 120 samples from the beginning
        let ignoreSamples = ignoreTime * sampleFrequency ;

        
        var NaRed: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
        for z in ignoreSamples..<acounter  {
            NaRed[z - ignoreSamples] = Double((-1) * arr_RedData[z]);
        }

        acounter = acounter - ignoreSamples ;

        //Remove in PPG Data
        var NaPPG: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
        for z in ignoreSamples..<acounter  {
            NaPPG[z - ignoreSamples] = Double((-1) * arr_RedData[z]);
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
        //print("GATI TYPE === \(gatiType)")

        //MARK: == RYTHM

        var ppg_data = [Double]()
        let filterd_value = butterworthBandpassFilter(signal: NaRed)
        //debugPrint("NEW filterd_value===>>", filterd_value)
        for filterValue in filterd_value {
            ppg_data.append(filterValue[0])
        }

        var mean_HR = HeartRateDetectionModel.getMeanHR(ppg_data, time: Float(sampleFrequency))

        //*****************************************************************//
        //Temp logic for matching Oximeter as per saying Ram Sir Abhilesh Sir
        mean_HR = mean_HR - 7
        //*****************************************************************//

        //========//
        var green_data = ""
        for green in self.arr_GreenData {
            green_data = green_data + "\(green) "
        }

        //debugPrint("Green Data in Strign=====>>\(green_data)")

        self.callAPIforGetHR(str_RedData: green_data, completion: { success, meanHeartRate  in
            if success {
                if meanHeartRate != 0 {
                    mean_HR = meanHeartRate ?? mean_HR
                }
            }
            self.localAlgorythm_calculations(kapha: kapha, pitta: pitta, vata: vata, counter: acounter, sampleFrequency: sampleFrequency, mean_HR: mean_HR, NaRed: NaRed, ignoreSamples: 6, arrFilteredData: arrFilteredData, gatiType: gatiType)
        })

    }

    
    func localAlgorythm_calculations(kapha: Double, pitta: Double, vata: Double, counter: Int, sampleFrequency: Int, mean_HR: Float, NaRed: [Double], ignoreSamples: Int, arrFilteredData: [Double], gatiType: String) {

        let Rythm = self.getTalaValue()
        //let Rythm_Temp = self.HRVCalculationAlgo(ppgData: NaRed, samplingRate: sampleFrequency, numFrame: counter, mean_HR: Int(mean_HR)) ;
        
        //MARK: == RR(Respiratory Rate)
        let rr = self.FFT2(input: NaRed, samplingFrequency: sampleFrequency, sizeOld: counter)
        let RR_red = ceil(60.0 * rr) ;
        print(RR_red)
        let mean_RR = Int(RR_red)
        let acounter = counter + ignoreSamples ;
        
        //calculating the mean of red and blue intensities on the whole period of recording
        let meanr = arr_RedData.reduce(0, +) / Float(acounter)
        let meanb = arr_BlueData.reduce(0, +) / Float(acounter);
        
        //calculating the standard  deviation
        var Stdb: Float = 0.0
        var Stdr: Float = 0.0
        for i in 0..<acounter - 1 {
            let bufferb = arr_BlueData[i];
            Stdb = Stdb + ((bufferb - meanb) * (bufferb - meanb));
            
            let bufferr = arr_RedData[i];
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

        //tala
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
                    
                    if UserDefaults.user.is_facenaadi_subscribed == false {
                        let free_done_count = UserDefaults.user.facenaadi_assessment_trial + 1
                        UserDefaults.user.set_facenaadi_trialCount(data: free_done_count)
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

            sparshnaValue = "\((gatiKPercentage*0.75) + (vataKPercentage*0.25))" + "," +
                            "\((gatiPPercentage*0.75) + (vataPPercentage*0.25))" + "," +
                            "\((gatiVPercentage*0.75) + (vataVPercentage*0.25))"
            kUserDefaults.set(sparshnaValue, forKey: VIKRITI_SPARSHNA)
        } else { //7
            let totalVataKPV = kaphaOld * 132 + pittaOld * 132 + vataOld * 132
            vataKPercentage = Double((kaphaOld * 132 * 100)/totalVataKPV)
            vataPPercentage = Double((pittaOld * 132 * 100)/totalVataKPV)
            vataVPercentage = Double((vataOld * 132 * 100)/totalVataKPV)

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
        

        let graphParamsDictValue = ["counter": acounter, "SamplingFreq": sampleFrequency, "Red_HR": arr_RedData.jsonStringRepresentation ?? "", "fft_gati": arrFilteredData.jsonStringRepresentation ?? ""] as [String: Any]
        let graphParamsStringValue = graphParamsDictValue.jsonStringRepresentation ?? ""
        
        ARLog(">> Internal algo Vikriti Presentage: \n \(str_vikriti_result)")
        ARLog(">> Internal algo Prakriti Presentage: \n \(str_prakriti_result)")
        ARLog(">> Internal algo sparshnaResults: \n \(sparshnaResults)")
        ARLog(">> Internal algo sparshnaValue: \n \(sparshnaValue)")
        ARLog(">> Internal algo graphParamsStringValue: \n \(graphParamsStringValue)")
        ARLog(">> Internal algo arrHeartRates[\(arrHeartRates.count)] : \n \(arrHeartRates)")

        
        
        
//        // MARK: upload sprashna data on server
//        self.postSparshnaData(value: result, sparshnaResult: sparshnaResults, sparshnaValue: sparshnaValue, graphParams: graphParamsStringValue)
//        self.uploadMeasumentDataOnServer(graphParams: graphParamsStringValue, sparshnaResult: sparshnaResults)
        
        self.str_facenaadi_result = str_vikriti_result
        self.dic_vikriti_params = sparshnaDic
        self.str_facenaadi_sparshna_result = sparshnaResults
        self.str_facenaadi_graphParamsStringValue = graphParamsStringValue
        debugPrint("FaceNaadi Process Complete=====>>", self.is_faceAnalycsAPI)
        
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
                appDelegate.cloud_vikriti_status = vikriti_pred?.type ?? ""
                
                debugPrint("str_vikriti_result========>>\(str_vikriti_result)")
                
                //MARK: - Upload FaceNaadi Data
                if self.is_faceAnalycsAPI {
                    self.callAPIforUpdateGraphaperAPI(value: str_vik, sparshnaResult: sparshnaResults, graphParams: graphParamsStringValue) { success in
                        if success {
                            self.postFaceNaadiData(vikriti_value: str_vik)
                            self.uploadMeasumentDataOnServer(graphParams: graphParamsStringValue, sparshnaResult: sparshnaResults)
                        }
                    }
                }
                else {
                    self.is_facenaadiProcess = true
                }
                
                
            }
        }
        
    }
    
    func callAPIAfterFacenaadiProcess() {
        self.callAPIforUpdateGraphaperAPI(value: self.str_facenaadi_result,
                                          sparshnaResult: self.str_facenaadi_sparshna_result,
                                          graphParams: self.str_facenaadi_graphParamsStringValue) { success in
            if success {
                self.postFaceNaadiData(vikriti_value: self.str_facenaadi_result)
                self.uploadMeasumentDataOnServer(graphParams: self.str_facenaadi_graphParamsStringValue,
                                                 sparshnaResult: self.str_facenaadi_sparshna_result)
            }
        }
    }
    
    func callAPIforGetHR(str_RedData: String, completion: @escaping (_ success: Bool, _ meanHeartRate: Float?)->Void) {
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
                        completion(false, nil)
                        return
                    }
                    var HR: Float = 0.0
                    var gati_data = ""
                    print(String(data: data, encoding: .utf8)!)
                    if let dic_json = self.dataToJSON(data: data) as? [String: Any] {
                        HR = Float(dic_json["Heart_Rate"] as? Int ?? 0)
                    }
                    completion(true, HR)
                }
            }

            task.resume()
        }
        else {
            completion(false, nil)
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
    
    func butterworthBandpassFilter(signal: [Double]) -> [[Double]] {
        
        // Calculate the filter coefficients.
        let coefficients = butterworthBandpassFilterCoefficients()
        
        // Apply the filter to the signal.
        var filteredSignal = [[Double]]()
        for sample in signal {
            filteredSignal.append(`butterworthBandpassFilter`(sample: sample, coefficients: coefficients))
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
    
    func butterworthBandpassFilter(sample: Double, coefficients: [[Double]]) -> [Double] {

      // Calculate the filter's output.
      var output = [Double]()
      for i in 0 ..< coefficients.count {
        let new_order_1 = pow(sample, Double(i) - 1)
        output.append(coefficients[i][0] * new_order_1)
      }

      return output
    }
}


//MARK: - API CALL
extension FaceNaadiCameraVC {
    
    func uploadMeasumentDataOnServer(graphParams: String, sparshnaResult: String) {
        if Utils.isConnectedToNetwork() {
            let dateOfSparshna = Date().dateString(format: "dd-MM-yyyy hh:mm:ss a")
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                //REGISTERED USER
                let userIdOld = (empData["id"] as? String ?? "")
                
                //graphParams
                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : userIdOld]
                
                //fromVC.showActivityIndicator()
                Utils.doAPICall(endPoint: .savesparshnatest, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                    if isSuccess  || status.caseInsensitiveEqualTo("Sucess") {
                        self.hideActivityIndicator()
                        //DebugLog(">> Response : \(responseJSON?.rawString() ?? "-")")
                    } else {
                        self.hideActivityIndicator()
                        //fromVC.hideActivityIndicator(withTitle: APP_NAME, Message: message)
                    }
                }
            } else {
                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : ""]
                kUserDefaults.set(params, forKey: kUserMeasurementData)
            }
            kUserDefaults.set(sparshnaResult, forKey: LAST_ASSESSMENT_DATA)
        }
    }
    
//    func postSparshnaData(value: String, sparshnaResult: String, sparshnaValue: String, graphParams: String) {
//        guard kUserDefaults.object(forKey: USER_DATA) as? [String: Any] != nil else {
//            let newValues = Utils.parseValidValue(string: value)
//            kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
//            kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
//            handleBackNavigationForSparshna()
//            return
//        }
//        
//        if Utils.isConnectedToNetwork() {
//            //fromVC.showActivityIndicator()
//            var params = ["user_vikriti": value, "vikriti_sprashna": "true", "sparshna": sparshnaResult, "vikriti_sprashnavalue": sparshnaValue/*, "suryathon_count": kUserDefaults.suryaNamaskarCount*/, "graph_params": graphParams] as [String : Any]
//            params.addVikritiResultFinalValue()
//            
//            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
//                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
//                    
//                    let newValues = Utils.parseValidValue(string: value)
//                    kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
//                    kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
//                    kUserDefaults.suryaNamaskarCount = 0 //reset count
//                    self.hideActivityIndicator()
//                    
//                    self.handleBackNavigationForSparshna()
//                } else {
//                    var finalMessage = message
//                    if finalMessage.isEmpty {
//                        finalMessage = responseJSON?["error"].stringValue ?? ""
//                    }
//                    self.hideActivityIndicator()
//                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: self) {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//            }
//        } else {
//            handleBackNavigationForSparshna()
//        }
//    }
    
    func handleBackNavigationForSparshna() {
        if UserDefaults.user.is_facenaadi_subscribed == false {
            let free_done_count = UserDefaults.user.facenaadi_assessment_trial + 1
            UserDefaults.user.set_facenaadi_trialCount(data: free_done_count)
        }
        self.gotoResultScreen()
    }
    
    func gotoResultScreen() {
        appDelegate.sparshanAssessmentDone = true

        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
            let vc = PrakritiResult1VC.instantiate(fromAppStoryboard: .Questionnaire)
            vc.hidesBottomBarWhenPushed = true
            vc.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        else {
            let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
            let objDescription = storyBoard.instantiateViewController(withIdentifier: "LastAssessmentVC") as! LastAssessmentVC
            objDescription.isFromCameraView = true
            self.navigationController?.pushViewController(objDescription, animated: true)
        }
    }
}


//MARK: - API Call
extension FaceNaadiCameraVC {
    
    func callAPIforUpdateGraphaperAPI(value: String, sparshnaResult: String, graphParams: String, completion: @escaping (_ success: Bool)->Void) {
        guard kUserDefaults.object(forKey: USER_DATA) as? [String: Any] != nil else {
            let newValues = Utils.parseValidValue(string: value)
            kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
            kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
            handleBackNavigationForSparshna()
            return
        }
        
        if Utils.isConnectedToNetwork() {

            let str_Image =  self.convertImageToBase64String(img: self.bitmapImage)// self.bitmapImage.toBase64()
            
            self.dic_face_anylysic["user_ffs"] = ""
            self.dic_face_anylysic["user_ppf"] = ""
            self.dic_face_anylysic["sparshna"] = sparshnaResult
            self.dic_face_anylysic["graph_params"] = graphParams
            self.dic_face_anylysic["type_of_assessment"] = "facenaadi"
            self.dic_face_anylysic["image"] = str_Image
            
            let params = self.dic_face_anylysic

            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
                    completion(true)
                } else {
                    var finalMessage = message
                    if finalMessage.isEmpty {
                        finalMessage = responseJSON?["error"].stringValue ?? ""
                    }
                    self.hideActivityIndicator()
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            handleBackNavigationForSparshna()
        }
    }
    
    func postFaceNaadiData(vikriti_value: String) {
        
        if Utils.isConnectedToNetwork() {
            //fromVC.showActivityIndicator()
            var params = ["user_vikriti": vikriti_value,
                          "vikriti_sprashna": "true",
                          "aggravation": appDelegate.cloud_vikriti_status] as [String : Any]
            //params.addVikritiResultFinalValue()
            
            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
                    
                    let newValues = Utils.parseValidValue(string: vikriti_value)
                    kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
                    kUserDefaults.set(true, forKey: kVikritiSparshanaCompleted)
                    kUserDefaults.suryaNamaskarCount = 0 //reset count
                    self.hideActivityIndicator()
                    
                    self.handleBackNavigationForSparshna()
                } else {
                    var finalMessage = message
                    if finalMessage.isEmpty {
                        finalMessage = responseJSON?["error"].stringValue ?? ""
                    }
                    self.hideActivityIndicator()
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            handleBackNavigationForSparshna()
        }
    }
    
    func callAPIforGetFaceImageAnalysis() {
        if Utils.isConnectedToNetwork() {
            //self.showActivityIndicator()
            AF.upload(multipartFormData: { (multipartFormData) in
                
                guard let imgData = self.bitmapImage.jpegData(compressionQuality: 0.25) else { return }
                let timestamp = NSDate().timeIntervalSince1970
                multipartFormData.append(imgData, withName: "image", fileName: String(timestamp) + ".jpeg", mimeType: "image/jpeg")
                
            },to: URL.init(string: kAPIFaceAnalysis)!, usingThreshold: UInt64.init(), method: .post, headers: Utils.apiCallHeaders).response { response in
                if((response.error == nil)) {
                    do {
                        if let jsonData = response.data {
                            let dic_json_result = try? JSONDecoder().decode(ResultFaceAnalysic.self, from: jsonData)
                            let str_age = dic_json_result?.age?.joined(separator: ", ")
                            let str_emotion = dic_json_result?.emotion?.joined(separator: ", ")
                            let str_eye_color = dic_json_result?.eye_color?.joined(separator: ", ")
                            let str_hair = dic_json_result?.hair?.joined(separator: ", ")
                            let str_skin_color = dic_json_result?.skin_color?.joined(separator: ", ")
                            
                            self.dic_face_anylysic = ["age": str_age ?? "",
                                                      "emotion": str_emotion ?? "",
                                                      "eye_color": str_eye_color ?? "",
                                                      "hair": str_hair ?? "",
                                                      "skin_color": str_skin_color ?? ""]
                            debugPrint(self.dic_face_anylysic)
                            self.is_faceAnalycsAPI = true
                            debugPrint("Face analytics api response === >>", self.is_facenaadiProcess)
                            
                            if self.is_facenaadiProcess {
                                self.callAPIAfterFacenaadiProcess()
                            }
                        }
                    }catch{
                        print("error message")
                    }
                    self.hideActivityIndicator()
                } else{
                    self.hideActivityIndicator()
                    print(response.error!.localizedDescription)
                }
            }
        }
        
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.25)?.base64EncodedString() ?? ""
    }
    
    
    //MARK: - Call API for Get Vikriti Python Logic
    func callAPIforVikritiPredictioPythonAPI(vikriti_values: String, prakriti_values: String, completion: @escaping (_ success: Bool, _ model_result: Vikriti_Prediction_Model?)->Void) {
        
        if Utils.isConnectedToNetwork() {
            self.showActivityIndicator()
            
            var str_ppgData = ""
            let urlString = kAPIVikritiPredction
            
            for ppgData in self.arr_RedData {
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
