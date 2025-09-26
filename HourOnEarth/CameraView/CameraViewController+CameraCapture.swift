//
//  CameraViewController+CameraCapture.swift
//  HourOnEarth
//
//  Created by Pradeep on 12/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//
/*
import UIKit

// Typealias for RGB color values
typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

// Typealias for HSV color values
typealias HSV = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)


extension CameraViewController {
    
    
    
    /*
       Method for Camera Setup
     */
    func setUpCamera() {
        let modelName = UIDevice.modelName
        
//         let capturedDevices = AVCaptureDevice.devices(for: AVMediaType.video)
//        for device in capturedDevices {
//            if device.position == .front {
//                self.captureDevice = device
//                break
//            }
//        }
        /*
        //BACK
        if #available(iOS 13.0, *) {
            if modelName == "" || modelName.contains("iPhone SE") || modelName.contains("iPhone 6") || modelName.contains("iPhone 7") || modelName.contains("iPhone 8") || modelName.contains("iPhone 9") || modelName.contains("iPhone X") || modelName.contains("iPhone 10") {
                guard let capDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else{
                    return
                }
                self.captureDevice = capDevice
            }
            else {
                guard let capDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back) else{
                    return
                }
                self.captureDevice = capDevice
            }
        } else {
            // Fallback on earlier versions
            guard let capDevice = AVCaptureDevice.default(for: AVMediaType.video) else{
                return
            }
            self.captureDevice = capDevice
        }
        */
        
        
        //NEW CODE DEVELOPE Date - 25 June 2023

        // -- Changes begun
        if #available(iOS 13.0, *) {

            if modelName == "" || modelName.contains("iPhone SE") || modelName.contains("iPhone 6") || modelName.contains("iPhone 7") || modelName.contains("iPhone 8") || modelName.contains("iPhone 9") || modelName.contains("iPhone X") || modelName.contains("iPhone 10") {
                guard let capDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else{
                    return
                }
                self.captureDevice = capDevice
            }
            else {
                // Your iPhone has UltraWideCamera.
                let deviceTypes: [AVCaptureDevice.DeviceType] = [AVCaptureDevice.DeviceType.builtInUltraWideCamera]
                let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: .back)
                self.captureDevice = discoverySession.devices.first
            }
            
        }
        // -- Changes end
        else {
            var deviceTypes: [AVCaptureDevice.DeviceType] = [AVCaptureDevice.DeviceType.builtInWideAngleCamera] // builtInWideAngleCamera // builtInUltraWideCamera
            if #available(iOS 11.0, *) {
                deviceTypes.append(.builtInDualCamera)
            } else {
                deviceTypes.append(.builtInDuoCamera)
            }
            
            // prioritize duo camera systems before wide angle
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: .back)
            for device in discoverySession.devices {
                if #available(iOS 11.0, *) {
                    if (device.deviceType == AVCaptureDevice.DeviceType.builtInDualCamera) {
                        self.captureDevice = device
                    }
                } else {
                    if (device.deviceType == AVCaptureDevice.DeviceType.builtInDuoCamera) {
                        self.captureDevice = device
                    }
                }
            }
            
            self.captureDevice = discoverySession.devices.first
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        //default(for: AVMediaType.video)!
        self.captureSession.beginConfiguration()
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            self.captureSession.addInput(input)
        } catch {
        }
        self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        
        
        captureSession.sessionPreset = AVCaptureSession.Preset.low

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)
            ] as [String : Any]
        
        
        /*****/
        // Find the max frame rate we can get from the given device
        var currentFormat: AVCaptureDevice.Format? = nil
        if let formats = captureDevice?.formats {
            for format in formats {
                let ranges = format.videoSupportedFrameRateRanges
                let frameRates = ranges.first
                if Int(frameRates?.maxFrameRate ?? 0) == FRAMES_PER_SECOND && (currentFormat == nil || (CMVideoFormatDescriptionGetDimensions(format.formatDescription).width < CMVideoFormatDescriptionGetDimensions((currentFormat?.formatDescription)!).width && CMVideoFormatDescriptionGetDimensions(format.formatDescription).height < CMVideoFormatDescriptionGetDimensions((currentFormat?.formatDescription)!).height)) {
                    currentFormat = format;
                }
            }
        }
        if currentFormat != nil {
            do {
                try self.captureDevice?.lockForConfiguration()
                captureDevice?.activeFormat = currentFormat!
                self.captureDevice?.unlockForConfiguration()
                
            } catch let error as NSError {
                print(error)
            }
        }
        /*****/
        
        self.captureSession.beginConfiguration()
        if captureSession.canAddOutput(videoOutput)
        {
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
       
        let rootLayer :CALayer = self.view.layer
        rootLayer.masksToBounds=true
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        if isDebugOn {
            self.view.bringSubviewToFront(self.debugView)
            self.debugView.isHidden = false
        }
        
        self.addProgressLayer()
        self.captureSession.commitConfiguration()
        
        //BACK
        self.setFlashMode(torchMode: AVCaptureDevice.TorchMode.on, device: self.captureDevice!)
        
    }
    
    /*
     Method to set flash
     */
    func setFlashMode(torchMode: AVCaptureDevice.TorchMode, device: AVCaptureDevice) {
        
        if device.hasTorch && device.isTorchModeSupported(torchMode) {
            do {
                try device.lockForConfiguration()
                device.torchMode = torchMode
                device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(FRAMES_PER_SECOND));
                device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(FRAMES_PER_SECOND));
                if UIDevice.current.hasNotch {
                    try device.setTorchModeOn(level: 0.3)
                }
                device.unlockForConfiguration()
            } catch let error as NSError {
                print(error)
                Utils.showAlertWithTitleInController("No Torch Error", message: error.debugDescription, controller: self)
            }
        } else {
            Utils.showAlertWithTitleInController("No Torch", message: "Torch is not supported", controller: self)
        }
    }
    
    /*
     Delegate Method to capture frames
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            DispatchQueue.global().async
            {
                guard let cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }
                if self.isFingerCheckEnable && self.count > 1 {
                    
                    //guard self.handle_isFingerPlaced(buffer: sampleBuffer) else {
                    
                    let ciImage = CIImage(cvPixelBuffer: cvimgRef)
                    let context = CIContext()
                    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                        return
                    }
                    let uiImage = UIImage(cgImage: cgImage)
                    if self.isFingerCoveringCamera(image: uiImage) {
                        print("FINGER PLACED")
                        self.isFingerPlaced = true
                    }
                    else {
                        print("NOT PLACED")
                        self.isFingerPlaced = false
                        self.stopCamera()
                        
                        DispatchQueue.main.async {
                            Utils.showAlertWithTitleInControllerWithCompletion("Unable to capture data".localized(), message: "Probable cause finger not placed.".localized(), okTitle: "Ok".localized(), controller: self) {
                                if self.isDebugOn {
                                    self.showGetRedMaxValueAlert(from: self)
                                } else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                        return
                    }
                    
                    //guard HeartRateDetectionModel.isFingerPlaced(sampleBuffer, maxValue: Shared.sharedInstance.maxValue) else {
                    //}
                    //print("FINGER PLACED")
                    //self.isFingerPlaced = true
                }
                
                // Lock the image buffer
                CVPixelBufferLockBaseAddress(cvimgRef, CVPixelBufferLockFlags(rawValue: 0))
                // access the data
                let width: size_t = CVPixelBufferGetWidth(cvimgRef)
                let height: size_t = CVPixelBufferGetHeight(cvimgRef)
                // get the raw image bytes
                var buf = unsafeBitCast(CVPixelBufferGetBaseAddress(cvimgRef), to: UnsafeMutablePointer<UInt8>.self)
                
                let bprow: size_t = CVPixelBufferGetBytesPerRow(cvimgRef)
                // and pull out the average rgb value of the frame
                var r: Float = 0
                var g: Float = 0
                var b: Float = 0
                
                let widthScaleFactor = width/192;
                let heightScaleFactor = height/144;
                
                var y = 0
                while y <  height {
                    var x = 0
                    while x < width * 4 {
                        b += Float(buf[x])
                        g += Float(buf[x + 1])
                        r += Float(buf[x + 2])
                        x += 4 * widthScaleFactor
                    }
                    buf += bprow
                    y += heightScaleFactor
                }
                
                //                    for _ in 0..<height {
                //                        var x = 0
                //                        while x < width * 4 {
                //                            b += Float(buf[x])
                //                            g += Float(buf[x + 1])
                //                            r += Float(buf[x + 2])
                //                            x += 4
                //                        }
                //                        buf += bprow
                //                    }
                r /= 255 * Float(width * height/widthScaleFactor/heightScaleFactor)
                g /= 255 * Float(width * height/widthScaleFactor/heightScaleFactor)
                b /= 255 * Float(width * height/widthScaleFactor/heightScaleFactor)
                print(r,g,b)
                
                let rgbStr = "R: \(r * 255), G: \(g * 255), B: \(b * 255)"
                let debugValue = rgbStr + "\n" + "Red_max: \(Shared.sharedInstance.maxValue)"
                self.showDebugValue(value: debugValue)
                
                let color: UIColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
                var hue: CGFloat = 0
                var sat: CGFloat = 0
                var bright: CGFloat = 0
                
                color.getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
                
                self.arrHuePoints.append(Float(hue))
                
                //FOR TALA
                if self.arrHuePoints.count % self.FRAMES_PER_SECOND == 0 {
                    let hr = HeartRateDetectionModel.getMeanHR(self.arrHuePoints, time: 0)
                    self.arrHeartRates.append(hr)
                    
                    //                        let heartRate = self.calculateHeartRate(redValues: self.arrRed, width: width, height: height)
                    print("HEART RATE = \(hr)")
                    
                    
                    
                    
                    
                    
                }
                
                
                
                self.arrRed.append(r)
                self.arrGreen.append(g)
                self.arrBlue.append(b)
                self.arraverage_Red.append(self.avg(redData: self.arrRed, offset: 0, length: Float(self.arrRed.count)))
                self.arraverage_Red_Double.append(Double(self.avg(redData: self.arrRed, offset: 0, length: Float(self.arrRed.count))))
                self.ppgDataServer.append("{\(self.ppgDataServer.count + 1),\(r)}")
                self.ppgDataServer_double.append(Double(r))
                CVPixelBufferUnlockBaseAddress(cvimgRef, CVPixelBufferLockFlags(rawValue: 0))
            }
        }
    }
    
    func processRedData(_ redData: UnsafeMutableRawPointer, _ redDataSize: Int) -> [Double] {
        var heartRateSignal = [Double]()
        
        for i in 0..<redDataSize {
            let redValue = redData.bindMemory(to: UInt8.self, capacity: 1)[i]
            heartRateSignal.append(Double(redValue))
        }
        
        return heartRateSignal
    }

    func findPeaks(_ data: [Double]) -> [Double] {
        var peaks = [Double]()
        
        for i in 1..<data.count-1 {
            if data[i] > data[i-1] && data[i] > data[i+1] {
                peaks.append(data[i])
            }
        }
        
        return peaks
    }
    
    func avg(redData: [Float], offset: Float, length: Float) -> Float {
        var total: Float = 0.0
        for redDatum in redData {
            total += redDatum
        }
        let avgValue = total/length
        return avgValue
    }
    
    
    
    
    /*
     Method to stop camera
     */
    func stopCamera() {
        self.captureSession.stopRunning()
    }
    
    /***/
    func addProgressLayer() {
        progressRing = CircularProgressBar(radius: 100, position: CGPoint(x: view.center.x, y: view.center.y), innerTrackColor: AppColor.app_DarkGreenColor, outerTrackColor: UIColor.lightGray, lineWidth: 10)
        guard let layer = progressRing else {
            return
        }
        view.layer.addSublayer(layer)
    }
}

