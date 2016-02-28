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
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginWithEmail: UIButton!
    @IBOutlet weak var loginAnonymously: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("debug in LoginVC")
        getDataOnLogin()
        
    }
    
    func getDataOnLogin() {
        APIClient.sharedInstance().getRecipePackage({data, error in
            print("debug2 in LoginVC")
            
            if (error != nil) {
                print("debug3 in LoginVC")
                
                print(error)
            } else {
                print("debug4 in LoginVC")
                
                print(data)
            }
        })
    }
}
