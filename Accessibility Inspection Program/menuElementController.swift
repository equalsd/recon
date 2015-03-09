//
//  menuController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 3/2/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class menuElementController: UIViewController {
    var username: String!
    var password: String!
    var site: String!
    var tracking: String!
    var elements: [Elemental] = []
    var continuance: String!
    //var nsdata: String!
    
    @IBAction func toSiteList(sender: AnyObject) {
        self.performSegueWithIdentifier("toSiteList", sender: self)
    }
    
    @IBAction func toUpload(sender: AnyObject) {
        self.performSegueWithIdentifier("uploader", sender: self)
    }
    
    @IBAction func toReload(sender: AnyObject) {
        self.continuance = "reload"
        self.performSegueWithIdentifier("returnToElements", sender: self)
    }
    
    @IBAction func toCancel(sender: AnyObject) {
        self.continuance = "continue"
        self.performSegueWithIdentifier("returnToElements", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println(self.tracking)
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "returnToElements") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as elementTable
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.continuance = self.continuance
        } else if (segue.identifier == "uploader") {
            //var navigationController = segue.destinationViewController as UINavigationController
            //var controller = navigationController.topViewController as menuElementController
            var controller = segue.destinationViewController as uploadController
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.elements = self.elements
        } else if (segue.identifier == "toSiteList") {
            var navigationController = segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as tableViewControl
            //var controller = segue.destinationViewController as tableViewControl
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
        }
    }
    
}
