//
//  Method.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/2/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import CoreData

class MethodStep: NSManagedObject {
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(recipe: Recipe, number: NSNumber, step: String, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("MethodStep", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.number     = number
        self.step       = step
        self.recipe     = recipe
    }
}

