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
    
    var objectID = NSManagedObjectID()
    var recipe: Recipe {
            return try! sharedContext.existingObjectWithID(objectID) as! Recipe
    }
    
    var favRecipe = false
    
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
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Setups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300.0
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        // Load recipe into custom array
        loadedRecipe = loadRecipe()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBarHidden = false
        navigationItem.title = loadedRecipe.first!.items[0]["name"] as? String

        favRecipe = recipe.favorite as! Bool

        if favRecipe {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Hearts-Filled-Red"), style: .Plain, target: self, action: #selector(RecipeDetailVC.favButtonTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Hearts"), style: .Plain, target: self, action: #selector(RecipeDetailVC.favButtonTapped))
        }

        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections
        return 6
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return loadedRecipe[section].items.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if loadedRecipe[section].heading != "Header" {
            return loadedRecipe[section].heading
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView //recast view as a UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor(red: 67/255, green: 71/255, blue: 77/255, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "HelveticaNeue", size: 12)
        header.contentView.backgroundColor = UIColor(red: 254/255, green: 218/255, blue: 146/255, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = loadedRecipe[indexPath.section]
        let row = section.items[indexPath.row]
        switch section.heading {
        case "Header":
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeHeader", forIndexPath: indexPath) as! RecipeHeader
            cell.recipeImage.image = (row["image"]! as! UIImage)
            cell.nameLabel.text = (row["name"]! as! String)
            return cell
            
        case "Summary":
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeSummary", forIndexPath: indexPath) as! RecipeSummary
            cell.summaryLabel.text = (row["summary"]! as! String)
            return cell
            
        case "Numbers":
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeNumbers", forIndexPath: indexPath) as! RecipeNumbers
            cell.prepLabel.text = "\(row["prepTime"]!) min"
            cell.cookLabel.text = "\(row["cookTime"]!) min"
            cell.forAgesLabel.text = "\(row["startAge"]!) to \(row["endAge"]!) months"
            cell.makesLabel.text = "\(row["portions"]!) portions"
            return cell
            
        case "Ingredients":
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeIngredients", forIndexPath: indexPath) as! RecipeIngredients
            cell.ingredientLabel.text = "\(row["quantity"]!) \(row["unit"]!) \(row["item"]!)"
            return cell
            
        case "Method":
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeMethod", forIndexPath: indexPath) as! RecipeMethod
            cell.numberLabel.text = "\(row["number"]!)."
            cell.methodStepLabel.text = (row["step"] as! String)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeNutrition", forIndexPath: indexPath) as! RecipeNutrition
            cell.carbsLabel.text = "\(row["carbohydrates"]!) g"
            cell.fatsLabel.text = "\(row["fats"]!) g"
            cell.proteinsLabel.text = "\(row["proteins"]!) g"
            cell.caloriesLabel.text = "\(row["calories"]!) cal"
            return cell
        }
    }
    
    // Convenience method to load recipe into custom array
    // This allows us to use sections in the tableview
    func loadRecipe() -> [recipeSection] {
        
        // Section: Header
        let header = recipeSection(title: "Header", objects: [["image": recipe.image ?? UIImage(named: "default-placeholder")!, "name": recipe.name ?? ""]])
        
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
            var result = [[String:AnyObject]]()
            let ingredients = recipe.ingredients?.allObjects as! [Ingredient]
            for i in ingredients {
                let newEntry = ["item": i.item!, "note": i.note!, "quantity": Double(i.quantity!), "unit": i.unit!]
                result.append(newEntry as! [String : AnyObject])
            }
            return result
        }
        let ingredients = recipeSection(title: "Ingredients", objects: ingredientArray)
        
        // Section: Method
        var methodArray: [[String:AnyObject]] {
            var result = [[String:AnyObject]]()
            //print(recipe.method)
            var method = recipe.method?.allObjects as! [MethodStep]
            method.sortInPlace { Int($0.number!) < Int($1.number!) }
            for i in method {
                let newEntry = ["number": Int(i.number!), "step": i.step!]
                result.append(newEntry as! [String : AnyObject])
            }
            return result
        }
        let method = recipeSection(title: "Method", objects: methodArray)
        
        // Section: Nutrition
        let nutritionEntry = recipe.nutrition! as Nutrition
        let nutrition = recipeSection(title: "Nutrition", objects: [["carbohydrates": Double(nutritionEntry.carbohydrates!), "fats": Double(nutritionEntry.fats!), "proteins": Double(nutritionEntry.proteins!), "calories": Double(nutritionEntry.calories!)]])
        
        let result = [header, summary, numbers, ingredients, method, nutrition]
        
        // Set global variable favRecipe
        if let fav = recipe.favorite {
            favRecipe = Bool(fav)
        }
        
        return result
    }
    
    func favButtonTapped() {
        
        if favRecipe {  // If currently favorite
            recipe.favorite = false // make not favorite
            saveContext()
            navigationItem.rightBarButtonItem!.image = UIImage(named: "Hearts") // Set the button image to unfilled
        } else {        // If currently not favorite
            recipe.favorite = true  // make favorite
            saveContext()
            navigationItem.rightBarButtonItem!.image = UIImage(named: "Hearts-Filled-Red") // Set the button image to filled
        }
        favRecipe = recipe.favorite as! Bool
    }

    //MARK: - Save Managed Object Context helper
    func saveContext() {
        do {
            try self.sharedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
