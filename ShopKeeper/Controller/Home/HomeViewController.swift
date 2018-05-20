//
//  HomeViewController.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var shouldReloadCollectionView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ProductCollectionViewCell.self)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        collectionView.dataSource = self
        self.configureCollectionView()
        self.title = "Categories"
        let btn: UIBarButtonItem = UIBarButtonItem(title: "Filter", style: .done, target: self, action: #selector(HomeViewController.clicked))
        
        self.navigationItem.rightBarButtonItem = btn
        self.activity.startAnimating()
        
    }
    
    
    
    @objc func clicked(btn: UIButton){
        if !self.subCategorySelected {
            self.title = "Sub Categories"
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "categorized")
            
        }else{
            self.title = "Categories"
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "subCategorized")
        }
        self.subCategorySelected = !self.subCategorySelected
        self._fetchedResultsController = nil
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    func fetchCategories(){
        do{
            try fetchedResultController.performFetch()
        }catch{
            let fetchError = error as NSError
            print("Fetch error: \(fetchError)")
        }
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
   
    var _fetchedResultsController: NSFetchedResultsController<Product>? = nil
    var blockOperations: [BlockOperation] = []
    var subCategorySelected: Bool = false
    
    var fetchedResultController: NSFetchedResultsController<Product> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let managedObjectContext = CoreDataManager.coreDataManager.managedObjectContext
        
        //fetchRequest.predicate = NSPredicate(format: "name != nil")
        
        var predicateArray: [NSPredicate] = [NSPredicate]()
        predicateArray.append(NSPredicate(format: "name != nil"))
        
    
        if !self.subCategorySelected{
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true),NSSortDescriptor(key: "id", ascending: true)]
        }else{
            if var cat = Category.findAll(condition: NSPredicate(format: "%K > 0",#keyPath(Category.child_categories)), fetchLimit: nil, sortBy: "", ascending: false, MOC: managedObjectContext) as? [Category]{
                var ids: [Int] = []
                cat = cat.filter{
                    if let chld = $0.child_categories as? [Int]{
                        ids += chld
                        return chld.count > 0
                    }
                    return false
                }
                print(cat)
                let conciseUniqueValues: [Int] = ids.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
                print(conciseUniqueValues)
                predicateArray.append(NSPredicate(format: "ANY id IN %@", conciseUniqueValues))
            }
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true),NSSortDescriptor(key: "id", ascending: true)]
            
        }
        let coumpoundPredicate: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        fetchRequest.predicate = coumpoundPredicate
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "category.name", cacheName:     self.subCategorySelected ? "subCategorized" : "categorized")
        
        resultsController.delegate = self;
        _fetchedResultsController = resultsController
        
        do {
            try _fetchedResultsController!.performFetch()
            self.activity.stopAnimating()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror)")
        }
        
        return _fetchedResultsController!
    }
    
    deinit {

    }

}

extension HomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        let product: Product = fetchedResultController.object(at: indexPath) as! Product
        
        cell.productNameLabel.text = product.name
        //print(category.id)
    return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo: NSFetchedResultsSectionInfo = fetchedResultController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            let header: CategoryHeader = collectionView.dequeueReusableSupplementaryView(forSupplementaryViewOfKind: kind, forIndexPath: indexPath)
             let product: Product = fetchedResultController.object(at: indexPath) as! Product
            
            header.headingLabel.text = product.category?.name ?? ""
            return header
        }
        return UICollectionReusableView()
        
    }
  
}


