//
//  DBManager.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation
import CoreData


enum ClassString: String {
    case Category      = "category"
    case Ranking    = "ranking"
}

class DBManager{
    class func parseData(className: ClassString, dict: [[String: Any]], MOC: NSManagedObjectContext){
        switch className {
        case .Category:
            Category.parseData(dict: dict, MOC: MOC)
        case .Ranking:
            return
            Rankings.parseData(dict: dict, MOC: MOC)
        default:
            return
        }
        
        
    }
    
   
}
