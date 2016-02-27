//
//  Configuration.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

class Configuration: NSObject {

    struct Allergies {
        var peanuts: Bool?
        var garlic: Bool?
    }
    
    enum DietaryPreference {
        case Vegan, Vegetarian, OvoLactoVegetarian, None
    }
    
    var name: String?
    var image: UIImage?
    var dateOfBirth: NSDate?
    var allergies: Allergies
    var dietaryPreference: DietaryPreference
    
    override init() {
        self.name = nil
        self.image = nil
        self.dateOfBirth = nil
        self.allergies = Allergies(peanuts: false, garlic: false)
        self.dietaryPreference = DietaryPreference.None
    }
    
}