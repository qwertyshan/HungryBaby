//
//  RecipeListVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/25/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import UIKit

class RecipeListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    var recipes         = [Recipe]()
    var shownRecipes    = [Recipe]()
    var favoriteRecipes = [Recipe]()
    var snackRecipes    = [Recipe]()
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - View Setups
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownRecipes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recipeCell", forIndexPath: indexPath) as! RecipeCell
        let recipe = shownRecipes[indexPath.item] //Select meme on current row
        
        cell.cellImage.image = recipe.image
        cell.cellText.text = recipe.name
        if recipe.favorite == true {
            cell.favImage.image = UIImage(named: "Hearts-Filled-Red")
        } else {
            cell.favImage.image = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("Selected recipe: \(shownRecipes[indexPath.item].name)")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecipeDetailSegue" {
            if let detailController = segue.destinationViewController as? RecipeDetailVC {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailController.recipe = shownRecipes[indexPath.item]
                    detailController.recipeIndex = indexPath.row
                }
            }
        }
    }

}
