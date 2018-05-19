//
//  CoreDataManager.swift
//  
//
//  Created by Vivek Gupta on 17/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//


import UIKit
import CoreData

public class CoreDataManager {
    
    private let modelName: String
    static let coreDataManager = CoreDataManager(modelName: "ShopKeeper")
    
    init(modelName: String) {
        self.modelName = modelName
        self.setupNotificationHandling()
        self.setExcluediCloud()
    }
    
    private func setExcluediCloud() {
        var appSupport = self.applicationDocumentsDirectory
        if !FileManager.default.fileExists(atPath: appSupport.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true, attributes: nil)
            }catch {
                
            }
        }
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try appSupport.setResourceValues(resourceValues)
        } catch { print("failed to set resource value") }
    }
    
    private lazy var databaseName: String = {
        return "\(self.modelName).sqlite"
    }()
    
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            return nil
        }
        
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        return managedObjectModel
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else {
            return nil
        }
        let persistentStoreURL = self.applicationDocumentsDirectory.appendingPathComponent(self.databaseName)
        print(persistentStoreURL)
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true ]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
            
        } catch {
            let addPersistentStoreError = error as NSError
            
            print("Unable to Add Persistent Store")
            print("\(addPersistentStoreError.localizedDescription)")
        }
        
        return persistentStoreCoordinator
    }()
    
    @objc func merge(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            if let slf = self {
                slf.managedObjectContext.mergeChanges(fromContextDidSave: notification)
                slf.privateManagedObjectContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    @objc func saveChanges(_ notification: NSNotification) {
        DispatchQueue.main.async {[weak self] in
            guard let slf = self else {return}
            slf.managedObjectContext.performAndWait({
                do {
                    if slf.managedObjectContext.hasChanges {
                        try slf.managedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            })
            slf.privateManagedObjectContext.perform({
                do {
                    if slf.privateManagedObjectContext.hasChanges {
                        try slf.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            })
        }
    }
    
    // MARK: - Helper Methods
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                
            }
        }
    }
    
    func resetCoordinator()  {
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.databaseName)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                let saveError = error as NSError
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.saveChanges(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.saveChanges(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.saveChanges(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CoreDataManager.merge(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
}
