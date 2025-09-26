//
//  HOECerificates.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 20/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class HOECertificates: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tblCertificates: UITableView!

    let arrayCertificate:Array<String> = ["SVYASA and HealthCare Global Hospitals","NIRAAMAYA", "DR. VAIDYA's"]

    let arrCertificateimages = [["s_vyasa_vikriti","s_vyasa_prakriti"],["niraamaya_vikriti","niraamaya_prakriti"],["vaidya_vikriti"]]
    let arrCertificateTitle = [["Vikriti","Prakriti"],["Vikriti","Prakriti"],["Vikriti"]]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tblCertificates.tableFooterView = UIView()
        self.tblCertificates.delegate = self
        self.tblCertificates.dataSource = self
        
        navigationController!.navigationBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        navigationItem.title = "Certificates".localized()

        tblCertificates.rowHeight = UITableView.automaticDimension
        tblCertificates.estimatedRowHeight = 60

        // Do any additional setup after loading the view.
    }
    
    //MARK: UITableView Delegates and Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayCertificate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellCertificates")!
        let lblSettings: UILabel = cell.viewWithTag(1001) as! UILabel
        lblSettings.text = self.arrayCertificate[(indexPath as NSIndexPath).row].localized()
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let storyBoard = UIStoryboard(name: "Certificates", bundle: nil)
        let objCertificateView:HOECertificatesDetails = storyBoard.instantiateViewController(withIdentifier: "HOECertificatesDetails") as! HOECertificatesDetails
        objCertificateView.arrImages = arrCertificateimages[indexPath.row]
        objCertificateView.dictTitle = arrayCertificate[indexPath.row]
        objCertificateView.arrTitles = arrCertificateTitle[indexPath.row]
        self.navigationController?.pushViewController(objCertificateView, animated: true)

    }
}
