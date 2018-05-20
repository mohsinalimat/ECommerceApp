//
//  NSManagedObject+Additions.swift
//  AuthTestRaw
//
//  Created by Vivek Gupta on 17/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation
import CoreData


protocol NSManagedObjectEntityName: class{}

extension NSManagedObjectEntityName where Self: NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
}
extension NSManagedObject: NSManagedObjectEntityName {}

protocol NSManagedObjectFetch: class{}

extension NSManagedObject {
    
    class func deleteAllAndSave() {
        self.deleteAllAndSaveInContext(CoreDataManager.coreDataManager.managedObjectContext)
        CoreDataManager.coreDataManager.saveContext()
        
    }
    
    class func deleteAllAndSaveInContext(_ context: NSManagedObjectContext) {
        if let array = self.findAll(MOC: context) {
            array.forEach({ (object) in
                context.delete(object)
            })
        }
    }
    
    
    
    class func delete(condition: Any? = nil, MOC: NSManagedObjectContext) {
        let fetchRequest = self.getFetchRequest()
        if let cntn = condition {
            fetchRequest.predicate = self.predicate(formCondition: cntn)
        }
        if let objects = self.fetch(fetchRequest: fetchRequest, MOC: MOC) {
            for managedObject in objects {
                MOC.delete(managedObject)
            }
        }
    }
    private class func getFetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        return NSFetchRequest(entityName: self.entityName)
    }
    
    private class func fetchRequestWithKey<T: NSManagedObject>(key: String, ascending: Bool = true) -> NSFetchRequest<T> {
        let request = getFetchRequest()
        var sortDescriptorArray = [NSSortDescriptor]()
        if key != "" {
            let sortKeys = key.components(separatedBy: (","))
            for sortKey in sortKeys {
                let sortComponent = sortKey.components(separatedBy: ":")
                if sortComponent.count > 1 {
                    let sortDescriptor = NSSortDescriptor(key: sortComponent.first!, ascending: sortComponent.last!.toBool()!)
                    sortDescriptorArray.append(sortDescriptor)
                }else {
                    let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
                    sortDescriptorArray.append(sortDescriptor)
                }
            }
            if sortDescriptorArray.count > 0 {
                request.sortDescriptors = sortDescriptorArray
            }
        }
        return request as! NSFetchRequest<T>
    }
    
    private class func predicate(formCondition condition: Any) -> NSPredicate? {
        if let dictionary = condition as? [String: Any] {
            let predicateArray = dictionary.flatMap({ (arg) -> NSPredicate? in
                let (key, value) = arg
                return NSPredicate(format: "\(key) = %@",value as! CVarArg)
            })
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        }else if let predicate  = condition as? NSPredicate {
            return predicate
        }else if let string = condition as? String {
            return NSPredicate(format: string, TID_NULL)
        }
        return nil
    }
    
    class func count(condition: Any? = nil, MOC: NSManagedObjectContext) -> Int {
        let fetchRequest = self.getFetchRequest()
        if let cntn = condition {
            fetchRequest.predicate = self.predicate(formCondition: cntn)
        }
        var count: Int = 0
        do {
            count = try MOC.count(for: fetchRequest)
        }catch {
            
        }
        return count
    }
    
    class func findOrCreate<T: NSManagedObject>(condition: Any? = nil, MOC: NSManagedObjectContext) ->  T {
        let fetchRequest = self.getFetchRequest()
        if let cntn = condition {
            fetchRequest.predicate = self.predicate(formCondition: cntn)
        }
        if let objects = self.fetch(fetchRequest: fetchRequest, MOC: MOC) {
            if let object = objects.first {
                
                return object as! T
            }
        }
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: MOC) as! T
    }
    
    class func findAll<T: NSManagedObject>(condition: Any? = nil,fetchLimit: Int? = nil, sortBy: String = "", ascending: Bool = true, MOC: NSManagedObjectContext) ->  [T]? {
        let fetchRequest = self.fetchRequestWithKey(key: sortBy, ascending: ascending)
        if let cntn = condition {
            fetchRequest.predicate = self.predicate(formCondition: cntn)
        }
        if let limit = fetchLimit{
            fetchRequest.fetchLimit = limit
        }
        if let objects = self.fetch(fetchRequest: fetchRequest, MOC: MOC) as? [T] {
            return objects
        }
        return nil
    }
    
    class func find<T: NSManagedObject>(condition: Any? = nil, sortBy: String = "", MOC: NSManagedObjectContext) ->  T? {
        let fetchRequest = self.fetchRequestWithKey(key: sortBy)
        if let cntn = condition {
            fetchRequest.predicate = self.predicate(formCondition: cntn)
        }
        if let objects = self.fetch(fetchRequest: fetchRequest, MOC: MOC) {
            if let object = objects.first as? T {
                return object
            }
        }
        return nil
    }
    
    class func create<T: NSManagedObject>(MOC: NSManagedObjectContext) ->  T {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: MOC) as! T
    }
    
    private class func fetch <T: NSManagedObject>(fetchRequest: NSFetchRequest<NSManagedObject>, MOC: NSManagedObjectContext) -> [T]? {
        do {
            if let objects = try MOC.fetch(fetchRequest) as? [T] {
                return objects
            }
        }catch {
            
        }
        return nil
    }
}
