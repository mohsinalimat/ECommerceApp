//
//  Rankings+CoreDataClass.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 20/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Rankings)
public class Rankings: NSManagedObject {
   class func parseData(dict: [[String: Any]], MOC: NSManagedObjectContext){
    let modelRanking: Rankings = Rankings.findOrCreate(condition:"id = '\(0)'", MOC: MOC)
    _ = dict.map{
            if let element = $0 as? [String: Any]{
                if let rank  = element["ranking"] as? String{
                    if rank.contains("Most Viewed Products") || rank.lowercased().contains("viewed"){
                        if let products = element["products"] as? [[String: Any]]{
                            modelRanking.parseViewedDict(products: products, MOC: MOC)
                        }
                    }
                    if rank.contains("Most ShaRed Products") || rank.lowercased().contains("shared"){
                        if let products = element["products"] as? [[String: Any]]{
                            modelRanking.parseSharedDict(products: products, MOC: MOC)
                        }
                    }
                    if rank.contains("Most OrdeRed Products") || rank.lowercased().contains("ordered"){
                        if let products = element["products"] as? [[String: Any]]{
                            modelRanking.parseOrderedDict(products: products, MOC: MOC)
                        }
                    }
                    
                }
            }
        }
    }
    
    func parseSharedDict(products: [[String: Any]], MOC: NSManagedObjectContext){
        let mutableViewed = self.mutableSetValue(forKey: "mostsharedrel")
        _ = products.map{
            if let id = $0["id"] as? Int32{
                let shareModel: MostShared = MostShared.findOrCreate(condition: "id = '\(id)'", MOC: MOC)
                shareModel.setValue(id, forKey: "id")
                
                if let count = $0["shares"] as? Int32{
                    shareModel.setValue(count, forKey: "sharecount")
                    if let product = Product.find(condition: "id = '\(id)'", sortBy: "id", MOC: MOC) as? Product{
                        product.setValue(count, forKey: "sharecount")
                        do{
                            try MOC.save()
                        }catch{
                            
                        }
                    }
                }
                mutableViewed.add(shareModel)
                shareModel.setValue(self, forKey: "ranking")
                
            }
        }
        
    }
    
    func parseOrderedDict(products: [[String: Any]], MOC: NSManagedObjectContext){
        let mutableOrdered = self.mutableSetValue(forKey: "mostorderdrel")
        _ = products.map{
            if let id = $0["id"] as? Int{
                let orderModel: MostOrdered = MostOrdered.findOrCreate(condition: "id = '\(id)'", MOC: MOC)
                orderModel.setValue(id, forKey: "id")
                if let count = $0["order_count"] as? Int{
                    orderModel.setValue(count, forKey: "ordercount")
                    if let product = Product.find(condition: "id = '\(id)'", sortBy: "id", MOC: MOC) as? Product{
                        product.setValue(count, forKey: "orderedcount")
                        do{
                            try MOC.save()
                        }catch{
                            
                        }
                       
                    }
                }
                mutableOrdered.add(orderModel)
                orderModel.setValue(self, forKey: "ranking")
                
            }
        }
    }
    
    func parseViewedDict(products: [[String: Any]], MOC: NSManagedObjectContext){
        let mutableViewed = self.mutableSetValue(forKey: "mostviewedrel")
        _ = products.map{
            if let id = $0["id"] as? Int{
                let viewdModel: MostViewed = MostViewed.findOrCreate(condition: "id = '\(id)'", MOC: MOC)
                viewdModel.setValue(id, forKey: "id")
                if let count = $0["view_count"] as? Int{
                    viewdModel.setValue(count, forKey: "viewcount")
                    if let product = Product.find(condition: "id = '\(id)'", sortBy: "id", MOC: MOC) as? Product{
                        product.setValue(count, forKey: "viewcount")
                    }
                }
                mutableViewed.add(viewdModel)
                viewdModel.setValue(self, forKey: "ranking")
                
            }
        }

    }
}
