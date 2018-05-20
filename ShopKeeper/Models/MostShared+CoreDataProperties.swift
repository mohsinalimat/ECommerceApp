//
//  MostShared+CoreDataProperties.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 20/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData


extension MostShared {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MostShared> {
        return NSFetchRequest<MostShared>(entityName: "MostShared")
    }

    @NSManaged public var id: Int32
    @NSManaged public var sharecount: Int32
    @NSManaged public var ranking: Rankings?

}
