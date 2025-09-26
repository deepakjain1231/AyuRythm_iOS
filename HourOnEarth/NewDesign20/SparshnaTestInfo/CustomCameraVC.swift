//
//  CustomCameraVC.swift
//  Tummoc
//
//  Created by Deepak Jain on 18/03/22.
//  Copyright © 2022 Tummoc. All rights reserved.
//

import UIKit
import MLKit
import MLImage
import CoreVideo
import AVFoundation
import Alamofire
import SwiftyJSON


protocol delegateClickedImage {
    func customCameraCliickedImage(_ success: Bool, clickedimage: UIImage)
}

class CustomCameraVC: UIViewController {

    var resultsText = ""
    var clicked_image = UIImage()
    //var delegate: delegateClickedImage?
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var view_Base_BG: UIView!
    
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
    
    var ppgDataServer:[String] = [String]()
    var fftDataServer:[String] = [String]()
    var newFFT = FFT()
    var isTalaRegular = false
    
    var is_TimerStart = false
    
    //For Custom Camera
    var is_CaptureEnable = false
    var lastFrame: CMSampleBuffer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    
    private var isUsingFrontCamera = true
    private lazy var captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    
    private lazy var previewOverlayView: UIImageView = {
      precondition(isViewLoaded)
      let previewOverlayView = UIImageView(frame: .zero)
      previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
      previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return previewOverlayView
    }()
    
    private lazy var annotationOverlayView: UIView = {
      precondition(isViewLoaded)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return annotationOverlayView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        setUpPreviewOverlayView()
        setUpAnnotationOverlayView()
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
        let overlay = createOverlay(frame: view.frame, xOffset: view.frame.midX, yOffset: view.frame.midY, radius: 150)
        self.view.addSubview(overlay)
        

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
            
            
        
        // MARK: - Change Status Bar Style
        navigationController?.navigationBar.barStyle = .black
    }
    
    
    func createOverlay(frame: CGRect, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> UIView {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.white
        // Step 2
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                    radius: radius,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.0
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        // For Swift 4.2
        maskLayer.fillRule = .evenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true

        return overlayView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view_Base_BG.frame
    }
    
    func setUpCaptureSessionOutput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.beginConfiguration()
            // When performing latency tests to determine ideal capture settings,
            // run the app in 'release' mode to get accurate performance metrics
            strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.medium
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
            guard strongSelf.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            strongSelf.captureSession.addOutput(output)
            strongSelf.captureSession.commitConfiguration()
        }
    }

    func setUpCaptureSessionInput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            let cameraPosition: AVCaptureDevice.Position = strongSelf.isUsingFrontCamera ? .front : .back
            guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                strongSelf.captureSession.beginConfiguration()
                let currentInputs = strongSelf.captureSession.inputs
                for input in currentInputs {
                    strongSelf.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard strongSelf.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                strongSelf.captureSession.addInput(input)
                strongSelf.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }

    func startSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.startRunning()
        }
    }

    func stopSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.stopRunning()
        }
    }
    
    func setUpPreviewOverlayView() {
        self.view_Base_BG.addSubview(previewOverlayView)
        NSLayoutConstraint.activate([
            previewOverlayView.centerXAnchor.constraint(equalTo: view_Base_BG.centerXAnchor),
            previewOverlayView.centerYAnchor.constraint(equalTo: view_Base_BG.centerYAnchor),
            previewOverlayView.leadingAnchor.constraint(equalTo: view_Base_BG.leadingAnchor),
            previewOverlayView.trailingAnchor.constraint(equalTo: view_Base_BG.trailingAnchor),
            
        ])
    }

    func setUpAnnotationOverlayView() {
        self.view_Base_BG.addSubview(annotationOverlayView)
        NSLayoutConstraint.activate([
            annotationOverlayView.topAnchor.constraint(equalTo: view_Base_BG.topAnchor),
            annotationOverlayView.leadingAnchor.constraint(equalTo: view_Base_BG.leadingAnchor),
            annotationOverlayView.trailingAnchor.constraint(equalTo: view_Base_BG.trailingAnchor),
            annotationOverlayView.bottomAnchor.constraint(equalTo: view_Base_BG.bottomAnchor),
        ])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - UIButton Method Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Instruction_Action(_ sender: UIControl) {
    }
    
    @IBAction func btn_takeSelfie_Action(_ sender: UIControl) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        if self.is_CaptureEnable {
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @IBAction func btn_Proceed_Action(_ sender: UIControl) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_close_Action(_ sender: UIControl) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIView.AnimationOptions.curveEaseInOut) {
        } completion: { success in
        }
    }
}

