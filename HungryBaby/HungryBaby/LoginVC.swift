//
//  LoginVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/27/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var recipes = [Recipe]()
    
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
            APIClient.sharedInstance().loginWithEmail(email.text!, password: password.text!, completionHandler: loginCompletionHandler)
        } else {
            let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please enter email and password to login."])
            CommonElements.showAlert(self, error: error)
        }
    }
    
    @IBAction func loginAnonymously(sender: UIButton) {
        APIClient.sharedInstance().loginAnonymously(loginCompletionHandler)
    }
    
    // MARK: - Helper Methods
    
    func loginCompletionHandler(data: AnyObject?, error: NSError?) -> Void {
        if (error != nil) {
            CommonElements.showAlert(self, error: error!)
        } else {
            print("Login successful")
            self.getDataOnLogin()
        }
    }
    
    func getDataOnLogin() {
        let activityIndicator = UIActivityIndicatorView()
        initActivityIndicator(activityIndicator)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        APIClient.sharedInstance().getRecipePackage({data, error in
            if (error != nil) {
                CommonElements.showAlert(self, error: error!)
            } else {
                for dictionary in data as! NSArray {
                    let recipe = Recipe(dictionary: dictionary as! [String : AnyObject])
                    var copiedRecipeAlready = false
                    if let i = self.recipes.indexOf({$0.name! == recipe.name}) {
                        print("Found existing recipe: \(self.recipes[i].name!)")
                        //print(self.recipes[i].version)
                        if let currentVersion = self.recipes[i].version {
                            //print(currentVersion)
                            if currentVersion < recipe.version! as Double {
                                recipe.favorite = self.recipes[i].favorite   // Copy current favorite status
                                self.recipes[i] = recipe // Copy new recipe into current recipe
                                copiedRecipeAlready = true
                                print("Updated existing recipe: \(recipe.name!)")
                            } else {
                                print("Current version is latest.")
                            }
                        }
                    }
                    if copiedRecipeAlready == false {
                        recipe.nutrition?.carbohydrates = Double(arc4random_uniform(101))
                        recipe.nutrition?.proteins = Double(arc4random_uniform(101))
                        recipe.nutrition?.fats = Double(arc4random_uniform(101))
                        recipe.nutrition?.calories = Double(arc4random_uniform(101))
                        self.recipes.append(recipe)
                        print("Adding recipe for: \(recipe.name!)")
                    }
                }
                for recipe in self.recipes {
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
            dispatch_async(dispatch_get_main_queue()){
                self.stopActivityIndicator(activityIndicator)
            }
        })
        
        // Start main app
        startMainApp()
    }
    
    func startMainApp() {
        performSegueWithIdentifier("TabBarSegue", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TabBarSegue" {
            let tabBarController = segue.destinationViewController as! UITabBarController
            let viewController = tabBarController.viewControllers?[0] as! RecipeListVC
            viewController.recipes = recipes
        }
    }
    
    func initActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        // Set activity indicator
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.frame.origin.x = view.frame.size.width / 2 - activityIndicator.frame.size.width / 2
        activityIndicator.frame.origin.y = view.frame.size.height / 2 - activityIndicator.frame.size.height / 2
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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

}
