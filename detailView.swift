//
//  detailView.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/19/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreData

class detailView: UIViewController {
    
    var location: String!
    var notes: String!
    var picture: String!
    var uniqueID: Int!
    
    @IBOutlet weak var locationBar: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var pictureField: UIImageView!
    
    @IBAction func saveButton(sender: AnyObject) {
        //self.performSegueWithIdentifier("saveDetail", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //println(location)
        locationBar.text = location
        notesField.text = notes
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "saveDetail") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as elementTable
            //controller.delegate = self
            controller.uniqueID = self.uniqueID
            controller.location = self.location
            controller.picture = self.picture
            controller.notes = self.notes
        }
    }
}
