//
//  APIManager.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation
import CoreData

class APIManager: Any {
    private static var _apiManager: APIManager?
    private let InstanceManageObject: NSManagedObjectContext  = CoreDataManager.coreDataManager.managedObjectContext
    class var apiManager: APIManager {
        guard let manager = APIManager._apiManager else {
            APIManager._apiManager = APIManager()
            APIManager._apiManager!.operationQueue.maxConcurrentOperationCount = 7
            return APIManager._apiManager!
        }
        return manager
    }
    var observerArray: [NSObjectProtocol]    = [NSObjectProtocol]()
    var operationQueue: OperationQueue        = OperationQueue()
    
    init() {
        self.setObservers()
    }
    
    
    func setObservers () {
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {[weak self] (_) in
            guard let slf = self else {return}
            slf.checkForUpdate()
        }
        self.observerArray.append(observer)
    }
    
    func checkForUpdate(){
        //Here we can check for any updates
    }
    
    func setupAPIStart() {
        operationQueue.qualityOfService = .userInitiated
        let group = Group()
        //if Category.count(MOC: self.InstanceManageObject) == 0{
        group.enter()
        let url = "https://stark-spire-93433.herokuapp.com/json" //endpoint
        self.performApiCall(group: group, classname: .Category, url: url)
        //}
        group.wait {
            print("API END")
            self.checkForUpdate()
        }
    }
    func performApiCall(group: Group, classname : ClassString, url: String, completion: (()->Swift.Void)? = nil){
        let networkOperation = NetworkOperation(className: classname, url: url)
        networkOperation.name = classname.rawValue
        let managedObjectContext = CoreDataManager.coreDataManager.privateManagedObjectContext
        let coreDataOperation = CoreDataOperation(manageObjectContext: managedObjectContext, group: group) {
            
            if completion != nil {
                completion!()
            }
        }
        coreDataOperation.name = "\(classname)_Data"
        let operations = [networkOperation, coreDataOperation]
        coreDataOperation.addDependency(networkOperation)
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}

class Group: NSObject {
    var group = DispatchGroup()
    func enter () {
        self.group.enter()
    }
    func exit () {
        self.group.leave()
    }
    func wait(_ block: @escaping (()-> Swift.Void)) {
        self.group.notify(queue: DispatchQueue.main) {
            block()
        }
    }
}
