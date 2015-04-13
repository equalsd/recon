//
//  ElementCategoryControllerTableViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class ElementCategoryControllerTableViewController: UITableViewController {
    
    var elementCategories:[String] = ["Parking", "Exterior", "Egress Doors", "Interior", "Support Areas", "Restroom"]
    var category: String!
    var username: String!
    var password: String!
    var tracking: String!
    var site: String!
    var type: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if (type.lowercaseString.rangeOfString("Bank") != nil) {
            elementCategories.append("Bank")
        }
        if (type.lowercaseString.rangeOfString("GasStation") != nil) {
            elementCategories.append("Gas Station")
        }
        if (type.lowercaseString.rangeOfString("Restaurant") != nil) {
            elementCategories.append("Restaurant")
        }
        if (type.lowercaseString.rangeOfString("Hotel") != nil) {
            elementCategories.append("Hotel")
        }
        if (type.lowercaseString.rangeOfString("StripMall") != nil) {
            elementCategories.append("Strip Mall")
        }
        
        sort(&elementCategories)
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("siteCell", forIndexPath: indexPath) as UITableViewCell
        
        let siteType = self.elementCategories[indexPath.row] as String
        
        //cell.textLabel.text = rowData["tracking"] as? String
        if let nameLabel = cell.viewWithTag(100) as? UILabel{
            nameLabel.text = siteType
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.category = self.elementCategories[indexPath.row] as String
            //self.performSegueWithIdentifier("toNew", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toLogin" {
            let loginViewController = segue.destinationViewController as ViewController
            println("login")
        } else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as siteListController
            
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
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as siteNewController
            //println("sobeit")
            //println(segue.identifier)
        }
    }

}
