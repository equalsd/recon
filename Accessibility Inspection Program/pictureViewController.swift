//
//  pictureViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/15/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import AssetsLibrary
//import Photos

class pictureViewController: UICollectionViewController {
    
    var username: String!
    var password: String!
    var category: String!
    var site: String!
    var tracking: String!
    var elements: [Elemental] = []
    var notes: [String] = []
    var pictures: [String] = []
    let reuseIdentifier = "Cell"
    var selectedLocation: String!
    var type: String!
    var uniqueIDs: [Int] = []
    var selectedID: Int!
    var selectedNote: String!
    
    @IBAction func addButton(sender: AnyObject) {
        self.selectedID = -1
        self.selectedNote = ""
        self.performSegueWithIdentifier("pictureToDetail", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.title = selectedLocation
        println("checking")
        getItemsByLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return pictures.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LocationViewCell
        
        let labelText = self.notes[indexPath.row]
        cell.label.text = labelText
        var photo = self.pictures[indexPath.row]
        println(photo)
        
        //check if needing assetLibrary....
        if (photo == "") {
            cell.imageView.image = UIImage(named: "noimg.png")
            //println("d")
        } else if (photo.lowercaseString.rangeOfString("asset") != nil) {
            //println("s");
            /*let path = NSURL(fileURLWithPath: photo as String)
            var image: UIImage
            let library = ALAssetsLibrary()
            var orientation:ALAssetOrientation = ALAssetOrientation.Right
            
            library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                var assetRep = asset.defaultRepresentation()
                var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                
                let size = CGSizeMake(120, 90)
                let scale: CGFloat = 0.0
                let hasAlpha = false
                
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image2!.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                cell.imageView.image = image2
                }, failureBlock: nil)*/
            /*let path = [NSURL(fileURLWithPath: photo as String)!]
            
            let options = PHFetchOptions()
            //options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let results = PHAsset.fetchAssetsWithALAssetURLs(path, options: options)
            
            let optioning = PHImageRequestOptions()
            optioning.deliveryMode = .FastFormat
            
            if (results != nil) {
                if let asset = results[0] as? PHAsset {
                    let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: optioning) { (finalResult, _) in
                        cell.imageView.image = finalResult
                    }
                }
            } else {
                cell.backgroundColor = UIColor.redColor()
            }*/
            
            let assetsLibrary = ALAssetsLibrary()
            let url = NSURL(string: photo)
            
            var image: UIImage?
            var loadError: NSError?
            assetsLibrary.assetForURL(url, resultBlock: {
                (asset: ALAsset!) -> Void in
                if (asset != nil) {
                    var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                    var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    var image = UIImage(CGImage: iref)
                    
                    let size = CGSizeMake(120, 90)
                    let scale: CGFloat = 0.0
                    let hasAlpha = false
                    
                    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                    image!.drawInRect(CGRect(origin: CGPointZero, size: size))
                    
                    cell.imageView.image = image
                }
            }, failureBlock: nil)
        } else {
            let imageText = "http://precisreports.com/clients/" + "\(self.tracking)" + "/thumbnails/" + "\(photo).jpg"
        
            //image
            let url = NSURL(string: imageText)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            var image = UIImage(data: data!)
            
            let size = CGSizeMake(120, 90)
            let scale: CGFloat = 0.0
            let hasAlpha = false
            
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            image!.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            cell.imageView.image = image

        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 120, height: 150)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func getItemsByLocation() {
        var elements = self.elements
        
        var notes: [String] = []
        var pictures: [String] = []
        var uniqueIDs: [Int] = []
        
        for item in elements {
            if (item.location == self.selectedLocation && item.category == self.category) {
                notes.append(item.notes! as String)
                pictures.append(item.picture! as String)
                uniqueIDs.append(item.uniqueID! as Int)
            }
        }
        
        self.notes = notes
        self.pictures = pictures
        self.uniqueIDs = uniqueIDs
        self.collectionView!.reloadData()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        self.selectedID = self.uniqueIDs[indexPath.row]
        self.performSegueWithIdentifier("pictureToDetail", sender: self)
        
        return false
    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pictureToDetail" {
            var navigationController =  segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! detailView
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.category = self.category
            controller.type = self.type
            controller.elements = self.elements
            controller.uniqueID = self.selectedID
            controller.location = self.selectedLocation
            controller.notes = self.selectedNote
            
        } /*else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteListController
            
            controller.username = self.username
            controller.password = self.password
            controller.type = self.type
            controller.tracking = self.tracking
            controller.site = self.site
            //controller.category = self.category
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        } else if (segue.identifier == "toNew") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteNewController
            //println("sobeit")
            //println(segue.identifier)
        }*/
    }

}
