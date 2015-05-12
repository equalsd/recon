//
//  uploadController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/28/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
//import AssetsLibrary
import Photos
import CoreData

class uploadController: UIViewController {
    
    var state: position!
    var elements: [Elemental] = []
    var pictures: [NSArray] = []
    //var total: Int = 1
    var on: Int = 0
    var number: Int!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBAction func returnToElements(sender: AnyObject) {
        self.performSegueWithIdentifier("uploaderToOrganize", sender: self)
    }
    
    @IBAction func uploadStart(sender: AnyObject) {
        uploadElements()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressView.setProgress(0, animated: true)
    }
    
    func compatiblize(elements: [Elemental]) -> NSArray {
        var returnArray = [NSArray]()
        self.pictures.removeAll()
        
        let date = NSDate()
        var timestamp = Int(date.timeIntervalSince1970)
        
        returnArray.append([self.state.username!, self.state.password!, "skip", self.state.tracking!])
        
        for item in elements {
            timestamp = timestamp + 1
            println(item.uniqueID!)
            if (item.picture == "location") {
                returnArray.append([item.location!, item.notes!, "location", item.uniqueID!, item.category!])
            } else {
                if (item.uniqueID > 80000) {
                    returnArray.append([item.location!, item.notes!, "ignore", item.uniqueID!, item.category!])
                } else {
                    if (item.picture!.lowercaseString.rangeOfString("/") != nil) {
                    item.uniqueID = timestamp
                        self.pictures.append([item.picture!, "\(item.uniqueID!)"])
                        returnArray.append([item.location!, item.notes!, "change", "\(item.uniqueID!)", item.category!])
                    } else {
                    //self.pictures.append([item.picture!, "leave be"])
                        returnArray.append([item.location!, item.notes!, "leave be", item.picture!, item.category!])
                    }
                }
            }
        }
        
        self.number = self.pictures.count
        return returnArray
    }
    
    func uploadElements() {
        println("uploading...")
        self.uploadButton.enabled = false
        self.progressView.setProgress(0.0, animated: false)
        self.progressLabel.text = "Uploading... do not turn off or shut off internet connection"

        var elements = self.elements
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)

        var jsonCompatible = compatiblize(elements)
        println(jsonCompatible)
        println(self.pictures)
        
        let url = NSURL(string: "http://precisreports.com/api/put-json-elements.php")
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonCompatible, options: NSJSONWritingOptions.allZeros, error: &err)
        //println(request.HTTPBody)
        let task = session.dataTaskWithRequest(request) {
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
            
            //println(data)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressBar()
                })
            })
        }
        
        task.resume()
        if (self.pictures.isEmpty != true) {
            self.uploadPictures(0)
        }

    }

    func uploadPictures (index: Int) {
        println("pictures... \(index) of \(self.number)")
        if (index < self.number) {
            var picture = self.pictures[index]
            //println(picture)
        
            //let assetsLibrary = ALAssetsLibrary()
            let key = picture[0] as! String
            //if (picture[1] as! String != "leave be") {
                
                let imageManager = PHImageManager.defaultManager()
                var targetSize: CGSize!
                var location = [key]
                println(key)
                
                let photos = PHAsset.fetchAssetsWithLocalIdentifiers(location, options: nil)
                var asset = photos.firstObject! as! PHAsset
                var width = CGFloat(asset.pixelWidth)
                var height = CGFloat(asset.pixelHeight)
                var turn: String!
                if (height > width) {
                    turn = "vertical"
                } else {
                    //targetSize = CGSizeMake(height, width)
                    turn = "horizontal"
                }
                targetSize = CGSizeMake(width, height)
            
                var ID = imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: {
                    (imageData, dataUTI, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                    var name = "picture_\(index)"
                    SRWebClient.POST("http://precisreports.com/api/put-picture.php")
                    .datar(imageData, fieldName: "file", data:["orientation": turn, "site": self.state.tracking, "title": name, "key": picture[1] as! String])
                        .send({(response: AnyObject!, status:Int) -> Void in //println(response)
                            //println("okay..")
                            println("response: \(response)")
                            println(picture[1])
                            self.progressBar()
                            
                            var next = index + 1
                            self.uploadPictures(next)
                            }, failure:{
                                (error:NSError!) -> Void in (println(error.code))
                        })
                    })
            //} else {
            /*    self.progressBar()
                println("asset already online")
                var next = index + 1
                uploadPictures(next)
            }*/
        } else {
            self.coreRemoveElements()
        }
    }
    
    func progressBar() {
        self.on = self.on + 1
        println("updating progress bar \(self.on)")
        var total = self.number + 1
        if (on >= total) {
            self.progressView.setProgress(100.00, animated: false)
            self.progressLabel.text = "Saving..."
            self.progressLabel.text = "Done."
            self.uploadButton.enabled = true
            println("okay")
        } else {
            var fractionalProgress: Float = Float(self.on) / Float(total)
            self.progressView.setProgress(fractionalProgress, animated: true)
            self.progressLabel.text = "Uploading \(on) of \(total)"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "uploaderToOrganize") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            controller.state = self.state
            controller.elements = self.elements
            controller.continuance = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func coreSaveElements() {
        println("inserting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Elements", inManagedObjectContext: managedContext)
        
        
        //var index = 0
        for element in elements {
            var item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            item.setValue(element.location, forKey: "location")
            item.setValue(element.picture, forKey: "picture")
            item.setValue(element.notes, forKey: "notes")
            item.setValue(element.category, forKey: "category")
            item.setValue(element.uniqueID!, forKey: "uniqueID")
            println(element.uniqueID!)
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            //index++
        }
    }
    
    func coreRemoveElements() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSFetchRequest(entityName: "Elements")
        
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
        
        coreSaveElements()
    }
}
