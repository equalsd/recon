//
//  LocationController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/14/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import AssetsLibrary

let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)

class locationController: UICollectionViewController, UICollectionViewDelegate {
    
    var username: String!
    var password: String!
    var category: String!
    var site: String!
    var type: String!
    var tracking: String!
    var elements: [Elemental] = []
    var locations: [String] = []
    var pictures: [String] = []
    let reuseIdentifier = "Cell"
    var selectedLocation: String!
    var locationCount = Dictionary<String, Int>()

    @IBAction func addLocation(sender: AnyObject) {
        //println("new Location")
        self.performSegueWithIdentifier("toGetLocation", sender: self)
    }
    
    @IBAction func locationToOrganizer(sender: AnyObject) {
        self.performSegueWithIdentifier("locationToOrganizer", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getItemsByCategory()
        self.title = self.category!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //println(locations.count)
        return locations.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LocationViewCell
    
        // Configure the cell
        //cell.backgroundColor = UIColor.blackColor()
        let labelText = self.locations[indexPath.row]
        let number = self.locationCount[labelText]!
        cell.label.text = labelText + " (\(number))"
        
        
        //check if needing assetLibrary....
        /*let imageText = "http://precisreports.com/clients/" + "\(self.tracking)" + "/thumbnails/" + "\(self.pictures[indexPath.row]).jpg"
        
        //image
        let url = NSURL(string: imageText)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        var image = UIImage(data: data!)
        
        let size = CGSizeMake(120, 90)
        let scale: CGFloat = 0.0
        let hasAlpha = false
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        cell.imageView.image = image*/
        
        var photo: String = self.pictures[indexPath.row]
        
        //check if needing assetLibrary....
        if (photo == "") {
            cell.imageView.image = UIImage(named: "noimg.png")
            //println("d")
        } else if (photo.lowercaseString.rangeOfString("asset") != nil) {
            //println("s");
            /*let path = NSURL(fileURLWithPath: photo as String)
            println(path)
            
            //var orientation:ALAssetOrientation = ALAssetOrientation.Right
            let library = ALAssetsLibrary()
            library.assetForURL(path, resultBlock: { (asset: ALAsset!) in
                var assetRep = asset.defaultRepresentation()
                if (assetRep != nil) {
                    println(assetRep)
                    var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    var image2 = UIImage(CGImage: iref, scale: CGFloat(1.0), orientation: .Right)
                
                    let size = CGSizeMake(120, 90)
                    let scale: CGFloat = 0.0
                    let hasAlpha = false
                
                    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                    image2!.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                    cell.imageView.image = image2
                } else {
                    cell.imageView.image = UIImage(named: "noimg.png")
                }
            }, failureBlock: nil)*/
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
    
    func getItemsByCategory () {
        var elements = self.elements
        
        var locations: [String] = []
        var pictures: [String] = []
        
        for item in elements {
            if (item.category == self.category) {
                if (!contains(locations, item.location! as String)) {
                    locations.append(item.location! as String)
                    pictures.append(item.picture! as String)
                    locationCount[item.location! as String] = 1
                } else {
                    locationCount[item.location! as String] = locationCount[item.location! as String]! + 1
                }
            }
        }
                
        self.locations = locations
        self.pictures = pictures
        //self.tableView.reloadData()
    }
    
    /*override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            //1
            switch kind {
                //2
            case UICollectionElementKindSectionHeader:
                //3
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "locationReusableView",
                    forIndexPath: indexPath)
                    as! locationReusableView
                headerView.headerTitle.text = self.category!
                return headerView
            default:
                //4
                assert(false, "Unexpected element kind")
            }
    }*/

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        //println(self.locations[indexPath.row])
        self.selectedLocation = self.locations[indexPath.row]
        
        self.performSegueWithIdentifier("locationToPicture", sender: self)
        //println("monkey")
        return false
    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        println("okay")
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        println(self.locations[indexPath.row])
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "locationToPicture" {
            var navigationController =  segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! pictureViewController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.type = self.type
            controller.category = self.category
            controller.elements = self.elements
            controller.selectedLocation = self.selectedLocation
            
        } else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteListController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.type = self.type
            //controller.category = self.category
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        } else if (segue.identifier == "toGetLocation") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! menuLocationController
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.type = self.type
            controller.category = self.category
            controller.elements = self.elements
            controller.selectedLocation = self.selectedLocation
            controller.uniqueID = -1
        } else if (segue.identifier == "locationToOrganizer") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! elementCategoryController
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.type = self.type
            controller.category = self.category
            controller.elements = self.elements
        }
    }

}
