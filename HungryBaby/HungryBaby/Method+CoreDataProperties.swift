//
//  Method+CoreDataProperties.swift
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

class Method: NSManagedObject {

    @NSManaged var number: NSNumber?
    @NSManaged var step: String?
    @NSManaged var recipe: Recipe?
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(recipe: Recipe, number: NSNumber, step: String, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Recipe", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.number     = number
        self.step       = step
        self.recipe     = recipe
    }


}
