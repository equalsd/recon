//
//  CameraController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 7/24/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import Photos
import CoreMotion

class CameraController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var managePhotoButton: UIBarButtonItem!
    @IBOutlet weak var manageBackButton: UIBarButtonItem!
    
    let motionManager = CMMotionManager()
    let cDHelper = coreDataHelper(inheretAppDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var pictureString: String?
    var orientationX: Double?
    var savedX: Double?
    
    var timer = NSTimer()
    var counter = 0
    
    var elements: [Elemental] = []
    var state: position!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                
                //let rotation = atan2(data.gravity.x, data.gravity.y) - M_PI
                //println("x: \(data.gravity.x), y: \(data.gravity.y)")
                var x = data.gravity.x
                var y = data.gravity.y
                
                /*if (x > -0.5 && x < 0.5) {
                    //self!.textBox!.text = "portrait";
                    self!.orientationLandscape = false
                } else {
                    //self!.textBox!.text = "landscape";
                    self!.orientationLandscape = true
                
                }*/
                self!.orientationX = x
                //println("x: \(x), y: \(y)")
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.capturedImage.hidden = true
        self.previewView.hidden = false
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        
        if error == nil && captureSession!.canAddInput(input) {
            self.managePhotoButton.title = "New Photo"
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer)
                
                captureSession!.startRunning()
            }
        } else {
            self.managePhotoButton.title = "Not Available"
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("cameraToPicture", sender: self)
        
    }
    
    @IBAction func didPressTakePhoto(sender: UIBarButtonItem) {
        if (managePhotoButton.title == "New Photo") {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updatePhotoButton"), userInfo: nil, repeats: true)
            self.savedX = self.orientationX
            if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                    if (sampleBuffer != nil) {
                        var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        var dataProvider = CGDataProviderCreateWithCFData(imageData)
                        var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    
                        var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                        self.capturedImage.contentMode = .ScaleAspectFit
                        self.capturedImage.image = image
                        self.previewView.hidden = true
                        self.capturedImage.hidden = false
                        self.navigationItem.leftBarButtonItem!.enabled = false
                    }
                })
            }
        } else {
            self.previewView.hidden = false
            self.capturedImage.hidden = true
            println("not saved")
            timer.invalidate()
            managePhotoButton.title = "New Photo"
           self.navigationItem.leftBarButtonItem!.enabled = true
        }
    }
    
    func updatePhotoButton () {
        counter++
        var count = 3 - counter
        managePhotoButton.title = "Saving: \(count)"
        println("Cancel: \(count)")
        if (counter == 3) {
            self.navigationItem.rightBarButtonItem!.enabled = false
            self.didSavePhoto()
            managePhotoButton.title = "New Photo";
            counter = 0
            timer.invalidate()
        }
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
    
    /*override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // if landscape
        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            //landscapeScreen()
            self.orientationLandscape = true
            println("landscape")
        } else { // else portrait
            //portraitScreen()
            self.orientationLandscape = false
            println("portrait")
        }
        
    }*/
    
    func didSavePhoto() {
        if (self.capturedImage.image != nil) {
            var newImage = self.capturedImage.image
            
            if (self.savedX! > 0.5 ) {
                //landscape clockwise
                newImage = UIImage(CGImage: self.capturedImage.image!.CGImage, scale: 0.1, orientation: .Down);
                println("\(self.savedX!), clockwise")
            } else if (self.savedX! < -0.5) {
            //landscape counterclockwise
                newImage = UIImage(CGImage: self.capturedImage.image!.CGImage, scale: 0.1, orientation: .Up);
                println("\(self.savedX!), counterclockwise")
            } else { //if (self.savedX! < 0.5 || self.savedX < -0.5) {
            //portrait
                newImage = self.capturedImage.image
                println("\(self.savedX!), portrait")
            }
    
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0), {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(newImage)
                    let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                    self.pictureString = assetPlaceholder.localIdentifier
                    println(self.pictureString!)
                
                    let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.state.assetCollection, assets: nil)
                    albumChangeRequest.addAssets([assetPlaceholder])
                    }, completionHandler: {(success, error)in
                    dispatch_async(dispatch_get_main_queue(), {
                            NSLog("Adding Image to Library -> %@", (success ? "Success":"Error!"))
                        
                            if (success) {
                                var element = [Elemental]()
                                var number = self.greatest() + 1
                                self.elements.append(Elemental(location: self.state.last(), picture: self.pictureString!, notes: "", category: self.state.current(), uniqueID: number, site: self.state.tracking))
                                element.append(Elemental(location: self.state.last(), picture: self.pictureString!, notes: "", category: self.state.current(), uniqueID: number, site: self.state.tracking))
                                println("categories: \(self.state.current()), number: \(number)")
                                self.state.uniqueID = number
                                
                                self.cDHelper.coreSaveElements(element, tracking: self.state.tracking)
                                self.navigationItem.leftBarButtonItem!.enabled = true
                                self.navigationItem.rightBarButtonItem!.enabled = true
                            } else {
                                println("fail")
                            }
                        })
                })
            
            })
        
            self.previewView.hidden = false
            self.capturedImage.hidden = true
        
            //self.cDHelper.coreRemoveElements("Elements", tracking: self.state.tracking)
            //self.cDHelper.coreSaveElements(elements, tracking: self.state.tracking)
        } else {
            println("not saving")
        }
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession!.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.didSavePhoto()
        timer.invalidate()
        managePhotoButton.title = "New Photo";
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if (segue.identifier == "cameraToPicture") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var pc = navigationController.topViewController as! pictureViewController
            pc.elements = self.elements
            pc.state = self.state
        }
    }
    
    /*func coreSaveElements() {
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
    }*/

    
}
