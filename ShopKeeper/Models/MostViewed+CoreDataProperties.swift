//
//  MostViewed+CoreDataProperties.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 20/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData


extension MostViewed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MostViewed> {
        return NSFetchRequest<MostViewed>(entityName: "MostViewed")
    }

    @NSManaged public var id: Int32
    @NSManaged public var viewcount: Int32
    @NSManaged public var ranking: Rankings?

}
