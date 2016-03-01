//
//  Recipe+CoreDataProperties.swift
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

extension Recipe {

    @NSManaged var cookTime: NSNumber?
    @NSManaged var endAge: NSNumber?
    @NSManaged var favorite: NSNumber?
    @NSManaged var imagePath: String?
    @NSManaged var name: String?
    @NSManaged var portions: NSNumber?
    @NSManaged var prepTime: NSNumber?
    @NSManaged var snack: NSNumber?
    @NSManaged var startAge: NSNumber?
    @NSManaged var summary: String?
    @NSManaged var version: NSNumber?
    @NSManaged var ingredients: NSSet?
    @NSManaged var meals: NSSet?
    @NSManaged var method: NSSet?
    @NSManaged var nutrition: Nutrition?

}
