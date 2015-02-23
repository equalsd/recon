//
//  detailView.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/19/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import AssetsLibrary

class detailView: UIViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate {
    
    var location: String!
    var notes: String!
    var picture: String!
    var uniqueID: Int!
    var username: String!
    var password: String!
    var site: String!
    var tracking: String!
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
            locationBar.text = location
            notesField.text = notes
            
            //println(picture)
            let path = NSURL(string: picture)
            
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

    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        picker .dismissViewControllerAnimated(true, completion: nil)
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
            controller.uniqueID = self.uniqueID
            controller.location = self.locationBar.text
            controller.picture = self.picture
            controller.notes = self.notesField.text
            controller.continuance = "saveThis"
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
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
}
