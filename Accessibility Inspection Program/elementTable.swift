//
//  elementTable.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class elementTable: UITableViewController {
    
    var username: String!
    var password: String!
    var site: String!
    var use: String!
    var tracking: String!
    
    var elements = [String]()
    var notes = [String]()
    
    @IBAction func newItem(sender: AnyObject) {
        println("new Item")
    }
    
    func manageSite() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let existingUser = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        
        let users = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        if let users = fetchedResults {
            if (existingUser.count > 0) {
                let user = existingUser[0]
                if (self.site != user.valueForKey("site") as? String) {
                    jsonElements()
                } else {
                    coreElements()
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func jsonElements() {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : username, "password" : password]
        
        let url = NSURL(string: "http://precisreports.com/api/get-elements-json.php")
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        let task: Void = session.dataTaskWithRequest(request) {
            data, response, error in
            
            var elements = [String]()
            var notes = [String]()
            
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
            
            
            for (rootKey, rootValue) in jsonResult {
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                for (siteKey, siteValue) in rootValue as NSDictionary {
                    //println("\(siteKey), \(siteValue)")
                    if (siteKey as NSString == "tracking") {
                        elements.append(siteValue as NSString)
                    } else if (siteKey as NSString == "info") {
                        notes.append(siteValue as NSString)
                    } //else if (siteKey as NSString == "description") {
                      //  description.append(siteValue as NSString)
                      //}
                }
            }
            
            //println(description)
            //completionHandler(results)
            
            
            dispatch_async(dispatch_get_main_queue(), {
                //self.tableView.dataSource = self
                //self.tableView.delegate = self
                self.elements = elements
                self.notes = notes
                
            })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            })
            //self.tableData = results
            
            }.resume()
    }
    
    func coreEements() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        var error: NSError?
        
        let fetchedResults =  managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let elements = fetchedResults {
            //do something if its empty...
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let element = self.elements[indexPath.row]
        cell.textLabel.text = element.valueForKey("attribute") as? String
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //println(site)
        self.navigationItem.title = "List of Elements: \(site)"
        //if new tracking and in sitedata doesn't match; delete old.
        
        //get core, compare Tracking if not match, replace. get Elements or get jsonElements
        manageSite()
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
