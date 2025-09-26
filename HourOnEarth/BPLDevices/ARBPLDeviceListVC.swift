//
//  ARBPLDeviceListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 09/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARBPLDeviceListVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "Cell"
    var devices = [ARBPLDeviceModel]()
    
    // MARK: View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My BPL Devices".localized()
        tableView.tableFooterView = UIView()
        setupUI()
    }
    
    // MARK: Custom Methods
    
    func setupUI() {
        NotificationCenter.default.addObserver(forName: .refreshBPLDeviceList, object: nil, queue: nil) { [weak self] notif in
            self?.updateUI()
        }
        updateUI()
    }
    
    func updateUI() {
        devices = ARBPLDeviceManager.shared.deviceData.devices
        tableView.reloadData()
    }
}

// MARK: UITableView Delegate and DataSource Methods
extension ARBPLDeviceListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            return UITableViewCell()
        }
        
        let device = devices[indexPath.row]
        cell.textLabel?.text = device.displayString.localized()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        switch device.deviceType {
        case .registerNewDevice:
            ARBPLDeviceManager.shared.startBPLDeviceAddProcess(fromVC: self)
            
        case .enterOximeterResult, .enterBPMonitorResult, .enterWeighingScaleResult:
            ARBPLDeviceManager.shared.enterBPLDeviceResult(device: device, fromVC: self)
            
        default:
            ARBPLDeviceInfoVC.showScreen(device: device, isFromDeviceListingScreen: true, fromVC: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
