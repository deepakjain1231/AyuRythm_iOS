//
//  HOECertificatesDetails.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 20/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class HOECertificatesDetails: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tblCertificates: UITableView!

    var arrImages = [String]()
    var dictTitle = ""
    var arrTitles = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tblCertificates.tableFooterView = UIView()
        
        navigationController!.navigationBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        navigationItem.title = dictTitle.localized()
        self.tblCertificates.delegate = self
        self.tblCertificates.dataSource = self

        tblCertificates.reloadData()
        // Do any additional setup after loading the view.
    }
    //MARK: UITableView Delegates and Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CertificateCell = tableView.dequeueReusableCell(withIdentifier: "CertificateCell")! as! CertificateCell
        
        cell.lblTitle.text = arrTitles[indexPath.row].localized()
        cell.imagecertificate?.image = UIImage(named: arrImages[indexPath.row])
        cell.imagecertificate.layer.borderColor = UIColor.black.cgColor
        cell.imagecertificate.layer.borderWidth = 1
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
    
    
}
