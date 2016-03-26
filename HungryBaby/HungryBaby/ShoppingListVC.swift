//
//  ShoppingListVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/26/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class ShoppingListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate  {
    
    // MARK: - Properties
    
    var mealPlanObjectID: NSManagedObjectID? = nil
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        let ingredientSort = NSSortDescriptor(key: "ingredient", ascending: true)
        let quantitySort = NSSortDescriptor(key: "quantity", ascending: true)
        fetchRequest.sortDescriptors = [ingredientSort, quantitySort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var fetchedMealPlanResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "MealPlan")
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Setups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        do {
            try fetchedMealPlanResultsController.performFetch()
        } catch {}
        fetchedMealPlanResultsController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(fetchedMealPlanResultsController.fetchedObjects!.count)
        if fetchedMealPlanResultsController.fetchedObjects!.count == 0 {
            tableView.hidden = true
        } else {
            createShoppingList()
        }
    }
    
    // MARK: - IB Actions
    
    
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        let count = sectionInfo.numberOfObjects
        print("numberOfRowsInSection:\(count)")

        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let shoplist = fetchedResultsController.objectAtIndexPath(indexPath) as! ShoppingList
        
        let string1 = shoplist.ingredient!
        let string2 = String(shoplist.quantity!) + " " + shoplist.unit!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopCell", forIndexPath: indexPath)
        cell.textLabel?.text = string1
        cell.detailTextLabel?.text = string2
        
        if shoplist.delete == true {
            let attributes = [NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSStrikethroughStyleAttributeName: 1]
            let attrString1 = NSMutableAttributedString(string: string1)
            let attrString2 = NSMutableAttributedString(string: string2)
            attrString1.addAttributes(attributes, range: ((string1 as NSString)).rangeOfString(string1))
            attrString2.addAttributes(attributes, range: (string2 as NSString).rangeOfString(string2))
            
            cell.textLabel?.attributedText = attrString1
            cell.detailTextLabel?.attributedText = attrString2
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shoplist = fetchedResultsController.objectAtIndexPath(indexPath) as! ShoppingList

        if (shoplist.delete == true) {
            let restore = UITableViewRowAction(style: .Normal, title: "Restore") { action, index in
                self.deleteShoppingListEntry(indexPath)
            }
            restore.backgroundColor = UIColor(red: 40/255, green: 124/255, blue: 18/255, alpha: 1/1)
            return [restore]
        } else {
            let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
                self.deleteShoppingListEntry(indexPath)
            }
            delete.backgroundColor = UIColor.redColor()
            return [delete]
        }
    }
    /*
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Right)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
 
    */
    // MARK: - Convenience methods
    
    // Delete entry
    func deleteShoppingListEntry(indexPath: NSIndexPath) {
        let shoplist = fetchedResultsController.objectAtIndexPath(indexPath) as! ShoppingList
        if shoplist.delete == true {
            shoplist.setValue(false, forKey: "delete")
        } else {
            shoplist.setValue(true, forKey: "delete")
        }
        saveContext()
        //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        print(shoplist)
    }
    
    func createShoppingList() {
        
        
        let objectID = fetchedMealPlanResultsController.fetchedObjects?.first!.objectID
        
        // If the meal plan has already been parsed (we have the objectID), exit
        if mealPlanObjectID == fetchedMealPlanResultsController.fetchedObjects?.first!.objectID {
            print("Meal plan is current")
            return
        }
        
        // else
        let mealPlan = sharedContext.objectWithID(objectID!) as! MealPlan
        print("New meal plan with ID: \(objectID). Old ID was: \(mealPlanObjectID)")
        mealPlanObjectID = objectID
        
        print("Fetch count 1: \(fetchedResultsController.fetchedObjects!.count)")
        
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        do {
            let fetchedEntities = try sharedContext.executeFetchRequest(fetchRequest) as! [ShoppingList]
            
            for entity in fetchedEntities {
                sharedContext.deleteObject(entity)
                saveContext()
            }
        } catch {
            fatalError("Failure to execute deleteRequest: \(error)")
        }
        
        
        print("Fetch count 2: \(fetchedResultsController.fetchedObjects!.count)")
        
       
        
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
            let newEntry = NSEntityDescription.insertNewObjectForEntityForName("ShoppingList", inManagedObjectContext: sharedContext) as! ShoppingList
            newEntry.ingredient = entry.ingredient
            newEntry.quantity = entry.quantity
            newEntry.unit = entry.unit
            newEntry.delete = false
            saveContext()
        }
        
        print("Fetch count 3: \(fetchedResultsController.fetchedObjects!.count)")

        // Deinit
        shoppingArray = [shoppingStruct]()
        print(shoppingArray.count)
        
        tableView.reloadData()
        tableView.hidden = false
        
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
