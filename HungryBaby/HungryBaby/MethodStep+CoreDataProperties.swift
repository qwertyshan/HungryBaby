//
//  MethodStep+CoreDataProperties.swift
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

extension MethodStep {

    @NSManaged var number: NSNumber?
    @NSManaged var step: String?
    @NSManaged var recipe: Recipe?

}
