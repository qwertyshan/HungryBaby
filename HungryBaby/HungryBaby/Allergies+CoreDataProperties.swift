//
//  Allergies+CoreDataProperties.swift
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

extension Allergies {

    @NSManaged var garlic: NSNumber?
    @NSManaged var peanuts: NSNumber?
    @NSManaged var configuration: Configuration?

}
