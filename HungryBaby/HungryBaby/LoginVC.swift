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
    
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    // MARK: - View Setups
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - IB Actions
    
    @IBAction func loginWithEmail(sender: UIButton) {
        if (email.text != nil) && (password.text != nil) {
            APIClient.sharedInstance().loginWithEmail(email.text!, password: password.text!, completionHandler: loginCompletionHandler)
        }
    }
    
    @IBAction func loginAnonymously(sender: UIButton) {
        APIClient.sharedInstance().loginAnonymously(loginCompletionHandler)
    }
    
    // MARK: - Helper Methods
    
    func loginCompletionHandler(data: AnyObject?, error: NSError?) -> Void {
        if (error != nil) {
            print("Failed login with error: \(error)")
        } else {
            print("Login successful")
            self.getDataOnLogin()
        }
    }
    
    func getDataOnLogin() {
        var recipes = [Recipe]()
        let activityIndicator = UIActivityIndicatorView()
        initActivityIndicator(activityIndicator)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        APIClient.sharedInstance().getRecipePackage({data, error in
            if (error != nil) {
                print(error)
            } else {
                for dictionary in data as! NSArray {
                    let recipe = Recipe(dictionary: dictionary as! [String : AnyObject])
                    recipes.append(recipe)
                    //print(recipe.name)
                }
                //let controller: UIViewController
                //controller.recipes = recipes
                dispatch_async(dispatch_get_main_queue()){
                    self.stopActivityIndicator(activityIndicator)
                }
            }
        })
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
