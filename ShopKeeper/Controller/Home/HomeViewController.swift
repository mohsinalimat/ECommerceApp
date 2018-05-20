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
       // let controllerButton: UIBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "filter"), style: .bordered, target: self, action: #selector(HomeViewController.clicked))
        
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
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(newIndexPath)")
            
            if (collectionView?.numberOfSections)! > 0 {
                
                if collectionView?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true
                } else {
                    blockOperations.append(
                        BlockOperation(block: { [weak self] in
                            if let this = self {
                                DispatchQueue.main.async {
                                    this.collectionView!.insertItems(at: [newIndexPath!])
                                }
                            }
                        })
                    )
                }
                
            } else {
                self.shouldReloadCollectionView = true
            }
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            
                            this.collectionView!.reloadItems(at: [indexPath!])
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(indexPath)")
            if collectionView?.numberOfItems( inSection: indexPath!.section ) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.collectionView!.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            }
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if (self.shouldReloadCollectionView) {
            DispatchQueue.main.async {
                self.collectionView.reloadData();
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView!.performBatchUpdates({ () -> Void in
                    for operation: BlockOperation in self.blockOperations {
                        operation.start()
                    }
                }, completion: { (finished) -> Void in
                    self.blockOperations.removeAll(keepingCapacity: false)
                })
            }
        }
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
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


