//
//  Rankings+CoreDataProperties.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData


extension Rankings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rankings> {
        return NSFetchRequest<Rankings>(entityName: "Rankings")
    }

    @NSManaged public var id: Int32
    @NSManaged public var ordercount: Int32
    @NSManaged public var sharecount: Int32
    @NSManaged public var viewcount: Int32

}
