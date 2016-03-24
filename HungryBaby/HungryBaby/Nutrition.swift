//
//  Nutrition.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/2/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import CoreData

class Nutrition: NSManagedObject {
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(recipe: Recipe, dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Nutrition", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.carbohydrates  = dictionary[Recipe.Keys.Carbohydrates] as? Double
        self.fats           = dictionary[Recipe.Keys.Fats]          as? Double
        self.proteins       = dictionary[Recipe.Keys.Proteins]      as? Double
        self.calories       = dictionary[Recipe.Keys.Calories]      as? Double
        self.recipe         = recipe
    }
    
}
