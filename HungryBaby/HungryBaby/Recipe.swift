//
//  Recipe.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

class Recipe: NSObject {
    struct Keys {
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
    
    enum Unit {
        case Gram, Kilogram, Mililiter, Liter, Tablespoon, Teaspoon, Cup, None
    }
    
    // MARK: - Properties
    
    struct Ingredient {
        var item: String
        var quantity: Double
        var unit: Unit
        var note: String?
    }
    
    struct Nutrition {
        var carbohydrates: Double?
        var fats: Double?
        var proteins: Double?
        var calories: Double?
    }
    
    var version: Double?
    var name: String?
    var summary: String?
    var imagePath: String?
    var prepTime: Int?
    var cookTime: Int?
    var portions: Int?
    var snack: Bool?
    var startAge: Int?
    var endAge: Int?
    var ingredients: [Ingredient]?
    var method: [String]?
    var nutrition: Nutrition?
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
    
    // MARK: - Methods
    
    init(dictionary: [String : AnyObject]) {
        self.version    = dictionary[Keys.Version]  as? Double
        self.name       = dictionary[Keys.Name]     as? String
        self.summary    = dictionary[Keys.Summary]  as? String
        self.imagePath  = dictionary[Keys.ImagePath] as? String
        self.prepTime   = dictionary[Keys.PrepTime] as? Int
        self.cookTime   = dictionary[Keys.CookTime] as? Int
        self.portions   = dictionary[Keys.Portions] as? Int
        self.snack      = dictionary[Keys.Snack]    as? Bool
        self.startAge   = dictionary[Keys.StartAge] as? Int
        self.endAge     = dictionary[Keys.EndAge]   as? Int
        if let ingredients = dictionary[Keys.Ingredients] as? [[String: AnyObject]] {
            for ingredient in ingredients {
                var newIngredient: Ingredient
                newIngredient.item      = ingredient[Keys.Item] as! String
                newIngredient.quantity  = ingredient[Keys.Quantity] as! Double
                newIngredient.unit      = ingredient[Keys.Unit] as! Unit
                newIngredient.note      = ingredient[Keys.Note] as? String
                self.ingredients?.append(newIngredient)
            }
        }
        if let method = dictionary[Keys.Method] as? [String] {
            for step in method {
                self.method?.append(step as String)
            }
        }
        if let nutrition = dictionary[Keys.Nutrition] as? [String : AnyObject] {
            self.nutrition?.carbohydrates   = nutrition[Keys.Carbohydrates] as? Double
            self.nutrition?.fats            = nutrition[Keys.Fats]          as? Double
            self.nutrition?.proteins        = nutrition[Keys.Portions]      as? Double
            self.nutrition?.calories        = nutrition[Keys.Calories]      as? Double
        }
        
    }
    


/*
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
*/

}

