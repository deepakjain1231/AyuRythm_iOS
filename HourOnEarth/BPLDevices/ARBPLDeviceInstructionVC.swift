//
//  ARBPLDeviceInstructionVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARBPLDeviceInstructionVC: UIViewController {
    
    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var deviceImageIV: UIImageView!
    @IBOutlet weak var instructionsL: UILabel!
    
    var deviceType = ARBPLDeviceModel.DeviceType.other
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        switch deviceType {
        case .oximeter:
            deviceImageIV.image = #imageLiteral(resourceName: "oximeter-info")
            instructionsL.setBulletListedAttributedText(stringList: ["Connect your BPL device to Ayurythm via bluetooth",
                                                                     "Place your finger on BPL oximeter device",
                                                                     "Remove your finger after the test is done",
                                                                     "Get personlized results based on your doshas"], paragraphSpacing: 4)
            
        case .bpMonitor:
            deviceImageIV.image = #imageLiteral(resourceName: "bp-monitor-info")
            instructionsL.setBulletListedAttributedText(stringList: ["Search and connect your BP device to Ayurythm via bluetooth",
                                                                     "Sit down and wear the BP device",
                                                                     "Remove your arm after the test is done",
                                                                     "Get peronalized results based on your doshas"], paragraphSpacing: 4)
            
        default:
            DebugLog(">> handle this device - \(deviceType)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true)
    }
    
    @IBAction func okBtnPressed(sender: UIButton) {
        let fromVC = self.presentingViewController
        let deviceT = self.deviceType
        dismiss(animated: true) {
            switch deviceT {
            case .oximeter:
                ARBPLOximeterReaderVC.showScreen(fromVC: fromVC ?? self)
                
            case .bpMonitor:
                //ARBPLDeviceSearchVC.showScreen(deviceType: deviceT, fromVC: fromVC ?? self)s
                ARBPLBPMonitorReaderVC.showScreen(fromVC: fromVC ?? self)
                
            default:
                DebugLog(">> handle this device - \(deviceT)")
            }
        }
    }
}

extension ARBPLDeviceInstructionVC {
    static func showScreen(deviceType: ARBPLDeviceModel.DeviceType, fromVC: UIViewController) {
        ARBleManager.shareInstance.isBluetoothPermissionGiven(fromVC: fromVC)
        if ARBleManager.shareInstance.isBleEnable {
            let vc = ARBPLDeviceInstructionVC.instantiate(fromAppStoryboard: .BPLDevices)
            vc.deviceType = deviceType
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            fromVC.present(vc, animated: true, completion: nil)
        }
    }
}