extension CameraViewController {
    func showDebugValue(value: String) {
        if isDebugOn {
            DispatchQueue.main.async {
                self.debugL.text = value
            }
        }
    }
    
    func showGetRedMaxValueAlert(from vc: UIViewController) {
        let alert = UIAlertController(title: "Enter custom red max value".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter value".localized()
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { [weak alert] (_) in
            let value = alert?.textFields?.first?.text ?? ""
            //print("Count Value: \(value)")
            
            if !value.isEmpty, let newValue = Double(value) {
                Shared.sharedInstance.maxValue = newValue
                self.navigationController?.popViewController(animated: true)
            } else {
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Please enter valid value".localized(), okTitle: "Ok".localized(), controller: vc) {
                    self.showGetRedMaxValueAlert(from: vc)
                }
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}


//MARK: - Handle Image Buffer
extension CameraViewController {
    fileprivate func handle_isFingerPlaced(buffer: CMSampleBuffer) -> Bool {
        var redmean:CGFloat = 0.0;
        var greenmean:CGFloat = 0.0;
        var bluemean:CGFloat = 0.0;
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)

        let extent = cameraImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let averageFilter = CIFilter(name: "CIAreaAverage",
                              parameters: [kCIInputImageKey: cameraImage, kCIInputExtentKey: inputExtent])!
        let outputImage = averageFilter.outputImage!

        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(outputImage, from:outputImage.extent)!
        
        let rawData:NSData = cgImage.dataProvider!.data!
        let pixels = rawData.bytes.assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer<UInt8>(start:pixels, count:rawData.length)
        var BGRA_index = 0
        for pixel in UnsafeBufferPointer(start: bytes.baseAddress, count: bytes.count) {
            switch BGRA_index {
            case 0:
                bluemean = CGFloat (pixel)
            case 1:
                greenmean = CGFloat (pixel)
            case 2:
                redmean = CGFloat (pixel)
            case 3:
                break
            default:
                break
            }
            BGRA_index += 1
        }
        
        let hsv = rgb2hsv((red: redmean, green: greenmean, blue: bluemean, alpha: 1.0))
        // Do a sanity check to see if a finger is placed over the camera
        if (hsv.1 > 0.5 && hsv.2 > 0.5) {
            return true
        } else {
            return false
        }
    }
    
    func rgb2hsv(_ rgb: RGB) -> HSV {
        // Converts RGB to a HSV color
        var hsb: HSV = (hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        
        let rd: CGFloat = rgb.red
        let gd: CGFloat = rgb.green
        let bd: CGFloat = rgb.blue
        
        let maxV: CGFloat = max(rd, max(gd, bd))
        let minV: CGFloat = min(rd, min(gd, bd))
        var h: CGFloat = 0
        var s: CGFloat = 0
        let b: CGFloat = maxV
        
        let d: CGFloat = maxV - minV
        
        s = maxV == 0 ? 0 : d / minV;
        
        if (maxV == minV) {
            h = 0
        } else {
            if (maxV == rd) {
                h = (gd - bd) / d + (gd < bd ? 6 : 0)
            } else if (maxV == gd) {
                h = (bd - rd) / d + 2
            } else if (maxV == bd) {
                h = (rd - gd) / d + 4
            }
            
            h /= 6;
        }
        
        hsb.hue = h
        hsb.saturation = s
        hsb.brightness = b
        hsb.alpha = rgb.alpha
        return hsb
    }
    
    func isFingerCoveringCamera(image: UIImage) -> Bool {
        guard let pixelData = image.cgImage?.dataProvider?.data else {
            return false
        }
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        var reddishPixelCount = 0
        let pixelCount = width * height
        
        for x in 0..<width {
            for y in 0..<height {
                let pixelIndex = (y * width + x) * 4
                let r = CGFloat(data[pixelIndex]) / 255.0
                let g = CGFloat(data[pixelIndex + 1]) / 255.0
                let b = CGFloat(data[pixelIndex + 2]) / 255.0
                
                // Detect reddish hue common in skin tones (simple check)
                if r > 0.5 && g < 0.4 && b < 0.4 {
                    reddishPixelCount += 1
                }
            }
        }
        
        let reddishRatio = CGFloat(reddishPixelCount) / CGFloat(pixelCount)
        return reddishRatio > 0.7 // Adjust threshold as needed
    }
}
*/

//
//  CameraViewController+CameraCapture.swift
//  HourOnEarth
//
//  Created by Pradeep on 12/30/18.
//  Updated: 2025-09-24 (camera selection fix for some iPhone 13 builds)
//

import UIKit
import AVFoundation
import CoreImage

// Typealias for RGB color values
typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

// Typealias for HSV color values
typealias HSV = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)


extension CameraViewController {
    
    /*
       Method for Camera Setup
     */
    func setUpCamera() {
        let modelName = UIDevice.modelName
        
        // --- Camera selection: prefer Wide Angle (main) camera on modern devices (fixes iPhone13 mis-selection) ---
        if #available(iOS 13.0, *) {
            // Try the reliable wide-angle default first (main camera)
            if let capDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                self.captureDevice = capDevice
            } else {
                // Fallback: discover available back cameras and pick by priority
                let deviceTypes: [AVCaptureDevice.DeviceType] = [
                    .builtInWideAngleCamera,
                    .builtInDualCamera,
                    .builtInTripleCamera,
                    .builtInDualWideCamera,
                    .builtInUltraWideCamera,
                    .builtInTelephotoCamera
                ]
                let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
                
                // prefer a wide-angle style device if present among discovered devices
                var chosen: AVCaptureDevice? = nil
                let priorityOrder: [AVCaptureDevice.DeviceType] = [
                    .builtInWideAngleCamera,
                    .builtInDualCamera,
                    .builtInTripleCamera,
                    .builtInDualWideCamera,
                    .builtInUltraWideCamera,
                    .builtInTelephotoCamera
                ]
                for p in priorityOrder {
                    if let found = discoverySession.devices.first(where: { $0.deviceType == p && $0.position == .back }) {
                        chosen = found
                        break
                    }
                }
                // final fallback to the first discovered device
                self.captureDevice = chosen ?? discoverySession.devices.first
            }
        } else {
            // Legacy branch: keep earlier behavior for older iOS
            var deviceTypes: [AVCaptureDevice.DeviceType] = [ .builtInWideAngleCamera ]
            if #available(iOS 11.0, *) {
                deviceTypes.append(.builtInDualCamera)
            } else {
                // builtInDuoCamera was renamed; old fallback retained for completeness
                // (if you compile against an SDK where .builtInDuoCamera exists, you can add that)
            }
            
            // prioritize duo camera systems before wide angle when discovering (keeps original intent)
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
            for device in discoverySession.devices {
                if #available(iOS 11.0, *) {
                    if device.deviceType == .builtInDualCamera {
                        self.captureDevice = device
                        break
                    }
                }
            }
            self.captureDevice = self.captureDevice ?? discoverySession.devices.first
        }
        // --- end camera selection changes ---
        
        
        // Configure session input
        guard let captureDevice = self.captureDevice else {
            print("setUpCamera: no captureDevice available")
            return
        }
        
        self.captureSession.beginConfiguration()
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
        } catch {
            print("setUpCamera: error creating device input: \(error)")
            self.captureSession.commitConfiguration()
            return
        }
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
        
        // Keep original preset (low) to preserve earlier behaviour unless you want to change it later
        captureSession.sessionPreset = AVCaptureSession.Preset.low
        
        // Video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)
        ]
        
        // Try to find a format that supports target frame-rate (prefer smaller resolution that supports it)
        var currentFormat: AVCaptureDevice.Format? = nil
        if let formats = captureDevice.formats as? [AVCaptureDevice.Format] {
            for format in formats {
                // check each supported range on the format
                for range in format.videoSupportedFrameRateRanges {
                    if Int(range.maxFrameRate) >= FRAMES_PER_SECOND {
                        if currentFormat == nil {
                            currentFormat = format
                        } else {
                            let curDim = CMVideoFormatDescriptionGetDimensions(currentFormat!.formatDescription)
                            let fmtDim = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                            // choose the smaller resolution format that still supports the fps target
                            if fmtDim.width < curDim.width && fmtDim.height < curDim.height {
                                currentFormat = format
                            }
                        }
                        break
                    }
                }
            }
        }
        if let currentFormat = currentFormat {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.activeFormat = currentFormat
                // You can set min/max frame duration here if needed; keep minimal changes:
                captureDevice.unlockForConfiguration()
            } catch let error as NSError {
                print("setUpCamera: couldn't set activeFormat: \(error)")
            }
        }
        
        self.captureSession.beginConfiguration()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Preview Layer
        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let rootLayer :CALayer = self.view.layer
        rootLayer.masksToBounds = true
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        
        if isDebugOn {
            self.view.bringSubviewToFront(self.debugView)
            self.debugView.isHidden = false
        }
        
        self.addProgressLayer()
        self.captureSession.commitConfiguration()
        
        // Set torch/flash (safe handling inside method)
        self.setFlashMode(torchMode: AVCaptureDevice.TorchMode.on, device: captureDevice)
    }
    
    /*
     Method to set flash
     */
    func setFlashMode(torchMode: AVCaptureDevice.TorchMode, device: AVCaptureDevice) {
        
        if device.hasTorch && device.isTorchModeSupported(torchMode) {
            do {
                try device.lockForConfiguration()
                device.torchMode = torchMode
                // prefer min duration setting elsewhere; keep as original intent
                device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(FRAMES_PER_SECOND));
                device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(FRAMES_PER_SECOND));
                
                // set variable level safely (only if supported)
                if device.hasTorch {
                    // use slightly stronger torch level on notch devices (if desired)
                    if UIDevice.current.hasNotch {
                        if device.isTorchActive == false {
                            try device.setTorchModeOn(level: 0.3)
                        }
                    } else {
                        if device.isTorchActive == false {
                            try device.setTorchModeOn(level: 0.3)
                        }
                    }
                }
                
                device.unlockForConfiguration()
            } catch let error as NSError {
                print("setFlashMode error: \(error)")
                Utils.showAlertWithTitleInController("No Torch Error", message: error.localizedDescription, controller: self)
            }
        } else {
            Utils.showAlertWithTitleInController("No Torch", message: "Torch is not supported", controller: self)
        }
    }
    
    /*
     Delegate Method to capture frames
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            DispatchQueue.global().async {
                guard let cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }
                if self.isFingerCheckEnable && self.count > 1 {
                    
                    let ciImage = CIImage(cvPixelBuffer: cvimgRef)
                    let context = CIContext()
                    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                        return
                    }
                    let uiImage = UIImage(cgImage: cgImage)
                    if self.isFingerCoveringCamera(image: uiImage) {
                        print("FINGER PLACED")
                        self.isFingerPlaced = true
                    }
                    else {
                        print("NOT PLACED")
                        self.isFingerPlaced = false
                        self.stopCamera()
                        
                        DispatchQueue.main.async {
                            Utils.showAlertWithTitleInControllerWithCompletion("Unable to capture data".localized(), message: "Probable cause finger not placed.".localized(), okTitle: "Ok".localized(), controller: self) {
                                if self.isDebugOn {
                                    self.showGetRedMaxValueAlert(from: self)
                                } else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                        return
                    }
                }
                
                // Lock the image buffer
                CVPixelBufferLockBaseAddress(cvimgRef, CVPixelBufferLockFlags(rawValue: 0))
                // access the data
                let width: size_t = CVPixelBufferGetWidth(cvimgRef)
                let height: size_t = CVPixelBufferGetHeight(cvimgRef)
                // get the raw image bytes
                var buf = unsafeBitCast(CVPixelBufferGetBaseAddress(cvimgRef), to: UnsafeMutablePointer<UInt8>.self)
                
                let bprow: size_t = CVPixelBufferGetBytesPerRow(cvimgRef)
                // and pull out the average rgb value of the frame
                var r: Float = 0
                var g: Float = 0
                var b: Float = 0
                
                let widthScaleFactor = width/192;
                let heightScaleFactor = height/144;
                
                var y = 0
                while y <  height {
                    var x = 0
                    while x < width * 4 {
                        b += Float(buf[x])
                        g += Float(buf[x + 1])
                        r += Float(buf[x + 2])
                        x += 4 * widthScaleFactor
                    }
                    buf += bprow
                    y += heightScaleFactor
                }
                
                r /= 255 * Float(width * height/widthScaleFactor/heightScaleFactor)
                g /= 255 * Float(width * height/widthScaleFactor/heightScaleFactor)
                b /= 255 * Float(width * height/widthScaleFactor/heightScaleFactor)
                // debug print removed in release builds typically — kept as in original
                print(r,g,b)
                
                let rgbStr = "R: \(r * 255), G: \(g * 255), B: \(b * 255)"
                let debugValue = rgbStr + "\n" + "Red_max: \(Shared.sharedInstance.maxValue)"
                self.showDebugValue(value: debugValue)
                
                let color: UIColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
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
                
                self.arrRed.append(r)
                self.arrGreen.append(g)
                self.arrBlue.append(b)
                self.arraverage_Red.append(self.avg(redData: self.arrRed, offset: 0, length: Float(self.arrRed.count)))
                self.arraverage_Red_Double.append(Double(self.avg(redData: self.arrRed, offset: 0, length: Float(self.arrRed.count))))
                self.ppgDataServer.append("{\(self.ppgDataServer.count + 1),\(r)}")
                self.ppgDataServer_double.append(Double(r))
                CVPixelBufferUnlockBaseAddress(cvimgRef, CVPixelBufferLockFlags(rawValue: 0))
            }
        }
    }
    
    func processRedData(_ redData: UnsafeMutableRawPointer, _ redDataSize: Int) -> [Double] {
        var heartRateSignal = [Double]()
        
        for i in 0..<redDataSize {
            let redValue = redData.bindMemory(to: UInt8.self, capacity: 1)[i]
            heartRateSignal.append(Double(redValue))
        }
        
        return heartRateSignal
    }

    func findPeaks(_ data: [Double]) -> [Double] {
        var peaks = [Double]()
        
        for i in 1..<data.count-1 {
            if data[i] > data[i-1] && data[i] > data[i+1] {
                peaks.append(data[i])
            }
        }
        
        return peaks
    }
    
    func avg(redData: [Float], offset: Float, length: Float) -> Float {
        var total: Float = 0.0
        for redDatum in redData {
            total += redDatum
        }
        let avgValue = length > 0 ? total/length : 0
        return avgValue
    }
    
    
    
    
    /*
     Method to stop camera
     */
    func stopCamera() {
        self.captureSession.stopRunning()
    }
    
    /***/
    func addProgressLayer() {
        progressRing = CircularProgressBar(radius: 100, position: CGPoint(x: view.center.x, y: view.center.y), innerTrackColor: AppColor.app_DarkGreenColor, outerTrackColor: UIColor.lightGray, lineWidth: 10)
        guard let layer = progressRing else {
            return
        }
        view.layer.addSublayer(layer)
    }
}

