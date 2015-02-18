//
//  elementTable.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreData

class elementTable: UITableViewController {
    
    var username: String!
    var password: String!
    var site: String!
    var use: String!
    var tracking: String!
    
    var locations = [String]()
    var notes = [String]()
    var pictures = [String]()
    
    //var existingUser = [NSManagedObject]()
    
    @IBAction func newItem(sender: AnyObject) {
        println("new Item")
    }
    
    /*func manageSite() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
    
        //let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        
        //let object = NSManagedObject(entity: entity, insertIntoManagedObjectContext:managedContext)
        
        if fetchedResults != nil {
            let existingUser = fetchedResults
            site = existingUser[0]
            if (self.site != site.valueForKey("site")) {
                jsonElements()
            } else {
                coreElements()
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }*/
    
    func jsonElements() {
        println("fetching elements from online")
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : username, "password" : password, "site": tracking]
        
        let url = NSURL(string: "http://precisreports.com/api/get-elements-json.php")
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        let task: Void = session.dataTaskWithRequest(request) {
            data, response, error in
            
            var pictures = [String]()
            var notes = [String]()
            var locations = [String]()
            
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
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            
            println(jsonResult)
            
            for (rootKey, rootValue) in jsonResult {
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                if (rootKey as NSString != "Status" && rootKey as NSString != "dir") {
                    for (siteKey, siteValue) in rootValue as NSDictionary {
                        //println("\(siteKey), \(siteValue)")
                        if (siteKey as NSString == "location") {
                            locations.append(siteValue as NSString)
                        } else if (siteKey as NSString == "notes") {
                            notes.append(siteValue as NSString)
                        } else if (siteKey as NSString == "picture") {
                            pictures.append(siteValue as NSString)
                        }
                    }
                } else if (rootKey as NSString == "dir") {
                    self.site = rootValue as NSString
                }
            }
            
            
            //println(description)
            //completionHandler(results)
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if (locations.count == 0) {
                        var emptyAlert = UIAlertController(title: "Notice", message: "This site has no locations registered", preferredStyle: UIAlertControllerStyle.Alert)
                        emptyAlert.addAction(UIAlertAction(title: "Acknowledged", style: .Default, handler: {( action: UIAlertAction!) in
                            //add logic here
                        }))
                        
                        self.presentViewController(emptyAlert, animated: true, completion: nil)
                        
                    } else {
                        self.tableView.dataSource = self
                        self.tableView.delegate = self
                        self.locations = locations
                        self.notes = notes
                        self.pictures = pictures
                        self.tableView!.reloadData()
                    }
                })
            })
            
            }.resume()
    }
    
    func coreElements() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Elements")
        
        var error: NSError?
        
        let fetchedResults =  managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let elements = fetchedResults {
            //do something if its empty...
            println("empty for now")
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("elementItem") as UITableViewCell
        let location = self.locations[indexPath.row]
        //cell.textLabel.text = location
        
        if let locationLabel = cell.viewWithTag(100) as? UILabel{
            locationLabel.text = location
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //println(site)
        self.navigationItem.title = "List of Elements: \(site)"
        //if new tracking and in sitedata doesn't match; delete old.
        
        //get core, compare Tracking if not match, replace. get Elements or get jsonElements
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        var error: NSError?
        
        let fetchedResults =  managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let existingUser = fetchedResults {
            //println(exitingUser.count)
            if (existingUser.count > 0) {
                let user = existingUser[0]
                site = user.valueForKey("site") as? String
                //println("site: \(site)")
                //println("tracking: \(self.tracking)")
                if (site == nil) {
                    jsonElements()
                } else if (self.tracking == site && site != nil) {
                    coreElements()
                } else {
                    jsonElements()
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "backtoSites") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as tableViewControl
            //controller.delegate = self
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
        }
    }
    
    @IBAction func continueToELements(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
