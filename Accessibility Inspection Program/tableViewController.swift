//
//  tableViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/8/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class tableViewControl: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var username: String!
    var password: String!
    var site: String!

    var nameData = [String]()
    var descriptionData = [String]()
    var trackingData = [String]()

    @IBOutlet weak var continueLabel: UIBarButtonItem!
    
    @IBAction func continueElement(sender: AnyObject) {
        self.performSegueWithIdentifier("loadingElements", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        jsonGetSites()
        if (site != nil) {
            continueLabel.title = "continue \(site)"
            continueLabel.enabled = true
        } else {
            continueLabel.enabled = false
            //mod later with presence of sitedata...
        }
    }
    
    /*required init(coder aDecoder: NSCoder) {
        println("init tableViewController")
        super.init(coder: aDecoder)
    }
    
    deinit {
        println("deinit tableViewController")
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func jsonGetSites() {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        let params:[String: AnyObject] = ["username" : username, "password" : password]
        
        let url = NSURL(string: "http://precisreports.com/api/get-sites-json.php")
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
                //println(rootValue)
                //results[rootKey] = Dictionary<String, String>?
                for (siteKey, siteValue) in rootValue as NSDictionary {
                    //println("\(siteKey), \(siteValue)")
                    if (siteKey as NSString == "tracking") {
                        tracking.append(siteValue as NSString)
                    } else if (siteKey as NSString == "info") {
                        name.append(siteValue as NSString)
                    } else if (siteKey as NSString == "description") {
                        description.append(siteValue as NSString)
                    }
                }
            }
            
            //println(description)
            //completionHandler(results)
            
            
            dispatch_async(dispatch_get_main_queue(), {
                //self.tableView.dataSource = self
                //self.tableView.delegate = self
                self.nameData = name
                self.descriptionData = description
                self.trackingData = tracking
                self.tableView!.reloadData()
                println(self.nameData)
            })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            })
            //self.tableData = results
            
            }.resume()
    }
    
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
        if let nameLabel = cell.viewWithTag(100) as? UILabel{
            nameLabel.text = nameData
        }
        
        if let descriptionLabel = cell.viewWithTag(101) as? UILabel{
            descriptionLabel.text = descriptionData
        }
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        //let urlString: NSString = rowData["artworkUrl60"] as NSString
        //let imgURL: NSURL? = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        //let imgData = NSData(contentsOfURL: imgURL!)
        //cell.imageView.image = UIImage(data: imgData!)
        
        // Get the formatted price string for display in the subtitle
        //let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        //cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    
    // UITableViewDelegate Functions
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login" {
            //player = Player(name: self.nameTextField.text, game: "Chess", rating: 1)
            let loginViewController = segue.destinationViewController as UIViewController
            println("login")
            //gamePickerViewController.selectedGame = game
        } else if (segue.identifier == "loadingElements") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as elementTable
            //controller.delegate = self
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            
            let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
                let row = myIndexPath?.row
                controller.site = nameData[row!]
                controller.tracking = trackingData[row!]
            }
        }
        //println("sobeit")
        //println(segue.identifier)
    }
    
    @IBAction func siteList(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
        println("listElements")
    }

}