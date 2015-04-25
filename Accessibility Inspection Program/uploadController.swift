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
    
    var username: String!
    var password: String!
    var site: String!
    var tracking: String!
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
        
        returnArray.append([self.username!, self.password!, self.tracking!, ""])
        
        for item in elements {
            timestamp = timestamp + 1
            if (item.picture!.lowercaseString.rangeOfString("asset") != nil) {
                self.pictures.append([item.picture!, "\(timestamp)"])
                returnArray.append([item.location!, item.notes!, "change", "\(timestamp)", item.category!])
            } else {
                self.pictures.append([item.picture!, "leave be"])
                returnArray.append([item.location!, item.notes!, "leave be", item.picture!, item.category!])
            }
            //returnArray.append([item.location!, "", item.notes!])
            //println(item.picture!)
            //if (item.picture != "") {
                //self.total = self.total + 1
            //}
        }
        
        println(returnArray)
        self.number = self.pictures.count + 1
        return returnArray
    }
    
    func uploadElements() {
        println("uploading...")
        self.uploadButton.enabled = false
        self.progressView.setProgress(0.0, animated: false)
        self.on = 0
        self.progressLabel.text = "Uploading..."
        //self.on = 1
        var elements = self.elements
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        //let params:[String: AnyObject] = ["username" : self.username, "password" : self.password, "site": self.tracking]
        
        //var testtest = [["4", "5"], ["3", "4"]]
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
            
            //println(jsonResult)
            
            /*
            for (rootKey, rootValue) in jsonResult {
            //println(rootValue)
            //results[rootKey] = Dictionary<String, String>?
            if (rootKey as NSString != "Status" && rootKey as NSString != "dir") {
            for (siteKey, siteValue) in rootValue as NSDictionary {
            //println("\(siteKey), \(siteValue)")
            if (siteKey as NSString == "location") {
            location = siteValue as NSString
            } else if (siteKey as NSString == "notes") {
            notes = siteValue as NSString
            } else if (siteKey as NSString == "picture") {
            picture = siteValue as NSString
            }
            
            }
            
            elements.append(Elemental(location: location!, picture: picture!, notes: notes!))
            } else if (rootKey as NSString == "dir") {
            self.site = rootValue as NSString
            }
            }*/
            
            
            //println(description)
            //completionHandler(results)
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    /*for i in 1..<(self.total + 1) {
                        //self.counter = onfile / totalfile
                        sleep(1)
                        //self.on = self.on + 1
                        var fractionalProgress:Float = Float(i) / Float(self.total)
                        var counter:Int = Int(fractionalProgress * 100.0)
                        //let animated = counter != 0
                        self.progressView.setProgress(fractionalProgress, animated: true)
                        self.progressLabel.text = ("\(counter)%")
                        println(fractionalProgress)
                    }*/
                    self.progressBar()
                    
                })
            })
            
            }//.resume()
        
        //var session = NSURLSession(configuration: configuration)
        
        //let params:[String: AnyObject] = ["username" : self.username, "password" : self.password, "site": self.tracking]
        
        //var jsonCompatible = compatiblize(elements)
        
        /*let url = NSURL(string: "http://precisreports.com/api/put-json-elements.php")
        var request = createRequest(elements)
        //let request = NSMutableURLRequest(URL: url!)
        //request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //request.HTTPMethod = "POST"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonCompatible, options: NSJSONWritingOptions.allZeros, error: &err)
        //println(request.HTTPBody)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:  {
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
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON ERROR \(err!.localizedDescription)")
            }
            
            println(jsonResult)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    /*for i in 1..<(self.total + 1) {
                    //self.counter = onfile / totalfile
                    sleep(1)
                    //self.on = self.on + 1
                    var fractionalProgress:Float = Float(i) / Float(self.total)
                    var counter:Int = Int(fractionalProgress * 100.0)
                    //let animated = counter != 0
                    self.progressView.setProgress(fractionalProgress, animated: true)
                    self.progressLabel.text = ("\(counter)%")
                    println(fractionalProgress)
                    }*/
                    
                    self.progressLabel.text = "Done.";
                    
                })
            })

        })
        println("last")*/
        
        task.resume()
        uploadPictures()
        
    }
    
    func uploadPictures () {
        println("pictures...")
        var pictures = self.pictures
        var index: Int = 1
        for picture in pictures {
            //var orientation:ALAssetOrientation = ALAssetOrientation.Right
            /*let library = ALAssetsLibrary()
            var key: String = picture[0] as! String
            let path = NSURL(string: key)
            
            library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                var assetRep = asset.defaultRepresentation()
                var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                var data = UIImageJPEGRepresentation(image2, 1.0)
                var name = "picture \(index)"*/
            
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
                
                        //SRWebClient.POST("http://precisreports.com/temp/yah/upload-file.php")
                        SRWebClient.POST("http://precisreports.com/api/put-picture.php")
                            .datar(data, fieldName: "file", data:["site": self.tracking, "title": name, "key": picture[1] as! String])
                            .send({(response:AnyObject!, status:Int) -> Void in println(response)
                                //println("okay..")
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
        println("updating progress bar")
        self.on  = self.on + 1
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
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.continuance = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func createRequest (elements: [Elemental]) -> NSURLRequest {
        /*var params = [NSArray]()
        var pictures = [String]()
        
        params.append([self.username!, self.password!, self.tracking!])
        
        for item in elements {
            params.append([item.location!, "placeholder", item.notes!])
            pictures.append(item.picture!)
            //returnArray.append([item.location!, "", item.notes!])
            //println(item.picture!)
            //if (item.picture != "") {
            //self.total = self.total + 1
            //}
        }*/

        let boundary = generateBoundaryString()
        
        let url = NSURL(string: "http://precisreports.com/api/put-json-elements.php")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multiform/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createBodyWithParameters(boundary)
        
        return request
        
    }
    
    func createBodyWithParameters(boundary: String) -> NSData {
        let body = NSMutableData()
        
        var index = 0
        var pie = "e"
        for item in self.elements {
            var location = "location\(index)"
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(location)\"\r\n\r\n")
            body.appendString("\(item.location!)\r\n")
            
            var note = "note\(index)"
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(note)\"\r\n\r\n")
            body.appendString("\(item.notes!)\r\n")
            pie += "p"
            
            if (item.picture != "") {
                //println(item.picture)
                //let data = NSData(contentsOfFile: item.picture!)
                
                var orientation:ALAssetOrientation = ALAssetOrientation.Right
                let library = ALAssetsLibrary()
                let path = NSURL(string: item.picture!)
                
                library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                    var assetRep = asset.defaultRepresentation()
                    var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                    var data = UIImageJPEGRepresentation(image2, 1.0)
                    
                    dispatch_sync(dispatch_get_main_queue()) {
                        let mimetype = "image/jpeg"
                        
                        body.appendString("--\(boundary)\r\n")
                        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(item.picture)\"\r\n")
                        body.appendData(data!)
                        body.appendString("\r\n")
                        //println(data)
                        println("sss")
                    }
                    
                    //self.pictureField.image = image2
                }, failureBlock: nil)
                    /*var imagePath: NSString = "\(path)"
                    var data:NSData = NSData.dataWithContentsOfMappedFile(imagePath) as NSData
                    var imageData = UIImage(data:data)
                    self.imageView.image = imageData*/
            }
            
        }
        println(pie)
        //println(body)
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }*/

}

/*extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}*/
