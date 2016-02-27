//
//  ShoppingList.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation

class ShoppingList: NSObject {
    
    // MARK: - Properties
    
    var items: [Recipe.Ingredient]?
    var mealPlan: MealPlan
    
    // MARK: - Methods
    
    init(items: [Recipe.Ingredient]?, mealPlan: MealPlan) {
        self.items = items
        self.mealPlan = mealPlan
    }
    
}
