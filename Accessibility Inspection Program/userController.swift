//
//  userController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 8/26/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class userController: UIViewController {
    
    @IBOutlet weak var loginName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verifyPassword: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var companyAddress: UITextField!
    @IBOutlet weak var contactName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var casp: UITextField!
    
    var state = position()
    
    let cDHelper = coreDataHelper(inheretAppDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func createUser(sender: AnyObject) {
        var message = "Warning: \n"
        if (password.text != verifyPassword.text) {
            message += "Passwords do not match. \n"
        }
        
        if (password.text == "") {
            message += "Password cannot be blank. \n"
        }
        
        if (loginName.text == "") {
            message += "Login Name cannot be blank. \n"
        }
        
        if (companyName.text == "") {
            message += "Company Name cannot be blank. \n"
        }
        
        if (companyAddress.text == "") {
            message += "Company Address cannot be blank. \n"
        }
        
        if (email.text == "" || !isValidEmail(email.text)) {
            message += "Email is not valid."
        }
        
        if (message != "Warning: \n") {
            var emptyAlert = UIAlertController(title: "Menu", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
            }))
            
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        } else {
            jsonCreateUser()
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluateWithObject(testStr)
    }
    
    func jsonCreateUser() {
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : self.loginName.text, "password" : self.password.text, "email": self.email.text, "contact_name": self.contactName.text, "contact_phone": self.phone.text, "company_address": self.companyAddress.text, "company_name": self.companyName.text, "casp": self.casp.text]
        
        let url = NSURL(string: "http://ada-veracity.com/api/new-user-json.php")
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
            
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
            //println(result)
            let loginStatus: String! = result["status"] as! String
            if (loginStatus != "login") {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    var emptyAlert = UIAlertController(title: "Menu", message: loginStatus, preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
                    }))
                    
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                })
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    //println(self.existingUser.count)
                    //if (self.existingUser.count == 0) {
                    //    self.coreSaveUser()
                    //} else {
                    //self.coreRemoveUser()
                    //self.coreSaveUser()
                    self.cDHelper.coreRemoveElements("User", tracking: "")
                    self.cDHelper.coreRemoveElements("Elements", tracking: "")
                    self.cDHelper.coreSaveUser(self.state, password: self.password.text, username: self.loginName.text)
                    //}
                    
                    self.performSegueWithIdentifier("fromNewtoReportTypes", sender: self)
                })
            }
            
            }.resume()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "fromNewtoReportTypes") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteCategoryController
            //controller.delegate = self
            self.state.username = self.loginName.text
            self.state.password = self.password.text
            controller.state = self.state
        }
    }

}