//
//  siteNewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreData

class siteNewController: UIViewController {
    
    var state: position!
    
    @IBOutlet weak var switchBank: UISwitch!
    @IBOutlet weak var switchGas: UISwitch!
    @IBOutlet weak var switchHotel: UISwitch!
    @IBOutlet weak var switchRestaurant: UISwitch!
    @IBOutlet weak var switchStripMall: UISwitch!
    @IBOutlet weak var siteName: UITextField!
    @IBOutlet weak var siteAddress: UITextField!
    
    @IBAction func done(sender: AnyObject) {
        if (siteName.text == "" || siteAddress.text == "") {
            var emptyAlert = UIAlertController(title: "Notice", message: "Name and address of site must be selected.", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
            }))
            
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        } else {
            jsonNewSite()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func jsonNewSite() {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        var type = ""
        
        if (switchBank.on) {type = "Bank"}
        if (switchGas.on) {if (type != "") {type += "|Gas Station"} else {type = "Gas Station"}}
        if (switchHotel.on) {if (type != "") {type += "|Hotel"} else {type = "Hotel"}}
        if (switchRestaurant.on) {if (type != "") {type += "|Restaurant"} else {type = "Restaurant"}}
        if (switchStripMall.on) {if (type != "") {type += "|Strip Mall"} else {type = "Strip Mall"}}
        
        let params:[String: AnyObject] = ["username" : self.state.username, "password" : self.state.password, "name": self.siteName.text, "description": self.siteAddress.text, "type": type]
        
        let url = NSURL(string: "http://precisreports.com/api/new-site-json.php")
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
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            //println(jsonResult)
            
            /*for (rootKey, rootValue) in jsonResult {
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
            }*/
            
            self.state.tracking = jsonResult["site"] as! NSString as String
            self.state.type = type
            
            //println(description)
            //completionHandler(results)
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    /*self.coreRemoveElements()
                    
                    if (elements.count == 0) {
                        var emptyAlert = UIAlertController(title: "Notice", message: "This site has no registered locations", preferredStyle: UIAlertControllerStyle.Alert)
                        emptyAlert.addAction(UIAlertAction(title: "Acknowledged", style: .Default, handler: {( action: UIAlertAction!) in
                            //add logic here
                        }))
                        
                        self.presentViewController(emptyAlert, animated: true, completion: nil)
                        
                    } else {*/
                        
                        //self.tableView.dataSource = self
                        //self.tableView.delegate = self
                        //self.locations = locations
                        //self.notes = notes
                        //self.pictures = pictures
                        //self.elements = elements
                        self.coreSaveSite()
                        self.performSegueWithIdentifier("toElementCatFromNew", sender: self)
                    //}
                    
                    //self.tableView!.reloadData()
                })
            })
            
            }.resume()
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
        
        results.setValue(self.state.tracking, forKey: "tracking")
        results.setValue(self.siteName.text, forKey: "site")
        results.setValue(self.state.username, forKey: "username")
        results.setValue(self.state.password, forKey: "password")
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toElementCatFromNew") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            
            controller.state = self.state
            controller.continuance = false
        }

    }
}
