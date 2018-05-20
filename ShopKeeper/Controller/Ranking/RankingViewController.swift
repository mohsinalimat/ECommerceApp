//
//  RankingViewController.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 19/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import UIKit
import CoreData

class RankingViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var shouldReloadCollectionView: Bool = false
    var sections: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(RankingWiseProductCell.self)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        collectionView.dataSource = self
        self.configureCollectionView()
        self.title = "Categories"
        getProductIDDictWise()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCollectionView(){
        let screenSize = UIScreen.main.bounds
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionViewLayout.itemSize = CGSize(width: (screenSize.width/2) - 10, height: (screenSize.width/2) - 10)
        collectionViewLayout.minimumInteritemSpacing = 5
        collectionViewLayout.minimumLineSpacing = 5
        collectionViewLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.width, height: 44)
        
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
    }
    lazy var viewCountSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Rankings.mostviewedrel.viewcount),ascending: false)
    }()
    lazy var shareCountSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(
            key: #keyPath(Rankings.mostsharedrel.sharecount),
            ascending: false)
    }()
    lazy var orderedSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(
            key: #keyPath(Rankings.mostorderdrel.ordercount),
            ascending: false)
    }()
    var rankingDict: [String: [Product]] = [:]
    func getProductIDDictWise(){
        let predicate = NSPredicate(format: "id != nil")
        var viewdIds: [Int32] = []
        var orderIds: [Int32] = []
        var shareIds: [Int32] = []
        if let mostViewed = MostViewed.findAll(condition: predicate, fetchLimit: nil, sortBy: "viewcount", ascending: false, MOC: CoreDataManager.coreDataManager.managedObjectContext) as? [MostViewed]{
            print(mostViewed)
            _ = mostViewed.map{
                viewdIds.append($0.id)
            }
        }
        if let mostShared = MostShared.findAll(condition: predicate, fetchLimit: nil, sortBy: "sharecount", ascending: false, MOC: CoreDataManager.coreDataManager.managedObjectContext) as? [MostShared]{
            _ = mostShared.map{
                shareIds.append($0.id)
            }
        }
        if let mostOrdered = MostOrdered.findAll(condition: predicate, fetchLimit: nil, sortBy: "ordercount", ascending: false, MOC: CoreDataManager.coreDataManager.managedObjectContext) as? [MostOrdered]{
            _ = mostOrdered.map{
                orderIds.append($0.id)
            }
        }
        do{
            let managedObjectContext = CoreDataManager.coreDataManager.managedObjectContext
            let predicateOrder = NSPredicate(format: "%K IN %@", "id", orderIds)
            if let orderProducts = Product.findAll(condition: predicateOrder, fetchLimit: nil, sortBy: "orderedcount", ascending: false, MOC: managedObjectContext) as? [Product]{
                rankingDict["Most Ordered Products"] = orderProducts
                self.sections.append("Most Ordered Products")
            }
            let predicateShare = NSPredicate(format: "%K IN %@", "id", shareIds)
            if let shareProducts = Product.findAll(condition: predicateShare, fetchLimit: nil, sortBy: "sharecount", ascending: false, MOC: managedObjectContext) as? [Product]{
                rankingDict["Most Shared Products"] = shareProducts
                self.sections.append("Most Shared Products")
            }
           
            let predicateView = NSPredicate(format: "%K IN %@", "id", viewdIds)
            if let viewdProducts = Product.findAll(condition: predicateView, fetchLimit: nil, sortBy: "viewcount", ascending: false, MOC: managedObjectContext) as? [Product]{
                rankingDict["Most Viewed Products"] = viewdProducts
                self.sections.append("Most Viewed Products")
            }
            
           
            //self.sections = Array(rankingDict.keys)
            self.collectionView.reloadData()
        }
    }
    
    
    
    
    
    
    
    
    deinit {
       
    }
    
}

extension RankingViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankingWiseProductCell", for: indexPath) as! RankingWiseProductCell
        
        if let product =  self.rankingDict[self.sections[indexPath.section]]![indexPath.row] as? Product{
                cell.productName.text = product.name
            if indexPath.section == 0{
                cell.countLabel.text = "Order count - \(product.orderedcount)"
                cell.imageView.image = UIImage(named: "Ordered")
            }else if indexPath.section == 1{
                cell.countLabel.text = "Share count - \(product.sharecount)"
                cell.imageView.image = UIImage(named: "Shared")
            }else{
                cell.countLabel.text = "View count - \(product.viewcount)"
                cell.imageView.image = UIImage(named: "Viewed")
            }
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.rankingDict.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.rankingDict[self.sections[section]]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            let header: CategoryHeader = collectionView.dequeueReusableSupplementaryView(forSupplementaryViewOfKind: kind, forIndexPath: indexPath)
            
            
            header.headingLabel.text = self.sections[indexPath.section]
            return header
        }
        return UICollectionReusableView()
        
    }
    
}



