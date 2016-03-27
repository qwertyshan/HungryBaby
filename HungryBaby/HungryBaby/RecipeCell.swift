//
//  RecipeCell.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/29/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

class RecipeCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellText: UILabel!
    @IBOutlet weak var favImage: UIImageView!
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}

class RecipeHeader: UITableViewCell {
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
}

class RecipeSummary: UITableViewCell {
    @IBOutlet var summaryLabel: UILabel!
}

class RecipeNumbers: UITableViewCell {
    @IBOutlet var prepLabel: UILabel!
    @IBOutlet var cookLabel: UILabel!
    @IBOutlet var forAgesLabel: UILabel!
    @IBOutlet var makesLabel: UILabel!
}

class RecipeIngredients: UITableViewCell {
    @IBOutlet var ingredientLabel: UILabel!
}

class RecipeMethod: UITableViewCell {
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var methodStepLabel: UILabel!
}

class RecipeNutrition: UITableViewCell {
    @IBOutlet var carbsLabel: UILabel!
    @IBOutlet var fatsLabel: UILabel!
    @IBOutlet var proteinsLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
}

class MealPlanCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellText: UILabel!
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet var mealTypeLabel: UILabel!
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}