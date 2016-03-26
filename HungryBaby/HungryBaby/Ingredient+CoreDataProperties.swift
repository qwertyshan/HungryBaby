//
//  Ingredient+CoreDataProperties.swift
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

extension Ingredient {

    @NSManaged var item: String?
    @NSManaged var note: String?
    @NSManaged var quantity: NSNumber?
    @NSManaged var unit: String?
    @NSManaged var recipe: Recipe?

}
