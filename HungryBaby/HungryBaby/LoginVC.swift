//
//  LoginVC.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/27/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    // MARK: - View Setups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("debug in LoginVC")
        
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
        APIClient.sharedInstance().getRecipePackage({data, error in
            if (error != nil) {
                print(error)
            } else {
                print(data)
            }
        })
    }
}
