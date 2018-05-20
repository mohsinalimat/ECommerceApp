//
//  MostOrdered+CoreDataProperties.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 20/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData


extension MostOrdered {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MostOrdered> {
        return NSFetchRequest<MostOrdered>(entityName: "MostOrdered")
    }

    @NSManaged public var id: Int32
    @NSManaged public var ordercount: Int32
    @NSManaged public var ranking: Rankings?

}
