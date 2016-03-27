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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get count of current Meal Plans
        var count = Int()
        do {
            count = try sharedContext.executeFetchRequest(NSFetchRequest(entityName: "MealPlan")).count
        } catch {}
        
        // If no meal plan exists, hide table
        if count == 0 {
            tableView.hidden = true
        }
        // Else, restart fetchedResultsController and reload table data
        else {
            do {
                try fetchedResultsController.performFetch()
            } catch {}
            tableView.reloadData()
            tableView.hidden = false
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        let count = sectionInfo.numberOfObjects
        print("numberOfRowsInSection:\(count)")

        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //print(indexPath)
        let shoplist = fetchedResultsController.objectAtIndexPath(indexPath) as! ShoppingList
        var string1: String
        var quantity: String
        var unit: String
        
        //print(shoplist)
        
        if let ingredient = shoplist.ingredient {
            string1 = ingredient
        } else {
            string1 = ""
        }
        if let quantityX = shoplist.quantity {
            quantity = String(quantityX)
        } else {
            quantity = ""
        }
        if let unitX = shoplist.unit {
            unit = unitX
        } else {
            unit = ""
        }
        
        let string2 = quantity + " " + unit
        
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
 
    // MARK: - Convenience methods
    
    // Delete entry
    func deleteShoppingListEntry(indexPath: NSIndexPath) {
        //print("in deleteShoppingListEntry()")
        let shoplist = self.fetchedResultsController.objectAtIndexPath(indexPath) as! ShoppingList
        if shoplist.delete == true {
            shoplist.setValue(false, forKey: "delete")
        } else {
            shoplist.setValue(true, forKey: "delete")
        }
        self.saveContext()
        //print(shoplist)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
    }
    
    //Save Managed Object Context helper
    func saveContext() {
        do {
            try self.sharedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

}
