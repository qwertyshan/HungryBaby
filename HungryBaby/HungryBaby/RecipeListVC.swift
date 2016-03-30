//
//  RecipeListVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/25/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import UIKit
import CoreData

//@IBDesignable

class RecipeListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    //var recipes = [Recipe]()
    
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
    }
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell
        let recipe = fetchedResultsController.objectAtIndexPath(indexPath) as! Recipe
        
        configureCellImage(cell, atIndexPath: indexPath)
        
        cell.cellText.text = recipe.name
        if recipe.favorite == true {
            cell.favImage.image = UIImage(named: "Hearts-Filled-Red")
        } else {
            cell.favImage.image = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: - Configure Cell
    
    func configureCellImage(cell: RecipeCell, atIndexPath indexPath: NSIndexPath) {
        
        var recipeImage = UIImage()
        var activityIndicator = UIActivityIndicatorView()
        
        // Set cell image to nil
        cell.cellImage.image = nil
        
        // Set activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
        activityIndicator.backgroundColor = (UIColor(white: 0.2, alpha: 0.7))
        activityIndicator.hidesWhenStopped = true
        
        // Load photo
        let recipe = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Recipe
        
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
                        CommonElements.showAlert(self, error: error)
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
        if segue.identifier == "RecipeDetailSegue" {
            if let detailController = segue.destinationViewController as? RecipeDetailVC {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailController.objectID = fetchedResultsController.objectAtIndexPath(indexPath).objectID
                }
            }
        }
    }
    
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
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}
