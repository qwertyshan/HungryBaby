//
//  MealPlanVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MealPlanVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Fetched Results Controller
    
    lazy var fetchedMealPlanResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "MealEntry")
        let daySort = NSSortDescriptor(key: "daysFromStart", ascending: true)
        let numSort = NSSortDescriptor(key: "numberForDay", ascending: true)
        fetchRequest.sortDescriptors = [daySort, numSort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: "daysFromStart", cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - View Setups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        do {
            try fetchedMealPlanResultsController.performFetch()
        } catch {}
        fetchedMealPlanResultsController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedMealPlanResultsController.sections!.count == 0 {
            tableView.hidden = true
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - IB Actions
    
    @IBAction func refreshMealPlan(sender: UIBarButtonItem) {
        createMealPlan()
    }
    
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return fetchedMealPlanResultsController.sections!.count
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedMealPlanResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch section {
        case 0: return "Monday"
        case 1: return "Tuesday"
        case 2: return "Wednesday"
        case 3: return "Thursday"
        case 4: return "Friday"
        case 5: return "Saturday"
        default: return "Sunday"
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView //recast view as a UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor(red: 67/255, green: 71/255, blue: 77/255, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "HelveticaNeue", size: 12)
        
        header.contentView.backgroundColor = UIColor(red: 254/255, green: 218/255, blue: 146/255, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mealEntry = fetchedMealPlanResultsController.objectAtIndexPath(indexPath) as! MealEntry
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MealPlanCell", forIndexPath: indexPath) as! MealPlanCell
        let recipe = mealEntry.recipe 
        
        configureCellImage(cell, recipe: recipe, atIndexPath: indexPath)
        
        cell.cellText.text = (recipe.name! as String)
        if recipe.favorite == true {
            cell.favImage.image = UIImage(named: "Hearts-Filled-Red")
        } else {
            cell.favImage.image = nil
        }
        cell.mealTypeLabel.text = (mealEntry.type! as String)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: - Configure Cell
    
    func configureCellImage(cell: MealPlanCell, recipe: Recipe, atIndexPath indexPath: NSIndexPath) {
        
        var recipeImage = UIImage()
        var activityIndicator = UIActivityIndicatorView()
        
        // Set cell image to nil
        cell.cellImage.image = nil
        
        // Set activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
        activityIndicator.backgroundColor = (UIColor(white: 0.2, alpha: 0.7))
        activityIndicator.hidesWhenStopped = true
        
        // Set the Photo Image
        if recipe.imagePath == nil || recipe.imagePath == "" {
            recipeImage = UIImage(named: "Baby")!
            print("Image not available.")
            
        } else if recipe.image != nil {
            recipeImage = recipe.image!
            //print("Image retrieved from cache.")
            
        } else { // This is the interesting case. The photo has an image name, but it is not downloaded yet.
            
            // Start activity indicator
            dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.startAnimating()
                cell.addSubview(activityIndicator)
            }
            
            // Download image
            let task = APIClient.sharedInstance().getImage(recipe.imagePath!) {data, error in
                if let error = error {
                    print("Image download error: \(error.localizedDescription)")
                    // Update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.cellImage!.image = UIImage(named: "Baby")!
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                    }
                }
                if let data = data {
                    print("Image download successful")
                    // Create the image
                    recipeImage = UIImage(data: data as! NSData)!
                    dispatch_async(dispatch_get_main_queue()) {
                        recipe.image = recipeImage
                    }
                    
                    // Update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.cellImage!.image = recipeImage
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.cellImage!.image = recipeImage
        
        // Stop activity indicator
        if activityIndicator.isAnimating() {
            dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecipeDetailSegue2" {
            if let detailController = segue.destinationViewController as? RecipeDetailVC {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailController.objectID = fetchedMealPlanResultsController.objectAtIndexPath(indexPath).recipe.objectID
                }
            }
        }
    }
    
    
    // MARK: - Meal Plan logic
    
    func createMealPlan() {
        // Assume that we will have just one meal plan at any given time.
        // If a plan exists, delete it. 
        // Then create a new one and add it to Core Data.
        
        // Get count of existing recipes
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        var recipes = [Recipe]()
        do {
            recipes = try sharedContext.executeFetchRequest(fetchRequest) as! [Recipe]
        } catch {}
        let count = recipes.count
        
        // If there are no recipes, return
        if count == 0 {
            let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No recipes available. Please wait for recipes to download or restart the app."])
            CommonElements.showAlert(self, error: error)
            return
        }
        
        if fetchedMealPlanResultsController.fetchedObjects?.count != 0 {
            let fetchRequest = NSFetchRequest(entityName: "MealPlan")
            do {
                let fetchedEntities = try sharedContext.executeFetchRequest(fetchRequest) as! [MealPlan]
                
                for entity in fetchedEntities {
                    sharedContext.deleteObject(entity)
                }
            } catch {
                fatalError("Failure to execute deleteRequest: \(error)")
            }
            saveContext()
        }
        
        // Create new meal plan
        let newMealPlan = NSEntityDescription.insertNewObjectForEntityForName("MealPlan", inManagedObjectContext: sharedContext) as! MealPlan
        newMealPlan.startDate = NSDate()
        
        for day in (0..<7) {
            for number in (0..<4) {
                let newMealEntry = NSEntityDescription.insertNewObjectForEntityForName("MealEntry", inManagedObjectContext: sharedContext) as! MealEntry
                let index = Int(arc4random_uniform(UInt32(count)))
                let recipe = recipes[index]
                
                newMealEntry.daysFromStart = day
                newMealEntry.numberForDay = number
                newMealEntry.recipe = recipe
                newMealEntry.mealPlan = newMealPlan
                
                switch number {
                case 0: newMealEntry.type = "Breakfast"
                case 1: newMealEntry.type = "Lunch"
                case 2: newMealEntry.type = "Dinner"
                case 3: newMealEntry.type = "Snack"
                default: newMealEntry.type = "Extra Meal"
                }
                
                saveContext()
            }
        }
        saveContext()
       
        do {
            try fetchedMealPlanResultsController.performFetch()
        } catch {}
        
        tableView.reloadData()
        
        if tableView.hidden == true {
            tableView.hidden = false
        }
        
        createShoppingList(newMealPlan)
    }
    
    func createShoppingList(mealPlan: MealPlan) {
        
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        
        do {
            let fetchedEntities = try sharedContext.executeFetchRequest(fetchRequest) as! [ShoppingList]
            print("Fetch count 1: \(fetchedEntities.count)")
            
            for entity in fetchedEntities {
                self.sharedContext.deleteObject(entity)
            }
            self.saveContext()
            
        } catch {
            fatalError("Failure to execute deleteRequest: \(error)")
        }
        
        struct shoppingStruct {
            var ingredient: String = ""
            var quantity: Double = 0
            var unit: String = ""
        }
        var shoppingArray = [shoppingStruct]()
        
        // Gather all ingredients
        for item in mealPlan.mealEntry! {
            for ingredient in (item as! MealEntry).recipe.ingredients! {
                var shoppingList = shoppingStruct()
                shoppingList.ingredient = (ingredient as! Ingredient).item!
                shoppingList.quantity = Double((ingredient as! Ingredient).quantity!)
                shoppingList.unit = (ingredient as! Ingredient).unit!
                shoppingArray.append(shoppingList)
            }
        }
        
        // Sort ingredients
        shoppingArray.sortInPlace { $0.ingredient < $1.ingredient }
        
        var i = 0
        
        // Merge common ingredients
        while (i < shoppingArray.count-1) {
            let current = shoppingArray[i]
            let next = shoppingArray[i+1]
            //print("Current: \(current.ingredient) \(current.quantity) Next: \(next.ingredient) \(next.quantity)")
            
            if current.ingredient == next.ingredient {
                shoppingArray[i+1].quantity = Double(current.quantity) + Double(next.quantity)
                //print("Merge -> Current: \(current.ingredient) \(current.quantity) Next: \(shoppingArray[i+1].ingredient) \(shoppingArray[i+1].quantity)")
                shoppingArray.removeAtIndex(i)
            } else {
                i = i + 1
                //print("No Merge")
            }
        }
        
        // Load into CoreData
        for entry in shoppingArray {
            let newEntry = NSEntityDescription.insertNewObjectForEntityForName("ShoppingList", inManagedObjectContext: self.sharedContext) as! ShoppingList
            newEntry.ingredient = entry.ingredient
            newEntry.quantity = entry.quantity
            newEntry.unit = entry.unit
            newEntry.delete = false
            saveContext()
        }
        
        // Deinit
        shoppingArray = [shoppingStruct]()
        print(shoppingArray.count)
        
    }
    
    // Save Managed Object Context helper
    func saveContext() {
        do {
            try self.sharedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
