//
//  Category+CoreDataClass.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {
    class func parseData(dict: [String: Any], MOC: NSManagedObjectContext){
        if let categories = dict["categories"] as? [[String: Any]] {
            categories.map{
                if let category = $0 as? [String: Any]{
                    if let id = category["id"] as? Int{
                        let modelObj: Category = Category.findOrCreate(condition: "id = '\(id)'", MOC: MOC)
                        
                        modelObj.parseObject(categoryId: id, data: category, MOC: MOC)
                        modelObj.setValue(id, forKey: "id")
                    }
                }
            }
        }
    }
    
    private func parseObject(categoryId: Int, data: [String: Any], MOC: NSManagedObjectContext){
//        if let exsitingCatId = self.value(forKey: "id") as? Int{
//            if exsitingCatId != categoryId{
//                self.setValue(categoryId, forKey: "id")
//            }
//        }else{
//            self.setValue(categoryId, forKey: "id")
//        }
       
        if let name = data["name"] as? String{
            if let exsiting = self.value(forKey: "name") as? String{
                if exsiting != name{
                    self.setValue(name, forKey: "name")
                }
            }else{
                self.setValue(name, forKey: "name")
            }
        }

        if let products = data["products"] as? [[String: Any]] {
            let mutableProducts = self.mutableSetValue(forKey: "products")
            _ = products.map{
                if let jsonProduct = $0 as? [String: Any]{
                    if let prodId = jsonProduct["id"] as? Int{
                        let product: Product = Product.findOrCreate(condition: "id = '\(prodId)'", MOC: MOC)
                        product.setValue(prodId, forKey: "id")
                        if let dateAdded = jsonProduct["date_added"] as? String{
                            if let exsiting = product.value(forKey: "date_added") as? String{
                                if exsiting != dateAdded{
                                    product.setValue(dateAdded, forKey: "date_added")
                                }
                            }else{
                                product.setValue(dateAdded, forKey: "date_added")
                            }
                        }
                        if let name = jsonProduct["name"] as? String{
                            if let exsiting = product.value(forKey: "name") as? String{
                                if exsiting != name{
                                    product.setValue(name, forKey: "name")
                                }
                            }else{
                                product.setValue(name, forKey: "name")
                            }
                        }
                        if let taxJson = jsonProduct["tax"] as? [String: Any]{
                            let tax: Tax = Tax.create(MOC: MOC)
                            if let taxName = taxJson["name"] as? String{
                                tax.setValue(taxName, forKey: "name")
                            }
                            if let taxValue = taxJson["value"] as? Float{
                                tax.setValue(taxValue, forKey: "value")
                            }
                            product.setValue(tax, forKey: "tax")
                        }
                        if let variants = jsonProduct["variants"] as? [[String: Any]]{
                             let variantItems = product.mutableSetValue(forKey: "variants")
                            _ = variants.map{
                                if let variantJson = $0 as? [String: Any]{
                                    if let varId = variantJson["id"] as? Int{
                                        let variant: Variants = Variants.findOrCreate(condition: "id = '\(varId)'", MOC: MOC)
                                        variant.setValue(varId, forKey: "id")
                                        if let color = variantJson["color"] as? String{
                                            if let exsitingColor = variant.value(forKey: "color") as? String{
                                                if exsitingColor != color{
                                                    variant.setValue(color, forKey: "color")
                                                }
                                            }else{
                                                variant.setValue(color, forKey: "color")
                                            }
                                        }
                                        if let price = variantJson["price"] as? Int{
                                            if let exsitingprice = variant.value(forKey: "price") as? Int{
                                                if exsitingprice != price{
                                                    variant.setValue(price, forKey: "price")
                                                }
                                            }else{
                                                variant.setValue(price, forKey: "price")
                                            }
                                        }
                                        if let size = variantJson["size"] as? Int{
                                            if let exsitingsize = variant.value(forKey: "size") as? Int{
                                                if exsitingsize != size{
                                                    variant.setValue(size, forKey: "size")
                                                }
                                            }else{
                                                variant.setValue(size, forKey: "size")
                                            }
                                        }
                                        variantItems.add(variant)
                                    }
                                    
                                    
                                    
                                }
                            }
                        }
                       mutableProducts.add(product)
                        
                    }
                }
            }
            
        }
        
        
    }
}
