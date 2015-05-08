//
//  uploadController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/28/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import AssetsLibrary

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
       /*self.counter = 0
        for i in 0..<100 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                sleep(1)
                dispatch_async(dispatch_get_main_queue(), {
                    self.counter++
                    return
                })
            })
        }*/
        //self.counter = 50
        uploadElements()
        /*for i in 1..<11 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                //sleep(1)
                dispatch_async(dispatch_get_main_queue(), {
                    sleep(1)
                    //self.on = self.on + 1
                    var fractionalProgress:Float = Float(i) / Float(self.total)
                    var counter:Int = Int(fractionalProgress * 100.0)
                    //let animated = counter != 0
                    self.progressView.setProgress(fractionalProgress, animated: true)
                    self.progressLabel.text = ("\(counter)%")
                    println(fractionalProgress)
                    return
                })
            })
        }*/
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
            if (item.picture!.lowercaseString.rangeOfString("asset") != nil) {
                self.pictures.append([item.picture!, "\(timestamp)"])
                returnArray.append([item.location!, item.notes!, "change", "\(timestamp)", item.category!])
            } else {
                self.pictures.append([item.picture!, "leave be"])
                returnArray.append([item.location!, item.notes!, "leave be", item.picture!, item.category!])
            }
        }
        
        //println(returnArray)
        self.number = self.pictures.count + 1
        return returnArray
    }
    
    func uploadElements() {
        println("uploading...")
        self.uploadButton.enabled = false
        self.progressView.setProgress(0.0, animated: false)
        self.on = 0
        self.progressLabel.text = "Uploading..."

        var elements = self.elements
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)

        var jsonCompatible = compatiblize(elements)
        
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
            uploadPictures()
        }
        
    }
    
    /*func uploadPictures (on: Int) {
        println("pictures...")
        var count = self.pictures.count - 1
        var index: Int = 1
        if (on <= count) {
            var item = self.pictures[on]
            
            let key = item[0] as! String
            if (key.lowercaseString.rangeOfString("asset") != nil) {
                
                let url = NSURL(string: key) // relativeToURL: "\(appItem.URLSchema)://")
                //let url = NSURL(fileURLWithPath: photo)
                
                var image: UIImage?
                var loadError: NSError?
                let assetsLibrary = ALAssetsLibrary()
                assetsLibrary.assetForURL(url, resultBlock: {
                    (asset: ALAsset!) -> Void in
                    if (asset != nil) {
                        var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                        var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                        image = UIImage(CGImage: iref)
                        /*var name = "picture \(index)"
                        let data = UIImageJPEGRepresentation(image, 1.0)
                        println(item[1])
                        
                        //SRWebClient.POST("http://precisreports.com/temp/yah/upload-file.php")
                        SRWebClient.POST("http://precisreports.com/api/put-picture.php")
                            .datar(data, fieldName: "file", data:["site": self.tracking, "title": name, "key": item[1] as! String])
                            .send({(response:AnyObject!, status:Int) -> Void in println(response)
                                //println("okay..")
                                //println(response)
                                self.progressBar()
                                self.uploadPictures(on + 1)
                                }, failure:{
                                    (error:NSError!) -> Void in (println(error.code))
                            })*/
                    } else {
                        println("asset nil for \(key)")
                        self.progressBar()
                    }
                    //self.pictureField.image = image2
                    index = index + 1
                    }, failureBlock: nil)
            } else {
                self.progressBar()
                index = index + 1
                println("asset already online")
            }
        }
    }*/
    
    func uploadPictures () {
        println("pictures...")
        var pictures = self.pictures
        var index: Int = 1
        for picture in pictures {
            
            let assetsLibrary = ALAssetsLibrary()
            let key = picture[0] as! String
            if (key.lowercaseString.rangeOfString("asset") != nil) {
                
                let url = NSURL(string: key) // relativeToURL: "\(appItem.URLSchema)://")
                //let url = NSURL(fileURLWithPath: photo)
            
                var image: UIImage?
                var loadError: NSError?
                assetsLibrary.assetForURL(url, resultBlock: {
                    (asset: ALAsset!) -> Void in
                    if (asset != nil) {
                        var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                        var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                        var image = UIImage(CGImage: iref)
                        var name = "picture \(index)"
                        let data = UIImageJPEGRepresentation(image, 1.0)
                        println(picture[1])
                
                        //SRWebClient.POST("http://precisreports.com/temp/yah/upload-file.php")
                        SRWebClient.POST("http://precisreports.com/api/put-picture.php")
                            .datar(data, fieldName: "file", data:["site": self.state.tracking, "title": name, "key": picture[1] as! String])
                            .send({(response:AnyObject!, status:Int) -> Void in println(response)
                                //println("okay..")
                                //println(response)
                                self.progressBar()
                                }, failure:{
                                    (error:NSError!) -> Void in (println(error.code))
                            })
                    } else {
                        println("asset nil for \(key)")
                        self.progressBar()
                    }
                    //self.pictureField.image = image2
                    index = index + 1
                }, failureBlock: nil)
            } else {
                self.progressBar()
                index = index + 1
                println("asset already online")
            }
        }
    }

    
    func progressBar() {
        self.on  = self.on + 1
        println("updating progress bar \(self.on)")
        var fractionalProgress: Float = Float(self.on) / Float(self.number)
        self.progressView.setProgress(fractionalProgress, animated: true)
        var counter:Int = Int(fractionalProgress * 100.0)
        if (on == number) {
            self.progressLabel.text = "Done."
            self.uploadButton.enabled = true
        } else {
            self.progressLabel.text = "Uploading \(on) of \(self.number)"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "uploaderToOrganize") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            controller.state = self.state
            controller.continuance = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
