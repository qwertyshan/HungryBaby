//
//  Configuration+CoreDataProperties.swift
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

extension Configuration {

    @NSManaged var dateOfBirth: NSDate?
    @NSManaged var dietaryPreference: NSNumber?
    @NSManaged var imagePath: String?
    @NSManaged var name: String?
    @NSManaged var allergies: Allergies?

}
