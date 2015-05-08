//
//  siteCategoryController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class siteCategoryController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var siteType:[String] = ["Add New Site", "Bank", "Gas Station", "Hotel", "Restaurant", "Strip Mall"]
    var siteSelected: String!
    var state: position!

    @IBAction func toLogin(sender: AnyObject) {
        //self.performSegueWithIdentifier("toLogin", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toEdit(sender: AnyObject) {
        self.performSegueWithIdentifier("toElementCatFromCont", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println(self.state.type)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteType.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        //let cell = UITableViewCell()
        //let label = UILabel(CGRect(x:0, y:0, width:200, height:50))
        //label.text = "Hello Man"
        //cell.addSubview(label)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("siteCell", forIndexPath: indexPath) as! UITableViewCell
        
        let siteType = self.siteType[indexPath.row] as String
        
        //cell.textLabel.text = rowData["tracking"] as? String
        if let nameLabel = cell.viewWithTag(100) as? UILabel{
            nameLabel.text = siteType
        }
        
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        //let urlString: NSString = rowData["artworkUrl60"] as NSString
        //let imgURL: NSURL? = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        //let imgData = NSData(contentsOfURL: imgURL!)
        //cell.imageView.image = UIImage(data: imgData!)
        
        // Get the formatted price string for display in the subtitle
        //let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        //cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.siteSelected = self.siteType[indexPath.row] as String
        if (self.siteSelected != "Add New Site") {
            self.performSegueWithIdentifier("toSiteList", sender: self)
        } else {
            var emptyAlert = UIAlertController(title: "Notice", message: "This will delete all the current site's data. Pictures will remain in the photo gallery.", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
                self.performSegueWithIdentifier("toNew", sender: self)
            }))
            emptyAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {( action: UIAlertAction!) in
                //add logic here
            }))
            
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toLogin" {
            let loginViewController = segue.destinationViewController as! ViewController
            println("login")
        } else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteListController
            
            controller.state = self.state
            controller.siteSelected = self.siteSelected
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        } else if (segue.identifier == "toNew") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteNewController
            
            controller.state = self.state
        } else if (segue.identifier == "toElementCatFromCont") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            
            controller.state = self.state
            controller.continuance = true
            
        }
    }
}