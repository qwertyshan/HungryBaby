//
//  Nutrition+CoreDataProperties.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/1/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

class Nutrition: NSManagedObject {

    @NSManaged var calories: NSNumber?
    @NSManaged var carbohydrates: NSNumber?
    @NSManaged var fats: NSNumber?
    @NSManaged var proteins: NSNumber?
    @NSManaged var recipe: Recipe?
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(recipe: Recipe, dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Recipe", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.carbohydrates  = dictionary[Recipe.Keys.Carbohydrates] as? Double
        self.fats           = dictionary[Recipe.Keys.Fats]          as? Double
        self.proteins       = dictionary[Recipe.Keys.Portions]      as? Double
        self.calories       = dictionary[Recipe.Keys.Calories]      as? Double
        self.recipe         = recipe
    }

}
