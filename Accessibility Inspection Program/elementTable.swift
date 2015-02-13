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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println(site)
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
        }
    }

}
