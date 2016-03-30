//
//  APIClient.swift
//  HungryBaby
//
//  Created by Shantanu Rao on 2/27/16.
//  Copyright © 2016 Shantanu Rao. All rights reserved.
//

import Foundation
import Firebase
import SystemConfiguration

class APIClient: NSObject {
    
    typealias CompletionHandler = (data: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    var token: NSString
    
    override init() {
        session = NSURLSession.sharedSession()
        token = ""
        super.init()
    }
    
    // MARK: - Firebase Data Access Methods
    
    func getRecipePackage(completionHandler: CompletionHandler) {
        //TODO: Get recipe package from Firebase
        let ref = Firebase(url: Constants.BASE_URL+Constants.RECIPES)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            //TODO: Return recipe package to controller
                return completionHandler(data: snapshot.value!, error: nil)
            }, withCancelBlock: { error in
                return completionHandler(data: nil, error: error)
        })
    }
    
    // MARK: - Firebase Auth Methods
    
    func loginWithEmail(username: String, password: String, completionHandler: CompletionHandler){
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
    
    func loginWithGithub(accessToken: String, completionHandler: CompletionHandler){
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
    
    func loginAnonymously(completionHandler: CompletionHandler){
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
    
    func getGithubAccessToken(completionHandler: CompletionHandler) {
        // TODO: Get Github access token and return to controller
        
    }
    
    // MARK: - Get Image
    
    func getImage(imagePath: String, completionHandler: CompletionHandler) -> NSURLSessionTask {
        
        let imageURL = NSURL(string: Constants.IMAGE_URL+imagePath)
        
        let request = NSURLRequest(URL: imageURL!)
        
        // print("getImage --> imagePath: \(imagePath)")
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            guard let connectedToNetwork = (self.connectedToNetwork() as Bool?) where connectedToNetwork == true else {
                let error = NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network is not available and some recipe images could not be downloaded. Please restart app in a stable network to download recipes."])
                completionHandler(data: nil, error: error)
                return 
            }
            
            if let error = downloadError {
                completionHandler(data: nil, error: error)
            } else {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - All purpose task method for data
    
    func taskWithParameters(completionHandler: CompletionHandler) -> Void {
        
        //var mutableParameters = parameters
        
        // Add in the API Key
        //mutableParameters["api-key"] = Constants.API_KEY
        
        let urlString = Constants.BASE_URL+Constants.RECIPES+".json"
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
        
        //return task
    }
    
    
    // MARK: - Helpers
    
    // Checking network reachability
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandler) {
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