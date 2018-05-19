//
//  Variants+CoreDataProperties.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData


extension Variants {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Variants> {
        return NSFetchRequest<Variants>(entityName: "Variants")
    }

    @NSManaged public var color: String?
    @NSManaged public var id: Int32
    @NSManaged public var price: Int32
    @NSManaged public var size: Int32
    @NSManaged public var product: Product?

}
