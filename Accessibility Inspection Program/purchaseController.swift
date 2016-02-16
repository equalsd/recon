//
//  purchaseBoard.swift
//  Accessibility Inspection Program
//
//  Created by generic on 8/4/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import StoreKit
import CoreData

class purchaseController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var product_id: NSString?;
    
    let cDHelper = coreDataHelper(inheretAppDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var name: String!
    var address: String!
    var date: String!
    var type: [String] = []
    var typeNames: [String] = []
    var typePrices: [String] = []
    var tokens: [String] = []
    var state: position!
    var total: Int = 0
    var originalTokens: [String] = []
    
    @IBOutlet weak var purchaseDescription: UITextView!
    @IBAction func purchaseButton(sender: AnyObject) {
        if (self.total > 0) {
            buyConsumable()
        } else {
            jsonUpdateSite()
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        println("cancel")
        self.performSegueWithIdentifier("cancelToNav", sender: self)
        //self.performSegueWithIdentifier("toOrganizer", sender: self)
    }
    
    override func viewDidLoad() {
        //self.product_id = "com.adaveracity.casp.report_100";
        super.viewDidLoad()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        //addBotton();
        
        var descriptionText: String = ""
        for i in 0...self.typeNames.count - 1 {
            //purchaseDescription.text = "\(purchaseDescription) \n \(typeNames[i])"
            descriptionText = descriptionText + self.typeNames[i] + "\n\n"
            var number: Int = NSString(string: typePrices[i]).integerValue
            self.total = self.total + number
        }
        
        self.total = self.total - 1

        if (self.total > 199) {
            self.total = 199
        }
        
        self.product_id = "com.adaveracity.casp.report_\(self.total)"
        if (self.total < 0) {
            purchaseDescription.text = "Check out for Site Specifications: $0.00 \n\n" + descriptionText
        } else {
            purchaseDescription.text = "Check out for Site Specifications: $\(self.total).99 \n\n" + descriptionText
        }
    }
    
    
    func buyConsumable(){
        println("About to fetch the products");
        // We check that we are allow to make the purchase.
        if (SKPaymentQueue.canMakePayments()) {
            var productID:NSSet = NSSet(object: self.product_id!);
            var productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>);
            productsRequest.delegate = self;
            productsRequest.start();
            println("Fetching Products");
        } else {
            println("Can't make purchases");
        }
    }
    
    // Helper Methods

    func buyProduct(product: SKProduct){
        println("Sending the Payment Request to Apple");
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
    }
    
    
    // Delegate Methods for IAP
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        println("got the request from Apple")
        var count : Int = response.products.count
        if (count > 0) {
            var validProducts = response.products
            var validProduct: SKProduct = response.products[0] as! SKProduct
            if (validProduct.productIdentifier == self.product_id) {
                println(validProduct.localizedTitle)
                println(validProduct.localizedDescription)
                println(validProduct.price)
                buyProduct(validProduct);
            } else {
                println(validProduct.productIdentifier)
            }
        } else {
            println("nothing")
        }
    }
    
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("Error");
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
        println("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased:
                    println("Product Purchased");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    jsonNewSite()
                    break;
                case .Failed:
                    println("Purchased Failed");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                    // case .Restored:
                    //[self restoreTransaction:transaction];
                default:
                    println(transaction.transactionState.rawValue)
                    break;
                }
            }
        }
        
    }
    
    func jsonNewSite() {
        var elements: [Elemental] = []
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
    
        var typeString: String =  "-".join(self.type)
        var tokenSet: String = "|".join(self.tokens)
        
        let params:[String: AnyObject] = ["username" : self.state.username, "password": self.state.password, "name": self.name, "description": self.address, "type": typeString, "date": self.date, "tokenSet": tokenSet]
    
        let url = NSURL(string: "http://ada-veracity.com/api/new-site-json.php")
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
    
            //println(jsonResult)
    
            /*for (rootKey, rootValue) in jsonResult {
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                if (rootKey as! NSString != "Status" && rootKey as! NSString != "dir") {
                    for (siteKey, siteValue) in rootValue as! NSDictionary {
                        //println("\(siteKey), \(siteValue)")
                        if (siteKey as! NSString == "location") {
                            location = siteValue as! NSString
                        } else if (siteKey as! NSString == "notes") {
                            notes = siteValue as! NSString
                        } else if (siteKey as! NSString == "picture") {
                            picture = siteValue as! NSString
                        }
    
                    }
    
                    elements.append(Elemental(location: location!, picture: picture!, notes: notes!))
                } else if (rootKey as! NSString == "dir") {
                    self.site = rootValue as! NSString
                }
            }*/
    
            self.state.tracking = jsonResult["site"] as! NSString as String
            self.state.type = typeString
            elements.append(Elemental(location: self.address, picture: "name", notes: self.name, category: typeString, uniqueID: -2, site: self.state.tracking))
    
            self.cDHelper.coreSaveElements(elements, tracking: self.state.tracking)
    
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
    
                    self.coreSaveSite()
                    self.performSegueWithIdentifier("toOrganizer", sender: self)

                })
            })
    
            }.resume()
    }
    
    func jsonUpdateSite() {
        println("updating..." + self.name)
        var elements: [Elemental] = []
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        var typeString: String =  "-".join(self.type)
        //var tokenSet: String = "|".join(self.tokens)
        var tokenSet: String = reconcileTokens()
        
        let params:[String: AnyObject] = ["username" : self.state.username, "password": self.state.password, "name": self.name, "description": self.address, "type": typeString, "date": self.date, "tokenSet": tokenSet, "site": self.state.tracking]
        
        let url = NSURL(string: "http://ada-veracity.com/api/update-site-json.php")
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
            
            /*for (rootKey, rootValue) in jsonResult {
            //println(rootValue)
            //results[rootKey] = Dictionary<String, String>?
            if (rootKey as! NSString != "Status" && rootKey as! NSString != "dir") {
            for (siteKey, siteValue) in rootValue as! NSDictionary {
            //println("\(siteKey), \(siteValue)")
            if (siteKey as! NSString == "location") {
            location = siteValue as! NSString
            } else if (siteKey as! NSString == "notes") {
            notes = siteValue as! NSString
            } else if (siteKey as! NSString == "picture") {
            picture = siteValue as! NSString
            }
            
            }
            
            elements.append(Elemental(location: location!, picture: picture!, notes: notes!))
            } else if (rootKey as! NSString == "dir") {
            self.site = rootValue as! NSString
            }
            }*/
            
            self.state.type = typeString
            //elements.append(Elemental(location: self.address, picture: "name", notes: self.name, category: typeString, uniqueID: -2, site: self.state.tracking))
            
            //self.cDHelper.coreSaveElements(elements, tracking: self.state.tracking)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            //println("saving: \(uniqueID) for \(key) = \(value)")
            var fetchRequest = NSFetchRequest(entityName: "Elements")
            let pred1 = NSPredicate(format: "site == %@", self.state.tracking)
            let pred2 = NSPredicate(format: "uniqueID == %i", -2)
            let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1, pred2])
            fetchRequest.predicate = pred
            
            if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    
                    var managedObject = fetchResults[0]
                    //managedObject.setValue(value, forKey: key)
                    managedObject.setValue(self.date, forKey: "date")
                    managedObject.setValue(self.address, forKey: "description")
                    managedObject.setValue(self.name, forKey: "name")
                    managedObject.setValue(tokenSet, forKey: "tokenSet")
                    managedObject.setValue(typeString, forKey: "type")
                    
                    managedContext.save(nil)
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.coreSaveSite()
                    self.performSegueWithIdentifier("toOrganizer", sender: self)
                    
                })
            })
            
            }.resume()
    }
    
        
    func reconcileTokens() -> String {
        var arrayString = [String]()
        var finalTokens = Dictionary<String,String>()
        for new in self.tokens {
            var newLevels = split(new) {$0 == "."}
            var newTiers = split(newLevels[3]) {$0 == "_"}
            for org in self.originalTokens {
                var orgLevels = split(org) {$0 == "."}
                var orgTiers = split(orgLevels[3]) {$0 == "_"}
                if (newTiers[0] == orgTiers[0]) {
                    if (orgTiers[2].toInt()! <= newTiers[2].toInt()!) {
                        if (finalTokens[orgTiers[0]] == nil) {
                            finalTokens[orgTiers[0]] = newTiers[2]
                        } else {
                            if (finalTokens[orgTiers[0]]!.toInt()! < newTiers[2].toInt()!) {
                                finalTokens[orgTiers[0]] = newTiers[2]
                            }
                        }
                    } else {
                        if (finalTokens[orgTiers[0]] == nil) {
                            finalTokens[orgTiers[0]] = orgTiers[2]
                        } else {
                            if (finalTokens[orgTiers[0]]!.toInt()! < orgTiers[2].toInt()!) {
                                finalTokens[orgTiers[0]] = orgTiers[2]
                            }
                        }
                    }
                }
            }
        }
        
        for (key, value) in finalTokens {
            arrayString.append("com.adaveracity.casp." + key + "_tier_" + value)
        }
        
        return "|".join(arrayString)
    }
    
    func coreSaveSite() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
    
        let entity = NSFetchRequest(entityName: "User")
    
    //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
    
        var error: NSError? = nil
        let list = managedContext.executeFetchRequest(entity, error: &error)
    
        if let users = list {
            var bas: NSManagedObject!
    
            for bas: AnyObject in users {
                managedContext.deleteObject(bas as! NSManagedObject)
            }
    
            managedContext.save(nil)
        }
    
        let newEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
    
        let results = NSManagedObject(entity: newEntity!, insertIntoManagedObjectContext:managedContext)
    
        results.setValue(self.state.tracking, forKey: "tracking")
        results.setValue(self.name, forKey: "site")
        results.setValue(self.state.username, forKey: "username")
        results.setValue(self.state.password, forKey: "password")
    
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "cancelToNav") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var scc = navigationController.topViewController as! siteCategoryController
            
            scc.state = self.state

        } else if (segue.identifier == "toOrganizer") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var ecc = navigationController.topViewController as! elementCategoryController
            
            ecc.state = self.state
            ecc.continuance = false
            
            /*pb.state = self.state
            pb.tokens = self.tokens
            pb.typeNames = self.typeNames
            pb.typePrices = self.typePrices
            pb.name = self.name
            pb.address = self.address
            pb.date = self.date
            pb.type = self.type*/
        
        }
    }

}