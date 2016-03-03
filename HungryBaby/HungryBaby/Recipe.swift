//
//  Recipe.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/1/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Recipe: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    struct Keys {
        static let Favorite = "favorite"
        static let Version = "version"
        static let Name = "name"
        static let Summary = "summary"
        static let ImagePath = "image"
        static let PrepTime = "prep-time"
        static let CookTime = "cook-time"
        static let Portions = "portions"
        static let Snack = "snack"
        static let StartAge = "start-age"
        static let EndAge = "end-age"
        static let Ingredients = "ingredients"
        static let Item = "item"
        static let Quantity = "quantity"
        static let Unit = "unit"
        static let Note = "note"
        static let Method = "method"
        static let Nutrition = "nutrition"
        static let Carbohydrates = "carbohydrates"
        static let Fats = "fats"
        static let Proteins = "proteins"
        static let Calories = "calories"
    }
    
    var image: UIImage? {
        
        // Getting and setting filename as URL's last component
        get {
            if let imagePath = imagePath {
                let url = NSURL(fileURLWithPath: imagePath)
                let fileName = url.lastPathComponent
                return APIClient.Caches.imageCache.imageWithIdentifier(fileName!)
            } else {
                return nil
            }
        }
        
        set {
            if let imagePath = imagePath {
                let url = NSURL(fileURLWithPath: imagePath)
                let fileName = url.lastPathComponent
                APIClient.Caches.imageCache.storeImage(newValue, withIdentifier: fileName!)
            }
        }
    }
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Recipe", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.favorite   = dictionary[Keys.Favorite] as? Bool
        self.version    = Double((dictionary[Keys.Version]  as? String)!)
        self.name       = dictionary[Keys.Name]     as? String
        self.summary    = dictionary[Keys.Summary]  as? String
        self.imagePath  = dictionary[Keys.ImagePath] as? String
        self.prepTime   = dictionary[Keys.PrepTime] as? Int
        self.cookTime   = dictionary[Keys.CookTime] as? Int
        self.portions   = dictionary[Keys.Portions] as? Int
        self.snack      = dictionary[Keys.Snack]    as? Bool
        self.startAge   = dictionary[Keys.StartAge] as? Int
        self.endAge     = dictionary[Keys.EndAge]   as? Int
    }
    
    init(context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Recipe", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.favorite   = nil
        self.version    = nil
        self.name       = nil
        self.summary    = nil
        self.imagePath  = nil
        self.prepTime   = nil
        self.cookTime   = nil
        self.portions   = nil
        self.snack      = nil
        self.startAge   = nil
        self.endAge     = nil
        self.method     = nil
    }
    
    
    override func prepareForDeletion() {
    
        //Delete the associated image file when the managed object is deleted.
        if let imagePath = imagePath {
            if imagePath != "" {
                let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let pathArray = [dirPath, NSURL(fileURLWithPath: imagePath).lastPathComponent!]
                let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                    print("Image deleted successfully: \(pathArray)")
                } catch {
                    print("Image delete failed with error: \(error)")
                }
            }
        }
    }
    

    

}