extension CustomCameraVC : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }
        
        guard let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }
        
        let width = capturedImage.size.width
        let height = capturedImage.size.height
        let origin = CGPoint(x: 0, y: 0)// (width - height)/2, y: (height - height)/2)
        let size = CGSize(width: height, height: height)
        
        guard let imageRef = capturedImage.cgImage?.cropping(to: CGRect(origin: origin, size: size)) else {
            print("Fail to crop image")
            return
        }
        
        self.clicked_image = UIImage(cgImage: imageRef, scale: 1.0, orientation: .leftMirrored)
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIView.AnimationOptions.curveEaseInOut) {
        } completion: { success in
        }
    }
}

extension CustomCameraVC : AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            return discoverySession.devices.first { $0.position == position }
        }
        return nil
    }
        
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = imageOrientation(fromDevicePosition: .front)
        visionImage.orientation = orientation
        
        guard let inputImage = MLImage(sampleBuffer: sampleBuffer) else {
            print("Failed to create MLImage from sample buffer.")
            return
        }
        inputImage.orientation = orientation
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        guard let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        let image = UIImage(ciImage: ciimage, scale: 1.0, orientation: orientation)

        self.detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight, capturedImage: image)
    }
    
    func colorForPixel(image: UIImage, x: Int, y: Int) -> UIColor {
        let cgImage =  image.cgImage
        
        let imageWidth = cgImage!.width
        let imageHeight = cgImage!.height
        let bytesPerPixel = cgImage!.bitsPerPixel / 8
        
        //print("\(imageWidth) x \(imageHeight) x \(bytesPerPixel)")
        let pixelData:CFData! = (image as! CGImage).dataProvider?.data
        let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        // CGImage is flipped. So (imageHeight - y) is needed.
        let pixelValue = data + (imageWidth * (imageHeight - y) + x) * bytesPerPixel
        
        // kCVPixelFormatType_32BGRA
        let blue  = CGFloat(pixelValue[0])
        let green = CGFloat(pixelValue[1])
        let red   = CGFloat(pixelValue[2])
        let alpha = CGFloat(pixelValue[3])
        
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha / 255)
    }
        
    func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat, capturedImage: UIImage) {
        // When performing latency tests to determine ideal detection settings, run the app in 'release'
        // mode to get accurate performance metrics.
        let options = FaceDetectorOptions()
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .all
        options.performanceMode = .accurate
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        var faces: [Face] = []
        var detectionError: Error?
        do {
            faces = try faceDetector.results(in: image)
        } catch let error {
            detectionError = error
        }
        weak var weakSelf = self
        DispatchQueue.main.sync {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.updatePreviewOverlayViewWithLastFrame()
            if let detectionError = detectionError {
                print("Failed to detect faces with error: \(detectionError.localizedDescription).")
                return
            }
            guard !faces.isEmpty else {
                print("On-Device face detector returned no results.")
                return
            }
            
            if faces.count != 0 {
                if self.is_TimerStart == false {
                    self.is_TimerStart = true
                    Timer.scheduledTimer(withTimeInterval: 25.0, repeats: false) { timeeeer in
                        timeeeer.invalidate()
                        debugPrint("Red Data======>>>>", self.arr_RedData)
                        debugPrint("Green Data======>>>>", self.arr_GreenData)
                        debugPrint("Blue Data=======>>>>", self.arr_BlueData)
                        debugPrint("arr_greenAverage======>>>>", self.arr_greenAverage)
                        
                        //self.callAPIforgetFacenaadiData()
                        self.updateProgressValue()
                        //self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
            
            for face in faces {
                let transform = strongSelf.transformMatrix(capturedimage: capturedImage)
                //let transformedRect = face.frame.applying(transform)
                
                //let normalizedRect = CGRect(
                //x: face.frame.origin.x / width,
                //y: face.frame.origin.y / height,
                //width: face.frame.size.width / width,
                //height: face.frame.size.height / height
                //)
                //let standardizedRect = strongSelf.previewLayer.layerRectConverted(fromMetadataOutputRect: normalizedRect).standardized
                //UIUtilities.addRectangle(standardizedRect, to: strongSelf.annotationOverlayView, color: UIColor.green)
                strongSelf.addContours(for: face, width: width, height: height)
                strongSelf.addLandmarks(forFace: face, transform: transform, capturedimage: capturedImage)
            }
            
            
            strongSelf.resultsText = faces.map { face in
                
                let headEulerAngleX = face.hasHeadEulerAngleX ? face.headEulerAngleX.description : "NA"
                let headEulerAngleY = face.hasHeadEulerAngleY ? face.headEulerAngleY.description : "NA"
                let headEulerAngleZ = face.hasHeadEulerAngleZ ? face.headEulerAngleZ.description : "NA"
                let leftEyeOpenProbability = face.hasLeftEyeOpenProbability ? face.leftEyeOpenProbability.description : "NA"
                let rightEyeOpenProbability = face.hasRightEyeOpenProbability ? face.rightEyeOpenProbability.description : "NA"
                let smilingProbability = face.hasSmilingProbability ? face.smilingProbability.description : "NA"
                let LeftCheekX = face.landmark(ofType: .leftCheek)?.position.x ?? 0.0
                let LeftCheekY = face.landmark(ofType: .leftCheek)?.position.x ?? 0.0
                let RightCheekX = face.landmark(ofType: .rightCheek)?.position.x ?? 0.0
                let RightCheekY = face.landmark(ofType: .rightCheek)?.position.x ?? 0.0
                
                let output = """
          Frame: \(face.frame)
          Head Euler Angle X: \(headEulerAngleX)
          Head Euler Angle Y: \(headEulerAngleY)
          Head Euler Angle Z: \(headEulerAngleZ)
          Left Cheek X: \(LeftCheekX)
          Left Cheek Y: \(LeftCheekY)
          Right Cheek X: \(RightCheekX)
          Right Cheek Y: \(RightCheekY)
          Left Eye Open Probability: \(leftEyeOpenProbability)
          Right Eye Open Probability: \(rightEyeOpenProbability)
          Smiling Probability: \(smilingProbability)
          """
                return "\(output)"
            }.joined(separator: "\n")
            //print(resultsText)
            //strongSelf.showResults()
            // [END_EXCLUDE]
        }
    }
    
    func transformMatrix(capturedimage: UIImage) -> CGAffineTransform {
        let image = capturedimage
        let imageViewWidth = previewLayer.frame.size.width
        let imageViewHeight = previewLayer.frame.size.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let imageViewAspectRatio = imageViewWidth / imageViewHeight
        let imageAspectRatio = imageWidth / imageHeight
        let scale =
        (imageViewAspectRatio > imageAspectRatio)
        ? imageViewHeight / imageHeight : imageViewWidth / imageWidth
        
        // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
        // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
        let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)
        
        var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
        transform = transform.scaledBy(x: scale, y: scale)
        return transform
    }
    
    
    
    private func updatePreviewOverlayViewWithLastFrame() {
      guard let lastFrame = lastFrame,
        let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
      else {
        return
      }
      self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
      self.removeDetectionAnnotations()
    }
    
    func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
        guard let imageBuffer = imageBuffer else {
            return
        }
        let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
        let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
        previewOverlayView.image = image
    }
    
    func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
    
    func normalizedPoint(fromVisionPoint point: VisionPoint, width: CGFloat, height: CGFloat) -> CGPoint {
        let cgPoint = CGPoint(x: point.x, y: point.y)
        var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
        normalizedPoint = self.previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
        return normalizedPoint
    }
    
    func pointFrom(_ visionPoint: VisionPoint) -> CGPoint {
        return CGPoint(x: visionPoint.x - 20, y: visionPoint.y - 20)
    }
    
    private func addContours(for face: Face, width: CGFloat, height: CGFloat) {
      // Face
      if let faceContour = face.contour(ofType: .face) {
        for point in faceContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.blue,
            radius: Constant.smallDotRadius
          )
        }
      }

      // Eyebrows
      if let topLeftEyebrowContour = face.contour(ofType: .leftEyebrowTop) {
        for point in topLeftEyebrowContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.orange,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let bottomLeftEyebrowContour = face.contour(ofType: .leftEyebrowBottom) {
        for point in bottomLeftEyebrowContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.orange,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let topRightEyebrowContour = face.contour(ofType: .rightEyebrowTop) {
        for point in topRightEyebrowContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.orange,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let bottomRightEyebrowContour = face.contour(ofType: .rightEyebrowBottom) {
        for point in bottomRightEyebrowContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.orange,
            radius: Constant.smallDotRadius
          )
        }
      }

      // Eyes
      if let leftEyeContour = face.contour(ofType: .leftEye) {
        for point in leftEyeContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.cyan,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let rightEyeContour = face.contour(ofType: .rightEye) {
        for point in rightEyeContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.cyan,
            radius: Constant.smallDotRadius
          )
        }
      }

      // Lips
      if let topUpperLipContour = face.contour(ofType: .upperLipTop) {
        for point in topUpperLipContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.red,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let bottomUpperLipContour = face.contour(ofType: .upperLipBottom) {
        for point in bottomUpperLipContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.red,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let topLowerLipContour = face.contour(ofType: .lowerLipTop) {
        for point in topLowerLipContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.red,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let bottomLowerLipContour = face.contour(ofType: .lowerLipBottom) {
        for point in bottomLowerLipContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.red,
            radius: Constant.smallDotRadius
          )
        }
      }

      // Nose
      if let noseBridgeContour = face.contour(ofType: .noseBridge) {
        for point in noseBridgeContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.yellow,
            radius: Constant.smallDotRadius
          )
        }
      }
      if let noseBottomContour = face.contour(ofType: .noseBottom) {
        for point in noseBottomContour.points {
          let cgPoint = normalizedPoint(fromVisionPoint: point, width: width, height: height)
          UIUtilities.addCircle(
            atPoint: cgPoint,
            to: annotationOverlayView,
            color: UIColor.yellow,
            radius: Constant.smallDotRadius
          )
        }
      }
    }
    
    func addLandmarks(forFace face: Face, transform: CGAffineTransform, capturedimage: UIImage) {
        // Cheeks
        if let leftCheekLandmark = face.landmark(ofType: .rightCheek) {
            let point = pointFrom(leftCheekLandmark.position)
            let transformedPoint = point.applying(transform)
            UIUtilities.addCircle(atPoint: transformedPoint, to: annotationOverlayView, color: UIColor.orange, radius: Constant.largeDotRadius)
            
            let size = CGSize(width: Constant.largeDotRadius, height: Constant.largeDotRadius)
            //let image = capturedimage.crop(to: size, x_ypoint: point)
            let img_rect = CGRect.init(x: point.x, y: point.y, width: 50, height: 50)
            if let imageRef = capturedimage.ciImage?.cropped(to: img_rect) {
                let image = UIImage(ciImage: imageRef, scale: 1.0, orientation: .right)
                
                let ctx = CIContext(options: [.useSoftwareRenderer: false])
                guard let cgImage = ctx.createCGImage(image.ciImage!, from: image.ciImage!.extent) else { return }
                let newImage = UIImage.init(cgImage: cgImage)
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
                        print("HEART RATE = \(hr)")
                    }
                    
                    self.ppgDataServer.append("{\(self.ppgDataServer.count + 1),\(getRGB.first ?? 0.0)}")
                    
                    
                    
                    
                    
                }
                debugPrint("converted image to RGB========>>>\(getRGB)")
            }

        }