extension CameraViewController {
    func showDebugValue(value: String) {
        if isDebugOn {
            DispatchQueue.main.async {
                self.debugL.text = value
            }
        }
    }
    
    func showGetRedMaxValueAlert(from vc: UIViewController) {
        let alert = UIAlertController(title: "Enter custom red max value".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter value".localized()
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { [weak alert] (_) in
            let value = alert?.textFields?.first?.text ?? ""
            //print("Count Value: \(value)")
            
            if !value.isEmpty, let newValue = Double(value) {
                Shared.sharedInstance.maxValue = newValue
                self.navigationController?.popViewController(animated: true)
            } else {
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Please enter valid value".localized(), okTitle: "Ok".localized(), controller: vc) {
                    self.showGetRedMaxValueAlert(from: vc)
                }
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}


//MARK: - Handle Image Buffer
extension CameraViewController {
    fileprivate func handle_isFingerPlaced(buffer: CMSampleBuffer) -> Bool {
        var redmean:CGFloat = 0.0;
        var greenmean:CGFloat = 0.0;
        var bluemean:CGFloat = 0.0;
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)

        let extent = cameraImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let averageFilter = CIFilter(name: "CIAreaAverage",
                              parameters: [kCIInputImageKey: cameraImage, kCIInputExtentKey: inputExtent])!
        let outputImage = averageFilter.outputImage!

        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(outputImage, from:outputImage.extent)!
        
        let rawData:NSData = cgImage.dataProvider!.data!
        let pixels = rawData.bytes.assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer<UInt8>(start:pixels, count:rawData.length)
        var BGRA_index = 0
        for pixel in UnsafeBufferPointer(start: bytes.baseAddress, count: bytes.count) {
            switch BGRA_index {
            case 0:
                bluemean = CGFloat (pixel)
            case 1:
                greenmean = CGFloat (pixel)
            case 2:
                redmean = CGFloat (pixel)
            case 3:
                break
            default:
                break
            }
            BGRA_index += 1
        }
        
        let hsv = rgb2hsv((red: redmean, green: greenmean, blue: bluemean, alpha: 1.0))
        // Do a sanity check to see if a finger is placed over the camera
        if (hsv.1 > 0.5 && hsv.2 > 0.5) {
            return true
        } else {
            return false
        }
    }
    
    func rgb2hsv(_ rgb: RGB) -> HSV {
        // Converts RGB to a HSV color
        var hsb: HSV = (hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: rgb.alpha)
        
        let rd: CGFloat = rgb.red
        let gd: CGFloat = rgb.green
        let bd: CGFloat = rgb.blue
        
        let maxV: CGFloat = max(rd, max(gd, bd))
        let minV: CGFloat = min(rd, min(gd, bd))
        var h: CGFloat = 0
        var s: CGFloat = 0
        let b: CGFloat = maxV
        
        let d: CGFloat = maxV - minV
        
        // FIXED: saturation should divide by maxV (not minV)
        s = maxV == 0 ? 0 : d / maxV;
        
        if (maxV == minV) {
            h = 0
        } else {
            if (maxV == rd) {
                h = (gd - bd) / d + (gd < bd ? 6 : 0)
            } else if (maxV == gd) {
                h = (bd - rd) / d + 2
            } else if (maxV == bd) {
                h = (rd - gd) / d + 4
            }
            
            h /= 6;
        }
        
        hsb.hue = h
        hsb.saturation = s
        hsb.brightness = b
        hsb.alpha = rgb.alpha
        return hsb
    }
    
    func isFingerCoveringCamera(image: UIImage) -> Bool {
        guard let pixelData = image.cgImage?.dataProvider?.data else {
            return false
        }
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        var reddishPixelCount = 0
        let pixelCount = width * height
        
        // Sample pixels (don't iterate every pixel on high-res devices)
        let step = max(4, min(12, width / 100)) // adaptive step: coarse but safe
        for x in stride(from: 0, to: width, by: step) {
            for y in stride(from: 0, to: height, by: step) {
                let pixelIndex = (y * width + x) * 4
                let r = CGFloat(data[pixelIndex]) / 255.0
                let g = CGFloat(data[pixelIndex + 1]) / 255.0
                let b = CGFloat(data[pixelIndex + 2]) / 255.0
                
                // Detect reddish hue common in skin tones (simple check)
                if r > 0.5 && g < 0.4 && b < 0.4 {
                    reddishPixelCount += 1
                }
            }
        }
        
        let sampledCount = ( (width + step - 1) / step ) * ( (height + step - 1) / step )
        let reddishRatio = CGFloat(reddishPixelCount) / CGFloat(max(1, sampledCount))
        return reddishRatio > 0.7 // Adjust threshold if needed
    }
}
