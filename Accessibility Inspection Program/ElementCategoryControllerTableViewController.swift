//
//  ElementCategoryControllerTableViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreData

class elementCategoryController: UITableViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var elementCategories:[String] = ["Parking", "Exterior", "Egress Doors", "Interior", "Support Areas", "Restroom"]
    var category: String!
    var username: String!
    var password: String!
    var tracking: String!
    var site: String!
    var type: String!
    var elements: [Elemental] = []
    var continuance: Bool!
    var locationCount = Dictionary<String, Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(tracking)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        if (type.lowercaseString.rangeOfString("bank") != nil) {
            elementCategories.append("Bank")
        }
        if (type.lowercaseString.rangeOfString("gas station") != nil) {
            elementCategories.append("Gas Station")
            println("okay")
        }
        if (type.lowercaseString.rangeOfString("restaurant") != nil) {
            elementCategories.append("Restaurant")
        }
        if (type.lowercaseString.rangeOfString("hotel") != nil) {
            elementCategories.append("Hotel")
        }
        if (type.lowercaseString.rangeOfString("strip mall") != nil) {
            elementCategories.append("Strip Mall")
        }
        
        sort(&elementCategories)
        
        if (continuance == true) {
            coreGetElements()
        } else {
            jsonElements()
        }
        
        /*for item in elements {
            let location = item.location
            if (locationCount[location! as String] != nil) {
                locationCount[location! as String] = locationCount[location! as String]! + 1
            } else {
                locationCount[location! as String] = 1
                println(location)
            }
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementCategories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        //let cell = UITableViewCell()
        //let label = UILabel(CGRect(x:0, y:0, width:200, height:50))
        //label.text = "Hello Man"
        //cell.addSubview(label)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! UITableViewCell
        
        let siteType = self.elementCategories[indexPath.row] as String
        
        //cell.textLabel.text = rowData["tracking"] as? String
        if let nameLabel = cell.viewWithTag(100) as? UILabel{
            var number: Int!
            
            if (locationCount[siteType] == nil) {
                number = 0
            } else {
                number = locationCount[siteType]
            }
            
            nameLabel.text = siteType + " (\(number))"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.category = self.elementCategories[indexPath.row] as String
            self.performSegueWithIdentifier("toLocation", sender: self)
        println(self.category)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toLocation" {
            var navigationController =  segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! locationController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.category = self.category
            controller.elements = self.elements
            
        } else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteListController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            //controller.category = self.category
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        } else if (segue.identifier == "toNew") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteNewController
            //println("sobeit")
            //println(segue.identifier)
        }
    }
    
    func jsonElements() {
        println("getting...Online")
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : self.username, "password" : self.password, "site": self.tracking]
        
        let url = NSURL(string: "http://precisreports.com/api/get-elements-json.php")
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        let task: Void = session.dataTaskWithRequest(request) {
            data, response, error in
            
            var picture: String?
            var notes: String?
            var location: String?
            var category: String?
            var elements: [Elemental] = []
            
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
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            //println(jsonResult)
            
            for (rootKey, rootValue) in jsonResult {
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                if (rootKey as! NSString != "Status" && rootKey as! NSString != "dir") {
                    for (siteKey, siteValue) in rootValue as! NSDictionary {
                        //println("\(siteKey), \(siteValue)")
                        if (siteKey as! NSString == "location") {
                            location = siteValue as? String
                        } else if (siteKey as! NSString == "notes") {
                            notes = siteValue as? String
                        } else if (siteKey as! NSString == "picture") {
                            picture = siteValue as? String
                        } else if (siteKey as! NSString == "category") {
                            category = siteValue as? String
                        }
                    }
                    
                    elements.append(Elemental(location: location!, picture: picture!, notes: notes!, category: category!))
                } else if (rootKey as! NSString == "dir") {
                    self.site = rootValue as! String
                }
            }
            
            
            //println(description)
            //completionHandler(results)
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.coreRemoveElements()
                    
                    if (elements.count == 0) {
                        var emptyAlert = UIAlertController(title: "Notice", message: "This site has no registered locations", preferredStyle: UIAlertControllerStyle.Alert)
                        emptyAlert.addAction(UIAlertAction(title: "Acknowledged", style: .Default, handler: {( action: UIAlertAction!) in
                            //add logic here
                        }))
                        
                        self.presentViewController(emptyAlert, animated: true, completion: nil)
                        
                    } else {
                        
                        self.tableView.dataSource = self
                        self.tableView.delegate = self
                        //self.locations = locations
                        //self.notes = notes
                        //self.pictures = pictures
                        self.elements = elements
                        self.coreSaveElements()
                        
                        for item in elements {
                            let location = item.category
                            if (self.locationCount[location! as String] != nil) {
                                self.locationCount[location! as String] = self.locationCount[location! as String]! + 1
                            } else {
                                self.locationCount[location! as String] = 1
                                //println(location)
                            }
                        }
                    }
                    
                    self.tableView!.reloadData()
                })
            })
            
            }.resume()
    }
    
    
    func coreRemoveElements() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSFetchRequest(entityName: "Elements")
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = managedContext.executeFetchRequest(entity, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext.deleteObject(bas as! NSManagedObject)
            }
            
            managedContext.save(nil)
            
        }
        //println(user)
    }
    
    func coreSaveSite() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSFetchRequest(entityName: "User")
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = managedContext.executeFetchRequest(entity, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext.deleteObject(bas as! NSManagedObject)
            }
            
            managedContext.save(nil)
        }
        
        let newEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        
        let results = NSManagedObject(entity: newEntity!, insertIntoManagedObjectContext:managedContext)
        
        results.setValue(self.password, forKey: "password")
        results.setValue(self.username, forKey: "username")
        results.setValue(self.tracking, forKey: "tracking")
        results.setValue(self.site, forKey: "site")
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func coreGetElements() {
        println("getting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Elements")
        
        var error: NSError?
        
        let fetchedResults =  managedContext.executeFetchRequest(fetchRequest, error: &error) as![NSManagedObject]?
        
        if let results = fetchedResults {
            //do something if its empty...
            //println("empty for now")
            println(results.count)
            
            var picture: String?
            var notes: String?
            var location: String?
            var elements: [Elemental] = []
            
            if (results.count == 0) {
                var emptyAlert = UIAlertController(title: "Notice", message: "This site has no registered locations", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Acknowledged", style: .Default, handler: {( action: UIAlertAction!) in
                    //add logic here
                }))
                
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            } else {
                for result in results {
                    location = result.valueForKey("location") as? String
                    notes = result.valueForKey("notes") as? String
                    picture = result.valueForKey("picture") as? String
                    
                    if (picture == nil) {
                        elements.append(Elemental(location: location!, picture: "", notes: notes!, category: category!))
                    } else {
                        elements.append(Elemental(location: location!, picture: picture!, notes: notes!, category: category!))
                    }
                }
                
                for item in elements {
                    let location = item.category
                    if (self.locationCount[location! as String] != nil) {
                        self.locationCount[location! as String] = self.locationCount[location! as String]! + 1
                    } else {
                        self.locationCount[location! as String] = 1
                        //println(location)
                    }
                }
                
                self.elements = elements
                self.tableView!.reloadData()
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func coreSaveElements() {
        println("inserting...Core//elements")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Elements", inManagedObjectContext: managedContext)
        
        
        //var index = 0
        for element in elements {
            //index++
            var item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            item.setValue(element.location, forKey: "location")
            item.setValue(element.picture, forKey: "picture")
            item.setValue(element.notes, forKey: "notes")
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            //println(index)
            //println(element.picture)
        }
    }

}