//        if let rightCheekLandmark = face.landmark(ofType: .leftCheek) {
//            let point = pointFrom(rightCheekLandmark.position)
//            let transformedPoint = point.applying(transform)
//            UIUtilities.addCircle(
//                atPoint: transformedPoint,
//                to: annotationOverlayView,
//                color: UIColor.orange,
//                radius: Constant.largeDotRadius
//            )
//        }
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
//    func uiimagetoRGB(right_cheekImage: UIImage) {
//        let inputCIImage = right_cheekImage.ciImage
//        let width = CIImage.wi CGImageGetWidth(inputCGImage)
//        let height = CGImageGetHeight(inputCGImage)
//
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        let bitsPerComponent = 8
//
//        let pixels = UnsafeMutablePointer<UInt32>(calloc(height * width, sizeof(UInt32)))
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//
//        let context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
//
//        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage)
//
//        let dataType = UnsafePointer<UInt8>(pixels)
//
//        for j in 0 ..< height {
//          for i in 0 ..< width {
//            let offset = 4*((Int(width) * Int(j)) + Int(i))
//            let alphaValue = dataType[offset] as UInt8
//            let redColor = dataType[offset+1] as UInt8
//            let greenColor = dataType[offset+2] as UInt8
//            let blueColor = dataType[offset+3] as UInt8
//          }
//        }
//
//        free(pixels)
//    }
    
    func showResults() {
        let resultsAlertController = UIAlertController(title: "Detection Results", message: nil, preferredStyle: .actionSheet)
        resultsAlertController.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in
            resultsAlertController.dismiss(animated: true, completion: nil)
        })
        resultsAlertController.message = resultsText
        present(resultsAlertController, animated: true, completion: nil)
        print(resultsText)
    }
    
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) ->UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
    
    func avg(greenData: [Float], offset: Float, length: Float) -> Float {
        var total: Float = 0.0
        for greenDatum in greenData {
            total += greenDatum
        }
        let avgValue = total/length
        return avgValue
    }
}







