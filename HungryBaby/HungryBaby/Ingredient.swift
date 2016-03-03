//
//  Ingredient.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/2/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import CoreData

class Ingredient: NSManagedObject  {
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(recipe: Recipe, dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Ingredient", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.item      = dictionary[Recipe.Keys.Item] as? String
        self.quantity  = Double((dictionary[Recipe.Keys.Quantity] as? String)!)!
        switch (dictionary[Recipe.Keys.Unit] as! String).lowercaseString {
            
        case "gram":            self.unit = "g"
        case "kilogram":        self.unit = "kg"
        case "mililiter", "mililitre": self.unit = "ml"
        case "liter", "litre":  self.unit = "l"
        case "tablespoon":      self.unit = "tbsp"
        case "teaspoon":        self.unit = "tsp"
        case "cup":             self.unit = "cup"
        default:                self.unit = ""
            
        }
        self.note       = dictionary[Recipe.Keys.Note] as? String
        self.recipe     = recipe
    }
    
}
