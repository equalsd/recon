//
//  pictureViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/15/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

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
    
    @IBAction func addButton(sender: AnyObject) {
        self.performSegueWithIdentifier("pictureToDetail", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedLocation
        getItemsByLocation()
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
        
        
        //check if needing assetLibrary....
        let imageText = "http://precisreports.com/clients/" + "\(self.tracking)" + "/thumbnails/" + "\(self.pictures[indexPath.row]).jpg"
        
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
        
        for item in elements {
            if (item.location == self.selectedLocation) {
                notes.append(item.notes! as String)
                pictures.append(item.picture! as String)
            }
        }
        
        self.notes = notes
        self.pictures = pictures
        //self.tableView.reloadData()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

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
