//
//  ShoppingList+CoreDataProperties.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/23/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ShoppingList {

    @NSManaged var note: String?
    @NSManaged var items: NSSet?
    @NSManaged var mealPlan: MealPlan?

}
