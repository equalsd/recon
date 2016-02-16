//
//  siteNewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class siteNewController: UIViewController {
    
    var state: position!
    var action: String!
    var originalTokens: [String] = []
    
    @IBOutlet weak var switchBank: UISwitch!
    @IBOutlet weak var switchGas: UISwitch!
    @IBOutlet weak var switchHealth: UISwitch!
    @IBOutlet weak var switchRestaurant: UISwitch!
    @IBOutlet weak var switchStripMall: UISwitch!
    @IBOutlet weak var switchHotel: UISwitch!
    @IBOutlet weak var switchTenant: UISwitch!
    @IBOutlet weak var siteName: UITextField!
    @IBOutlet weak var siteDate: UITextField!
    @IBOutlet weak var siteAddress: UITextField!
    
    @IBAction func done(sender: AnyObject) {
        if (siteName.text == "" || siteAddress.text == "") {
            var emptyAlert = UIAlertController(title: "Notice", message: "Name and address of site must be selected.", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
            }))
            
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        } else {
            //jsonNewSite()
            self.performSegueWithIdentifier("toTypeController", sender: self)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (action == "upgrade") {
            getSiteData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if (segue.identifier == "toElementCatFromNew") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            
            controller.state = self.state
            controller.continuance = false
        }*/
        
        if (segue.identifier == "toTypeController") {
            var controller = segue.destinationViewController as! typeController
            
            var type: [String] = []
            var typeNames: [String] = []
            var typePrices: [String] = []
            var tokens: [String] = []
            
            if (switchBank.on) {
                type.append("Bank")
                typeNames.append("Bank")
                if (typePrices.isEmpty || (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.undefined_tier_1"))) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.undefined_tier_1")
            }
            if (switchGas.on) {
                type.append("Gas Station")
                typeNames.append("Gas Station")
                if (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.gas_tier_1")) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.gas_tier_1")
            }
            if (switchHotel.on) {
                type.append("Hotel")
            }
            if (switchRestaurant.on) {
                type.append("Restaurant")
                typeNames.append("Restaurant")
                if (typePrices.isEmpty || (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.undefined_tier_1"))) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.undefined_tier_1")
            }
            if (switchTenant.on) {
                type.append("Office")
                typeNames.append("Retail/Office Suite")
                if (typePrices.isEmpty || (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.undefined_tier_1"))) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.undefined_tier_1")
            }
            if (switchHealth.on) {
                type.append("Health")
                typeNames.append("Health Care Facility")
                if (typePrices.isEmpty || (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.undefined_tier_1"))) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.undefined_tier_1")
            }
            if (switchStripMall.on) {
                type.append("Strip Mall")
                typeNames.append("Mall")
                if (typePrices.isEmpty || (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.undefined_tier_1"))) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.undefined_tier_1")
            }
            
            if (type.isEmpty) {
                type.append("Empty")
                typeNames.append("Undefined Site")
                if (typePrices.isEmpty || (action != "upgrade" && !contains(originalTokens, "com.adaveracity.casp.undefined_tier_1"))) {
                    typePrices.append("25")
                } else {
                    typePrices.append("0")
                }
                tokens.append("com.adaveracity.casp.undefined_tier_1")
            }
            
            var verifiedType = type
            verifiedType.append("Parking")
            
            println("orig")
            println(self.originalTokens)
            
            controller.name = self.siteName.text
            controller.address = self.siteAddress.text
            controller.date = self.siteDate.text
            controller.verifiedType = verifiedType
            controller.typeNames = typeNames
            controller.originalTokens = self.originalTokens
            controller.typePrices = typePrices
            controller.tokens = tokens
            controller.action = self.action
            controller.type = type
            controller.state = self.state
        }

    }
    
    func getSiteData() {
        println("getting...Online")
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : self.state.username, "password" : self.state.password, "site": self.state.tracking]
        
        let url = NSURL(string: "http://ada-veracity.com/api/get-site-type-json.php")
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
            
            println(jsonResult)
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //self.tableView!.reloadData()
                    
                    for (rootKey, rootValue) in jsonResult {
                        //println(rootValue)
                        //results[rootKey] = Dictionary<String, String>?
                        if (rootKey as! NSString == "name") {
                            self.siteName.text = rootValue as! String
                        } else if (rootKey as! NSString == "address") {
                            self.siteAddress.text = rootValue as! String
                        } else if (rootKey as! NSString == "type") {
                            let range = rootValue.rangeOfString("|")
                            if (range.length != 0) {
                                var types = split(rootValue as! String) {$0 == "|"}
                                for type in types {
                                    println(type)
                                    switch (type) {
                                    case "Office" :
                                        self.switchTenant.setOn(true, animated: true)
                                        break
                                    case "Bank" :
                                        self.switchBank.setOn(true, animated: true)
                                        break
                                    case "Mall" :
                                        self.switchStripMall.setOn(true, animated: true)
                                        break
                                    case "Strip Mall" :
                                        self.switchStripMall.setOn(true, animated: true)
                                        break
                                    case "Hotel" :
                                        self.switchHotel.setOn(true, animated: true)
                                        break
                                    case "Gas Station" :
                                        self.switchGas.setOn(true, animated: true)
                                        break
                                    case "Restaurant" :
                                        self.switchRestaurant.setOn(true, animated: true)
                                        break
                                    default:
                                        break
                                    }
                                }
                            } else {
                                println(rootValue as! String)
                                switch (rootValue as! String) {
                                case "Office" :
                                    self.switchTenant.setOn(true, animated: true)
                                    break
                                case "Bank" :
                                    self.switchBank.setOn(true, animated: true)
                                    break
                                case "Mall" :
                                    self.switchStripMall.setOn(true, animated: true)
                                    break
                                case "Strip Mall" :
                                    self.switchStripMall.setOn(true, animated: true)
                                    break
                                case "Hotel" :
                                    self.switchHotel.setOn(true, animated: true)
                                    break
                                case "Gas Station" :
                                    self.switchGas.setOn(true, animated: true)
                                    break
                                case "Restaurant" :
                                    self.switchRestaurant.setOn(true, animated: true)
                                    break
                                default:
                                    break
                                }
                                
                            }
                        } else if (rootKey as! NSString == "date") {
                            self.siteDate.text = rootValue as! String
                        } else if (rootKey as! NSString == "tokens") {
                            var value = rootValue as! NSString
                            println("value: " + (value as String))
                            let range = value.rangeOfString("|")
                            if (range.length != 0) {
                                println("range")
                                var tokens = split(rootValue as! String) {$0 == "|"}
                                for token in tokens {
                                    self.originalTokens.append(token)
                                }
                            } else {
                                self.originalTokens.append(rootValue as! String)
                            }
                        }
                    }
                })
            })
            
            }.resume()
    }
}
