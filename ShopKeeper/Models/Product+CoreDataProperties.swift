//
//  Product+CoreDataProperties.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 20/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var date_added: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var viewcount: Int32
    @NSManaged public var sharecount: Int32
    @NSManaged public var orderedcount: Int32
    @NSManaged public var category: Category?
    @NSManaged public var tax: Tax?
    @NSManaged public var variants: NSSet?

}

// MARK: Generated accessors for variants
extension Product {

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: Variants)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: Variants)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: NSSet)

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: NSSet)

}
