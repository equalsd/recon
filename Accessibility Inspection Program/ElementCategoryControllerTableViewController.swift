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
    
    var elementCategories:[String] = ["View Images", "Add Location"]
    var elements: [Elemental] = []
    var state: position!
    var continuance: Bool!
    var reload: Bool!
    var locationCount = Dictionary<String, Int>()
    var pictures = false
    var sub = true

    @IBAction func menuButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toMenu", sender: self)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        if (state.self.current() == "empty") {
            var sc = self.storyboard?.instantiateViewControllerWithIdentifier("siteBoard") as! siteCategoryController
            sc.state = self.state
            
            self.navigationController!.pushViewController(sc, animated: true)
        } else {
            state.pop()
            var ecc = self.storyboard?.instantiateViewControllerWithIdentifier("elementBoard") as! elementCategoryController
            ecc.elements = self.elements
            ecc.state = self.state
            
            self.navigationController!.pushViewController(ecc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.continuance != nil) {
            if (self.continuance == true) {
                coreGetElements()
            } else {
                coreSaveSite()
                jsonElements()
            }
        } else {
            
        }
        
        for item in self.elements {
            if (item.picture != "location") {
                let category = item.category
                let location = item.location
                if (self.locationCount[location! as String] != nil) {
                    self.locationCount[location! as String] = self.locationCount[location! as String]! + 1
                } else {
                    self.locationCount[location! as String] = 1
                    //println(location)
                }
            
                if (self.locationCount[category! as String] != nil) {
                    self.locationCount[category! as String] = self.locationCount[category! as String]! + 1
                } else {
                    self.locationCount[category! as String] = 1
                    //println(location)
                }
            }
        }
        
        switch self.state.last() {
        case "Parking":
            var extended = categorizer("Parking")
            self.elementCategories.extend(extended)
        case "Primary Function Areas":
            var extended = categorizer("Primary Function Areas")
            self.elementCategories.extend(extended)
        case "Interior Path of Travel":
            var extended = categorizer("Interior Path of Travel")
            self.elementCategories.extend(extended)
        default:
            if (self.state.current() == "empty") {
                var extended = categorizer("Root")
                self.elementCategories.extend(extended)
            } else {
                //println("get locations in this category")
                getLocationsbyCategory()
                self.pictures = true
            }
        }
        
        var title = self.state.last()
        if (title == "empty") {
            self.title = "Root"
        } else {
            self.title = title
        }
        //counter()
        self.tableView!.reloadData()
    }
    
    func categorizer(parent: String) -> [String] {
        var typeArray = split(state.type) {$0 == "|"}
        
        switch parent {
        case "Parking":
            return ["Parking Lots", "Passenger Loading Zones"]
        case "Primary Function Areas":
            var extended:[String] = []
            if (contains(typeArray, "Bank")) {
                extended.extend(["Lobby", "Offices"])
            }
            if (contains(typeArray, "Gas Station")) {
                extended.extend(["Lobby", "Fuel Pumps"])
            }
            if (contains(typeArray, "Hotel")) {
                extended.extend(["Lobby", "Accessible Guest Rooms", "Non-Accessible Guest Rooms"])
            }
            if (contains(typeArray, "Restaurant")) {
                extended.extend(["Lobby", "Dining Areas", "Bars"])
            }
            return extended
        case "Interior Path of Travel":
            var extended = ["Path", "Telephones and Drinking Fountains", "Restrooms"]
            if (contains(typeArray, "Hotel")) {
                extended.extend(["Laundry Room", "Gym", "Locker Rooms"])
            }
            
            return extended
        case "Root":
            self.sub = false
            self.elementCategories.removeAtIndex(0)
            self.elementCategories.removeAtIndex(0)
            return ["General Location", "Parking", "Exterior Path of Travel", "Egress", "Primary Function Areas", "Interior Path of Travel"]
        default:
          return []
        }
    }
    
    //floats counts up.
    func counter() {
        for parent in self.elementCategories {
            var extended = categorizer(parent)
            for child in extended {
                if (self.locationCount[child] != nil) {
                    if (self.locationCount[parent] == nil) {
                        self.locationCount[parent] = 0
                    }
                    self.locationCount[parent] = self.locationCount[child]! + self.locationCount[parent]!
                }
            }
        }
    }
    
    func getLocationsbyCategory() {
        var current = self.state.current()
        println("current: \(current)")
        if (current != "empty") {
            for item in self.elements {
                println(item.category!)
                if (item.category! == current) {
                    if (!contains(self.elementCategories, item.location as! String)) {
                        self.elementCategories.extend([item.location as! String])
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementCategories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! UITableViewCell
        
        var siteType: String!
        if (indexPath.row == 1 && self.sub == true) {
            siteType = "Add Sub-Location"
        } else {
            siteType = self.elementCategories[indexPath.row]
        }
        
        //cell.textLabel.text = rowData["tracking"] as? String
        if let nameLabel = cell.viewWithTag(100) as? UILabel{
            var number: String!
            
            //if (self.locationCount[siteType] == nil || self.locationCount[siteType] == 0) {
                nameLabel.text = siteType
            /*} else {
                nameLabel.text = siteType //+ " (\(locationCount[siteType]!))"
            }*/
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var location = self.elementCategories[indexPath.row] as String
        switch location {
        case "Add Location" :
            var lm = self.storyboard?.instantiateViewControllerWithIdentifier("locationManager") as! menuLocationController
            lm.state = self.state
            lm.elements = self.elements
            lm.done = "elementCategoryController"
            
            self.navigationController!.pushViewController(lm, animated: true)
        case "View Images" :
            //state.add(location)
            
            var pc = self.storyboard?.instantiateViewControllerWithIdentifier("pictureBoard") as! pictureViewController
            pc.state = self.state
            pc.elements = self.elements
            
            self.navigationController!.pushViewController(pc, animated: true)
        default :
            state.add(location) //unless its a picture thing...
            var vc = self.storyboard?.instantiateViewControllerWithIdentifier("elementBoard") as! elementCategoryController
            vc.state = self.state
            vc.elements = self.elements
            self.navigationController!.pushViewController(vc, animated: true)
        }
        /*if (indexPath.row ==  1) {
            if (!self.pictures) {
            
                state.add(location) //unless its a picture thing...
                var vc = self.storyboard?.instantiateViewControllerWithIdentifier("elementBoard") as! elementCategoryController
                vc.state = self.state
                vc.elements = self.elements
                self.navigationController!.pushViewController(vc, animated: true)
            } else {
                //println("to pictures")
                state.add(location)
                
                var pc = self.storyboard?.instantiateViewControllerWithIdentifier("pictureBoard") as! pictureViewController
                pc.state = self.state
                pc.elements = self.elements
                self.navigationController!.pushViewController(pc, animated: true)

            }
        } else {
            var lm = self.storyboard?.instantiateViewControllerWithIdentifier("locationManager") as! menuLocationController
            lm.state = self.state
            lm.elements = self.elements
            lm.done = "elementCategoryController"
            
            self.navigationController!.pushViewController(lm, animated: true)
        }*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMenu" {
            var controller =  segue.destinationViewController as! menuElementController
            //let controller = navigationController.topViewController as! locationController
            
            controller.state = self.state
            controller.elements = self.elements
            
        } else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteListController
            
            controller.state = self.state
            //controller.category = self.category
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        } else if (segue.identifier == "toLocation") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! locationController
            controller.state = self.state
            controller.elements = self.elements
        }
    }
    
    func jsonElements() {
        println("getting...Online")
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : self.state.username, "password" : self.state.password, "site": self.state.tracking]
        
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
            
            println(jsonResult)
            var index: Int = 0
            for (rootKey, rootValue) in jsonResult {
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                if (rootKey as! NSString != "Status" && rootKey as! NSString != "dir" && rootKey as! NSString != "type") {
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
                    
                    if (picture! == "location") {
                        elements.append(Elemental(location: location!, picture: picture!, notes: notes!, category: category!, uniqueID: -2))
                    } else {
                        elements.append(Elemental(location: location!, picture: picture!, notes: notes!, category: category!, uniqueID: index))
                    }
                    index = index + 1
                } else if (rootKey as! NSString == "dir") {
                    self.state.site = rootValue as! String
                    //println(self.site)
                } else if (rootKey as! NSString == "type") {
                    self.state.type = rootValue as! String
                    //println(self.type)
                }
            }
            
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
                        self.elements = elements
                        self.coreSaveElements()

                    }
                    
                    //self.tableView!.reloadData()
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
        
        results.setValue(self.state.password, forKey: "password")
        results.setValue(self.state.username, forKey: "username")
        results.setValue(self.state.tracking, forKey: "tracking")
        results.setValue(self.state.site, forKey: "site")
        results.setValue(self.state.type, forKey: "type")
        
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
            var category: String?
            var uniqueID: Int?
            var elements: [Elemental] = []
            
            if (results.count == 0) {
                var emptyAlert = UIAlertController(title: "Notice", message: "This site has no registered locations", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Acknowledged", style: .Default, handler: {( action: UIAlertAction!) in
                    //add logic here
                }))
                
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            } else {
                //var index: Int = 0
                for result in results {
                    location = result.valueForKey("location") as? String
                    //println(location)
                    notes = result.valueForKey("notes") as? String
                    //println(notes)
                    picture = result.valueForKey("picture") as? String
                    //println(picture)
                    category =  result.valueForKey("category") as? String
                    uniqueID = result.valueForKey("uniqueID") as? Int
                    println(category)
                    
                    if (picture == nil) {
                        elements.append(Elemental(location: location!, picture: "", notes: notes!, category: category!, uniqueID: uniqueID!))
                    } else {
                        elements.append(Elemental(location: location!, picture: picture!, notes: notes!, category: category!, uniqueID: uniqueID!))
                    }
                    //index = index + 1
                }
                
                /*for item in elements {
                    let location = item.category
                    if (self.locationCount[location! as String] != nil) {
                        self.locationCount[location! as String] = self.locationCount[location! as String]! + 1
                    } else {
                        self.locationCount[location! as String] = 1
                        //println(location)
                    }
                }*/
                
                self.elements = elements
                //self.tableView!.reloadData()
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
            var item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            item.setValue(element.location, forKey: "location")
            item.setValue(element.picture, forKey: "picture")
            item.setValue(element.notes, forKey: "notes")
            item.setValue(element.category, forKey: "category")
            item.setValue(element.uniqueID, forKey: "uniqueID")
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            //index++
            //println(index)
            //println(element.picture)
        }
    }

}
