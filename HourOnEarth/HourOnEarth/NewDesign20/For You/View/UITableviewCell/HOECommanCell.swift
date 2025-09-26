////
////  HOECommanCell.swift
////  HourOnEarth
////
////  Created by Dhiren Bharadava on 12/05/20.
////  Copyright © 2020 Pradeep. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class HOECommanCell: UITableViewCell
//{
//    //===============================================================================================
//    // MARK: - UICollectionView IBOutlet
//    //===============================================================================================
//
//    @IBOutlet weak var collectionview: UICollectionView!
//    
//    //===============================================================================================
//    // MARK: - Closure for get return model
//    //===============================================================================================
//
//    var ClickActionFoodModel :((_ issuccess: NSManagedObject?) -> Void)?
//    func registerForFoodModel(action:@escaping (_ issuccess: NSManagedObject?) ->Void) -> Void{
//        
//        ClickActionFoodModel = action
//    }
//    
//    //===============================================================================================
//    // MARK: - Array
//    //===============================================================================================
//
//    var arrFoodList : Array<NSManagedObject> = []
//
//    var ISstatus : ForYouSectionType?
//    
//    override func awakeFromNib()
//    {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool)
//    {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//    //===============================================================================================
//    // MARK: - LoadCollectionview Method
//    //===============================================================================================
//
//    func LoadCollectionview(_ strStatus : ForYouSectionType,_ arrFood : [NSManagedObject])
//    {
//        arrFoodList = arrFood
//        ISstatus    = strStatus
//        
//        collectionview.dataSource = self
//        collectionview.delegate = self
//        
//        collectionview.register(UINib(nibName: "HOEYogaCell", bundle: nil), forCellWithReuseIdentifier: "HOEYogaCell")
//        collectionview.register(UINib(nibName: "HOEFoodCell", bundle: nil), forCellWithReuseIdentifier: "HOEFoodCell")
//
//        collectionview.reloadData()
//    }
//}
