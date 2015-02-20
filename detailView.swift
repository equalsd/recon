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
    
    @IBOutlet weak var locationBar: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var pictureField: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println(location)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
