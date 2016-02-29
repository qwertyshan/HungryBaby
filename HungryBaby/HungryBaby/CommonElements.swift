//
//  CommonElements.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/28/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import UIKit

// MARK: Convenience Class

class CommonElements {
    
    class func showAlert(caller: UIViewController, error: NSError) {
        print((error.domain),(error.localizedDescription))
        let alert = UIAlertController(title: error.domain, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        caller.presentViewController(alert, animated: true, completion: nil)
    }
    
}
