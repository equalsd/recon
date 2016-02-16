//
//  typeController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 8/15/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class typeController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var name: String!
    var address: String!
    var date: String!
    var verifiedType: [String] = []
    var type: [String] = []
    var typeNames: [String] = []
    var typePrices: [String] = []
    var tokens: [String] = []
    var state: position!
    var current: String!
    var displayTitleArray: [String] = []
    var displaySubArray: [String] = []
    var displayPriceArray: [String] = []
    var displayTokenArray: [String] = []
    var originalTokens: [String] = []
    var action: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("verifiedType: ")
        println(verifiedType)
        setup()
    
    }
    
    func setup() {
        self.displaySubArray.removeAll()
        self.displayTitleArray.removeAll()
        self.displayTokenArray.removeAll()
        
        if (verifiedType.isEmpty) {
            //to to purchase
            
            //var pb = self.storyboard?.instantiateViewControllerWithIdentifier("purchaseBoard") as! purchaseController
            self.performSegueWithIdentifier("typeToPurchase", sender: self)
            
            //self.navigationController!.pushViewController(pb, animated: true)

        } else {
            self.current = self.verifiedType[0]
            self.verifiedType.removeAtIndex(0)
            
            if (current == "Parking" || current == "Hotel") {
                self.title = "Select Tier"
                typeSet()
                
                self.tableView!.reloadData()
            } else {
                setup()
            }
        }
    }
    
    func typeSet() {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        
        let params:[String: AnyObject] = ["username" : self.state.username, "password" : self.state.password, "type": current]
        
        let url = NSURL(string: "http://ada-veracity.com/api/get-token-description.php")
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
            
            if (jsonResult["status"] as! NSString as String == "Success") {
                let results: NSDictionary = jsonResult["result"] as! NSDictionary
                /*for (index, result) in results {
                    //self.displayArray.append(result["Name"] as! String)
                    //println(result["Name"] as! String)
                    println(index)
                }*/
                for i in 0...results.count - 1 {
                    var index = "index\(i)"
                    let innerObj: NSDictionary = results[index] as! NSDictionary
                    var name = innerObj["Name"] as! String
                    var description = innerObj["Description"] as! String
                    var price = innerObj["Price"] as! String
                    var token = innerObj["ID"] as! String
                    if (self.action == "upgrade") {
                        var newPrice = self.tokenCheck(token)
                        if (newPrice == -1) {
                            self.displayTitleArray.append(name)
                            self.displaySubArray.append(description)
                            self.displayPriceArray.append(price)
                            self.displayTokenArray.append(token)
                        } else {
                            if (newPrice != -2) {
                                self.displayTitleArray.append(name)
                                self.displaySubArray.append(description)
                                self.displayPriceArray.append(String(newPrice))
                                self.displayTokenArray.append(token)
                            }
                        }
                        
                    } else {
                        self.displayTitleArray.append(name)
                        self.displaySubArray.append(description)
                        self.displayPriceArray.append(price)
                        self.displayTokenArray.append(token)
                    }
                }
                
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    //self.locations = locations
                    //self.notes = notes
                    //self.pictures = pictures
                    //self.elements = elements
                    //}
                    
                    self.tableView!.reloadData()
                })
            })
            
            }.resume()
    }
    
    func tokenCheck(token: String) -> Int {
        var tokenLevels = split(token) {$0 == "."}
        var tokenTiers = split(tokenLevels[3]) {$0 == "_"}
         for item in self.originalTokens {
            var itemLevels = split(item) {$0 == "."}
            var itemTiers = split(itemLevels[3]) {$0 == "_"}
            if (tokenTiers[0] == itemTiers[0]) {
                if (itemTiers[2].toInt()! <= tokenTiers[2].toInt()!) {
                    var tempInt: Int = (tokenTiers[2].toInt()! - itemTiers[2].toInt()!) * 25
                    if (tempInt < 0) {tempInt = 0}
                    
                    return tempInt
                } else {
                    return -2
                }
            }
        }
        
        return -1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayTitleArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tokenCell", forIndexPath: indexPath) as! UITableViewCell
        
        let nameData = self.displayTitleArray[indexPath.row] as String
        let subData = self.displaySubArray[indexPath.row] as String
        
        if let nameLabel = cell.viewWithTag(100) as? UILabel{
            nameLabel.text = nameData
        }
        
        if let subLabel = cell.viewWithTag(110) as? UILabel {
            subLabel.text = subData;
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("okay")
        self.typeNames.append(self.displayTitleArray[indexPath.row])
        self.tokens.append(self.displayTokenArray[indexPath.row])
        self.typePrices.append(self.displayPriceArray[indexPath.row])
        
        setup()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var navigationController =  segue.destinationViewController as! UINavigationController
        var pb = navigationController.topViewController as! purchaseController
        
        pb.state = self.state
        pb.tokens = self.tokens
        pb.typeNames = self.typeNames
        pb.typePrices = self.typePrices
        pb.name = self.name
        pb.address = self.address
        pb.date = self.date
        pb.type = self.type
        pb.originalTokens = self.originalTokens

    }
}



