//
//  MealPlan.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation

class MealPlan: NSObject {
    enum MealType {
        case Snack, Breakfast, Lunch, Dinner
    }
    
    struct MealEntry {
        var dayIndexFromStart: Int
        var mealType: MealType
        var meal: Recipe
    }
    
    // MARK: - Properties
    
    var mealPlan: [MealEntry]
    var startDate: NSDate
    
    // MARK: - Methods
    
    init(startDate: NSDate, mealPlan: [MealEntry]) {
        self.startDate = startDate
        self.mealPlan = mealPlan
    }
    
}
