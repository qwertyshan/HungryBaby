//
//  Ingredient+CoreDataProperties.swift
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

class Ingredient: NSManagedObject  {

    @NSManaged var item: String?
    @NSManaged var note: String?
    @NSManaged var quantity: NSNumber?
    @NSManaged var unit: NSNumber?
    @NSManaged var recipe: Recipe?
    @NSManaged var shoppingList: NSSet?

}
