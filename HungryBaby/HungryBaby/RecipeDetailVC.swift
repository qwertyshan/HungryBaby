//
//  RecipeDetailVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RecipeDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate  {
    
    // MARK: - Properties
    
    var recipe = Recipe()
    
    struct recipeSection {
        var heading : String
        var items : [[String:AnyObject]]
        
        init(title: String, objects: [[String:AnyObject]]) {
            heading = title
            items = objects
        }
    }
    
    var loadedRecipe = [recipeSection]()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "name == %@", self.recipe.name!);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Setups
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        // Load recipe into custom array
        loadedRecipe = loadRecipe()
    }
    
    
    // Convenience method to load recipe into custom array
    // This allows us to use sections in the tableview
    func loadRecipe() -> [recipeSection] {
        // Section: Header
        let header = recipeSection(title: "Header", objects: [["image": recipe.image ?? UIImage(named: "avocado-banana-puree")!, "name": recipe.name ?? ""]])
        
        // Section: Summary
        let summary = recipeSection(title: "Summary", objects: [["summary": recipe.summary ?? ""]])
        
        // Section: Numbers
        let prepTime = recipe.prepTime ?? "" as String
        let cookTime = recipe.cookTime ?? "" as String
        let portions = recipe.portions ?? "" as String
        let startAge = recipe.startAge ?? "" as String
        let endAge = recipe.endAge ?? "" as String
        let numbers = recipeSection(title: "Numbers", objects: [["prepTime": prepTime, "cookTime": cookTime, "portions": portions, "startAge": startAge, "endAge": endAge]])
        
        // Section: Ingredients
        var ingredientArray: [[String:AnyObject]] {
            let result: [[String:AnyObject]]
            let ingredients = self.recipe.ingredients! as [Ingredient]
            for i in ingredients {
                let newEntry = ["item": i.item!, "note": i.note!, "quantity": Double(i.quantity!), "unit": i.unit!]
                result.append(newEntry as! [String : AnyObject])
            }
            return result
        }
        let ingredients = recipeSection(title: "Ingredients", objects: ingredientArray)
        
        // Section: Method
        var methodArray: [[String:AnyObject]] {
            let result: [[String:AnyObject]]
            var method = self.recipe.method! as [MethodStep]
            method.sortInPlace { ($0.number as! Int) < ($1.number as! Int) }
            for i in method {
                let newEntry = ["number": Int(i.number!), "step": i.step!]
                result.append(newEntry as! [String : AnyObject])
            }
            return result
        }
        let method = recipeSection(title: "Method", objects: methodArray)
        
        // Section: Nutrition
        let nutritionEntry = self.recipe.nutrition! as Nutrition
        let nutrition = recipeSection(title: "Nutrition", objects: [["carbohydrates": Double(nutritionEntry.carbohydrates!), "fats": Double(nutritionEntry.fats!), "proteins": Double(nutritionEntry.proteins!), "calories": Double(nutritionEntry.calories!)]])
        
        let result = [header, summary, numbers, ingredients, method, nutrition]
        
        return result
    }
    
}
