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

class detailView: UIViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate {
    
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
    var keyboardShowing = false
    var multiple = false
    var category: String!
    var roll: [String] = []
    var type: String!
    var selectedLocation: String!
    
    var location: String!
    var notes: String!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationBar: UITextField! = nil
    @IBOutlet weak var pictureField: UIImageView!
    @IBOutlet weak var notesField: UITextView!
    @IBAction func cancelButton(sender: AnyObject) {
         self.performSegueWithIdentifier("cancelElements", sender: self)
    }
    
    @IBAction func addButton(sender: AnyObject) {
        println("add")
        //self.multiple = true
        self.openCamera()
    }
    @IBAction func viewTapped(sender: AnyObject) {
        notesField.resignFirstResponder()
        locationBar.resignFirstResponder()
    }
    
    /*override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        locationBar.resignFirstResponder()
        self.view.endEditing(true)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame.size.width = UIScreen.mainScreen().bounds.width
        // Do any additional setup after loading the view, typically from a nib.
        //saveButton.enabled = false
        
        
        picker!.delegate=self
        
        if (self.uniqueID == -1) {
            self.openCamera()
        } else {
            notesField.text = self.notes
            
            //println(picture)
            //setupDetail()
        }
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        locationBar.delegate = self
        
        if (location != nil) {
            locationBar.text = self.location
        }
        
        /*var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe) */
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (self.uniqueID == -1) {
            saveElementsForReturn()
        }
        
        if (!roll.isEmpty) {
            saveRoll()
        }
        
        if (self.uniqueID == -1 ) {
            self.uniqueID = self.elements.count - 1
        }
        
        if (sender.direction == .Left) {
            println("Swipe Left")
            self.uniqueID = self.uniqueID - 1
        }
        
        if (sender.direction == .Right) {
            println("Swipe Right")
            self.uniqueID = self.uniqueID + 1
        }
        
        if (self.uniqueID >= self.elements.count) {
            self.uniqueID = 0
        } else if (self.uniqueID < 0) {
            self.uniqueID = self.elements.count + self.uniqueID
        }
        