extension UIImage {
    func getPixelColors(atLocation location: CGPoint, withFrameSize size: CGSize) -> [Float] {
        let x: CGFloat = (self.size.width) * location.x / size.width
        let y: CGFloat = (self.size.height) * location.y / size.height
        let pixelPoint: CGPoint = CGPoint(x: x, y: y)
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelIndex: Int = ((Int(self.size.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4
        let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
        let g = CGFloat(data[pixelIndex+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelIndex+2]) / CGFloat(255.0)
        
//        let a = CGFloat(data[pixelIndex+3]) / CGFloat(255.0)
        return [Float(r), Float(g), Float(b)]
        //let testColor = UIColor(red: r, green: g, blue: b, alpha: a)
        //return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}


//MARK: - API Call
extension CustomCameraVC {
 
    func callAPIforgetFacenaadiData() {

        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            
            var str_ppgData = ""
            var str_redData = ""
            var str_greenData = ""
            var str_blueData = ""
            let urlString = kAPIforFaceNaadi
            
            for ppgData in self.arr_greenAverage {
                str_ppgData += "\(ppgData) "
            }
            
            for redData in self.arr_RedData {
                str_redData += "\(redData) "
            }
            
            for greenData in self.arr_GreenData {
                str_greenData += "\(greenData) "
            }
            
            for blueData in self.arr_BlueData {
                str_blueData += "\(blueData) "
            }
            
            var str_gender = ""
            var str_userAge = ""
            var str_height = ""
            var str_weight = ""
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                str_gender = empData["gender"] as? String ?? ""
                let str_dob = empData["dob"] as? String ?? ""
                str_userAge = "\(self.calcAge(birthday: str_dob))"
                let measurement = empData["measurements"] as? String ?? ""
                let dict = measurement.toJSON() as? [String] ?? []
                str_height = dict.first ?? ""
                str_weight = dict[1]
            }

            let params = ["ppg": str_ppgData.trimed(),
                          "red": str_redData.trimed(),
                          "blue": str_blueData.trimed(),
                          "green": str_greenData.trimed(),
                          "age": str_userAge, "weight": str_weight, "height": str_height, "gender": str_gender]
            
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
                  print("facenaadi api response:======>>", response ?? [])
                return
              }
                print(String(data: data, encoding: .utf8)?.toJSON() ?? [])
                if let dic_response = String(data: data, encoding: .utf8)?.toJSON() as? [String: Any] {
                    
                    let BPM: Int = Int(dic_response["BPM"] as? Double ?? 0.0)
                    let SP: Int = Int(dic_response["SP"] as? Double ?? 0.0)
                    let DP: Int = Int(dic_response["DP"] as? Double ?? 0.0)
                    let Rythm: Int = Int(dic_response["Rythm"] as? Double ?? 0.0)
                    let Bala: Int = Int(dic_response["Bala"] as? Double ?? 0.0)
                    let kathinya: Int = Int(dic_response["kathinya"] as? Double ?? 0.0)
                    let Gati = dic_response["Gati"] as? String ?? ""
                    let Spo2: Int = Int(dic_response["Spo2"] as? Double ?? 0.0)
                    let pbreath: Int = Int(dic_response["pbreath"] as? Double ?? 0.0)
                    let BMI: Double = dic_response["BMI"] as? Double ?? 0.0
                    let BMR: Int = Int(dic_response["BMR"] as? Double ?? 0.0)
                    let tbpm: Int = Int(dic_response["tbpm"] as? Double ?? 0.0)
                    
                    let Kapha: Double = Double(dic_response["Kapha"] as? String ?? "") ?? 0.0
                    let Pitta: Double = Double(dic_response["Pitta"] as? String ?? "") ?? 0.0
                    let Vata: Double = Double(dic_response["Vata"] as? String ?? "") ?? 0.0
                    
                    let result = "[" + "\"\(Kapha.roundToOnePlace)\",\"\(Pitta.roundToOnePlace)\",\"\(Vata.roundToOnePlace)\"" + "]"

                    let acounter = dic_response["counter"] as? Int ?? 0
                    let sampleFrequency = dic_response["SamplingFreq"] as? Int ?? 0
                    
                    let Fft_Gati = dic_response["Fft_Gati"] as? String ?? ""
                    let dicGati = Fft_Gati.toJSON() as? [String: Any] ?? [:]
                    let arr_gati = dicGati["gati_fft1"] as? [Double] ?? []
                    
                    let Red_HR = dic_response["Red_HR"] as? String ?? ""
                    let dicRed_HR = Red_HR.toJSON() as? [String: Any] ?? [:]
                    let arr_red_HR = dicRed_HR["X"] as? [Double] ?? []
                    
                    var sparshnaResults = ""
                    let sparshnaDic = ["bpm": BPM, "sp": SP,"dp": DP, "rythm": Rythm, "bala": Bala, "kath": kathinya, "gati": Gati, "o2r": Spo2, "pbreath": pbreath, "bmi": BMI, "bmr": BMR, "tbpm": tbpm] as [String : Any]
                    //TODO: need to check tbpm in android -- why used ??
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: sparshnaDic, options: JSONSerialization.WritingOptions.prettyPrinted)
                        sparshnaResults = String(bytes: jsonData, encoding: .utf8) ?? ""
                    } catch let error {
                        print(error)
                    }
                    
                    let graphParamsDictValue = ["counter": acounter, "SamplingFreq": sampleFrequency, "Red_HR": arr_red_HR.jsonStringRepresentation ?? "", "fft_gati": arr_gati.jsonStringRepresentation ?? ""] as [String: Any]
                    let graphParamsStringValue = graphParamsDictValue.jsonStringRepresentation ?? ""
                    
                    let sparshnaValue = "\(Kapha.roundToOnePlace),\(Pitta.roundToOnePlace),\(Vata.roundToOnePlace)"
                    
                    ARLog(">> result: \n \(result)")
                    ARLog(">> sparshnaResults: \n \(sparshnaResults)")
                    ARLog(">> sparshnaValue: \n \(sparshnaValue)")
                    ARLog(">> graphParamsStringValue: \n \(graphParamsStringValue)")
                    
                    // MARK: upload sprashna data on server
                    self.postSparshnaData(value: result, sparshnaResult: sparshnaResults, sparshnaValue: sparshnaValue, graphParams: graphParamsStringValue)
                    self.uploadMeasumentDataOnServer(graphParams: graphParamsStringValue, sparshnaResult: sparshnaResults)
                }
            }

            task.resume()
        }
        else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
        
    }
    
    func uploadMeasumentDataOnServer(graphParams: String, sparshnaResult: String) {
        if Utils.isConnectedToNetwork() {
            let dateOfSparshna = Date().dateString(format: "dd-MM-yyyy hh:mm:ss a")
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                //REGISTERED USER
                let userIdOld = (empData["id"] as? String ?? "")
                
                //graphParams
                let params = ["user_date": dateOfSparshna, "user_percentage": "", "user_ffs": "", "user_ppf": "" , "user_result": sparshnaResult, "graph_params": "" , "user_duid" : userIdOld]
                
                Utils.doAPICall(endPoint: .savesparshnatest, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                    if isSuccess  || status.caseInsensitiveEqualTo("Sucess") {
                        //DebugLog(">> Response : \(responseJSON?.rawString() ?? "-")")
                    } else {
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
    
    
    func postSparshnaData(value: String, sparshnaResult: String, sparshnaValue: String, graphParams: String) {
        if Utils.isConnectedToNetwork() {
            var params = ["user_vikriti": value, "vikriti_sprashna": "true", "sparshna": sparshnaResult, "vikriti_sprashnavalue": sparshnaValue/*, "suryathon_count": kUserDefaults.suryaNamaskarCount*/, "graph_params": graphParams] as [String : Any]
            params.addVikritiResultFinalValue()
            
            Utils.doAPICall(endPoint: .usergraphspar, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
                if isSuccess || status.caseInsensitiveEqualTo("Sucess") {
                    
                    let newValues = Utils.parseValidValue(string: value)
                    kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
                    
                    self.handleBackNavigationForSparshna(fromVC: self)
                } else {
                    var finalMessage = message
                    if finalMessage.isEmpty {
                        finalMessage = responseJSON?["error"].stringValue ?? ""
                    }
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: finalMessage, okTitle: "Ok".localized(), controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    
    func handleBackNavigationForSparshna(fromVC: UIViewController) {

        /*
        let storyBoard = UIStoryboard(name: "SparshnaResult", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "SparshnaResult") as! SparshnaResult
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
        #else
        // Code your app clip may access.
        objDescription.isRegisteredUser = false
        #endif
        objDescription.isFromCameraView = true
        fromVC.navigationController?.pushViewController(objDescription, animated: true)
        */
        
        
        let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "LastAssessmentVC") as! LastAssessmentVC
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        //objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
        #else
        // Code your app clip may access.
        //objDescription.isRegisteredUser = false
        #endif
        objDescription.isFromCameraView = true
        fromVC.navigationController?.pushViewController(objDescription, animated: true)
    }
    
    
    
    //MARK: - Inter Process
    //MARK: === PROGRESS COMPLETED
    func updateProgressValue() {
        
        //STOP AND MOVE TO NEXT SCREEN
        var acounter = self.arr_RedData.count ;
        let sampleFrequency = acounter / 25

        let ignoreTime = 0

        // Ignore 120 samples from the beginning
        let ignoreSamples = ignoreTime * sampleFrequency ;

        var NaRed: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
        for z in ignoreSamples..<acounter  {
            NaRed[z - ignoreSamples] = Double((-1) * self.arr_RedData[z]);
        }

        acounter = acounter - ignoreSamples ;

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

        let aRed_HR = NaRed.compactMap({return -1 * (HeartRateDetectionModel.butterworthBandpassFilter([$0]) as! [Double]).first!})

        //   PASS
        let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]

        let mean_HR = HeartRateDetectionModel.getMeanHR(aRed_HR_ButterWorthHue, time: Float(sampleFrequency))

        let Rythm = self.getTalaValue()

        //MARK: == RR(Respiratory Rate)
        let rr = self.FFT2(input: NaRed, samplingFrequency: sampleFrequency, sizeOld: acounter)
        let RR_red = ceil(60.0 * rr) ;
        print(RR_red)
        let mean_RR = Int(RR_red)
        acounter = acounter + ignoreSamples ;
        
        //calculating the mean of red and blue intensities on the whole period of recording
        let meanr = self.arr_RedData.reduce(0, +) / Float(acounter)
        let meanb = self.arr_BlueData.reduce(0, +) / Float(acounter);
        
        //calculating the standard  deviation
        var Stdb: Float = 0.0
        var Stdr: Float = 0.0
        for i in 0..<acounter - 1 {
            let bufferb = self.arr_BlueData[i];
            Stdb = Stdb + ((bufferb - meanb) * (bufferb - meanb));
            
            let bufferr = self.arr_RedData[i];
            Stdr = Stdr + ((bufferr - meanr) * (bufferr - meanr));
            
        }
        
        //calculating the variance
        let varr = sqrt(Stdr / Float(acounter - 1));
        let varb = sqrt(Stdb / Float(acounter - 1));
        
        //calculating ratio between the two means and two variances
        let R = (varr / meanr) / (varb / meanb);
        
        //estimating SPo2
        let spo2 = 100 - 5 * (R)
        
        let o2 = spo2
        
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
        
        let result = "[" + Utils.getVikritiValue() + "]"
        
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

        let graphParamsDictValue = ["counter": acounter, "SamplingFreq": sampleFrequency, "Red_HR": self.arr_RedData.jsonStringRepresentation ?? "", "fft_gati": arrFilteredData.jsonStringRepresentation ?? ""] as [String: Any]
        let graphParamsStringValue = graphParamsDictValue.jsonStringRepresentation ?? ""
        
        ARLog(">> result: \n \(result)")
        ARLog(">> sparshnaResults: \n \(sparshnaResults)")
        ARLog(">> sparshnaValue: \n \(sparshnaValue)")
        ARLog(">> graphParamsStringValue: \n \(graphParamsStringValue)")
        ARLog(">> arrHeartRates[\(arrHeartRates.count)] : \n \(arrHeartRates)")
        
        // MARK: upload sprashna data on server
        self.postSparshnaData(value: result, sparshnaResult: sparshnaResults, sparshnaValue: sparshnaValue, graphParams: graphParamsStringValue)
        self.uploadMeasumentDataOnServer(graphParams: graphParamsStringValue, sparshnaResult: sparshnaResults)
    }
    
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
        
        print("FREQUENCY ======= \(samplingFrequency) = \(frequency)=====\(POMP)")
        return frequency;
    }
    
}


extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
