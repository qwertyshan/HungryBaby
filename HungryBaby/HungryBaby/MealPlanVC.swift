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
    
    // Fetched Results Controllers
    
    lazy var fetchedRecipesResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
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
            try fetchedRecipesResultsController.performFetch()
        } catch {}
        fetchedRecipesResultsController.delegate = self
        
        do {
            try fetchedMealPlanResultsController.performFetch()
        } catch {}
        fetchedMealPlanResultsController.delegate = self
        
        sharedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

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
        cell.cellImage.image = (recipe.image! as UIImage)
        cell.cellText.text = (recipe.name! as String)
        if recipe.favorite == true {
            cell.favImage.image = UIImage(named: "Hearts-Filled-Red")
        } else {
            cell.favImage.image = nil
        }
        cell.mealTypeLabel.text = (mealEntry.type! as String)
        
        return cell
    }
    
    
    // MARK: - Meal Plan logic
    
    func createMealPlan() {
        // Assume that we will have just one meal plan at any given time.
        // If a plan exists, delete it. 
        // Then create a new one and add it to Core Data.
        
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
                
        // Get count of existing recipes
        let count = UInt32(fetchedRecipesResultsController.fetchedObjects!.count)
        
        for day in (0..<7) {
            for number in (0..<4) {
                let newMealEntry = NSEntityDescription.insertNewObjectForEntityForName("MealEntry", inManagedObjectContext: sharedContext) as! MealEntry
                let index = Int(arc4random_uniform(count))
                let recipe = fetchedRecipesResultsController.fetchedObjects![index] as! Recipe
                
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
