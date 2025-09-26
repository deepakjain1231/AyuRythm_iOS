//
//  ARBPLWeighingMachineReaderVC.swift
//  WatchDemoApp
//
//  Created by Paresh Dafda on 03/06/22.
//

import UIKit
import CoreBluetooth

class ARBPLWeighingMachineReaderVC: UIViewController {
    
    @IBOutlet weak var weightL: UILabel!
    @IBOutlet weak var instractionL: UILabel!
    @IBOutlet weak var connectionStatusL: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkWeightBtn: UIButton!
    
    var weight: Float = 0
    var timer: Timer?
    var isStableWeightFound = false
    let instractions = ["Please stand on the iWeight Scale with bare feet".localized(),
                        "Click on Scan Button".localized(),
                        "Please stay on the scale while measurement is going on...".localized()]
    let weightNotFoundMessage = "No stable weight found".localized()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBluetoothStatusUI(for: ARBleManager.shareInstance.state)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        doCleanUp()
    }
    
    deinit {
        DebugLog("-")
        doCleanUp()
    }

    func setupUI() {
        instractionL.setBulletListedAttributedText(stringList: instractions, paragraphSpacing: 8)
        ARBleConfig.continueScan = true
        ARBleManager.shareInstance.delegate = self
    }
    
    @IBAction func checkWeightBtnPressed(sender: UIButton) {
        if ARBleManager.shareInstance.isBluetoothPermissionGiven(fromVC: self) {
            self.startWeightMeasurement()
        }
    }
    
    func startWeightMeasurement() {
        weightL.text = "0.0 Kg"
        activityIndicator.startAnimating()
        connectionStatusL.text = "Processing..."
        checkWeightBtn.isEnabled = false
        startBleScanning()
        startTimer()
    }
    
    func weightMeasurementComplete(with weight: Float, error: String? = nil) {
        stopBleScanning()
        activityIndicator.stopAnimating()
        connectionStatusL.text = "Done"
        checkWeightBtn.isEnabled = true
        ARBle_debug_log(">>> Final Weight : \(weight)")
        
        if let error = error {
            let alert = UIAlertController(title: "Error".localized(), message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
            self.present(alert, animated: true)
        } else {
            //call weight update api
            updateWeightOnServer(weight: Double(weight))
        }
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
            self.weightMeasurementComplete(with: self.weight, error: !self.isStableWeightFound ? self.weightNotFoundMessage : nil)
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateBluetoothStatusUI(for status: ARBleState) {
        switch status {
        case .PowerOn:
            connectionStatusL.text = "Bluetooth ON".localized()
        default:
            connectionStatusL.text = "Bluetooth OFF".localized()
        }
    }
}

extension ARBPLWeighingMachineReaderVC {
    func updateWeightOnServer(weight: Double) {
        showActivityIndicator()
        ARLog("updateWeightBy : \(weight)")
        ARBPLDeviceManager.updateUserWeight(by: weight) { success, message, measurements  in
            if success {
                self.hideActivityIndicator()
            } else {
                self.hideActivityIndicator(withMessage: message)
            }
        }
    }
}

extension ARBPLWeighingMachineReaderVC: PDBluetoothHelperDelegate {
    func processData(data: Data) {
        /* logic :
         When the scale is turn on , it will turn on the BLE, and start advertising. The weight data is included in the Manufacturer Specific Data field of the BLE advertising data or scan response.
         
         The APP start scan , and parse the Device, advertising data, and get
         the Manufacturer Specific data field( AD TYPE=0xFF) of the advertising data .
         
         When get the Manufacturer Specific data, if the first byte value is 0xC0,and the length of the data is 15 , that is the target device.
         
         The simple smart scale have no GATT service , the app cannot connect to it. The app can only get the weight data from the advertising data.
         
         ["kCBAdvDataManufacturerData": <c0a100ae 00000c00 204b0ab7 6323ae>]
         
         byte[9-14] --> 115, 10, 109, -45, 12, -31   -->  MAC
         
         byte[8]     --> 32 --> unlocked or unstable.
         
         byte[8]     --> 33 --> locked
         
         byte[6-7]     --> 12, 0 --> Product ID Fixed
         
         byte[0]     --> -64 --> Version Fixed
         
         byte[1]     --> -108 --> The SN value will change when the weight measurement is not stable. If the weight measurement is stable, the LCD will display the locked data ,and the SN value will not change. If the SN value of current frame is equal to the SN value of previous frame, it meas that the weight is locked. Other vise the weight is UNLOCKED.
         
         byte[2-3]     --> 2, 23 --> Weight
         
         byte[4-5]     --> 21,-128 --> Imp
         */
        
        let bytes = [UInt8](data)
        let sn:UInt8 , weightNum:Int, impValue:Float, pid:Int, msg:UInt8
        if bytes.count == 15 && bytes[0] == 0xC0 {
            sn = bytes[1]
            weightNum =  Int(bytes[2]) * Int(256) + Int(bytes[3])
            impValue = Float(Int(bytes[4]) * Int(256) + Int(bytes[5]))/10
            msg = bytes[8]
            ARBle_debug_log("did rececive data : \(bytes), count : \(bytes.count)")
            
            // weight
            weight = Float(weightNum)/10
            ARBle_debug_log("weight:\(weight) kg")
            weightL.text = String(format: "%0.1f Kg", weight)
            
            // lock?
            let locked:Bool = (msg & 0x01 == 1)
            
            /*if !locked {
                tip.text="result: "
            }*/
            if locked {
                isStableWeightFound = true
                weightMeasurementComplete(with: weight)
                stopTimer()
                /*var sex:Bool=false
                var age:Float=0.0,cm:Float=0.0,kg:Float=0.0,imp:Float=0.0,level:Int32=0
                var fat:Float=0.0,tbw:Float=0.0,mus:Float=0.0,bone:Float=0.0,kcal:Float=0.0,vfat:Float=0.0,bage:Float=0.0,bestweight:Float=0.0,bmi:Float=0.0,protein:Float=0.0
                var wwfat:Float=0.0,score:Float=0.0,bodyshape:Float=0.0,obeserate:Float=0.0
                
                var res:String
                //init user info
                sex=MALE // male=false female=true
                age=37
                cm=170
//                kg=66.2
                kg = wt
//                imp=560.0
                imp = impValue
                level=0 // must keep default value=0
                //calculate the body fat tbw ...etc
                fat=libBodyFat.getFat(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                tbw=libBodyFat.getTbw(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                mus=libBodyFat.getMus(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                bone=libBodyFat.getBone(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                kcal=libBodyFat.getKcal(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                vfat=libBodyFat.getVfat(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                bage=libBodyFat.getBage(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                bestweight=libBodyFat.getBestWeight(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                bmi=libBodyFat.getBMI(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                protein=libBodyFat.getProtein(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                wwfat=libBodyFat.getWeightWithoutFat(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                score=libBodyFat.getScore(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                bodyshape=libBodyFat.getBodyShape(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                obeserate=libBodyFat.getObeseRate(sex, age: age, cm: cm, kg: kg, imp: imp, althlevel: level)
                //display result
                let ver:String=libBodyFat.getVersion()
                res="version:\(ver) fat:\(fat) tbw:\(tbw) mus: \(mus)bone:\(bone) kcal:\(kcal) vfat:\(vfat)bage:\(bage) bestwt:\(bestweight) bmi:\(bmi) protein:\(protein)";
                res="\(res) LBM=\(wwfat)obeserate=\(obeserate)totalscore=\(score)BodyShape=\(bodyshape)"
                tip.text=res
                 */
            }
        }
    }
}

extension ARBPLWeighingMachineReaderVC: ARBleManagerDelegate {
    func startBleScanning() {
        if ARBleManager.shareInstance.isBleEnable {
            ARBle_debug_log("scanning ...")
            ARBleManager.shareInstance.scanForDevices()
        } else {
            ARBle_debug_log("Bluetooth is OFF")
        }
    }
    
    func stopBleScanning() {
        ARBleManager.shareInstance.stopScan()
    }
    
    func doCleanUp() {
        stopBleScanning()
        ARBleManager.shareInstance.delegate = nil
        stopTimer()
    }
    
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState) {
        ARBle_debug_log("status change : \(state)")
        DispatchQueue.main.async {
            self.updateBluetoothStatusUI(for: state)
        }
    }
    
    func manager(_ manager: ARBleManager, didReceiveAdvertisementData data: Data) {
        let finalData = [UInt8](data)
        ARBle_debug_log("did rececive adv data : \(finalData), count : \(finalData.count)")
        DispatchQueue.main.async {
            self.processData(data: data)
        }
    }
}

extension ARBPLWeighingMachineReaderVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = ARBPLWeighingMachineReaderVC.instantiate(fromAppStoryboard: .BPLDevices)
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
