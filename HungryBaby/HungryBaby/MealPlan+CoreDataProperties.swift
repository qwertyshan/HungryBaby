//
//  MealPlan+CoreDataProperties.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 3/25/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

class MealPlan: NSManagedObject {

    @NSManaged var startDate: NSDate?
    @NSManaged var mealEntry: NSSet?

}
