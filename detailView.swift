//
//  detailView.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/19/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreData

class detailView: UIViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate {
    
    //var location: String!
    //var notes: String!
    var picture: String!
    var uniqueID: Int!
    var username: String!
    var password: String!
    var site: String!
    var tracking: String!
    var elements: [Elemental] = []
    var picker:UIImagePickerController?=UIImagePickerController()
    
    @IBOutlet weak var locationBar: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var pictureField: UIImageView!
    
    @IBAction func cancelButton(sender: AnyObject) {
         self.performSegueWithIdentifier("cancelElements", sender: self)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        self.performSegueWithIdentifier("returnElements", sender: self)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        picker!.delegate=self
        //println(location)
        if (self.uniqueID == -1) {
            //UIAlertAction in
            self.openCamera()
        } else {
            //locationBar.text = location
            //notesField.text = notes
            
            //println(picture)
            var item = elements[uniqueID]
            if (item.location != nil) {
                locationBar.text = item.location
            }
            if (item.notes != nil) {
            } else {
                notesField.text = item.notes
            }
            if (item.picture != nil && item.picture != "") {
                
                let path = NSURL(string: item.picture!)
            
                var orientation:ALAssetOrientation = ALAssetOrientation.Right
                let library = ALAssetsLibrary()
                library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                    var assetRep = asset.defaultRepresentation()
                    var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)

                    self.pictureField.image = image2
                }, failureBlock: nil)
                    /*var imagePath: NSString = "\(path)"
                    var data:NSData = NSData.dataWithContentsOfMappedFile(imagePath) as NSData
                    var imageData = UIImage(data:data)
                    self.imageView.image = imageData*/
            }
        }
    }

    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var image=info[UIImagePickerControllerOriginalImage] as UIImage
        var orientation:ALAssetOrientation = ALAssetOrientation.Right
        
        //imageView.image=image
        
        let library = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: orientation, completionBlock: { (path: NSURL!, error: NSError!) -> Void in
            println(path)
            self.picture = "\(path)"
            
            library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                var assetRep = asset.defaultRepresentation()
                var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                
                self.pictureField.image = image2
                
                }, failureBlock: nil)
            /*var imagePath: NSString = "\(path)"
            var data:NSData = NSData.dataWithContentsOfMappedFile(imagePath) as NSData
            var imageData = UIImage(data:data)
            self.imageView.image = imageData*/
        })
        
        
        //var stringly = info[UIImagePickerControllerOriginalImage] as String
        
        //works but no URL
        //UIImageWriteToSavedPhotosAlbum(image, self, "imager:didFinishSavingWithError:contextInfo:", nil)
        
        //upload(image)
        //var alert:UIAlertController=UIAlertController(title: "Success", message: "ok", preferredStyle: UIAlertControllerStyle.ActionSheet)
        //self.presentViewController(alert, animated: true, completion: nil)
        println("sd")
        
    }
    
    func imager(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<(Void)>) {
        println("nuts")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        println("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("cancelElements", sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "returnElements") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as elementTable
            //controller.delegate = self
            
            if (self.uniqueID > -1 ) {
                var path = self.uniqueID
                let item = self.elements[path]
                item.location = self.locationBar.text
                item.notes = self.notesField.text
                item.picture = self.picture
                //println(self.elements[path].location)
            } else {
                //add new element from details
                
                if (self.locationBar.text == "") {
                    var newlocationed: String = newlocation(elements, indexical: 0)
                    self.elements.append(Elemental(location: newlocationed, picture: self.picture!, notes: self.notesField.text))
                } else {
                     self.elements.append(Elemental(location: self.locationBar.text, picture: self.picture!, notes: self.notesField.text))
                }
                //println(self.location)
            }
            
            controller.uniqueID = self.uniqueID
            controller.location = self.locationBar.text
            controller.picture = self.picture
            controller.notes = self.notesField.text
            controller.continuance = "saveThis"
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.elements = self.elements
        } else if (segue.identifier == "cancelElements") {
            var navigationController =  segue.destinationViewController as UINavigationController
            var controller = navigationController.topViewController as elementTable
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.continuance = "continue"
        }
    }
    
    func coreSaveElements() {
        println("inserting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Elements", inManagedObjectContext: managedContext)
        
        
        //var index = 0
        for element in elements {
            //index++
            var item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            item.setValue(element.location, forKey: "location")
            item.setValue(element.picture, forKey: "picture")
            item.setValue(element.notes, forKey: "notes")
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
    }
    
    func newlocation(elements: [Elemental], indexical: Int) -> String {
        var returnLocation: String = "Location \(indexical)"
        var newIndex = indexical
        for item in elements {
            if (item.location! == returnLocation) {
                newIndex = newIndex + 1
                returnLocation = newlocation(elements, indexical: newIndex)
                return returnLocation
            }
        }
        
        return returnLocation
    }
}
