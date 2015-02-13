//
//  ViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/8/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var warning: UILabel!
    var login = "none"
    
    @IBAction func loginButton(sender: AnyObject) {
        if (self.password.text == "" || self.username.text == "") {
            warning.text = "Warning: Username and Password need to be filled out"
        } else {
            println("logging in...")
            jsonLogin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func jsonLogin() {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        var username = self.username.text
        var password = self.password.text
        
        let params:[String: AnyObject] = ["username" : username, "password" : password]
        
        let url = NSURL(string: "http://precisreports.com/api/verify-login-json.php")
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
            
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            //println(result)
            let loginStatus: String! = result["status"] as NSString
            if (loginStatus == "error") {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.warning.text = "Error: Bad username or password"
                        println("bad username or password")
                    })
            } else {
                //self.warning.text = ""
                //self.performSegueWithIdentifier("sites", sender: self)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.warning.text = ""
                        self.performSegueWithIdentifier("sites", sender: self)
                    })
            }
            
        }.resume()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as tableViewControl
            //controller.delegate = self
            controller.username = self.username.text
            controller.password = self.password.text
    }
    
    @IBAction func cancelToLogin(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
        println("logiwn")
    }
}

