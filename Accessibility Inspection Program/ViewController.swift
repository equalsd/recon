//
//  ViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/8/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var warning: UILabel!
    var site: String?
    var tracking: String?
    
    //var existingUser = [NSManagedObject]()
    
    var login = "none"
    
    @IBAction func loginButton(sender: AnyObject) {
        if (self.password.text == "" || self.username.text == "") {
            warning.text = "Warning: Username and Password need to be filled out"
        } else {
            println("logging in...")
            jsonLogin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
    
        let fetchRequest = NSFetchRequest(entityName: "User")
    
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            println(results.count)
            if (results.count > 0) {
                //println(results[0].valueForKey("username"))
                let user = results[0]
                self.username.text = user.valueForKey("username") as? String
                self.password.text = user.valueForKey("password") as? String
                self.site = user.valueForKey("site") as? String
                self.tracking = user.valueForKey("tracking") as? String

            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    
        
        /*let fetchedResults =  managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        
        
        if let existingUser = fetchedResults {
            //println(fetchedResults)
            if (existingUser.count > 0) {
                let user = existingUser[0]
                self.username.text = user.valueForKey("username") as? String
                self.password.text = user.valueForKey("password") as? String
                self.site = user.valueForKey("site") as? String
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }*/
    }

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func jsonLogin() {
        activityIndicatorView.startAnimating()
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        var username = self.username.text
        var password = self.password.text
        
        let params:[String: AnyObject] = ["username" : username, "password" : password]
        
        let url = NSURL(string: "http://precisreports.com/api/verify-login-json.php")
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        let task: Void = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    println("response was not 200: \(response)")
                    return
                }
            }
            
            if (error != nil) {
                println("error submitting request: \(error)")
                return
            }
            
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            //println(result)
            let loginStatus: String! = result["status"] as NSString
            if (loginStatus == "error") {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.warning.text = "Error: Bad username or password"
                        println("bad username or password")
                        self.activityIndicatorView.stopAnimating()
                    })
            } else {
                //self.warning.text = ""
                //self.performSegueWithIdentifier("sites", sender: self)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    //println(self.existingUser.count)
                    //if (self.existingUser.count == 0) {
                    //    self.coreSaveUser()
                    //} else {
                        self.coreRemoveUser()
                        self.coreSaveUser()
                    //}
                    
                    self.warning.text = ""
                    self.performSegueWithIdentifier("sites", sender: self)
                    self.activityIndicatorView.stopAnimating()
                })
            }
            
        }.resume()
    }
    
    func coreRemoveUser() {
        println("removing...")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSFetchRequest(entityName: "User")
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = managedContext.executeFetchRequest(entity, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext.deleteObject(bas as NSManagedObject)
            }
            
            managedContext.save(nil)
            
        }
    }
    
    func coreSaveUser() {
        println("saving...")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        
        let results = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        results.setValue(self.password.text, forKey: "password")
        results.setValue(self.username.text, forKey: "username")
        if (self.site == nil) {
            var site = ""
        } else {
            var site = self.site
        }
        
        if (self.tracking == nil) {
            var tracking = ""
        } else {
            var tracking = self.tracking
        }
        
        results.setValue(site, forKey: "site")
        results.setValue(tracking, forKey: "tracking")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as tableViewControl
            //controller.delegate = self
            controller.username = self.username.text
            controller.password = self.password.text
            controller.site = self.site
            controller.tracking = self.tracking
    }
    
    @IBAction func cancelToLogin(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
        println("logiwn")
    }
}

