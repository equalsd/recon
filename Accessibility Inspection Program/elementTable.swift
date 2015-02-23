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
    var continuance: String!
    
    var location: String!
    var notes: String!
    var picture: String!
    var uniqueID: Int!
    
    var elements: [Elemental] = []
    
    //var existingUser = [NSManagedObject]()
    
    @IBAction func cancelElementList(sender: AnyObject) {
        var menuAlert = UIAlertController(title: "Options", message: "Cancel to return to site list.  Reload to lose all changes not on server.  Or select Upload to save to server", preferredStyle: UIAlertControllerStyle.Alert)
        menuAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {( action: UIAlertAction!) in
            //add logic here
            self.performSegueWithIdentifier("backtoSites", sender: self)
        }))
        menuAlert.addAction(UIAlertAction(title: "Upload", style: .Default, handler: {( action: UIAlertAction!) in
            //add logic here
            println("to be uploaded")
        }))
        menuAlert.addAction(UIAlertAction(title: "Reload", style: .Default, handler: {( action: UIAlertAction!) in
            //add logic here
            self.coreRemoveElements()
            self.jsonElements()
        }))
        
        self.presentViewController(menuAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func newItem(sender: AnyObject) {
        println("new Item")
        self.location = ""
        self.uniqueID = -1
        self.notes = ""
        self.performSegueWithIdentifier("detail", sender: self)
    }
    
    @IBAction func detailClick(sender: UIButton) {
        let pointInTable = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let myIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        //var row = myIndexPath.row
        if let path = myIndexPath?.indexAtPosition(1) {
            //println(self.nameData[path])
            self.uniqueID = path
            var item = self.elements[path]
            if let location = item.location {
                self.location = location
            }
            if let picture = item.picture {
                self.picture = picture
            }
            if let notes = item.notes {
                self.notes = notes
            }
            self.performSegueWithIdentifier("detail", sender: self)
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
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            //println(jsonResult)
            
            for (rootKey, rootValue) in jsonResult {
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                if (rootKey as NSString != "Status" && rootKey as NSString != "dir") {
                    for (siteKey, siteValue) in rootValue as NSDictionary {
                        //println("\(siteKey), \(siteValue)")
                        if (siteKey as NSString == "location") {
                            location = siteValue as NSString
                        } else if (siteKey as NSString == "notes") {
                            notes = siteValue as NSString
                        } else if (siteKey as NSString == "picture") {
                            picture = siteValue as NSString
                        }
                        
                    }
                    
                    elements.append(Elemental(location: location!, picture: picture!, notes: notes!))
                } else if (rootKey as NSString == "dir") {
                    self.site = rootValue as NSString
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
                        self.tableView!.reloadData()
                    }
                })
            })
            
            }.resume()
    }
    
    func coreSaveElements() {
        println("inserting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
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
        }
    }
    
    func coreRemoveElements() {
        println("removing...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSFetchRequest(entityName: "Elements")
        
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
        //println(user)
    }
    
    func coreSaveSite() {
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
        
        let newEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        
        let results = NSManagedObject(entity: newEntity!, insertIntoManagedObjectContext:managedContext)
        
        results.setValue(self.password, forKey: "password")
        results.setValue(self.username, forKey: "username")
        results.setValue(self.tracking, forKey: "site")
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func coreGetElements() {
        println("getting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Elements")
        
        var error: NSError?
        
        let fetchedResults =  managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
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
                    
                    elements.append(Elemental(location: location!, picture: picture!, notes: notes!))
                }
                
                self.elements = elements
                self.tableView!.reloadData()
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("elementItem") as UITableViewCell
        let item = self.elements[indexPath.row]
        //cell.textLabel.text = location
        
        if let locationLabel = cell.viewWithTag(100) as? UILabel{
            locationLabel.text = item.location
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //println(site)
        self.navigationItem.title = "\(site)"
        
        
        if (self.continuance == "continue") {
            //either from cancelled detail or from last edit
            coreGetElements()
        } else if (self.continuance == "saveThis") {
            coreGetElements()
            if (uniqueID > -1 ) {
                var path = self.uniqueID
                let item = self.elements[path]
                item.location = self.location
                item.notes = self.notes
                item.picture = self.picture
            //println(self.elements[path].location)
            } else {
                //add new element from details
                self.elements.append(Elemental(location: self.location!, picture: self.picture!, notes: self.notes!))
                println(self.location)
            }
            coreRemoveElements()
            coreSaveElements()
        } else {
            coreSaveSite()
            jsonElements()
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
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            //controller.delegate = self
        } else if (segue.identifier == "detail") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as detailView
            controller.location = self.location
            controller.picture = self.picture
            controller.notes = self.notes
            controller.uniqueID = self.uniqueID
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
        }
    }
    
    @IBAction func continueToELements(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*@IBAction func saveDetail(segue:UIStoryboardSegue) {
        //dismissViewControllerAnimated(true, completion: nil)
        println("pown")
        println(self.uniqueID)
        println(self.location)
        
    }*/
    
    /*@IBAction func cancelDetail(segue:UIStoryboardSegue) {
        //dismissViewControllerAnimated(true, completion: nil)
        //println("yo")
        //println(self.elements)
    }*/

}