        setupDetail()
    }

    
    func setupDetail() {
        var item = elements[uniqueID]
        if (item.location != nil) {
            locationBar.text = item.location as! String
        } else {
            locationBar.text = ""
        }
        if (item.notes != nil) {
            notesField.text = item.notes as! String
        } else {
            notesField.text = ""
        }
        var photo = item.picture
        self.picture = photo as! String
        if (photo == nil || photo == "") {
            self.picture == ""
            self.pictureField.image = UIImage(named: "noimg.png")
            //println("d")
        } else if (photo!.lowercaseString.rangeOfString("http") == nil) {
            //println("s");
            let path = NSURL(fileURLWithPath: photo! as String)
            
            var orientation:ALAssetOrientation = ALAssetOrientation.Right
            let library = ALAssetsLibrary()
            library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                var assetRep = asset.defaultRepresentation()
                var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                
                let size = CGSizeMake(120, 90)
                let scale: CGFloat = 0.0
                let hasAlpha = false
                
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image2!.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                self.pictureField.image = image2
                }, failureBlock: nil)
        } else {
            let path = "http://precisreports.com/clients/" + "\(self.tracking)" + "/thumbnails/" + "\(photo!).jpg"
            
            //image
            let url = NSURL(string: path)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            var image2 = UIImage(data: data!)
            
            let size = CGSizeMake(120, 90)
            let scale: CGFloat = 0.0
            let hasAlpha = false
            
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            image2!.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            self.pictureField.image = image2
        }
        //saveButton.enabled = true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //println("just")
        self.performSegueWithIdentifier("getLocation", sender: self)
        return false
    }
    
    func keyboardShow(n:NSNotification) {
        /*self.keyboardShowing = true
        
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        r = self.notesField.convertRect(r, fromView:nil)
        self.notesField.contentInset.bottom = r.size.height
        self.notesField.scrollIndicatorInsets.bottom = r.size.height
        println("s")*/
        animateViewMoving(true, moveValue: 220)
    }
    
    func keyboardHide(n:NSNotification) {
        /*self.keyboardShowing = false
        self.notesField.contentInset = UIEdgeInsetsZero
        self.notesField.scrollIndicatorInsets = UIEdgeInsetsZero*/
        animateViewMoving(false, moveValue: 220)
    }

    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var image=info[UIImagePickerControllerOriginalImage] as! UIImage
        var orientation:ALAssetOrientation = ALAssetOrientation.Right
        
        //imageView.image=image
        
        let library = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: orientation, completionBlock: { (path: NSURL!, error: NSError!) -> Void in
            println(path)
            self.picture = "\(path)"
            
            if (self.multiple == false) {
                library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                    var assetRep = asset.defaultRepresentation()
                    var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                
                    self.pictureField.image = image2
                
                    }, failureBlock: nil)
            } else {
                self.roll.append(self.picture)
                self.openCamera()
            }
        })
        
        //var stringly = info[UIImagePickerControllerOriginalImage] as String
        
        //works but no URL
        //UIImageWriteToSavedPhotosAlbum(image, self, "imager:didFinishSavingWithError:contextInfo:", nil)
        
        //upload(image)
        //var alert:UIAlertController=UIAlertController(title: "Success", message: "ok", preferredStyle: UIAlertControllerStyle.ActionSheet)
        //self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func imager(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<(Void)>) {
        println("nuts")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
        //if (multiple == false) {
        //    self.performSegueWithIdentifier("cancelElements", sender: self)
        //} else {
            //saved when hit save for one last chance to mod data
            //println(self.roll)
        //}
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailToLocation") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! locationController
            //controller.delegate = self
            
            if (multiple) {
                    saveRoll()
            } else {
                saveElementsForReturn()
            }
            
            //controller.uniqueID = self.uniqueID
            //controller.location = self.locationBar.text
            //controller.picture = self.picture
            //controller.notes = self.notesField.text
            controller.type = self.type
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.elements = self.elements
        } else if (segue.identifier == "cancelElements") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementTable
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.continuance = "continue"
            //println("cancelled")
        } else if (segue.identifier == "getLocation") {
            var controller = segue.destinationViewController as! menuLocationController
            controller.username = self.username
            controller.password = self.password
            controller.site = self.site
            controller.tracking = self.tracking
            controller.location = self.locationBar.text
            controller.elements = self.elements
            controller.picture = self.picture
            controller.notes = self.notesField.text
            controller.uniqueID = self.uniqueID
            //controller.roll = self.roll
        }
    }
    
    func saveElementsForReturn() {
        if (self.uniqueID > -1 ) {
            var path = self.uniqueID
            let item = self.elements[path]
            item.location = self.locationBar.text
            item.notes = self.notesField.text
            item.picture = self.picture
            //println(self.elements[path].location)
        } else {
            if (self.locationBar.text == "") {
                var newlocationed: String = newlocation(elements, indexical: 0)
                self.elements.append(Elemental(location: newlocationed, picture: self.picture!, notes: self.notesField.text, category: self.category, uniqueID: 0))
                self.locationBar.text = newlocationed
            } else {
                self.elements.append(Elemental(location: self.locationBar.text, picture: self.picture, notes: self.notesField.text, category: self.category, uniqueID: 0))
            }
        }
        
        //println(self.picture)
        println("saving element...")
    }
    
    func saveRoll() {
        saveElementsForReturn()
        
        var index = elements.count
        
        for photo in self.roll {
            index = index + 1
            self.elements.append(Elemental(location: self.locationBar.text, picture: photo, notes: self.notesField.text, category: category, uniqueID: index))
        }
        
        self.roll.removeAll()
        println("saving roll...")
    }
    
    func coreSaveElements() {
        println("inserting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    /*@IBAction func getLocation(sender: AnyObject) {
        self.view.endEditing(false);
        println("none")
    }*/
}
