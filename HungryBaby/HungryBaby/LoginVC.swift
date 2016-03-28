//
//  LoginVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/27/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var storedRecipes = [Recipe]()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    // MARK: - View Setups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate = self
        password.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - IB Actions
    
    @IBAction func loginWithEmail(sender: UIButton) {
        if (email.text != "") && (password.text != "") {
            dispatch_async(dispatch_get_main_queue()){
                self.initActivityIndicator(self.activityIndicator)
                self.activityIndicator.startAnimating()
                super.view.addSubview(self.activityIndicator)
            }
            APIClient.sharedInstance().loginWithEmail(email.text!, password: password.text!, completionHandler: loginCompletionHandler)
        } else {
            let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please enter email and password to login."])
            CommonElements.showAlert(self, error: error)
        }
    }
    
    @IBAction func loginAnonymously(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()){
            self.initActivityIndicator(self.activityIndicator)
            self.activityIndicator.startAnimating()
            super.view.addSubview(self.activityIndicator)
        }
        APIClient.sharedInstance().loginAnonymously(loginCompletionHandler)
    }
    
    // MARK: - Helper Methods
    
    func fetchAllRecipes() -> [Recipe] {
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Recipe]
        } catch let error as NSError {
            print("Error in fetchAllRecipes(): \(error)")
            return [Recipe]()
        }
    }
    
    func findRecipeWithName(name: String) -> [Recipe] {
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        let predicate = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = predicate
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Recipe]
        } catch let error as NSError {
            print("Error in findRecipeWithName(): \(error)")
            return [Recipe]()
        }
    }
    
    func loginCompletionHandler(data: AnyObject?, error: NSError?) -> Void {
        if (error != nil) {
            CommonElements.showAlert(self, error: error!)
            dispatch_async(dispatch_get_main_queue()){
                self.stopActivityIndicator(self.activityIndicator)
            }
        } else {
            print("Login successful")
            if self.getDataOnLogin() == true {
                dispatch_async(dispatch_get_main_queue()) {
                    // Start main app
                    self.startMainApp()
                }
            }
        }
    }
    
    func getDataOnLogin() -> Bool {
        var success = true
        
        APIClient.sharedInstance().getRecipePackage({data, error in
            if (error != nil) {
                success = false
                CommonElements.showAlert(self, error: error!)
            } else {
                // Load array of Recipe dictionaries
                let data = data.copy() as! [[String:AnyObject]]
                for dictionary in data {
                    
                    var doNotUpdateRecipe = false
                    
                    // CHECK 1: Look for stored recipe with same name as downloaded recipe
                    let searchResult = self.findRecipeWithName(dictionary[Recipe.Keys.Name] as! String)
                    var existingRecipe: Recipe
                    if searchResult.count > 0 {
                        existingRecipe = searchResult[0]
                
                        print("Found existing recipe: \(existingRecipe.name!)")

                        if let currentVersion = existingRecipe.version {
                            
                            // CHECK 2: Check if current version is less than downloaded version
                            if Double(currentVersion) < Double(dictionary[Recipe.Keys.Version] as! String) {
                                let recipeFavorite = existingRecipe.favorite  // Copy current favorite status
                                self.sharedContext.deleteObject(existingRecipe)
                                let recipe = self.generateRecipe(dictionary)
                                recipe.favorite = recipeFavorite
                                print("Updated existing recipe: \(dictionary[Recipe.Keys.Name] as! String)")
                                
                            } else {
                                print("Current version is latest.")
                            }
                        }
                        doNotUpdateRecipe = true
                    }
                    // If downloaded recipe was not added to Core Data, add it now
                    if doNotUpdateRecipe == false {

                        self.generateRecipe(dictionary)
                        print("Adding recipe for: \(dictionary[Recipe.Keys.Name] as! String)")
                    }
                }
                self.saveContext()
            }
        })
        return success
    }
    
    func generateRecipe(dictionary: [String : AnyObject]) -> Recipe {
        //print("debug 1")
        let recipe = Recipe(dictionary: dictionary, context: self.sharedContext)
        
        // Creating dummy nutrition data for recipe (will be changed later in later versions)
        let nutrition: [String: Double] = [
            Recipe.Keys.Carbohydrates:  Double(arc4random_uniform(101)),
            Recipe.Keys.Proteins:       Double(arc4random_uniform(101)),
            Recipe.Keys.Fats:           Double(arc4random_uniform(101)),
            Recipe.Keys.Calories:       Double(arc4random_uniform(101))
        ]
        if let ingredients = dictionary[Recipe.Keys.Ingredients] as? [[String : AnyObject]] {
            //recipe.ingredients = NSOrderedSet(array: self.generateIngredients(recipe, dictionary: ingredients))
            //print(recipe.ingredients)
            self.generateIngredients(recipe, dictionary: ingredients)
        }
        if let method = dictionary[Recipe.Keys.Method] as? [String]{
            //recipe.method = NSOrderedSet(array: self.generateMethod(recipe, array: method))
            //print(recipe.method)
            self.generateMethod(recipe, array: method)
        }
        recipe.nutrition = self.generateNutrition(recipe, dictionary: nutrition)
        //print(recipe.nutrition)
        
        return recipe
    }
    
    func generateIngredients(recipe: Recipe, dictionary: [[String : AnyObject]]) -> [Ingredient] {
        //print("debug 2")
        var ingredients = [Ingredient]()
        for ingredient in dictionary {
            ingredients.append(Ingredient(recipe: recipe, dictionary: ingredient, context: sharedContext))
        }
        return ingredients
    }
    
    func generateMethod(recipe: Recipe, array: [String]) -> [MethodStep] {
        //print("debug 3")
        var methodArray = [MethodStep]()
        var stepNumber = 1
        for step in array {
            methodArray.append(MethodStep(recipe: recipe, number: stepNumber, step: step, context: sharedContext))
            stepNumber += 1
        }
        return methodArray
    }
    
    func generateNutrition(recipe: Recipe, dictionary: [String : Double]) -> Nutrition {
        //print("debug 4")
        let nutrition = Nutrition(recipe: recipe, dictionary: dictionary, context: sharedContext)
        return nutrition
    }
    
    func setImages() {
        // Check if we have images for all recipes in Recipe
        // These images are cached, not stored in Core Data
        let recipes = fetchAllRecipes()
        for recipe in recipes {
            // Do we have the image?
            if recipe.image == nil {
                // Do we have the imagePath?
                if let imagePath = recipe.imagePath {
                    print(imagePath)
                    // Download image
                    APIClient.sharedInstance().getImage(imagePath) {data, error in
                        if let error = error {
                            print("Image download error: \(error.localizedDescription)")
                        }
                        if let data = data {
                            print("Image download successful")
                            // Create the image
                            let image = UIImage(data: data as! NSData)!
                            // Set the image in cache
                            recipe.image = image
                            print(recipe.image!)
                        }
                    }
                }
            }
        }
    }
    
    func startMainApp() {
        dispatch_async(dispatch_get_main_queue()){
            self.stopActivityIndicator(self.activityIndicator)
        }
        print("Segue to tab bar controller")
        performSegueWithIdentifier("TabBarSegue", sender: self)

    }
    
    func initActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        // Set activity indicator
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.frame = CGRect(x: 0,
                                         y: 0,
                                         width: super.view.frame.size.width,
                                         height: super.view.frame.size.height)
        activityIndicator.backgroundColor = (UIColor(white: 0.2, alpha: 0.7))
        activityIndicator.hidesWhenStopped = true
    }
    
    func stopActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        //print("stopped ActivityIndicator")
    }
    
    // MARK: - Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // MARK: - Keyboard notification methods
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
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
