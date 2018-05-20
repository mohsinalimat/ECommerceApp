//
//  CoreDataOperation.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation
import CoreData



protocol CoreDataOperationData {
    var result: [String: Any]? {get}
    var coreDataClassName: ClassString? {get}
}

extension NetworkOperation: CoreDataOperationData{
    var taskResult: [String: Any]? {return self.result}
    var coreDataClassName: ClassString? {return self.className}
}

class CoreDataOperation: Operation {
    
    private let privateManageobjectContext: NSManagedObjectContext
    private let completion: (() -> Swift.Void)
    private let group: Group?
    
    init(manageObjectContext: NSManagedObjectContext, group: Group? = nil, completeBlock: @escaping (() -> Swift.Void)) {
        self.privateManageobjectContext         =  NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.privateManageobjectContext.parent  = manageObjectContext
        self.completion                         = completeBlock
        self.group                              = group
        super.init()
    }
    
    private func performOperation(completion:(()->Swift.Void)) {
        let dataProvider = dependencies.filter{
            $0 is CoreDataOperationData
            }.first as? CoreDataOperationData
        if let data = dataProvider?.result, let className = dataProvider?.coreDataClassName{
            if let categories = data["categories"] as? [[String: Any]]{
                DBManager.parseData(className: .Category,dict: categories, MOC: self.privateManageobjectContext)
                self.saveChanges()
            }
            if let rankings = data["rankings"] as? [[String: Any]]{
                DBManager.parseData(className: .Ranking,dict: rankings, MOC: self.privateManageobjectContext)
            }
            
            
        }
        completion()
    }
    
    override func main() {
        super.main()
        if let grp = self.group {
            grp.exit()
        }
        performOperation { [weak self] in
            guard let sl = self else {
                return
            }
            print("SAVE core data")
            sl.saveChanges()
            
            sl.completion()
        }
    }
    
    private func saveChanges() {
        privateManageobjectContext.performAndWait {
            guard self.privateManageobjectContext.hasChanges else { return }
            
            do {
                try self.privateManageobjectContext.save()
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }
    
    deinit {
        
        print("CoreDataOperation DEINIT")
    }
}
