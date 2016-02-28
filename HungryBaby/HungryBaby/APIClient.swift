//
//  APIClient.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/27/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import Firebase


class APIClient: NSObject {
    
    typealias CompletionHander = (data: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    var token: NSString
    
    override init() {
        session = NSURLSession.sharedSession()
        token = ""
        super.init()
    }
    
    // MARK: - Firebase Data Access Methods
    
    func getRecipePackage(completionHandler: CompletionHander) {
        print("debug in APIClient")

        //TODO: Get recipe package from Firebase
        let ref = Firebase(url: Constants.BASE_URL+Constants.RECIPES)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            //print(snapshot)
            //TODO: Return recipe package to controller
                return completionHandler(data: snapshot, error: nil)
            }, withCancelBlock: { error in
                return completionHandler(data: nil, error: error)
        })
    }
    
    // MARK: - Firebase Auth Methods
    
    func loginWithEmail(username: String, password: String, completionHandler: CompletionHander){
        //TODO: Implement the following
        let ref = Firebase(url: Constants.BASE_URL)
        ref.authUser(username, password: password,
            withCompletionBlock: { error, authData in
                
                if error != nil {
                    // There was an error logging in to this account
                    return completionHandler(data: nil, error: error)
                } else {
                    // We are now logged in
                    self.token = authData.token
                    return completionHandler(data: authData, error: nil)
                }
        })
    }
    
    func loginWithGithub(accessToken: String, completionHandler: CompletionHander){
        // TODO: Implement this
        let ref = Firebase(url: Constants.BASE_URL)
        ref.authWithOAuthProvider("github", token:accessToken,
            withCompletionBlock: { error, authData in
                
                if error != nil {
                    // There was an error during log in
                } else {
                    // We have a logged in Github user
                }
        })
    }
    
    func loginAnonymously(completionHandler: CompletionHander){
        // TODO: Implement this
        let ref = Firebase(url: Constants.BASE_URL)
        ref.authAnonymouslyWithCompletionBlock { error, authData in
            if error != nil {
                // There was an error logging in anonymously
                return completionHandler(data: nil, error: error)
            } else {
                // We are now logged in
                self.token = authData.token
                return completionHandler(data: authData, error: nil)
            }
        }
    }
    
    // MARK: - Github Method
    
    func getGithubAccessToken(completionHandler: CompletionHander) {
        // TODO: Get Github access token and return to controller
        
    }
    
    // MARK: - All purpose task method for data
    
    func taskWithParameters(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        
        // Add in the API Key
        mutableParameters["api-key"] = Constants.API_KEY
        
        let urlString = Constants.BASE_URL + APIClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            print("taskWithParameters's completionHandler is invoked.")
            APIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        task.resume()
        
        return task
    }
    
    
    
    
    // MARK: - Helpers
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(data: nil, error: error)
        } else {
            print("parseJSONWithCompletionHandler is invoked.")
            completionHandler(data: parsedResult, error: nil)
        }
    }
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble escaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> APIClient {
        
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}