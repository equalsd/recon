//
//  siteListController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/12/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class siteListController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var username: String!
    var password: String!
    var tracking: String!
    var site: String!
    var type: String!
    var siteSelected: String!
    
    var nameData = [String]()
    var descriptionData = [String]()
    var trackingData = [String]()
    var typeData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        println(siteSelected)
        jsonGetSites()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }*/

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        //let cell = UITableViewCell()
        //let label = UILabel(CGRect(x:0, y:0, width:200, height:50))
        //label.text = "Hello Man"
        //cell.addSubview(label)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("siteCell", forIndexPath: indexPath) as UITableViewCell
        
        let nameData = self.nameData[indexPath.row] as String
        let descriptionData = self.descriptionData[indexPath.row] as String
        
        //cell.textLabel.text = rowData["tracking"] as? String
        if let nameLabel = cell.viewWithTag(150) as? UILabel{
            nameLabel.text = nameData
        }
        
        if let descriptionLabel = cell.viewWithTag(101) as? UILabel{
            descriptionLabel.text = descriptionData
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var emptyAlert = UIAlertController(title: "Notice", message: "This will delete all the current site's data. Pictures will remain in the photo gallery.", preferredStyle: UIAlertControllerStyle.Alert)
        emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
            self.tracking = self.trackingData[indexPath.row] as String
            self.site = self.nameData[indexPath.row] as String
            self.type = self.typeData[indexPath.row] as String
            self.performSegueWithIdentifier("toElementCatFromList", sender: self)
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {( action: UIAlertAction!) in
            //add logic here
        }))
        
        self.presentViewController(emptyAlert, animated: true, completion: nil)
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    func jsonGetSites() {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        var split = false
        let params:[String: AnyObject] = ["username" : self.username, "password" : self.password, "type" : self.siteSelected]
        
        let url = NSURL(string: "http://precisreports.com/api/get-sites-type-json.php")
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        let task: Void = session.dataTaskWithRequest(request) {
            data, response, error in
            
            var tracking = [String]()
            var description = [String]()
            var name = [String]()
            var type = [String]()
            
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
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            for (rootKey, rootValue) in jsonResult {
                //results[rootKey] = Dictionary<String, String>?
                if (rootKey as NSString == "result") {
                    if (rootValue as NSString == "Nothing Found") {
                        split = true
                    }
                } else {
                    for (siteKey, siteValue) in rootValue as NSDictionary {
                        //println("\(siteKey), \(siteValue)")
                        if (siteKey as NSString == "tracking") {
                            tracking.append(siteValue as NSString)
                        } else if (siteKey as NSString == "info") {
                            name.append(siteValue as NSString)
                        } else if (siteKey as NSString == "description") {
                            description.append(siteValue as NSString)
                        } else if (siteKey as NSString == "type") {
                            type.append(siteValue as NSString)
                        }
                    }
                }
            }
            
            //println(description)
            //completionHandler(results)
            
            
            dispatch_async(dispatch_get_main_queue(), {
                if (split) {
                    var emptyAlert = UIAlertController(title: "Notice", message: "No Sites in this Category.", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
                    }))
                    
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                } else {
                    //self.tableView.dataSource = self
                    //self.tableView.delegate = self
                    self.nameData = name
                    self.descriptionData = description
                    self.trackingData = tracking
                    self.typeData =  type
                    self.tableView!.reloadData()
                    //println(self.nameData)
                }
            })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            })
            //self.tableData = results
            
            }.resume()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toElementCatFromList" {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as ElementCategoryControllerTableViewController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.site = self.type
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        }
    }

}
