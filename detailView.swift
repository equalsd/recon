//
//  detailView.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/19/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
//import AssetsLibrary
import CoreData
import Photos

class detailView: UIViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate {
    
    //var location: String!
    //var notes: String!
    var selectedLocation : String!
    var picture: String!
    var elements: [Elemental] = []
    var picker:UIImagePickerController?=UIImagePickerController()
    var keyboardShowing = false
    var multiple = false
    //var roll: [String] = []
    var state: position!
    var swiped = false
    
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
        self.multiple = true
        resolveDetails()
        self.openCamera()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        //println("akc")
        self.performSegueWithIdentifier("detailToPicture", sender: self)
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
        self.pictureField.image = UIImage(named: "noimg.png")
        locationBar.text = self.state.last()
        
        picker!.delegate=self
        
        if (self.state.uniqueID == -1) {
            self.openCamera()
        } else {
            setupDetail(self.elements[self.state.uniqueID])
        }
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        locationBar.delegate = self
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        resolveDetails()
        
        var locality: [Elemental] = []
        var index: Int = 0
        
        for item in elements {
            if (item.location == self.state.current()) {
                locality.append(item)
                if (item.uniqueID == self.state.uniqueID && self.swiped == false) {
                    self.state.uniqueID = index
                }
                index = index + 1
            }
        }

        if (sender.direction == .Left) {
            println("Swipe Left")
            self.state.uniqueID = self.state.uniqueID - 1
        } else if (sender.direction == .Right) {
            println("Swipe Right")
            self.state.uniqueID = self.state.uniqueID + 1
        }
        
        if (self.state.uniqueID >= locality.count) {
            self.state.uniqueID = 0
        } else if (self.state.uniqueID < 0) {
            self.state.uniqueID = locality.count - 1
        }
        
        println(self.state.uniqueID)
        self.swiped = true
        setupDetail(locality[self.state.uniqueID])
    }
    
    func check_location(location: String) -> Bool {
        var elements = self.elements
        var locations: [String] = []
        var found = false
        
        for item in elements {
            if (item.location == location) {
                return true
            }
        }
        
         return false
    }
    
    func lookFor(ID: Int, locality: [Elemental]) -> Int {
        var index: Int = 0
        for item in locality {
            if (item.uniqueID == ID) {
                return index
            }
            index = index + 1
        }
        
        return 0
    }

    func resolveDetails() {
        var index = lookFor(self.state.uniqueID, locality: self.elements)
        if (self.notesField.text != nil) {
            self.elements[index].notes = self.notesField.text
        } else {
            self.elements[index].notes = ""
        }
        if (self.locationBar.text != nil) {
            self.elements[index].location = self.locationBar.text
        } else {
            self.elements[index].location = "misc location"
        }
        
        if (!check_location(self.locationBar.text)) {
            self.elements.append(Elemental(location: self.locationBar.text, picture: "location", notes: "", category: self.state.current(), uniqueID: -2))
        }
        
        coreRemoveElements()
        coreSaveElements()
    }
    
    func setupDetail(item: Elemental) {
        var number: Int = lookFor(self.state.uniqueID, locality: self.elements)
        self.pictureField.contentMode = .ScaleAspectFit
        
        if (swiped == false) {
            if (item.location != nil) {
                self.locationBar.text = item.location as! String
            } else {
                self.locationBar.text = "misc location"
            }
        }
        if (item.notes != nil) {
            notesField.text = item.notes as! String
        } else {
            notesField.text = ""
        }
        var photo = item.picture
        self.picture = photo as! String
        if (photo == nil || photo == "") {
            //self.picture == ""
            //self.pictureField.image = UIImage(named: "noimg.png")
            //println("d")
        } else if (photo!.lowercaseString.rangeOfString("/") != nil) {
            var targetSize: CGSize!
            let imageManager = PHImageManager.defaultManager()
            var location = [self.picture]
            //println(location)
            
            let photos = PHAsset.fetchAssetsWithLocalIdentifiers(location, options: nil)
            
            var asset = photos.firstObject! as! PHAsset
            //println("\(asset.pixelWidth) \(asset.pixelHeight)")
            
            if (asset.pixelHeight > asset.pixelWidth) {
                targetSize = CGSizeMake(225, 300)
            } else {
                targetSize = CGSizeMake(300, 225)
            }
            
            var ID = imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: {
                (result, info)->Void in
                self.pictureField.image = result
            })

        } else {
            let path = "http://precisreports.com/clients/" + "\(self.state.tracking)" + "/" + "\(photo!).jpg"
            
            //image
            let url = NSURL(string: path)
            if let data = NSData(contentsOfURL: url!) {//make sure your image in this url does exist, otherwise unwrap in a if let check
                var image2 = UIImage(data: data)
                
                //let size = CGSizeMake(120, 90)
                var size: CGSize!
                let scale: CGFloat = 0.0
                let hasAlpha = false
                
                if (image2!.size.height > image2!.size.width) {
                    size = CGSizeMake(225, 300)
                } else {
                    size = CGSizeMake(300, 225)
                }
                
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image2!.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                self.pictureField.image = image2
            }
        }
        //saveButton.enabled = true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //println("just")
        self.performSegueWithIdentifier("detailToLocation", sender: self)
        return false
    }
    
    func keyboardShow(n:NSNotification) {
        animateViewMoving(true, moveValue: 220)
    }
    
    func keyboardHide(n:NSNotification) {
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
        
        self.pictureField.contentMode = .ScaleAspectFit
        self.pictureField.image = image
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                self.picture = assetPlaceholder.localIdentifier
                println(self.picture)
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.state.assetCollection, assets: nil)
                albumChangeRequest.addAssets([assetPlaceholder])
                }, completionHandler: {(success, error)in
                    dispatch_async(dispatch_get_main_queue(), {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        
                        if (success) {
                            var number = self.greatest() + 1
                            self.elements.append(Elemental(location: self.locationBar.text, picture: self.picture, notes: self.notesField.text, category: self.state.current(), uniqueID: number))
                            println("categories: \(self.state.current())")
                            println("location  : \(self.locationBar.text)")
                            self.state.uniqueID = number
                            picker.dismissViewControllerAnimated(true, completion: nil)
                            
                            if (self.multiple == true) {
                                self.openCamera()
                            }
                        }
                })
            })
            
        })

    }
    
    func greatest() -> Int {
        var largest = 0
        for item in self.elements {
            if (item.uniqueID > largest && item.uniqueID < 80000) {
                largest = item.uniqueID!
            }
        }
        
        return largest
    }
    
    func imager(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<(Void)>) {
        println("nuts")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.multiple = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (self.picture != nil) {
            resolveDetails()
        } else {
            println("cancelled saving")
        }
        
        if (segue.identifier == "detailToLocation") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! menuLocationController
            controller.elements = self.elements
            controller.state = self.state
        } else if (segue.identifier == "detailToPicture") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! pictureViewController
            
            controller.state = self.state
            controller.elements = self.elements
        }
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
            item.setValue(element.uniqueID, forKey: "uniqueID")
            
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
        //println(user)
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
