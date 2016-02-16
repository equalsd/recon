//
//  menuController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 3/2/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class menuElementController: UIViewController, UIPopoverPresentationControllerDelegate {
    var state: position!
    var elements: [Elemental] = []
    var continuance: Bool!
    //var nsdata: String!
    
    /*@IBAction func toSiteList(sender: AnyObject) {
        self.performSegueWithIdentifier("toSiteList", sender: self)
    }*/
    
    @IBAction func toUpload(sender: AnyObject) {
        self.performSegueWithIdentifier("uploader", sender: self)
    }
    
    @IBAction func toReload(sender: AnyObject) {
        var emptyAlert = UIAlertController(title: "Warning!", message: "Reloading will destroy any new data that hasn't yet been uploaded.", preferredStyle: UIAlertControllerStyle.Alert)
        emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
            self.continuance = false
            self.performSegueWithIdentifier("menuToOrganize", sender: self)
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {( action: UIAlertAction!) in
            //add logic here
        }))
        
        self.presentViewController(emptyAlert, animated: true, completion: nil)
    }
    
    @IBAction func toCancel(sender: AnyObject) {
        self.continuance = true
        self.performSegueWithIdentifier("menuToOrganize", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println(self.state.tracking)
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "menuToOrganize") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            controller.state = self.state
            self.state.category.removeAll()
            controller.continuance = self.continuance
        } else if (segue.identifier == "uploader") {
            //var navigationController = segue.destinationViewController as UINavigationController
            //var controller = navigationController.topViewController as menuElementController
            var controller = segue.destinationViewController as! uploadController
            controller.state = self.state
            controller.elements = self.elements
            var pop = controller.popoverPresentationController
            
            if pop != nil
            {
                pop?.delegate = self
            }
        } /*else if (segue.identifier == "toSiteList") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! tableViewControl
            //var controller = segue.destinationViewController as tableViewControl
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
        }*/
    }
    
}
