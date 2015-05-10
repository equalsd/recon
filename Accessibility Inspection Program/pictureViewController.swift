//
//  pictureViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/15/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
//import AssetsLibrary
import Photos

class pictureViewController: UICollectionViewController {
    
    var elements: [Elemental] = []
    var notes: [String] = []
    var pictures: [String] = []
    let reuseIdentifier = "Cell"
    var uniqueIDs: [Int] = []
    //var selectedNote: String!
    var state: position!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
   
    @IBAction func addButton(sender: AnyObject) {
        self.state.uniqueID = -1
        //self.selectedNote = ""
        self.performSegueWithIdentifier("pictureToDetail", sender: self)
    }
    
    @IBAction func pictureToLocation(sender: AnyObject) {
        //self.performSegueWithIdentifier("pictureToLocations", sender: self)
        state.pop()
        var ecc = self.storyboard?.instantiateViewControllerWithIdentifier("elementBoard") as! elementCategoryController
        ecc.elements = self.elements
        ecc.state = self.state
        self.navigationController!.pushViewController(ecc, animated: true)
        
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
        self.title = self.state.current()
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
        
        cell.activity.startAnimating()
        cell.imageView.contentMode = .ScaleAspectFit
        
        let labelText = self.notes[indexPath.row]
        cell.label.text = labelText
        var photo = self.pictures[indexPath.row]
        println(photo)
        
        //check if needing assetLibrary....
        if (photo == "") {
            cell.imageView.image = UIImage(named: "noimg.png")
            //println("d")
        } else if (photo.lowercaseString.rangeOfString("/") != nil) {
            /*let assetsLibrary = ALAssetsLibrary()
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
            }, failureBlock: nil)*/
            
            //let targetSize = CGSizeMake(120, 90)
            var targetSize: CGSize!
            
            let imageManager = PHImageManager.defaultManager()
            var location = [photo]
            //println(location)
            
            let photos = PHAsset.fetchAssetsWithLocalIdentifiers(location, options: nil)
            
            var asset = photos.firstObject! as! PHAsset
            if (asset.pixelHeight > asset.pixelWidth) {
                targetSize = CGSizeMake(79, 105)
            } else {
                targetSize = CGSizeMake(105, 79)
            }
            
            var ID = imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: {
                (result, info)->Void in
                cell.imageView.image = result
            })

            
        } else {
            let imageText = "http://precisreports.com/clients/" + "\(self.state.tracking)" + "/thumbnails/" + "\(photo).jpg"
            
            //image
            let url = NSURL(string: imageText)
            if let data = NSData(contentsOfURL: url!) {//make sure your image in this url does exist, otherwise unwrap in a if let check
                var image = UIImage(data: data)
                var size: CGSize!
                
                if (image!.size.height > image!.size.width) {
                    size = CGSizeMake(79, 105)
                } else {
                    size = CGSizeMake(105, 79)
                }

                let scale: CGFloat = 0.0
                let hasAlpha = false
                
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image!.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                cell.imageView.image = image
            } else {
                cell.imageView.image = UIImage(named: "noimg.png")
            }
        }
        
        cell.activity.stopAnimating()
        
        return cell
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 120, height: 150)
    }*/
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    
    func getItemsByLocation() {
        var elements = self.elements
        
        var notes: [String] = []
        var pictures: [String] = []
        var uniqueIDs: [Int] = []
        
        for item in elements {
            if (item.location == self.state.current() && item.picture != "location") {
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
        //self.selectedID = self.uniqueIDs[indexPath.row]
        //self.selectedLocation =
        self.state.uniqueID = self.uniqueIDs[indexPath.row]
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
            
            controller.elements = self.elements
            controller.selectedLocation = self.state.current()
            //controller.notes = self.selectedNote
            controller.state = self.state
            
        } else if (segue.identifier == "pictureToLocations") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! locationController
            
            controller.state = self.state
            controller.elements = self.elements
            self.state.pop()
            
        } /*else if (segue.identifier == "toNew") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteNewController
            //println("sobeit")
            //println(segue.identifier)
        }*/
    }

}
